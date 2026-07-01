extends State

var state_name:StringName = &"MoveState"

func enter() -> void:
	connect_components()


func exit() -> void:
	disconnect_components()

func connect_components() -> void:
	var move: MoveComponent = _handler.get_component(MoveComponent)
	if move:
		_handler.set_active(MoveComponent, true)
		move.velocity_zeroed.connect(transition_to.bind(&"IdleState"))
		if _owner.input:
			_owner.input.moved.connect(move.set_direction)
			move.set_direction(_owner.input.direction)  # sync current state immediately


func disconnect_components() -> void:
	var move: MoveComponent = _handler.get_component(MoveComponent)
	if move:
		_handler.set_active(MoveComponent, false)
		move.velocity_zeroed.disconnect(transition_to)
		if _owner.input:
			_owner.input.moved.disconnect(move.set_direction)
