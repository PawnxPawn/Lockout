@tool
extends Node3D

@export var grid_map_path: NodePath
@onready var grid_map: GridMap = get_node(grid_map_path)

@export var start: bool = false:
	set = set_start

## How many DunCells are stacked on top of each other per grid cell.
@export_range(1, 6) var wall_layers: int = 2
## Prints the DunCell's child nodes and measured height to the output, for debugging.
@export var print_cell_info: bool = false
## Height of one layer in world units. 0 = measure it from the DunCell scene.
@export var wall_height: float = 0.0
## Node names inside DunCell.tscn removed from every layer except the bottom one.
@export var upper_layer_remove: Array[StringName] = [&"Floor"]
## Node names inside DunCell.tscn removed from every layer except the top one.
@export var lower_layer_remove: Array[StringName] = [&"Ceiling"]
## Mirror the walls of upper layers upside down.
@export var flip_upper_walls: bool = true
## Nudge flipped upper walls up (+) or down (-) if they sit off.
@export var upper_wall_y_offset: float = 0.0
## Only every Nth cell (in x and z) gets a real light. Fixtures stay on every cell.
@export_range(1, 6) var light_spacing: int = 2

signal built

const DUN_CELL_SCENE: PackedScene = preload("res://Scenes/Levels/DungenGeneration/DunCell.tscn")

const DIRECTIONS := {
	"up": Vector3i(0, 0, -1),
	"down": Vector3i(0, 0, 1),
	"left": Vector3i(-1, 0, 0),
	"right": Vector3i(1, 0, 0)
}

const OPPOSITES := {
	"up": "down",
	"down": "up",
	"left": "right",
	"right": "left"
}

const DIR_ORDER: Array[String] = [
	"up",
	"right",
	"down",
	"left"
]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	get_parent().generated.connect(create_dungeon)


func set_start(_value: bool) -> void:
	if Engine.is_editor_hint():
		create_dungeon()


func should_keep_door(cell_index: int, neighbour_index: int) -> bool:
	# Only the door cell (2) keeps its door, facing the hallway (1).
	return cell_index == 2 and neighbour_index == 1


func clear_dungeon() -> void:
	for child: Node in get_children():
		remove_child(child)
		if Engine.is_editor_hint():
			# Free immediately so old physics bodies don't pile up between rebuilds.
			child.free()
		else:
			child.queue_free()


func _layer_height() -> float:
	if wall_height > 0.0:
		return wall_height
	# Measure the real wall stack of one DunCell, so layers never overlap or leave gaps.
	var probe: Node3D = DUN_CELL_SCENE.instantiate() as Node3D
	var measured: float = probe.call("get_wall_height")
	if print_cell_info:
		probe.call("print_tree_info")
	probe.free()
	print("DunMesh layer height: ", measured)
	if measured < 0.01:
		return grid_map.cell_size.y
	return measured


func _cell_has_light(cell: Vector3i) -> bool:
	var s: int = maxi(light_spacing, 1)
	return cell.x % s == 0 and cell.z % s == 0


func _strip_nodes(cell: Node3D, names: Array[StringName]) -> void:
	for node_name: StringName in names:
		var n: Node = cell.get_node_or_null(NodePath(node_name))
		if n:
			cell.remove_child(n)
			n.free()


## Removes the wall piece and/or door piece on one side of every layer of a cell.
## On upper layers a kept door becomes a solid wall, so nothing is open above doorways.
func _trim_side(layers: Array, dir_name: String, keep_door: bool, interior: bool) -> void:
	for i: int in layers.size():
		var layer: Node3D = layers[i] as Node3D
		if not interior:
			layer.call("remove_door_" + dir_name)
		elif keep_door and i > 0:
			layer.call("remove_door_" + dir_name)
		else:
			layer.call("remove_wall_" + dir_name)
			if not keep_door:
				layer.call("remove_door_" + dir_name)


func create_dungeon() -> void:
	grid_map.visible = false
	grid_map.collision_layer = 0
	grid_map.collision_mask = 0
	print("create_dungeon called, cells: ", grid_map.get_used_cells().size())

	clear_dungeon()

	# Wait one frame in-game so queued nodes are actually removed.
	if !Engine.is_editor_hint():
		await get_tree().process_frame

	var rooms: Dictionary = {}       # Vector3i -> Array of Node3D, bottom layer first
	var room_types: Dictionary = {}  # Vector3i -> int
	var height: float = _layer_height()

	# Step 1: instantiate every layer of every cell but do NOT add them to the tree yet.
	for cell: Vector3i in grid_map.get_used_cells():

		var cell_index: int = grid_map.get_cell_item(cell)

		if cell_index < 0 or cell_index > 2:
			continue

		# Convert through global space so DunMesh and GridMap don't need identical transforms.
		var base_pos: Vector3 = to_local(grid_map.to_global(grid_map.map_to_local(cell)))

		var layers: Array[Node3D] = []
		for layer_i: int in wall_layers:
			var room: Node3D = DUN_CELL_SCENE.instantiate() as Node3D
			room.position = base_pos + Vector3.UP * height * layer_i

			if layer_i > 0:
				_strip_nodes(room, upper_layer_remove)
				if flip_upper_walls:
					room.call("flip_walls_vertical", upper_wall_y_offset)

			# Lights and fixtures belong on the top layer only, where the real ceiling is.
			# DunCell creates its light in _ready(), so switch it off before add_child.
			if layer_i < wall_layers - 1:
				_strip_nodes(room, lower_layer_remove)
				room.call("remove_light_fixture")
			elif not _cell_has_light(cell):
				room.call("remove_light")

			layers.append(room)

		rooms[cell] = layers
		room_types[cell] = cell_index

	# Step 2: remove unneeded walls/doors while the cells are still out of the tree,
	# so their physics bodies are never created.
	for key: Variant in rooms.keys():

		var cell: Vector3i = key as Vector3i
		var layers: Array = rooms[cell] as Array
		var cell_index: int = room_types[cell] as int

		for dir_name: String in DIR_ORDER:

			var offset: Vector3i = DIRECTIONS[dir_name] as Vector3i
			var neighbour_cell: Vector3i = cell + offset

			var neighbour_index: int = grid_map.get_cell_item(neighbour_cell)

			# Exterior
			if neighbour_index == -1 or neighbour_index == 3:
				_trim_side(layers, dir_name, false, false)
				continue

			# Interior
			_trim_side(layers, dir_name, should_keep_door(cell_index, neighbour_index), true)

			if rooms.has(neighbour_cell):
				var neighbour_layers: Array = rooms[neighbour_cell] as Array
				var opposite: String = OPPOSITES[dir_name] as String
				_trim_side(neighbour_layers, opposite, should_keep_door(neighbour_index, cell_index), true)

	# Step 3: now add the trimmed cells to the tree.
	for key: Variant in rooms.keys():
		for room: Node3D in (rooms[key] as Array):
			add_child(room)

	built.emit()
