extends Node

var game_state: GameState
var scene_loader: SceneLoader
var ui_service: UIService
#var audio_services

func _ready() -> void:
	_register_services()


func _register_services() -> void:
	game_state = GameState.new()
	add_child(game_state)
	
	scene_loader = SceneLoader.new()
	ui_service = UIService.new()
	
