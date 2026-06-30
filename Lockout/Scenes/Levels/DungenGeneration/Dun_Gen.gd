@tool
extends Node3D

@onready var grid_map : GridMap = $GridMap

func _get_grid_map() -> GridMap:
	if grid_map == null:
		grid_map = get_node_or_null("GridMap")
	return grid_map

@export var start : bool = false: set = set_start
func set_start(_val:bool)->void:
	if Engine.is_editor_hint():
		generate()

var rooms: Array[Dictionary] = []

@export_range(0,1) var survival_chance : float = 0.25
@export var border_size : int = 20 : set = set_border_size

func set_border_size(val : int)->void:
	border_size = val
	if Engine.is_editor_hint():
		visualize_border()

@export var room_number: int = 4
@export var room_margin: int = 1
@export var room_recursion: int = 15
@export var min_room_size: int = 2
@export var max_room_size: int = 4

@export_multiline var custom_seed : String = "" : set = set_seed
func set_seed(val:String)->void:
	custom_seed = val
	seed(val.hash())

var room_tiles : Array[PackedVector3Array] = []
var room_positions : PackedVector3Array = []


func visualize_border() -> void:
	var gm := _get_grid_map()
	if gm == null:
		return
	gm.clear()
	for i in range(-1, border_size + 1):
		gm.set_cell_item(Vector3i(i, 0, -1), 3)
		gm.set_cell_item(Vector3i(i, 0, border_size), 3)
		gm.set_cell_item(Vector3i(border_size, 0, i), 3)
		gm.set_cell_item(Vector3i(-1, 0, i), 3)


func generate() -> void:
	if _get_grid_map() == null:
		return

	room_tiles.clear()
	room_positions.clear()
	rooms.clear()

	if custom_seed:
		set_seed(custom_seed)

	visualize_border()

	for i in room_number:
		make_room(room_recursion)

	if room_positions.size() < 2:
		return

	var rpv2 : PackedVector2Array = []
	var del_graph : AStar2D = AStar2D.new()
	var mst_graph : AStar2D = AStar2D.new()
	var idx := 0

	for p in room_positions:
		rpv2.append(Vector2(p.x, p.z))
		del_graph.add_point(idx, Vector2(p.x, p.z))
		mst_graph.add_point(idx, Vector2(p.x, p.z))
		idx += 1

	var delaunay : Array = Array(Geometry2D.triangulate_delaunay(rpv2))

	for i in int(delaunay.size() / 3):
		var p1 : int = delaunay.pop_front()
		var p2 : int = delaunay.pop_front()
		var p3 : int = delaunay.pop_front()
		del_graph.connect_points(p1, p2)
		del_graph.connect_points(p2, p3)
		del_graph.connect_points(p1, p3)

	var visited_points : PackedInt32Array = []
	visited_points.append(randi() % room_positions.size())

	while visited_points.size() != mst_graph.get_point_count():
		var possible_connections : Array[PackedInt32Array] = []

		for vp in visited_points:
			for c in del_graph.get_point_connections(vp):
				if !visited_points.has(c):
					var con : PackedInt32Array = [vp, c]
					possible_connections.append(con)

		if possible_connections.is_empty():
			break

		var connection : PackedInt32Array = possible_connections.pick_random()
		for pc in possible_connections:
			if rpv2[pc[0]].distance_squared_to(rpv2[pc[1]]) < \
			rpv2[connection[0]].distance_squared_to(rpv2[connection[1]]):
				connection = pc

		visited_points.append(connection[1])
		mst_graph.connect_points(connection[0], connection[1])
		del_graph.disconnect_points(connection[0], connection[1])

	var hallway_graph : AStar2D = mst_graph

	for p in del_graph.get_point_ids():
		for c in del_graph.get_point_connections(p):
			if c > p:
				var kill : float = randf()
				if survival_chance > kill:
					hallway_graph.connect_points(p, c)

	create_hallways(hallway_graph)


func create_hallways(hallway_graph: AStar2D) -> void:
	var hallways: Array[PackedVector3Array] = []

	for p in hallway_graph.get_point_ids():
		for c in hallway_graph.get_point_connections(p):
			if c <= p:
				continue

			var room_from: PackedVector3Array = room_tiles[p]
			var room_to: PackedVector3Array = room_tiles[c]

			var center_from: Vector3 = room_positions[p]
			var center_to: Vector3 = room_positions[c]

			var dir: Vector3 = center_to - center_from

			var tile_from: Vector3i
			var tile_to: Vector3i

			if abs(dir.x) > abs(dir.z):
				if dir.x > 0:
					tile_from = Vector3i(room_from[0])
					for t in room_from:
						if t.x > tile_from.x or (t.x == tile_from.x and abs(t.z - center_to.z) < abs(tile_from.z - center_to.z)):
							tile_from = Vector3i(t)
					tile_to = Vector3i(room_to[0])
					for t in room_to:
						if t.x < tile_to.x or (t.x == tile_to.x and abs(t.z - center_from.z) < abs(tile_to.z - center_from.z)):
							tile_to = Vector3i(t)
				else:
					tile_from = Vector3i(room_from[0])
					for t in room_from:
						if t.x < tile_from.x or (t.x == tile_from.x and abs(t.z - center_to.z) < abs(tile_from.z - center_to.z)):
							tile_from = Vector3i(t)
					tile_to = Vector3i(room_to[0])
					for t in room_to:
						if t.x > tile_to.x or (t.x == tile_to.x and abs(t.z - center_from.z) < abs(tile_to.z - center_from.z)):
							tile_to = Vector3i(t)
			else:
				if dir.z > 0:
					tile_from = Vector3i(room_from[0])
					for t in room_from:
						if t.z > tile_from.z or (t.z == tile_from.z and abs(t.x - center_to.x) < abs(tile_from.x - center_to.x)):
							tile_from = Vector3i(t)
					tile_to = Vector3i(room_to[0])
					for t in room_to:
						if t.z < tile_to.z or (t.z == tile_to.z and abs(t.x - center_from.x) < abs(tile_to.x - center_from.x)):
							tile_to = Vector3i(t)
				else:
					tile_from = Vector3i(room_from[0])
					for t in room_from:
						if t.z < tile_from.z or (t.z == tile_from.z and abs(t.x - center_to.x) < abs(tile_from.x - center_to.x)):
							tile_from = Vector3i(t)
					tile_to = Vector3i(room_to[0])
					for t in room_to:
						if t.z > tile_to.z or (t.z == tile_to.z and abs(t.x - center_from.x) < abs(tile_to.x - center_from.x)):
							tile_to = Vector3i(t)

			grid_map.set_cell_item(tile_from, 2)
			grid_map.set_cell_item(tile_to, 2)
			hallways.append(PackedVector3Array([tile_from, tile_to]))

	var astar := AStarGrid2D.new()
	astar.size = Vector2i(border_size + 1, border_size + 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()

	for t in grid_map.get_used_cells_by_item(0):
		astar.set_point_solid(Vector2i(t.x, t.z))

	for hallway in hallways:
		var start_pt := Vector2i(hallway[0].x, hallway[0].z)
		var end_pt := Vector2i(hallway[1].x, hallway[1].z)
		var path := astar.get_point_path(start_pt, end_pt)

		for p2: Vector2 in path:
			var pos := Vector3i(p2.x, 0, p2.y)
			if grid_map.get_cell_item(pos) == -1:
				grid_map.set_cell_item(pos, 1)


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

	for r in range(-room_margin, height + room_margin):
		for c in range(-room_margin, width + room_margin):
			var pos := start_pos + Vector3i(c, 0, r)
			if grid_map.get_cell_item(pos) == 0:
				make_room(rec - 1)
				return

	var room: PackedVector3Array = PackedVector3Array()

	for z in range(height):
		for x in range(width):
			var pos := start_pos + Vector3i(x, 0, z)
			grid_map.set_cell_item(pos, 0)
			room.append(pos)

	room_tiles.append(room)

	rooms.append({
		"start": start_pos,
		"width": width,
		"height": height
	})

	room_positions.append(
		Vector3(
			start_pos.x + (width - 1) * 0.5,
			0,
			start_pos.z + (height - 1) * 0.5
		)
	)


func get_door_tile(room: Dictionary, target: Vector3) -> Vector3i:
	var start: Vector3i = room["start"]
	var width: int = room["width"]
	var height: int = room["height"]

	var center := Vector3(
		start.x + (width - 1) * 0.5,
		0,
		start.z + (height - 1) * 0.5
	)

	var dx := target.x - center.x
	var dz := target.z - center.z

	if abs(dx) > abs(dz):
		if dx > 0:
			return Vector3i(start.x + width - 1, 0, start.z + height / 2)
		else:
			return Vector3i(start.x, 0, start.z + height / 2)
	else:
		if dz > 0:
			return Vector3i(start.x + width / 2, 0, start.z + height - 1)
		else:
			return Vector3i(start.x + width / 2, 0, start.z)
