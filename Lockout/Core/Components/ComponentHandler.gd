class_name ComponentHandler extends Node

@export var Components: Array

var component_map: Dictionary = {}




func add_component(component: Component, _get_highest_level_parent: bool = true) -> void:
	var script: Script = component.get_script()
	
	var parent_script: Script = script.get_base_script()
	
	#Looking for parent that is above component example: Player Input -> Input Source
	# -> Component returns Input Source
	while  parent_script.get_global_name() != "Component":
		script = parent_script
		parent_script = parent_script.get_base_script()
	
	if not component_map.has(script):
		component_map[script.get_global_name()] = component


func remove_component(component_type: StringName) -> void:
	component_map.erase(component_type)


func has_component(component_type: StringName)  -> void:
	component_map.has(component_type)
