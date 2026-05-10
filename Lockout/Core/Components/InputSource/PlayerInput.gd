class_name PlayerInput extends InputSource



func process(delta: float) -> void:
	_process_move(delta)
	_process_input(delta)


func _process_move(_delta:float) -> void:
	var move_input: Vector2 = Input.get_vector(&"Move_Left",&"Move_Right", &"Move_Forward", &"Move_Backward")
	move_direction = Vector3(move_input.x, 0 , move_input.y)


func _process_input(_delta:float) -> void:
	is_sprinting = Input.is_action_pressed(&"Sprint")
	is_interacting = Input.is_action_just_pressed(&"Interact")
	is_inventory = Input.is_action_just_pressed(&"Inventory")


func input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_direction = Vector3(event.relative.x, event.relative.y, 0)
	else:
		look_direction = Vector3.ZERO
