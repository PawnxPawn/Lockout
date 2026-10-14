@tool
extends Node3D

# Tracks which sides have had their lower wall / door removed.
var wall_removed: Dictionary = {}
var door_removed: Dictionary = {}


# Frees immediately (not queue_free) so pieces are gone before the cell enters the tree.
func _free_node(node_name: String) -> void:
	var n := get_node_or_null(node_name)
	if n:
		remove_child(n)
		n.free()


func _remove_wall(dir: String) -> void:
	_free_node("Wall" + dir)
	wall_removed[dir] = true
	_check_top(dir)


func _remove_door(dir: String) -> void:
	_free_node("Door" + dir)
	door_removed[dir] = true
	_check_top(dir)


# The upper wall only goes away when the side is fully open
# (lower wall removed AND no door kept there).
func _check_top(dir: String) -> void:
	if wall_removed.get(dir, false) and door_removed.get(dir, false):
		_free_node("Wall" + dir + "Top")


func remove_wall_up() -> void: _remove_wall("Up")
func remove_wall_down() -> void: _remove_wall("Down")
func remove_wall_left() -> void: _remove_wall("Left")
func remove_wall_right() -> void: _remove_wall("Right")

func remove_door_up() -> void: _remove_door("Up")
func remove_door_down() -> void: _remove_door("Down")
func remove_door_left() -> void: _remove_door("Left")
func remove_door_right() -> void: _remove_door("Right")
