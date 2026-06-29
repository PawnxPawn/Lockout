class_name Player extends Entity

@onready var _handler: ComponentHandler = %ComponentHandler
@onready var flashlight: SpotLight3D = $Flashlight

var camera: CameraComponent = null
func _ready() -> void:
	setup_camera()


func setup_camera() -> void:
	camera = _handler.get_component(CameraComponent)
	if not camera: return
	var head_location = Vector3(0.0, 1.4, 0.0)
	camera.set_position(head_location)
	
	if not flashlight: return
	var remote_transform: RemoteTransform3D = RemoteTransform3D.new()
	camera.camera.add_child(remote_transform)
	remote_transform.remote_path = flashlight.get_path()
