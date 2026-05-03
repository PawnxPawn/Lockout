extends Control


func _on_new_game_button_down() -> void:
	Services.scene_loader.load_scene(SceneLoader.Scenes.TEST)
