@tool
class_name FlickerEnvironment
extends WorldEnvironment

@export var base_energy: float = 1.0
@export_range(0.1, 5.0) var flicker_speed: float = 1.0

var _time := 0.0
var _next_burst := 2.0
var _burst_left := 0.0
var _toggle_timer := 0.0
var _level := 1.0

func _ready() -> void:
	randomize()
	_next_burst = randf_range(1.0, 5.0)

func _process(delta: float) -> void:
	if environment == null:
		return
	_time += delta

	if _burst_left > 0.0:
		_burst_left -= delta
		_toggle_timer -= delta
		if _toggle_timer <= 0.0:
			_toggle_timer = randf_range(0.02, 0.09)
			_level = randf_range(0.0, 0.3) if randf() < 0.45 else randf_range(0.8, 1.0)
		if _burst_left <= 0.0:
			_level = 1.0
			_next_burst = randf_range(2.0, 8.0) / flicker_speed
	else:
		_next_burst -= delta
		if _next_burst <= 0.0:
			_burst_left = randf_range(0.2, 0.8)
			_toggle_timer = 0.0

	var hum := 0.97 + 0.03 * sin(_time * 120.0)
	environment.ambient_light_energy = base_energy * _level * hum
