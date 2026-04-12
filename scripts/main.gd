extends Node2D

@export var player_scene: PackedScene = preload("res://scenes/player.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

var player: PlayerController
var enemy_manager: EnemyManager
var weapon: WeaponController

func _ready() -> void:
	setup_player()
	setup_enemy_manager()

func setup_player() -> void:
	player = player_scene.instantiate() as PlayerController
	add_child(player)
	player.global_position = get_viewport_rect().size / 2
	
	var aim := PlayerAim.new()
	aim.player = player
	player.add_child(aim)
	
	weapon = WeaponController.new()
	weapon.player = player
	weapon.fire_rate = 3.0
	weapon.bullet_speed = 500.0
	weapon.damage = 10.0
	weapon.bullet_requested.connect(_on_bullet_requested)
	weapon.kill_reward.connect(_on_kill_reward)
	player.add_child(weapon)

func _on_bullet_requested(direction: Vector2, speed: float, damage: float) -> void:
	var bullet := bullet_scene.instantiate() as Bullet
	bullet.setup(direction, speed, damage)
	add_child(bullet)
	bullet.global_position = player.global_position + direction * 20

func _on_kill_reward(pos: Vector2) -> void:
	pass

func setup_enemy_manager() -> void:
	enemy_manager = EnemyManager.new()
	enemy_manager.enemy_scene = enemy_scene
	enemy_manager.player = player
	add_child(enemy_manager)
