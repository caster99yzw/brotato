class_name WeaponController
extends Node2D

@export var player: PlayerController
@export var bullet_scene: PackedScene

signal kill_reward(position: Vector2)

var fire_rate: float = 3.0
var bullet_speed: float = 500.0
var damage: float = 10.0

var can_shoot: bool = true
var fake_timer: RefCounted
var _shoot_timer: Timer

func _ready() -> void:
	if fake_timer:
		if fake_timer.has_method("trigger_timeout"):
			fake_timer.timeout.connect(_on_shoot_timer_timeout)
	else:
		_shoot_timer = Timer.new()
		_shoot_timer.wait_time = 1.0 / fire_rate
		_shoot_timer.timeout.connect(_on_shoot_timer_timeout)
		add_child(_shoot_timer)

func _process(_delta: float) -> void:
	if can_shoot and player.aim_direction.length() > 0:
		shoot()

func shoot() -> void:
	if not bullet_scene:
		return
	
	can_shoot = false
	if fake_timer:
		fake_timer.start()
	else:
		_shoot_timer.start()
	
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
