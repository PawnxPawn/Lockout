extends Control

@onready var buttons: VBoxContainer = %Buttons
@onready var title: VBoxContainer = $Title


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	for button in buttons.get_children():
		if not button is Button: continue
		button.button_down.connect(_on_button_pressed.bind(button))
	
	Services.ui.ui_hidden.connect(_on_ui_hidden)


func _on_button_pressed(button: Button) -> void:
	match button.name:
		&"NewGame":
			Services.scene_loader.load_scene(SceneLoader.Scenes.TEST)
		&"LoadGame":
			print("Load Game not set up yet.")
		&"Options":
			title.visible = false
			Services.ui.show_ui(UI.Uis.GAME_SETTINGS)
		&"Exit":
			get_tree().quit()


func _on_ui_hidden(ui:UI.Uis) -> void:
	match ui:
		UI.Uis.GAME_SETTINGS:
			title.visible = true


func _disconnect_external_signals() -> void:
	Services.ui.ui_hidden.disconnect(_on_ui_hidden) 

func _exit_tree() -> void:
	_disconnect_external_signals()
