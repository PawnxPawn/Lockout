@tool
extends Node3D

func remove_wall_up() -> void:
	if is_instance_valid($WallUp):
		$WallUp.queue_free()

func remove_wall_down() -> void:
	if is_instance_valid($WallDown):
		$WallDown.queue_free()

func remove_wall_left() -> void:
	if is_instance_valid($WallLeft):
		$WallLeft.queue_free()

func remove_wall_right() -> void:
	if is_instance_valid($WallRight):
		$WallRight.queue_free()

func remove_door_up() -> void:
	if is_instance_valid($DoorUp):
		$DoorUp.queue_free()

func remove_door_down() -> void:
	if is_instance_valid($DoorDown):
		$DoorDown.queue_free()

func remove_door_left() -> void:
	if is_instance_valid($DoorLeft):
		$DoorLeft.queue_free()

func remove_door_right() -> void:
	if is_instance_valid($DoorRight):
		$DoorRight.queue_free()
