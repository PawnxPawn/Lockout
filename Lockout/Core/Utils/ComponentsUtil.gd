class_name ComponentsUtil

enum Field {
	NAME,
	PATH,
}

enum ComponentType {
	NONE,
	CAMERA,
	INPUT_SOURCE,
	PLAYER_INPUT,
}

const COMPONENT_DATA = {
	ComponentType.NONE: { 
		Field.NAME: &"",
		Field.PATH: &"",
	},
	ComponentType.CAMERA: {
		Field.NAME: &"CameraComponent",
		Field.PATH: &"uid://ch5wra7y1gllq",
	},
	ComponentType.INPUT_SOURCE: {
		Field.NAME: &"InputSource",
		Field.PATH: &"uid://5b7xcl2gqdey",
	},
	ComponentType.PLAYER_INPUT: {
		Field.NAME: &"PlayerInput",
		Field.PATH: &"uid://bgsj8gw2nmanw",
	},
}


static func get_component_type(value: StringName) -> ComponentType:
	for key in COMPONENT_DATA:
		if COMPONENT_DATA[key][Field.NAME] == value:
			return key
	return ComponentType.NONE


static func get_name(type: ComponentType) -> StringName:
	return COMPONENT_DATA[type][Field.NAME]


static func get_path(type: ComponentType) -> String:
	return COMPONENT_DATA[type][Field.PATH]


static func is_valid(type: ComponentType) -> bool:
	return type != ComponentType.NONE and COMPONENT_DATA.has(type)

static func create(type:ComponentType, p_owner: Node, handler: ComponentHandler) -> Component:
	var path = get_path(type)
	var component = load(path)
	if not is_instance_valid(component):
		push_error("ComponentsUtil: Failed to create component: %s" % ComponentType.keys()[type])
		return null
	return component.new(p_owner, handler)
