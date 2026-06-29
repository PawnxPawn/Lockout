class_name PlayerIdleState extends State

func enter() -> void:
	set_up_components()


func exit() -> void:
	disconnect_components()


func set_up_components() -> void:
	var _input: InputSource = _handler.get_component(InputSource)
	if _input:
		_handler.set_active(InputSource, true)
		_input.moved.connect(transition_to.bind("MoveState"))


func disconnect_components() -> void:
	pass
