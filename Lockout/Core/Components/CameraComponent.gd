class_name CameraComponent extends Component
signal camera_entered
var camera: Camera3D


func ready() -> void:
	camera = Camera3D.new()
	camera.tree_entered.connect(_camera_entered)
	camera.name = &"CameraComponent"
	_owner.add_child.call_deferred(camera)


func get_camera_path() -> NodePath:
	return camera.get_path()


func set_fov(fov: float) -> void:
	var min_fov:float = 60.0
	var max_fov:float = 100.0
	camera.fov = clamp(fov, min_fov, max_fov)


func set_position(position: Vector3) -> void:
	camera.position = position


func set_rotation(pitch:float, yaw:float, roll:float) -> void:
	camera.rotation = Vector3(pitch, yaw, roll)


func make_current() -> void:
	if camera.current: return
	camera.make_current()


func _camera_entered() -> void:
	camera_entered.emit()
