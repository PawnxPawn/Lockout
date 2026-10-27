extends State

var state_name: StringName = &"MoveState"

var _to_idle: Callable
var _sprint_on: Callable
var _sprint_off: Callable


func enter() -> void:
	connect_components()


func exit() -> void:
	disconnect_components()


func connect_components() -> void:
	var move: MoveComponent = _handler.get_component(MoveComponent)
	if not move: return

	_handler.set_active(MoveComponent, true)

	_to_idle = transition_to.bind(&"IdleState")
	move.velocity_zeroed.connect(_to_idle)

	var input = _owner.input
	if input:
		_sprint_on = move.set_sprinting.bind(true)
		_sprint_off = move.set_sprinting.bind(false)
		input.moved.connect(move.set_direction)
		input.sprinting_pressed.connect(_sprint_on)
		input.sprinting_released.connect(_sprint_off)

		# sync current state immediately
		move.set_direction(input.direction)
		move.set_sprinting(input.sprint_held)


func disconnect_components() -> void:
	var move: MoveComponent = _handler.get_component(MoveComponent)
	if not move: return

	_handler.set_active(MoveComponent, false)

	if move.velocity_zeroed.is_connected(_to_idle):
		move.velocity_zeroed.disconnect(_to_idle)

	var input = _owner.input
	if input:
		if input.moved.is_connected(move.set_direction):
			input.moved.disconnect(move.set_direction)
		if input.sprinting_pressed.is_connected(_sprint_on):
			input.sprinting_pressed.disconnect(_sprint_on)
		if input.sprinting_released.is_connected(_sprint_off):
			input.sprinting_released.disconnect(_sprint_off)

	move.set_sprinting(false)
