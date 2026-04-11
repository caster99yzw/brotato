class_name EnemyManager
extends Node2D

@export var enemy_scene: PackedScene
@export var player: Node2D

var spawn_timer: Timer
var enemies: Array[Enemy] = []

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

func _process(_delta: float) -> void:
	enemies = enemies.filter(func(e): return is_instance_valid(e))

func spawn_enemy() -> void:
	if not enemy_scene:
		return
	
	var enemy := enemy_scene.instantiate() as Enemy
	if enemy:
		enemy.setup(player)
		var angle := randf() * TAU
		var radius := 400.0
		enemy.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * radius
		add_child(enemy)
		enemies.append(enemy)

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()
