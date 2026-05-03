class_name UI extends Node

enum {
	TEST,
}

const _UI_SCENES_PRELOAD: Dictionary = {
	0: preload("uid://dxyeviydep8bt")
}


var ui_manager: CanvasLayer
var Settings: GameSettings



func _ui_manager_check() -> bool:
	if not ui_manager:
		push_error("UI: Can't control ui's because ui_manager is not set.")
		return false
	return true
