class_name Player extends Entity

@onready var _sm: StateMachine = %StateMachine
@onready var _handler: ComponentHandler = %ComponentHandler

func _ready() -> void:
	_init_sm()


func _init_sm() -> void:
	_sm.init(_handler,[
		PlayerIdle.new()
	])
