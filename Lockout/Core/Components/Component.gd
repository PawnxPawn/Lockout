class_name Component extends RefCounted

var _owner: Node

func _init(owner:Node) ->void:
	_owner = owner


func enter_tree() -> void:
	pass


func _ready() -> void:
	pass


func frame_update() -> void:
	pass


func physics_update() -> void:
	pass


func exit_tree() -> void:
	pass
