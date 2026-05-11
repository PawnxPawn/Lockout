class_name State extends RefCounted

var _sm: StateMachine
var _owner: Node
var _handler: ComponentHandler
var _input: InputSource
var _look: LookComponent
#var _movement: MoveComponent
	
func _setup(sm: StateMachine, parent: Node, handler: ComponentHandler) -> void:
	_sm = sm
	_owner = parent
	_handler = handler
	if _handler.has_component(ComponentsUtil.ComponentType.INPUT_SOURCE):
		_input = _handler.get_component(ComponentsUtil.ComponentType.INPUT_SOURCE)
	if _handler.has_component(ComponentsUtil.ComponentType.LOOK):
		_look = _handler.get_component(ComponentsUtil.ComponentType.LOOK)

func enter() -> void:
	pass


func exit() -> void:
	pass


func process_input(_event: InputEvent) -> void:
	pass


func process_frame(_delta: float) -> void:
	pass


func process_physics(_delta: float) -> void:
	pass


func transition_to(name: StringName) -> void:
	_sm.change_state(name)
