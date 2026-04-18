class_name UpgradeManager
extends Node2D

signal upgrade_selected(option_name: String, damage_mult: float, fire_rate_mult: float, bullet_speed_mult: float)
signal wave_started(wave: int, enemy_count: int)
signal wave_completed(wave: int)
signal game_won
signal enemy_spawned(enemy: EnemyData)

var weapon_controller: WeaponController
var enemy_world: EnemyWorld
var player: Node2D
var current_wave: int = 0
var max_waves: int = 10
var enemies_per_wave: int = 0
var enemies_spawned: int = 0
var enemies_killed: int = 0
var upgrade_options: Array = []
var spawn_interval: float = 1.5
var spawn_timer_accum: float = 0.0

func _ready() -> void:
	load_upgrades()

func _process(delta: float) -> void:
	if enemy_world == null or player == null:
		return
	if current_wave > max_waves:
		return
	if enemies_spawned >= enemies_per_wave:
		return

	spawn_timer_accum += delta
	if spawn_timer_accum >= spawn_interval:
		spawn_timer_accum = 0.0
		var enemy := EnemyData.new()
		enemy.position = _random_spawn_position()
		enemy.velocity = Vector2.ZERO
		enemy_world.add_enemy(enemy)
		enemies_spawned += 1
		enemy_spawned.emit(enemy)

func _random_spawn_position() -> Vector2:
	var angle := randf() * TAU
	var radius := 400.0
	return player.global_position + Vector2(cos(angle), sin(angle)) * radius

func load_upgrades() -> void:
	var file := FileAccess.open("res://resources/weapon/upgrades.json", FileAccess.READ)
	if not file:
		push_error("Failed to open upgrades.json")
		return
	
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		push_error("Failed to parse upgrades.json")
		return
	
	var data := json.get_data() as Dictionary
	if data.has("upgrades"):
		upgrade_options = data["upgrades"]

func start_next_wave() -> void:
	current_wave += 1
	if current_wave > max_waves:
		game_won.emit()
		return
	
	enemies_spawned = 0
	enemies_killed = 0
	enemies_per_wave = 5 + (current_wave * 3)
	wave_started.emit(current_wave, enemies_per_wave)

func on_enemy_spawned() -> void:
	enemies_spawned += 1

func on_enemy_killed() -> void:
	enemies_killed += 1
	if enemies_killed >= enemies_per_wave:
		wave_completed.emit(current_wave)

func get_random_upgrade_options(count: int = 3) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	var remaining: Array = upgrade_options.duplicate()
	var total_weight := 0
	for opt in remaining:
		total_weight += opt["weight"]
	
	for i in range(count):
		if remaining.is_empty():
			break
		var roll := randf() * total_weight
		var cumulative := 0.0
		var selected_idx := 0
		for j in range(remaining.size()):
			cumulative += float(remaining[j]["weight"])
			if roll <= cumulative:
				selected_idx = j
				break
		options.append(remaining[selected_idx])
		total_weight -= float(remaining[selected_idx]["weight"])
		remaining.remove_at(selected_idx)
	
	return options

func apply_upgrade(option: Dictionary) -> void:
	if weapon_controller:
		weapon_controller.apply_upgrade(option["damage"], option["fire_rate"], option["bullet_speed"])
	upgrade_selected.emit(option["name"], option["damage"], option["fire_rate"], option["bullet_speed"])
