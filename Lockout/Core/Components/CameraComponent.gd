class_name CameraComponent
extends Component

var camera: Camera3D

func _ready() -> void:
	camera = Camera3D.new()
	_owner.add_child(camera)


func set_rotation(pitch:float, yaw:float, roll:float) -> void:
	camera.rotation = Vector3(pitch, yaw, roll)
