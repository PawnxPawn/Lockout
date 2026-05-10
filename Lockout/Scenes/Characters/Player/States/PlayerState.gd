class_name PlayerState extends State

var _player: Player

func _setup(sm: StateMachine, parent: Node, handler: ComponentHandler) -> void:
	super(sm, parent, handler)
	_player = parent as Player
