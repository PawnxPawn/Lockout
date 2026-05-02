class_name SceneLoader extends Node

#TODO: Threaded loading, Chunk Loading

enum Scenes {
	MAIN_MENU,
	TEST,
}

const _PRELOADED_SCENES = {
	0: preload("uid://c11qt0vcye7g3"),
	1: preload("uid://cfpeosla7ei55"),
}

const _DYNAMIC_SCENES: Dictionary = {
	
}

var scene_manager: Node

var is_transitioning: bool = false
var _loaded_scenes:Dictionary = {}


func load_scene(scene:Scenes, transition: bool = true) -> void:
	if transition:
		is_transitioning = true
		_swap_scene(scene)
		
		transition = false
		is_transitioning = false
		return
	
	_add_to_scene(scene)


func _swap_scene(scene: Scenes) -> void:
	if _loaded_scenes.has(scene):
		push_warning("SceneLoader: %s already is loaded." % Scenes.keys()[scene])
		return
	
	_clean_up()
	
	var instance = _PRELOADED_SCENES[scene].instantiate()
	scene_manager.add_child(instance)
	_loaded_scenes[scene] = instance


func _add_to_scene(scene: Scenes) -> void:
	print(scene)
	#Place holder for level streaming


func _clean_up() -> void:
	if not _loaded_scenes.is_empty():
		for key in _loaded_scenes:
			_loaded_scenes[key].queue_free()
		_loaded_scenes.clear()
