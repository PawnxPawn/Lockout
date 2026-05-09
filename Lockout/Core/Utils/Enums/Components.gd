class_name Components

enum Field {
	NAME,
	PATH,
}

enum component_type {
	NONE,
	INPUT_SOURCE
}

const COMPONENT_DATA = {
	component_type.NONE: { 
		Field.NAME: &"",
		Field.PATH: &"",
	},
	component_type.INPUT_SOURCE: {
		Field.NAME: &"InputSource",
		Field.PATH: &"uid://5b7xcl2gqdey",
	},
}


static func get_component_type(value: StringName) -> component_type:
	for key in COMPONENT_DATA:
		if COMPONENT_DATA[key][Field.NAME] == value:
			return key
	return component_type.NONE


static func get_name(type: component_type) -> StringName:
	return COMPONENT_DATA[type][Field.NAME]


static func get_path(type: component_type) -> String:
	return COMPONENT_DATA[type][Field.PATH]


static func is_valid(type: component_type) -> bool:
	return type != component_type.NONE and COMPONENT_DATA.has(type)

static func create(type:component_type, p_owner: Node) -> Component:
	var path = get_path(type)
	var component = load(path)
	if not is_instance_valid(component):
		push_error("Components: Failed to create component: %s" % component_type.keys()[type])
		return null
	return component.new(p_owner)
