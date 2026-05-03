extends Node

var game_state: GameState
var scene_loader: SceneLoader
var ui: UI
#var audio_services

func _ready() -> void:
	_register_services()


func _register_services() -> void:
	game_state = GameState.new()
	add_child(game_state)
	
	scene_loader = SceneLoader.new()
	ui = UI.new()


func set_ui_manager(ui_manager:Node):
	ui.ui_manager = ui_manager

func set_scene_manager(scene_manager:Node):
	scene_loader.scene_manager = scene_manager
