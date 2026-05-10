class_name InputSource extends Component

var move_direction: Vector3 = Vector3.ZERO
var look_direction: Vector3 = Vector3.ZERO

var is_jumping: bool = false
var is_interacting:bool = false
var is_sprinting: bool = false
var is_inventory: bool = false


func get_move_direction() -> Vector3:
	return move_direction


func get_look_direction() -> Vector3:
	return look_direction
