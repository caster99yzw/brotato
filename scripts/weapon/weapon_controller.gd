class_name WeaponController
extends Node2D

class WeaponStats:
	var weapon_name: String
	var fire_rate: float
	var bullet_count: int

	static func create(weapon_name: String, config: Dictionary) -> WeaponStats:
		var stats := WeaponStats.new()
		stats.weapon_name = weapon_name
		stats.fire_rate = config.get("fire_rate", 3.0)
		stats.bullet_count = config.get("bullet_count", 1)
		return stats

@export var bullet_world: BulletWorld
@export var player: PlayerController

signal stats_changed(damage: float, fire_rate: float, bullet_speed: float)
signal weapon_changed(current_weapon: WeaponStats)
signal weapons_updated(weapons: Array)
signal weapon_fired(weapon_name: String, spawn_pos: Vector2, direction: Vector2, damage_mult: float, speed_mult: float, bullet_count: int)

const MAX_WEAPONS: int = 6

const _WeaponConfig = preload("res://scripts/weapon/weapon_config.gd")
var _weapon_config
var equipped_weapons: Array[WeaponStats] = []
var current_weapon_index: int = 0
var current_weapon: WeaponStats:
	get:
		if equipped_weapons.is_empty():
			return null
		return equipped_weapons[current_weapon_index]

var can_shoot: bool = true
var _shoot_timers: Dictionary = {}
var _aim_direction: Vector2 = Vector2.RIGHT
var _damage_mult: float = 1.0
var _fire_rate_mult: float = 1.0
var _bullet_speed_mult: float = 1.0

func _ready() -> void:
	_weapon_config = _WeaponConfig.get_instance()

func set_aim_direction(dir: Vector2) -> void:
	_aim_direction = dir

func equip_weapon(weapon_name: String) -> bool:
	if equipped_weapons.size() >= MAX_WEAPONS:
		return false

	var config: Dictionary = _weapon_config.get_config(weapon_name)
	if config.is_empty():
		return false

	var weapon_data: WeaponStats = WeaponStats.create(weapon_name, config)
	equipped_weapons.append(weapon_data)
	_setup_weapon_timer(weapon_data)
	weapons_updated.emit(equipped_weapons)
	if equipped_weapons.size() == 1:
		weapon_changed.emit(current_weapon)
	return true

func unequip_weapon(index: int) -> void:
	if index < 0 or index >= equipped_weapons.size():
		return
	var weapon: WeaponStats = equipped_weapons[index]
	_remove_weapon_timer(weapon)
	equipped_weapons.remove_at(index)
	if current_weapon_index >= equipped_weapons.size():
		current_weapon_index = maxi(0, equipped_weapons.size() - 1)
	weapons_updated.emit(equipped_weapons)

func switch_weapon(index: int) -> void:
	if index < 0 or index >= equipped_weapons.size():
		return
	current_weapon_index = index
	weapon_changed.emit(current_weapon)

func switch_to_next() -> void:
	if equipped_weapons.is_empty():
		return
	current_weapon_index = (current_weapon_index + 1) % equipped_weapons.size()
	weapon_changed.emit(current_weapon)

func _setup_weapon_timer(weapon: WeaponStats) -> void:
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0 / (weapon.fire_rate * _fire_rate_mult)
	timer.timeout.connect(_on_weapon_shoot_timer_timeout.bind(weapon))
	add_child(timer)
	_shoot_timers[weapon] = timer

func _remove_weapon_timer(weapon: WeaponStats) -> void:
	if _shoot_timers.has(weapon):
		var timer: Timer = _shoot_timers[weapon]
		timer.stop()
		timer.queue_free()
		_shoot_timers.erase(weapon)

func _on_weapon_shoot_timer_timeout(weapon: WeaponStats) -> void:
	can_shoot = true

func apply_upgrade(damage_mult: float, fire_rate_mult: float, bullet_speed_mult: float) -> void:
	_damage_mult *= (1.0 + damage_mult)
	_fire_rate_mult *= (1.0 + fire_rate_mult)
	_bullet_speed_mult *= (1.0 + bullet_speed_mult)

	for weapon: WeaponStats in equipped_weapons:
		if _shoot_timers.has(weapon):
			var timer: Timer = _shoot_timers[weapon]
			timer.wait_time = 1.0 / (weapon.fire_rate * _fire_rate_mult) if weapon.fire_rate > 0 else 9999
	stats_changed.emit(get_total_damage(), get_total_fire_rate(), get_avg_bullet_speed())

func get_stats() -> Dictionary:
	return {
		"damage": get_total_damage(),
		"fire_rate": get_total_fire_rate(),
		"bullet_speed": get_avg_bullet_speed(),
		"weapon_count": equipped_weapons.size()
	}

func get_total_damage() -> float:
	return 10.0 * _damage_mult * equipped_weapons.size()

func get_total_fire_rate() -> float:
	var total: float = 0.0
	for weapon: WeaponStats in equipped_weapons:
		total += weapon.fire_rate * _fire_rate_mult
	return total

func get_avg_bullet_speed() -> float:
	return 500.0 * _bullet_speed_mult

func get_dps() -> float:
	return get_total_damage() * get_total_fire_rate()

func _process(_delta: float) -> void:
	if equipped_weapons.is_empty():
		return
	if can_shoot and _aim_direction.length() > 0:
		shoot()

func shoot() -> void:
	if not can_shoot or current_weapon == null:
		return

	can_shoot = false
	if _shoot_timers.has(current_weapon):
		_shoot_timers[current_weapon].start()

	weapon_fired.emit(
		current_weapon.weapon_name,
		player.global_position,
		_aim_direction,
		_damage_mult,
		_bullet_speed_mult,
		current_weapon.bullet_count
	)