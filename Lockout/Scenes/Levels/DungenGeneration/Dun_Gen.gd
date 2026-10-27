@tool
extends Node3D

signal generated

@export var player: Node3D
## Small extra gap between the bottom of the player's collision shape and the floor at spawn.
@export var spawn_clearance: float = 0.05
var _player_mode: Node.ProcessMode = Node.PROCESS_MODE_INHERIT

@onready var grid_map: GridMap = $GridMap

# MeshLibrary items: 0 = room floor, 1 = hallway, 2 = door, 3 = border wall
const ITEM_ROOM := 0
const ITEM_HALL := 1
const ITEM_DOOR := 2
const ITEM_BORDER := 3


func _get_grid_map() -> GridMap:
	if grid_map == null:
		grid_map = get_node_or_null("GridMap")
	return grid_map


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	# Freeze the player until the dungeon (and its collision) exists.
	_find_player()
	if player:
		_player_mode = player.process_mode
		player.process_mode = Node.PROCESS_MODE_DISABLED
	var dun_mesh := get_node_or_null("DunMesh")
	if dun_mesh:
		dun_mesh.built.connect(place_player)
	generate()


@export var start: bool = false: set = set_start
func set_start(_val: bool) -> void:
	if Engine.is_editor_hint():
		generate()
		# In the editor the signals aren't connected, so run the chain by hand.
		var dun_mesh := get_node_or_null("DunMesh")
		if dun_mesh:
			dun_mesh.create_dungeon()
		place_player()


var rooms: Array[Dictionary] = []

## Chance that each non-essential connection becomes an extra hallway (loops).
## 0.0 = every room has exactly one route to every other room.
@export_range(0.0, 1.0, 0.01) var survival_chance: float = 0.08
@export var border_size: int = 20: set = set_border_size

func set_border_size(val: int) -> void:
	border_size = val
	if Engine.is_editor_hint():
		visualize_border()


@export var room_number: int = 4
@export var room_margin: int = 3
@export var room_recursion: int = 15
@export var min_room_size: int = 2
@export var max_room_size: int = 4

@export_multiline var custom_seed: String = "": set = set_seed
func set_seed(val: String) -> void:
	custom_seed = val
	seed(val.hash())


var room_tiles: Array[PackedVector3Array] = []
var room_positions: PackedVector3Array = []


func visualize_border() -> void:
	var gm := _get_grid_map()
	if gm == null:
		return
	gm.clear()
	for i in range(-1, border_size + 1):
		gm.set_cell_item(Vector3i(i, 0, -1), ITEM_BORDER)
		gm.set_cell_item(Vector3i(i, 0, border_size), ITEM_BORDER)
		gm.set_cell_item(Vector3i(border_size, 0, i), ITEM_BORDER)
		gm.set_cell_item(Vector3i(-1, 0, i), ITEM_BORDER)


func generate() -> void:
	if _get_grid_map() == null:
		return

	room_tiles.clear()
	room_positions.clear()
	rooms.clear()

	if custom_seed:
		set_seed(custom_seed)

	# With a big room_margin the random placement can fail, so retry a few times.
	for attempt in 20:
		room_tiles.clear()
		room_positions.clear()
		rooms.clear()
		visualize_border()
		for i in room_number:
			make_room(room_recursion)
		if room_positions.size() >= 2:
			break

	if room_positions.size() < 2:
		_restore_player_mode()
		return

	var rpv2: PackedVector2Array = []
	var del_graph := AStar2D.new()
	var mst_graph := AStar2D.new()

	for i in room_positions.size():
		var p: Vector3 = room_positions[i]
		rpv2.append(Vector2(p.x, p.z))
		del_graph.add_point(i, Vector2(p.x, p.z))
		mst_graph.add_point(i, Vector2(p.x, p.z))

	# Candidate connections: Delaunay triangulation.
	var triangles: PackedInt32Array = Geometry2D.triangulate_delaunay(rpv2)
	if triangles.is_empty():
		# 2 rooms or collinear rooms: no triangles, so connect everything.
		for a in range(room_positions.size()):
			for b in range(a + 1, room_positions.size()):
				del_graph.connect_points(a, b)
	else:
		for i in range(0, triangles.size(), 3):
			var p1: int = triangles[i]
			var p2: int = triangles[i + 1]
			var p3: int = triangles[i + 2]
			del_graph.connect_points(p1, p2)
			del_graph.connect_points(p2, p3)
			del_graph.connect_points(p1, p3)

	# Minimum spanning tree (Prim): guarantees every room is reachable.
	var visited_points: PackedInt32Array = []
	visited_points.append(randi() % room_positions.size())

	while visited_points.size() != mst_graph.get_point_count():
		var possible_connections: Array[PackedInt32Array] = []

		for vp in visited_points:
			for c in del_graph.get_point_connections(vp):
				if not visited_points.has(c):
					var con: PackedInt32Array = [vp, c]
					possible_connections.append(con)

		if possible_connections.is_empty():
			break

		var connection: PackedInt32Array = possible_connections[0]
		for pc in possible_connections:
			if rpv2[pc[0]].distance_squared_to(rpv2[pc[1]]) < \
			rpv2[connection[0]].distance_squared_to(rpv2[connection[1]]):
				connection = pc

		visited_points.append(connection[1])
		mst_graph.connect_points(connection[0], connection[1])
		del_graph.disconnect_points(connection[0], connection[1])

	var hallway_graph: AStar2D = mst_graph

	# Leftover edges (MST edges were removed above) may survive as extra loops.
	for p in del_graph.get_point_ids():
		for c in del_graph.get_point_connections(p):
			if c > p and randf() < survival_chance:
				hallway_graph.connect_points(p, c)

	create_hallways(hallway_graph)
	generated.emit()


func _find_player() -> void:
	if player == null:
		player = get_node_or_null("Player") as Node3D


func place_player() -> void:
	_find_player()

	if player == null:
		return

	if rooms.is_empty() or _get_grid_map() == null:
		_restore_player_mode()
		return

	var room: Dictionary = rooms[0]
	var room_start: Vector3i = room["start"]
	var width: int = room["width"]
	var height: int = room["height"]

	# A tile near the center of the first room.
	var spawn_cell := room_start + Vector3i(int(width * 0.5), 0, int(height * 0.5))

	var spawn_position: Vector3 = grid_map.to_global(grid_map.map_to_local(spawn_cell))

	# Rough guess first (also used in the editor, where there is no physics).
	player.global_position = spawn_position + Vector3.UP * 1.0

	if "velocity" in player:
		player.velocity = Vector3.ZERO

	if not Engine.is_editor_hint():
		# Let the physics server register the freshly built collision, then
		# find the real floor under the spawn point.
		await get_tree().physics_frame
		var floor_pos: Variant = _find_floor(spawn_position)
		if floor_pos == null:
			push_warning("DunGen: no floor collision found under the spawn point")
		else:
			player.global_position = (floor_pos as Vector3) + Vector3.UP * (_feet_offset() + spawn_clearance)
			if "velocity" in player:
				player.velocity = Vector3.ZERO

	_restore_player_mode()
	print("DunGen: player placed at ", player.global_position, ", process_mode restored to ", _player_mode)


## The player is frozen in _ready() until the dungeon exists. Every path out of
## generation must call this, or the player stays frozen and cannot move.
func _restore_player_mode() -> void:
	if player and not Engine.is_editor_hint():
		player.process_mode = _player_mode


## Distance from the player's origin down to the bottom of its collision shape,
## so the player stands on the floor whether its origin is at the feet or the center.
func _feet_offset() -> float:
	for n: Node in player.find_children("*", "CollisionShape3D", true, false):
		var cs := n as CollisionShape3D
		if cs.shape == null or cs.disabled:
			continue
		var half := 0.0
		if cs.shape is CapsuleShape3D:
			half = (cs.shape as CapsuleShape3D).height * 0.5
		elif cs.shape is BoxShape3D:
			half = (cs.shape as BoxShape3D).size.y * 0.5
		elif cs.shape is SphereShape3D:
			half = (cs.shape as SphereShape3D).radius
		elif cs.shape is CylinderShape3D:
			half = (cs.shape as CylinderShape3D).height * 0.5
		else:
			continue
		half *= cs.global_transform.basis.y.length()
		var bottom_y: float = cs.global_position.y - half
		return player.global_position.y - bottom_y
	return 0.0


## Casts a ray straight down from just above the spawn cell. Returns the hit position or null.
func _find_floor(from: Vector3) -> Variant:
	var query := PhysicsRayQueryParameters3D.create(
		from + Vector3.UP * 1.0,
		from + Vector3.DOWN * 10.0
	)
	if player is CollisionObject3D:
		query.exclude = [(player as CollisionObject3D).get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return hit["position"]


## Picks the room tile that sits furthest in direction `out`, preferring the
## one closest to `target` along the other axis, so doors face the other room.
func _edge_tile(tiles: PackedVector3Array, out: Vector3i, target: Vector3) -> Vector3i:
	var best := Vector3i(tiles[0])
	for t in tiles:
		var ti := Vector3i(t)
		var a: int = ti.x * out.x + ti.z * out.z
		var b: int = best.x * out.x + best.z * out.z
		var da: float
		var db: float
		if out.x != 0:
			da = absf(ti.z - target.z)
			db = absf(best.z - target.z)
		else:
			da = absf(ti.x - target.x)
			db = absf(best.x - target.x)
		if a > b or (a == b and da < db):
			best = ti
	return best


func create_hallways(hallway_graph: AStar2D) -> void:
	var hallways: Array[Dictionary] = []

	for p in hallway_graph.get_point_ids():
		for c in hallway_graph.get_point_connections(p):
			if c <= p:
				continue

			var center_from: Vector3 = room_positions[p]
			var center_to: Vector3 = room_positions[c]
			var dir := center_to - center_from

			var out_from := Vector3i.ZERO
			if absf(dir.x) > absf(dir.z):
				out_from = Vector3i(int(signf(dir.x)), 0, 0)
			else:
				out_from = Vector3i(0, 0, int(signf(dir.z)))
			var out_to := -out_from

			var tile_from := _edge_tile(room_tiles[p], out_from, center_to)
			var tile_to := _edge_tile(room_tiles[c], out_to, center_from)

			grid_map.set_cell_item(tile_from, ITEM_DOOR)
			grid_map.set_cell_item(tile_to, ITEM_DOOR)

			# The hallway starts on the cell directly in front of each door.
			hallways.append({
				"from": Vector2i(tile_from.x + out_from.x, tile_from.z + out_from.z),
				"to": Vector2i(tile_to.x + out_to.x, tile_to.z + out_to.z),
			})

	var astar := AStarGrid2D.new()
	astar.region = Rect2i(0, 0, border_size, border_size)  # no border cells
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()

	# Block rooms and a 1-cell halo around them, so hallways never hug room walls.
	var offsets: Array[Vector2i] = [Vector2i.ZERO, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	for t in grid_map.get_used_cells_by_item(ITEM_ROOM):
		for off: Vector2i in offsets:
			var cell: Vector2i = Vector2i(t.x, t.z) + off
			if astar.is_in_boundsv(cell):
				astar.set_point_solid(cell)

	# Block door tiles themselves.
	for t in grid_map.get_used_cells_by_item(ITEM_DOOR):
		var door_cell := Vector2i(t.x, t.z)
		if astar.is_in_boundsv(door_cell):
			astar.set_point_solid(door_cell)

	# Re-open only the cell directly in front of each door.
	for h in hallways:
		var from_cell: Vector2i = h["from"]
		var to_cell: Vector2i = h["to"]
		if astar.is_in_boundsv(from_cell):
			astar.set_point_solid(from_cell, false)
		if astar.is_in_boundsv(to_cell):
			astar.set_point_solid(to_cell, false)

	for h in hallways:
		var from_cell: Vector2i = h["from"]
		var to_cell: Vector2i = h["to"]
		if not astar.is_in_boundsv(from_cell) or not astar.is_in_boundsv(to_cell):
			continue
		var path: PackedVector2Array = astar.get_point_path(from_cell, to_cell)
		if path.is_empty():
			continue
		for p2 in path:
			var pos := Vector3i(int(p2.x), 0, int(p2.y))
			if grid_map.get_cell_item(pos) == GridMap.INVALID_CELL_ITEM:
				grid_map.set_cell_item(pos, ITEM_HALL)


func make_room(rec: int) -> void:
	if rec <= 0:
		return

	var width := randi_range(min_room_size, max_room_size)
	var height := randi_range(min_room_size, max_room_size)

	if width >= border_size or height >= border_size:
		make_room(rec - 1)
		return

	var start_pos := Vector3i(
		randi() % (border_size - width + 1),
		0,
		randi() % (border_size - height + 1)
	)

	# Reject if another room is within the margin.
	for r in range(-room_margin, height + room_margin):
		for c in range(-room_margin, width + room_margin):
			var pos := start_pos + Vector3i(c, 0, r)
			if grid_map.get_cell_item(pos) == ITEM_ROOM:
				make_room(rec - 1)
				return

	var room := PackedVector3Array()

	for z in range(height):
		for x in range(width):
			var pos := start_pos + Vector3i(x, 0, z)
			grid_map.set_cell_item(pos, ITEM_ROOM)
			room.append(pos)

	room_tiles.append(room)

	rooms.append({
		"start": start_pos,
		"width": width,
		"height": height,
	})

	room_positions.append(Vector3(
		start_pos.x + (width - 1) * 0.5,
		0,
		start_pos.z + (height - 1) * 0.5
	))
