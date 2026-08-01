@tool
extends Node3D

@export var grid_map_path: NodePath
@onready var grid_map: GridMap = get_node(grid_map_path)

@export var start: bool = false:
	set = set_start

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


func set_start(_value: bool) -> void:
	if Engine.is_editor_hint():
		create_dungeon()


func should_keep_door(cell_index: int, neighbour_index: int) -> bool:
	return (
		(cell_index == 2 and neighbour_index == 1)
		or (cell_index == 1 and neighbour_index == 2)
	)


func clear_dungeon() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()


func create_dungeon() -> void:

	clear_dungeon()

	# Wait one frame in-game so queued nodes are actually removed.
	if !Engine.is_editor_hint():
		await get_tree().process_frame

	var rooms: Dictionary = {}
	var room_types: Dictionary = {}

	for cell: Vector3i in grid_map.get_used_cells():

		var cell_index: int = grid_map.get_cell_item(cell)

		if cell_index < 0 or cell_index > 2:
			continue

		var room: Node3D = DUN_CELL_SCENE.instantiate() as Node3D

		room.position = grid_map.map_to_local(cell)

		add_child(room)

		rooms[cell] = room
		room_types[cell] = cell_index

	for key: Variant in rooms.keys():

		var cell: Vector3i = key as Vector3i
		var room: Node3D = rooms[cell] as Node3D
		var cell_index: int = room_types[cell] as int

		for dir_name: String in DIR_ORDER:

			var offset: Vector3i = DIRECTIONS[dir_name] as Vector3i
			var neighbour_cell: Vector3i = cell + offset

			var neighbour_index: int = grid_map.get_cell_item(neighbour_cell)

			# Exterior
			if neighbour_index == -1 or neighbour_index == 3:
				room.call("remove_door_" + dir_name)
				continue

			# Interior
			room.call("remove_wall_" + dir_name)

			if !should_keep_door(cell_index, neighbour_index):
				room.call("remove_door_" + dir_name)

			if rooms.has(neighbour_cell):

				var neighbour: Node3D = rooms[neighbour_cell] as Node3D
				var opposite: String = OPPOSITES[dir_name] as String

				neighbour.call("remove_wall_" + opposite)

				if !should_keep_door(neighbour_index, cell_index):
					neighbour.call("remove_door_" + opposite)
