class_name GameSettings
extends Control

@onready var save_and_exit: HBoxContainer = %SaveAndExit

#TODO: Visual design of this needs to be re-worked
func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	for button in save_and_exit.get_children():
		if not button is Button: continue
		button.button_down.connect(_on_save_or_exit.bind(button))


func _on_save_or_exit(button: Button) -> void:
	match button.name:
		&"Apply":
			print("Save Settings")
		&"Exit":
			Services.ui.hide_ui(UI.Uis.GAME_SETTINGS)
