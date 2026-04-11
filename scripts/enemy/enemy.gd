class_name Enemy
extends Area2D

@export var speed: float = 80.0
@export var health: float = 30.0

var target: Node2D
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if target:
		var dir := (target.global_position - global_position).normalized()
		velocity = dir * speed
		position += velocity * delta

func setup(t: Node2D) -> void:
	target = t

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		queue_free()
