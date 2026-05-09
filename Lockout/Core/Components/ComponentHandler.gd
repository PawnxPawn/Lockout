class_name ComponentHandler extends Node

@export var component_list: ComponentList
var component_map: Dictionary = {}

func _ready() -> void:
	if not component_list: return
	
	for key in component_list.component_type:
		var component = Components.create(key, owner)
		if component:
			add_component(component)


#region Component Life-Cycle
func _process(delta: float) -> void:
	for component in component_map.values():
		component.process(delta)


func _physics_process(delta: float) -> void:
	for component in component_map.values():
		component.physics_process(delta)


func _input(event: InputEvent) -> void:
	for component in component_map.values():
		component.input(event)


func _unhandled_input(event: InputEvent) -> void:
	for component in component_map.values():
		component.unhandled_input(event)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_READY:
			for component in component_map.values():
				component.ready()
		NOTIFICATION_PAUSED:
			for component in component_map.values():
				component.paused()
		NOTIFICATION_UNPAUSED:
			for component in component_map.values():
				component.unpaused()
		NOTIFICATION_PREDELETE:
			component_map.clear()
#endregion


func add_component(component:Component) -> void:
	var script = component.get_script()
	
	var parent_script: Script = script.get_base_script()
	
	#Looking for parent that is above component example: Player Input -> Input Source -> Component returns Input Source
	while parent_script != null and parent_script.get_global_name() != &"Component":
		script = parent_script
		parent_script = parent_script.get_base_script()
	
	var script_name: StringName = script.get_global_name()
	var key: Components.component_type = Components.get_component_type(script_name)
	
	if not component_map.has(key):
		component_map[key] = component


func remove_component(component_type: Components.component_type) -> void:
	component_map.erase(component_type)


func has_component(component_type: Components.component_type)  -> bool:
	return component_map.has(component_type)


func get_component(component_type:Components.component_type) -> Component:
	return component_map.get(component_type)
