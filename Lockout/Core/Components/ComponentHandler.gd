class_name ComponentHandler extends Node

@export var default_components: Array[ComponentsUtil.ComponentType]
var component_map: Dictionary = {}

func _ready() -> void:
	if not default_components: return
	
	for key in default_components:
		add_and_create_component(key)
	
	for component in component_map.values():
		component.ready()


func _create_component(type: ComponentsUtil.ComponentType) -> Component:
	var component = ComponentsUtil.create(type, get_owner(), self) 
	return component


func add_and_create_component(type:ComponentsUtil.ComponentType) -> Component:
	var component:Component = _create_component(type)
	
	if not component:
		push_error("ComponentHandler: Failed to create cmponent: %s" % ComponentsUtil.ComponentType.keys()[type])
	
	var script = component.get_script()
	
	var parent_script: Script = script.get_base_script()
	
	#Looking for parent that is above component example: Player Input -> Input Source -> Component returns Input Source
	while parent_script != null and parent_script.get_global_name() != &"Component":
		script = parent_script
		parent_script = parent_script.get_base_script()
	
	var script_name: StringName = script.get_global_name()
	var key: ComponentsUtil.ComponentType= ComponentsUtil.get_component_type(script_name)
	
	if not ComponentsUtil.is_valid(key):
		push_error("ComponentHandler: Key failed to set : %s" % script.get_global_name())
	
	if not component_map.has(key):
		component_map[key] = component
	
	return component
	


func remove_component(component_type: ComponentsUtil.ComponentType) -> void:
	component_map.erase(component_type)


func has_component(component_type: ComponentsUtil.ComponentType)  -> bool:
	return component_map.has(component_type)


func get_component(component_type:ComponentsUtil.ComponentType) -> Component:
	return component_map.get(component_type)


#Component Life-Cycle
func _process(delta: float) -> void:
	for component in component_map.values():
		if component.is_active:
			component.process(delta)

func _physics_process(delta: float) -> void:
	for component in component_map.values():
		if component.is_active:
			component.physics_process(delta)

func _input(event: InputEvent) -> void:
	for component in component_map.values():
		if component.is_active:
			component.input(event)

func _unhandled_input(event: InputEvent) -> void:
	for component in component_map.values():
		if component.is_active:
			component.unhandled_input(event)
