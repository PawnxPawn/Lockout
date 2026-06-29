class_name GravityComponent extends Component

signal grounded
signal left_floor

var gravity_ascent: float = 15.0
var gravity_descent: float = 50.0
var is_on_floor: bool = false
var _was_on_floor: bool = false

const FLOOR_DOT_MIN: float = 0.99

enum GravityType {
	NORMAL,
	CUSTOM,
}

const PRESETS: Dictionary = {
	GravityType.NORMAL: {
		&"ascent": 200.0,
		&"descent": 1600.0,
	},
}

func _init(p_owner: Node) -> void:
	super(p_owner)
	if _owner is RigidBody2D:
		var body := _owner as RigidBody2D
		body.gravity_scale = 0.0
		body.can_sleep = false

func physics_process(_delta: float) -> void:
	if _owner is CharacterBody2D or _owner is CharacterBody2D:
		apply_characterbody_gravity()


func integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	is_on_floor_check(state)
	rigid2d_apply_gravity(state)


func is_on_floor_check(state: PhysicsDirectBodyState2D) -> void:
	_was_on_floor = is_on_floor
	is_on_floor = false

	for i in state.get_contact_count():
		var normal: float = state.get_contact_local_normal(i).dot(Vector2.UP)
		if normal > FLOOR_DOT_MIN:
			is_on_floor = true
			break

	if is_on_floor and not _was_on_floor:
		state.linear_velocity.y = 0.0
		grounded.emit()
	elif not is_on_floor and _was_on_floor:
		left_floor.emit()


func apply_characterbody_gravity() -> void:
	if _owner.is_on_floor():
			grounded.emit()
			return
	var gravity: float = gravity_ascent if _owner.velocity.y < 0.0 else gravity_descent
	_owner.velocity.y += gravity
	_owner.move_and_slide()


func rigid2d_apply_gravity(state:PhysicsDirectBodyState2D) -> void:
	if is_on_floor: return
	var gravity: float = gravity_ascent if state.linear_velocity.y < 0.0 else gravity_descent
	state.linear_velocity.y += gravity * state.step


func set_gravity(type: GravityType, custom_ascent: float = 0.0, custom_descent: float = 0.0) -> void:
	if type == GravityType.CUSTOM:
		gravity_ascent = custom_ascent
		gravity_descent = custom_descent
		return
	gravity_ascent = PRESETS[type][&"ascent"]
	gravity_descent = PRESETS[type][&"descent"]
