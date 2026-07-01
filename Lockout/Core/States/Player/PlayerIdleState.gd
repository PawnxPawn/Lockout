extends State

var state_name:StringName = &"IdleState"

func enter() -> void:
	connect_components()


func exit() -> void:
	disconnect_components()


func _moved(_direction:Vector2) -> void:
	transition_to("MoveState")


func connect_components() -> void:
	if _owner.input:
		_owner.input.moved.connect(_moved)


func disconnect_components() -> void:
	if _owner.input:
		_owner.input.moved.disconnect(_moved)
