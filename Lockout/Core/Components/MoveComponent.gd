class_name MoveComponent extends Component

signal velocity_zeroed

var speed: float = 230.0
var slow_down_speed: float = 20.0
var _direction: float = 0.0
var _last_direction: float = 0.0
const MAX_SPEED: float = 150.0

func _on_moved2D(direction: float) -> void:
	if _owner is CharacterBody2D:
		_move_char2d(direction)
	elif _owner is RigidBody2D:
		_direction = direction


func _on_moved3d(direction: Vector2) -> void:
	if _owner is CharacterBody3D:
		_move_char3d(direction)


func _move_char2d(direction: float) -> void:
	var body := _owner as CharacterBody2D
	if not body: return
	body.velocity.x = direction * speed
	if body.velocity.x == 0.0:
		velocity_zeroed.emit()
	body.move_and_slide()


func _move_char3d(direction:Vector2) -> void:
	var body: CharacterBody3D = _owner as CharacterBody3D
	var forward_direction: Vector2
	
	if direction:
		forward_direction = direction * speed
	else:
		forward_direction.x = move_toward(body.velocity.x, 0, speed)
		forward_direction.y = move_toward(body.velocity.z, 0, speed)
	
	body.velocity = Vector3(forward_direction.x, 0 ,forward_direction.y)
	
	body.move_and_slide()


func _move_node2d(direction: Vector2) -> void:
	var body := _owner as Node2D
	if not body: return
	body.position += direction * speed * body.get_process_delta_time()


func _move_node3d(direction:Vector3):
	var body := _owner as Node3D
	if not body: return
	body.position += direction * speed * body.get_process_delta_time()


func integrate_forces2D(state: PhysicsDirectBodyState2D) -> void:
	if signf(_direction) != signf(_last_direction) and _last_direction != 0.0:
		state.linear_velocity.x = 0.0

	_last_direction = _direction

	if _direction != 0.0:
		if absf(state.linear_velocity.x) < MAX_SPEED:
			state.linear_velocity.x += _direction * speed
		return

	if absf(state.linear_velocity.x) > 1.0:
		var brake := signf(-state.linear_velocity.x) * slow_down_speed
		if absf(brake) >= absf(state.linear_velocity.x):
			state.linear_velocity.x = 0.0
			velocity_zeroed.emit()
		else:
			state.linear_velocity.x += brake
		return

	state.linear_velocity.x = 0.0
	velocity_zeroed.emit()

#TODO: Add integrate_forces3D
