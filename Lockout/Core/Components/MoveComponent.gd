
class_name MoveComponent extends Component

signal velocity_zeroed
signal sprint_changed(is_sprinting: bool)

const MAX_SPEED: float = 20.0

var _input_direction: Vector2 = Vector2.ZERO
var _was_moving: bool = false
var _wants_sprint: bool = false
var _is_sprinting: bool = false
var _current_speed: float = 1.0

var speed: float = .5
var sprint_speed: float = 2.0
var acceleration: float = 2.0
var slow_down_speed: float = 12.0
var gravity: float = 20.0


func physics_process(delta: float) -> void:
	if not is_active:
		return

	_move_char3d(_input_direction, delta)


func set_direction(direction: Vector2) -> void:
	_input_direction = direction


func set_sprinting(value: bool) -> void:
	_wants_sprint = value


func _move_char3d(direction: Vector2, delta: float) -> void:
	var body := _owner as CharacterBody3D
	if not body:
		return

	# Only sprint while moving forward or sideways.
	var can_sprint: bool = (
		direction != Vector2.ZERO
		and direction.y <= 0.0
	)

	var sprinting: bool = _wants_sprint and can_sprint

	# Emit a signal when sprinting starts or stops.
	if sprinting != _is_sprinting:
		_is_sprinting = sprinting
		sprint_changed.emit(_is_sprinting)

	# Select walking or sprinting speed.
	var target_speed: float = (
		sprint_speed if _is_sprinting else speed
	)

	_current_speed = move_toward(
		_current_speed,
		target_speed,
		acceleration * delta
	)

	# Apply movement relative to the character's facing direction.
	if direction != Vector2.ZERO:
		var input_dir := Vector3(
			direction.x,
			0.0,
			direction.y
		)

		var world_dir := (
			body.global_transform.basis * input_dir
		).normalized()

		body.velocity.x = world_dir.x * _current_speed
		body.velocity.z = world_dir.z * _current_speed
	else:
		# Gradually stop horizontal movement.
		body.velocity.x = move_toward(
			body.velocity.x,
			0.0,
			slow_down_speed * delta
		)

		body.velocity.z = move_toward(
			body.velocity.z,
			0.0,
			slow_down_speed * delta
		)

	# Apply gravity while airborne.
	if not body.is_on_floor():
		body.velocity.y -= gravity * delta

	# Move the character.
	body.move_and_slide()

	# Detect when horizontal movement stops.
	var is_moving: bool = not (
		is_zero_approx(body.velocity.x)
		and is_zero_approx(body.velocity.z)
	)

	if _was_moving and not is_moving:
		velocity_zeroed.emit()

	_was_moving = is_moving
