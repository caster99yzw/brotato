class_name WeaponController
extends Node2D

@export var player: PlayerController
@export var bullet_scene: PackedScene

signal kill_reward(position: Vector2)

var fire_rate: float = 3.0
var bullet_speed: float = 500.0
var damage: float = 10.0

var can_shoot: bool = true
var shoot_timer: Timer

func _ready() -> void:
	shoot_timer = Timer.new()
	shoot_timer.wait_time = 1.0 / fire_rate
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)

func _process(_delta: float) -> void:
	if can_shoot and player.aim_direction.length() > 0:
		shoot()

func shoot() -> void:
	if not bullet_scene:
		return
	
	can_shoot = false
	shoot_timer.start()
	
	var bullet := bullet_scene.instantiate() as Bullet
	if bullet:
		bullet.setup(player.aim_direction, bullet_speed, damage)
		bullet.hit_enemy.connect(_on_bullet_hit_enemy)
		get_tree().root.add_child(bullet)
		bullet.global_position = player.global_position + player.aim_direction * 20

func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_bullet_hit_enemy(dmg: float, pos: Vector2) -> void:
	kill_reward.emit(pos)
