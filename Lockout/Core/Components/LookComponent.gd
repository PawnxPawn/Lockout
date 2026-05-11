class_name LookComponent extends Component

const PITCH_CLAMP: float = deg_to_rad(89.0)
var pitch: float = 0.0
var yaw: float = 0.0

var _input: InputSource = null
var _camera: CameraComponent = null

func ready() -> void:
	_input = _handler.get_component(ComponentsUtil.ComponentType.INPUT_SOURCE)
	_camera = _handler.get_component(ComponentsUtil.ComponentType.CAMERA)

func process(_delta: float) -> void:
	if not _input or _input.look_direction == Vector2.ZERO: return
	
	_pitch_rotation()
	_yaw_rotation()

func _pitch_rotation() -> void:
	pitch = clamp(
		pitch - _input.look_direction.y,
		-PITCH_CLAMP,
		PITCH_CLAMP
	)
	if not _camera: return
	_camera.set_rotation(pitch, 0.0, 0.0)

func _yaw_rotation() -> void:
	yaw -= _input.look_direction.x
	_owner.rotation.y = yaw
