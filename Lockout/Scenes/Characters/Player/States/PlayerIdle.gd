class_name PlayerIdle extends PlayerState

func enter() -> void:
	_input.is_active = true
	_look.is_active = true
	_movement.is_active = true

func process_frame(_delta: float) -> void:
	#var move_dir = _input.move_direction
	pass
