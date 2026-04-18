class_name BulletData
extends RefCounted

enum TrajectoryType {
	LINEAR,
	SPIRAL,
	HOMING,
	CURVED,
	BOOMERANG,
	ORBITING,
	DROPPING,
}

enum CollisionType {
	DESTROY,
	PIERCE,
	BOUNCE,
	EXPLOSIVE,
	CHAINING,
	SPREADING,
	BURNING,
}

var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var speed: float = 500.0
var damage: float = 10.0
var alive: bool = true

var trajectory_type: TrajectoryType = TrajectoryType.LINEAR
var trajectory_angle: float = 0.0
var trajectory_center: Vector2 = Vector2.ZERO

var collision_type: CollisionType = CollisionType.DESTROY
var pierce_count: int = 0
var bounces_left: int = 0

var lifetime: float = 0.0
var max_lifetime: float = 10.0

var source_position: Vector2 = Vector2.ZERO

var gravity: float = 0.0
var return_point: Vector2 = Vector2.ZERO
var orbiting_center: Vector2 = Vector2.ZERO
var orbiting_radius: float = 50.0
var orbiting_speed: float = 3.0
var orbiting_angle: float = 0.0
var orbiting_follow_player: bool = false

var chain_count: int = 0
var chain_range: float = 100.0
var spread_count: int = 0
var spread_angle: float = 45.0
var burn_damage: float = 0.0
var burn_duration: float = 0.0
var burn_tick_rate: float = 1.0
var explosive_radius: float = 50.0

var bullet_sprite: String = ""
var has_trail: bool = false
var trail_length: int = 0

var last_hit_enemy: EnemyData = null
var initial_direction: Vector2 = Vector2.ZERO
var has_returned: bool = false