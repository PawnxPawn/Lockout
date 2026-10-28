@tool
extends Node3D

@export var light_color := Color(1.0, 0.95, 0.7)
@export var light_energy := 0.5
@export var light_range := 7.0
@export var light_offset := Vector3(0, 2.6, 0) # set to your ceiling height
## Set to false BEFORE the cell enters the tree to skip creating its light.
@export var has_light := true

# Tracks which sides have had their lower wall / door removed.
var wall_removed: Dictionary = {}
var door_removed: Dictionary = {}


func _ready() -> void:
	if has_light:
		add_light()


func add_light() -> void:
	if has_node("CellLight"):
		return
	var light := OmniLight3D.new()
	light.name = "CellLight"
	light.light_color = light_color
	light.light_energy = light_energy
	light.omni_range = light_range
	light.shadow_enabled = false
	light.position = light_offset
	add_child(light)


## Works before or after the cell is in the tree.
func remove_light() -> void:
	has_light = false
	_free_node("CellLight")


## Removes the light and the fixture meshes (for stacked upper layers).
func remove_light_fixture() -> void:
	remove_light()
	_free_node("Diffuser")
	_free_node("Fixture")
	_free_node("Tubes")


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


func remove_diffuser() -> void: _free_node("Diffuser")
func remove_fixture() -> void: _free_node("Fixture")
func remove_tubes() -> void: _free_node("Tubes")

func remove_wall_up() -> void: _remove_wall("Up")
func remove_wall_down() -> void: _remove_wall("Down")
func remove_wall_left() -> void: _remove_wall("Left")
func remove_wall_right() -> void: _remove_wall("Right")

func remove_door_up() -> void: _remove_door("Up")
func remove_door_down() -> void: _remove_door("Down")
func remove_door_left() -> void: _remove_door("Left")
func remove_door_right() -> void: _remove_door("Right")


# ---- Stacking helpers (used by DunMesh) ----

## Transform of a node relative to this cell, usable before the cell is in the tree.
func _xf_in_cell(n: Node3D) -> Transform3D:
	var t := Transform3D.IDENTITY
	var cur: Node = n
	while cur != null and cur != self:
		if cur is Node3D:
			t = (cur as Node3D).transform * t
		cur = cur.get_parent()
	return t


func _wall_meshes() -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	for child: Node in get_children():
		if not String(child.name).begins_with("Wall"):
			continue
		if child is MeshInstance3D:
			out.append(child as MeshInstance3D)
		for n: Node in child.find_children("*", "MeshInstance3D", true, false):
			out.append(n as MeshInstance3D)
	return out

## player can not move still
## Lowest and highest point of all wall meshes (including the Top pieces), cell space.
func get_wall_range() -> Vector2:
	var lo := INF
	var hi := -INF
	for m: MeshInstance3D in _wall_meshes():
		var box: AABB = _xf_in_cell(m) * m.get_aabb()
		lo = minf(lo, box.position.y)
		hi = maxf(hi, box.end.y)
	if lo == INF:
		return Vector2.ZERO
	return Vector2(lo, hi)


## Full height of this cell's wall stack. DunMesh uses it to place upper layers.
func get_wall_height() -> float:
	var r := get_wall_range()
	return r.y - r.x


## Mirrors the whole wall stack upside down around its own center, so the trim
## that was at the bottom ends up at the top. Only meshes flip; collision stays put.
## extra_y nudges the result up (+) or down (-).



func flip_walls_vertical(extra_y: float = 0.0) -> void:
	var meshes: Array[MeshInstance3D] = _wall_meshes()
	if meshes.is_empty():
		return

	var wall_range: Vector2 = get_wall_range()
	var center_y: float = (wall_range.x + wall_range.y) * 0.5

	for mesh: MeshInstance3D in meshes:
		var original: Transform3D = _xf_in_cell(mesh)
		var flipped := original

		flipped.basis = Basis(
			Vector3.RIGHT,
			Vector3.DOWN,
			Vector3.BACK
		) * original.basis

		flipped.origin.y = 2.0 * center_y - original.origin.y + extra_y

		var parent := mesh.get_parent() as Node3D
		if parent == null:
			continue

		mesh.transform = _xf_in_cell(parent).affine_inverse() * flipped
		
## Debug: prints every child of the cell with its type and position.
func print_tree_info() -> void:
	for child: Node in get_children():
		var pos := Vector3.ZERO
		if child is Node3D:
			pos = (child as Node3D).position
		print("DunCell child: ", child.name, " (", child.get_class(), ") pos=", pos)
	print("DunCell wall range: ", get_wall_range(), " height: ", get_wall_height())
