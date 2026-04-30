extends Node

var game_state: GameState
#var scene_loader
#var ui_services
#var audio_services

func _ready() -> void:
	_register_services()


func _register_services() -> void:
	game_state = GameState.new()
	
	add_child(game_state)
