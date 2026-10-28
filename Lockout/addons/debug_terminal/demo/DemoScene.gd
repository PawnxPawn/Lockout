extends Node2D
## Demo scene for the Debug Terminal addon. Registers a few sample
## commands and watchers so you can see how the API is used.

@onready var player: ColorRect = $Player

const SPEED: float = 240.0

var _score: int = 0


func _ready() -> void:
	_register_demo_commands()
	_register_demo_watchers()
	
	DebugRegistry.log_message("Use \"~\" to hide the terminal.\nTry:", Color.CYAN)
	DebugRegistry.log_message(" - help", Color.CYAN)
	DebugRegistry.log_message(" - stats performance", Color.CYAN)
	DebugRegistry.log_message(" - show demo_score", Color.CYAN)
	DebugRegistry.log_message(" - break_if demo_score > 10", Color.CYAN)
	DebugRegistry.log_message(" - demo_greet [name]", Color.CYAN)
	DebugRegistry.log_message(" - tree", Color.CYAN)
	DebugRegistry.log_message(" - set_node Main/SceneManager/DemoScene/Player color Color(1,0,0,1)", Color.CYAN)


func _process(delta: float) -> void:
	_score += 1
	var move: Vector2 = Vector2.ZERO
	move.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	player.position += move.normalized() * SPEED * delta


## Shows off register_command() with a couple of example commands.
func _register_demo_commands() -> void:
	DebugRegistry.register_command(
		"demo_greet",
		func(who: String = "world"): return "Hello, %s!" % who,
		"demo_greet [name] - sample command, shows register_command()",
		"demo"
	)
	DebugRegistry.register_command(
		"demo_reset_score",
		_reset_score,
		"demo_reset_score - resets the sample score watcher",
		"demo"
	)


## Shows off watch() with a live-changing sample value, good for trying
## break_if against.
func _register_demo_watchers() -> void:
	DebugRegistry.watch("demo_score", _get_score, 1, true, "demo")


func _reset_score() -> String:
	_score = 0
	return "Score reset"


func _get_score() -> int:
	return _score
