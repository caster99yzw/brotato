extends Node2D

@export var player_scene: PackedScene = preload("res://scenes/player.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

var player: PlayerController
var enemy_manager: EnemyManager

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
	
	var weapon := WeaponController.new()
	weapon.player = player
	weapon.bullet_scene = bullet_scene
	weapon.fire_rate = 3.0
	weapon.bullet_speed = 500.0
	weapon.damage = 10.0
	player.add_child(weapon)

func setup_enemy_manager() -> void:
	enemy_manager = EnemyManager.new()
	enemy_manager.enemy_scene = enemy_scene
	enemy_manager.player = player
	add_child(enemy_manager)
