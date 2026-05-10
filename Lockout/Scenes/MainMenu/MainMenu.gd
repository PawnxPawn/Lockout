extends Control

@onready var buttons: VBoxContainer = %Buttons
@onready var title: VBoxContainer = $Title


func _ready() -> void:
	Services.game_state.change_game_state(GameState.GameStates.MAIN_MENU)
	_connect_signals()


func _connect_signals() -> void:
	for button in buttons.get_children():
		if not button is Button: continue
		button.button_down.connect(_on_button_pressed.bind(button))
	
	Services.ui.ui_hidden.connect(_on_ui_hidden)


func _on_button_pressed(button: Button) -> void:
	match button.name:
		&"NewGame":
			_new_game()
		&"LoadGame":
			_load_game()
		&"Options":
			title.visible = false
			Services.ui.show_ui(UI.Uis.GAME_SETTINGS)
		&"Exit":
			get_tree().quit()


func _new_game() ->void:
	Services.game_state.change_game_state(GameState.GameStates.PLAYING)
	Services.scene_loader.load_scene(SceneLoader.Scenes.TEST)

func _load_game() -> void:
	if has_node(^"LoadGame"): return
	
	var label:Label = Label.new()
	label.name = "LoadGame"
	label.text = "Load game not setup yet."
	label.add_theme_color_override("font_color", Color.RED)
	label.add_theme_font_size_override("font_size", 40)
	label.position = Vector2(get_viewport_rect().size.x / 2,get_viewport_rect().size.y / 2)
	add_child(label)
	
	await get_tree().create_timer(1.0).timeout
	
	var tween = get_tree().create_tween()
	tween.tween_property(label, ^"modulate", Color(0.0, 0.0, 0.0, 0.0),1.0)
	tween.tween_callback(label.queue_free)


func _on_ui_hidden(ui:UI.Uis) -> void:
	match ui:
		UI.Uis.GAME_SETTINGS:
			title.visible = true


func _disconnect_external_signals() -> void:
	Services.ui.ui_hidden.disconnect(_on_ui_hidden) 

func _exit_tree() -> void:
	_disconnect_external_signals()
