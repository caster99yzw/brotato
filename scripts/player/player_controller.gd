class_name PlayerController
extends CharacterBody2D

@export var speed: float = 200.0

var aim_direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W): input_dir.y -= 1
	if Input.is_key_pressed(KEY_S): input_dir.y += 1
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1
	if Input.is_key_pressed(KEY_D): input_dir.x += 1
	
	if input_dir != Vector2.ZERO:
		velocity = input_dir.normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func set_aim_direction(dir: Vector2) -> void:
	aim_direction = dir
	if dir != Vector2.ZERO:
		rotation = dir.angle()
