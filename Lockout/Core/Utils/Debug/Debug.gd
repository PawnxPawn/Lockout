class_name Debug extends CanvasLayer

var labels: VBoxContainer
var buttons: VBoxContainer

var frame_tracker = 0

var properties: Dictionary


func _ready() -> void:
	visible = false
	
	var panel_container:PanelContainer = PanelContainer.new()
	add_child(panel_container)
	
	var container:VBoxContainer = VBoxContainer.new()
	container.add_theme_constant_override("separation", 25)
	panel_container.add_child(container)
	
	
	labels = VBoxContainer.new()
	container.add_child(labels)
	buttons = VBoxContainer.new()
	container.add_child(buttons)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"Debug"):
		visible = not visible
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	frame_tracker += 1 


func add_debug_label(id: StringName, value: Variant, frames_before_updating: int = 1) -> void:
	if properties.has(id):
		if frame_tracker % frames_before_updating == 0: #Limits how often it updates
			var target: Label = properties[id]
			target.text = _get_id_value_string(id, value)
		return
	
	var property = Label.new()
	property.name = id
	property.text = _get_id_value_string(id, value)
	property.add_theme_font_size_override(&"font_size", 25)
	labels.add_child(property)
	
	properties[id] = property


func add_debug_button(id: StringName, connection: Callable, text: String = "") -> void:
	if properties.has(id): return
	
	var button = Button.new()
	button.name = id
	button.text = text if text else str(id)
	button.add_theme_font_size_override("font_size", 25)
	button.pressed.connect(connection)
	buttons.add_child(button)
	
	properties[id] = button


func remove_debug_property(id:StringName) -> void:
	if not properties.has(id): return
	
	properties[id].queue_free()
	properties.erase(id)


func _get_id_value_string(id: StringName, value: Variant) -> String:
	return "%s: %s" %[id, str(value)]
