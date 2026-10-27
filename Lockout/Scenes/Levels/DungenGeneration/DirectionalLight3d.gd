
@tool
extends DirectionalLight3D

enum FlickerType { BULB, FIRE, PULSE }

@export var flicker_type: FlickerType = FlickerType.BULB
@export var base_energy: float = 1.0
@export_range(0.1, 5.0) var flicker_speed: float = 1.0
@export_range(0.0, 1.0) var flicker_amount: float = 0.2
@export var enabled: bool = true

var _time: float = 0.0
var _rng := RandomNumberGenerator.new()
var _next_flicker: float = 0.0
var _current_energy: float = 1.0


func _ready() -> void:
	_rng.randomize()
	_current_energy = base_energy
	_next_flicker = 0.0
	light_energy = base_energy


func _process(delta: float) -> void:
	if not enabled:
		light_energy = base_energy
		return

	_time += delta

	match flicker_type:
		FlickerType.BULB:
			_bulb_flicker(delta)
		FlickerType.FIRE:
			_fire_flicker(delta)
		FlickerType.PULSE:
			_pulse_flicker(delta)


func _bulb_flicker(delta: float) -> void:
	_next_flicker -= delta

	if _next_flicker <= 0.0:
		_next_flicker = _rng.randf_range(0.03, 0.15)
		_current_energy = base_energy * _rng.randf_range(
			1.0 - flicker_amount,
			1.0
		)

	light_energy = _current_energy


func _fire_flicker(delta: float) -> void:
	var target_energy: float = base_energy * _rng.randf_range(
		1.0 - flicker_amount,
		1.0 + flicker_amount
	)

	_current_energy = lerpf(
		_current_energy,
		target_energy,
		minf(delta * flicker_speed, 1.0)
	)

	light_energy = _current_energy


func _pulse_flicker(_delta: float) -> void:
	light_energy = base_energy * (
		1.0 + sin(_time * flicker_speed) * flicker_amount
	)
