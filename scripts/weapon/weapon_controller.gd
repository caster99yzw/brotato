class_name WeaponController
extends Node2D

@export var bullet_world: BulletWorld
@export var player: PlayerController

signal stats_changed(damage: float, fire_rate: float, bullet_speed: float)

var base_fire_rate: float = 3.0
var base_bullet_speed: float = 500.0
var base_damage: float = 10.0

var fire_rate: float = 3.0:
	set(value):
		fire_rate = value
		_update_fire_rate()
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

func _update_fire_rate() -> void:
	if _shoot_timer:
		_shoot_timer.wait_time = 1.0 / fire_rate if fire_rate > 0 else 9999

func apply_upgrade(damage_mult: float, fire_rate_mult: float, bullet_speed_mult: float) -> void:
	damage = base_damage * (1.0 + damage_mult)
	fire_rate = base_fire_rate * (1.0 + fire_rate_mult)
	bullet_speed = base_bullet_speed * (1.0 + bullet_speed_mult)
	stats_changed.emit(damage, fire_rate, bullet_speed)

func get_stats() -> Dictionary:
	return {"damage": damage, "fire_rate": fire_rate, "bullet_speed": bullet_speed}

func get_dps() -> float:
	return damage * fire_rate

func _process(_delta: float) -> void:
	if can_shoot and player.aim_direction.length() > 0:
		shoot()

func shoot() -> void:
	if not can_shoot:
		return
	
	can_shoot = false
	if fake_timer:
		fake_timer.start()
	else:
		_shoot_timer.start()
	
	var bullet := BulletData.new()
	bullet.position = player.global_position + player.aim_direction * 20
	bullet.velocity = player.aim_direction * bullet_speed
	bullet.speed = bullet_speed
	bullet.damage = damage
	bullet.source_position = player.global_position
	
	bullet_world.add_bullet(bullet)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true
