class_name EnemyData
extends RefCounted

var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var speed: float = 80.0
var health: float = 30.0
var max_health: float = 30.0
var damage: float = 10.0
var alive: bool = true

var target: Node2D
var lifetime: float = 0.0
var max_lifetime: float = 60.0
