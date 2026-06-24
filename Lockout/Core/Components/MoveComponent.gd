class_name MoveComponent extends Component

var movement_call: Callable

var move_speed: float = 5.0
var gravity: float = 9.8

var _input_source: InputSource

func ready() -> void:
	if _owner is CharacterBody3D:
		movement_call = _move_char3d
	elif _owner is RigidBody3D:
		movement_call = _move_rigid3d
	else:
		movement_call = _move_transform3d
	
	if _handler.has_component(ComponentsUtil.ComponentType.INPUT_SOURCE):
		_input_source = _handler.get_component(ComponentsUtil.ComponentType.INPUT_SOURCE)


func physics_process(delta: float) -> void:
	var direction: Vector3 = _get_direction_3d()
	movement_call.call(direction, delta)


func _get_direction_3d() -> Vector3:
	if _input_source:
		return _input_source.move_direction
	return Vector3.ZERO


func _move_char3d(direction:Vector3, _delta: float) -> void:
	var body: CharacterBody3D = _owner as CharacterBody3D
	var direction_fall: Vector3
	
	if direction:
		direction_fall = direction * move_speed
	else:
		direction_fall.x = move_toward(body.velocity.x, 0, move_speed)
		direction_fall.z = move_toward(body.velocity.z, 0, move_speed)
	
	if not body.is_on_floor():
		direction_fall.y -= gravity
	
	body.velocity = direction_fall
	
	body.move_and_slide()


func _move_rigid3d(direction:Vector3, _delta: float):
	var body: CharacterBody3D = _owner as CharacterBody3D
	if direction:
		body.velocity = direction * move_speed


func _move_transform3d(direction:Vector3, _delta: float):
	var body: CharacterBody3D = _owner as CharacterBody3D
	if direction:
		body.velocity = direction * move_speed
