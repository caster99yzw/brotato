class_name Bullet
extends Area2D

signal hit_enemy(damage: float, position: Vector2)

@export var damage: float = 10.0
@export var speed: float = 500.0

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta

func setup(dir: Vector2, spd: float, dmg: float) -> void:
	velocity = dir.normalized() * spd
	speed = spd
	damage = dmg
	rotation = dir.angle()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
		hit_enemy.emit(damage, position)
		queue_free()
