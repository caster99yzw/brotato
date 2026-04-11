class_name PlayerAim
extends Node2D

@export var player: PlayerController

func _process(_delta: float) -> void:
	if player:
		var mouse_pos := get_global_mouse_position()
		var aim_dir := (mouse_pos - global_position).normalized()
		if aim_dir.length() > 0:
			player.set_aim_direction(aim_dir)
