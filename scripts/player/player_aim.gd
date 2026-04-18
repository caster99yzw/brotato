class_name PlayerAim
extends Node2D

signal aim_direction_changed(direction: Vector2)

@export var player: PlayerController

func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	var aim_dir := (mouse_pos - global_position).normalized()
	if aim_dir.length() > 0:
		aim_direction_changed.emit(aim_dir)
		player.set_aim_direction(aim_dir)
