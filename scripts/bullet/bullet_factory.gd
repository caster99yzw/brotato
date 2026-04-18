class_name BulletFactory
extends Node

const TRAJECTORY_MAP: Dictionary = {
	"linear": BulletData.TrajectoryType.LINEAR,
	"spiral": BulletData.TrajectoryType.SPIRAL,
	"homing": BulletData.TrajectoryType.HOMING,
	"curved": BulletData.TrajectoryType.CURVED,
	"boomerang": BulletData.TrajectoryType.BOOMERANG,
	"orbiting": BulletData.TrajectoryType.ORBITING,
	"dropping": BulletData.TrajectoryType.DROPPING,
}

const COLLISION_MAP: Dictionary = {
	"destroy": BulletData.CollisionType.DESTROY,
	"pierce": BulletData.CollisionType.PIERCE,
	"bounce": BulletData.CollisionType.BOUNCE,
	"explosive": BulletData.CollisionType.EXPLOSIVE,
	"chaining": BulletData.CollisionType.CHAINING,
	"spreading": BulletData.CollisionType.SPREADING,
	"burning": BulletData.CollisionType.BURNING,
}

const _WeaponConfig = preload("res://scripts/weapon/weapon_config.gd")
var _weapon_config

func _init() -> void:
	_weapon_config = _WeaponConfig.get_instance()

func create_bullets(weapon_name: String, spawn_pos: Vector2, direction: Vector2, damage_mult: float, speed_mult: float, bullet_count: int) -> Array[BulletData]:
	var bullets: Array[BulletData] = []
	var config: Dictionary = _weapon_config.get_config(weapon_name)
	var spread_angle: float = 15.0 if bullet_count > 1 else 0.0
	var angle_step: float = deg_to_rad(spread_angle) / float(bullet_count - 1) if bullet_count > 1 else 0.0
	var base_angle: float = direction.angle() - angle_step * float(bullet_count - 1) / 2.0

	for i: int in range(bullet_count):
		var bullet: BulletData = _create_bullet(weapon_name, config, spawn_pos, direction, damage_mult, speed_mult)
		var speed: float = config.get("speed", 500.0) * speed_mult
		if bullet_count > 1:
			bullet.velocity = Vector2.from_angle(base_angle + angle_step * float(i)) * speed
			bullet.trajectory_angle = base_angle + angle_step * float(i)
		else:
			bullet.velocity = direction * speed
			bullet.trajectory_angle = direction.angle()
		bullet.source_position = spawn_pos
		bullet.initial_direction = bullet.velocity.normalized()
		bullets.append(bullet)
	return bullets

func _create_bullet(weapon_name: String, config: Dictionary, spawn_pos: Vector2, direction: Vector2, damage_mult: float, speed_mult: float) -> BulletData:
	var bullet: BulletData = BulletData.new()
	bullet.position = spawn_pos + direction * 20
	bullet.speed = config.get("speed", 500.0) * speed_mult
	bullet.damage = config.get("damage", 10.0) * damage_mult
	bullet.trajectory_type = TRAJECTORY_MAP.get(config.get("trajectory", "linear"), BulletData.TrajectoryType.LINEAR)
	bullet.collision_type = COLLISION_MAP.get(config.get("collision", "destroy"), BulletData.CollisionType.DESTROY)
	bullet.bullet_sprite = config.get("sprite", weapon_name)
	bullet.max_lifetime = config.get("max_lifetime", 10.0)

	var trajectory: String = config.get("trajectory", "linear")
	match trajectory:
		"curved":
			bullet.gravity = config.get("gravity", 200.0)
		"spiral":
			bullet.trajectory_angle = direction.angle()
		"orbiting":
			bullet.orbiting_center = spawn_pos + direction * config.get("orbiting_radius", 50.0)
			bullet.orbiting_radius = config.get("orbiting_radius", 50.0)
			bullet.orbiting_speed = config.get("orbiting_speed", 3.0)
			bullet.orbiting_follow_player = config.get("orbiting_follow_player", false)
			bullet.orbiting_angle = 0.0
		"boomerang":
			bullet.has_returned = false

	var collision: String = config.get("collision", "destroy")
	match collision:
		"pierce":
			bullet.pierce_count = config.get("pierce_count", 3)
		"bounce":
			bullet.bounces_left = 3
		"explosive":
			bullet.explosive_radius = config.get("explosive_radius", 50.0)
		"chaining":
			bullet.chain_count = config.get("chain_count", 3)
			bullet.chain_range = config.get("chain_range", 100.0)
		"spreading":
			bullet.spread_count = config.get("spread_count", 3)
			bullet.spread_angle = config.get("spread_angle", 45.0)
		"burning":
			bullet.burn_damage = config.get("burn_damage", 5.0)
			bullet.burn_duration = config.get("burn_duration", 3.0)
			bullet.burn_tick_rate = config.get("burn_tick_rate", 1.0)

	return bullet