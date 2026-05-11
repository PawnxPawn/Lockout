class_name PlayerInput extends InputSource

const PIXEL_SCALE:float = 0.002

var mouse_sensitivity = Vector2(0.50, 0.25)
var _new_look_direction: Vector2 = Vector2.ZERO

func ready() -> void:
	change_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func process(delta: float) -> void:
	look_direction = _new_look_direction
	_new_look_direction = Vector2.ZERO
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
	#TODO: DELETE after pause menu is added
	if event.is_action_pressed(&"ui_cancel"):
		_owner.get_tree().quit()
	if event is InputEventMouseMotion:
		_new_look_direction = (event.screen_relative * PIXEL_SCALE) * mouse_sensitivity

func change_mouse_mode(mouse_mode) -> void:
	Input.mouse_mode = mouse_mode
