class_name Component extends RefCounted

var _owner: Node

func _init(p_owner:Node) ->void:
	_owner = p_owner


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
