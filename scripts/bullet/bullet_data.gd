class_name BulletData
extends RefCounted

enum TrajectoryType {
	LINEAR,
	SPIRAL,
	HOMING,
}

enum CollisionType {
	DESTROY,
	PIERCE,
	BOUNCE,
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
