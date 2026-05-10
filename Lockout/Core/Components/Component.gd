class_name Component extends RefCounted

var _owner: Node
var _handler: ComponentHandler
var is_active: bool = false

func _init(p_owner:Node, p_component_handler: ComponentHandler) ->void:
	_owner = p_owner
	_handler = p_component_handler


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	pass


func input(_event: InputEvent) -> void:
	pass


func unhandled_input(_event: InputEvent) -> void:
	pass


func paused() -> void:
	pass


func unpaused() -> void:
	pass
