class_name Component extends RefCounted

signal activated
signal deactivated

var _owner: Node
var _handler: ComponentHandler
var is_active: bool = false:
	set(value):
		is_active = value
		if is_active:
			activated.emit()
		else:
			deactivated.emit()

func _init(p_owner:Node, p_component_handler: ComponentHandler) ->void:
	_owner = p_owner
	_handler = p_component_handler
	activated.connect(_on_activated)
	deactivated.connect(_on_deactivated)


func setup() -> void:
	pass


func ready() -> void:
	pass


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


func _on_activated() -> void:
	pass


func _on_deactivated() -> void:
	pass
