class_name Level
extends Node2D

signal game_over
signal wave_started(wave: int)

@export var player_scene: PackedScene = preload("res://scenes/player.tscn")

var player: PlayerController
var enemy_world: EnemyWorld
var bullet_world: BulletWorld
var weapon: WeaponController
var upgrade_manager: UpgradeManager
var upgrade_panel: UpgradePanel
var stats_panel: StatsPanel
var wave_banner: Label
var ui_layer: CanvasLayer

var current_wave: int = 0
var enemies_per_wave: int = 0
var enemies_spawned: int = 0
var enemies_killed: int = 0
var spawn_interval: float = 1.5
var spawn_timer_accum: float = 0.0

func _ready() -> void:
	setup_ui()
	setup_player()
	setup_bullet_world()
	setup_enemy_world()
	setup_upgrade_system()
	start_game()

func setup_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	stats_panel = preload("res://scenes/ui/stats_panel.tscn").instantiate() as StatsPanel
	ui_layer.add_child(stats_panel)
	
	upgrade_panel = preload("res://scenes/ui/upgrade_panel.tscn").instantiate() as UpgradePanel
	ui_layer.add_child(upgrade_panel)
	upgrade_panel.visible = false
	
	wave_banner = Label.new()
	wave_banner.anchors_preset = 8
	wave_banner.anchor_left = 0.5
	wave_banner.anchor_top = 0.0
	wave_banner.anchor_right = 0.5
	wave_banner.anchor_bottom = 0.0
	wave_banner.offset_left = -100.0
	wave_banner.offset_top = 20.0
	wave_banner.offset_right = 100.0
	wave_banner.offset_bottom = 70.0
	wave_banner.grow_horizontal = 2
	wave_banner.text = ""
	wave_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui_layer.add_child(wave_banner)

func setup_player() -> void:
	player = player_scene.instantiate() as PlayerController
	add_child(player)
	player.global_position = get_viewport_rect().size / 2
	
	var aim := PlayerAim.new()
	aim.player = player
	player.add_child(aim)

func setup_bullet_world() -> void:
	bullet_world = BulletWorld.new()
	add_child(bullet_world)
	
	weapon = WeaponController.new()
	weapon.player = player
	weapon.bullet_world = bullet_world
	player.add_child(weapon)

func setup_enemy_world() -> void:
	enemy_world = EnemyWorld.new()
	enemy_world.set_player(player)
	enemy_world.enemy_killed.connect(_on_enemy_killed)
	add_child(enemy_world)
	bullet_world.set_enemy_world(enemy_world)

func setup_upgrade_system() -> void:
	upgrade_manager = UpgradeManager.new()
	upgrade_manager.weapon_controller = weapon
	add_child(upgrade_manager)
	
	upgrade_panel.option_selected.connect(_on_upgrade_selected)
	weapon.stats_changed.connect(_on_stats_changed)
	upgrade_manager.wave_completed.connect(_on_wave_completed)
	upgrade_manager.game_won.connect(_on_game_won)
	
	_on_stats_changed(weapon.damage, weapon.fire_rate, weapon.bullet_speed)

func _process(delta: float) -> void:
	bullet_world.set_player_position(player.global_position)
	spawn_enemies_if_needed(delta)

func spawn_enemies_if_needed(delta: float) -> void:
	if upgrade_manager.current_wave > upgrade_manager.max_waves:
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

func _random_spawn_position() -> Vector2:
	var angle := randf() * TAU
	var radius := 400.0
	return player.global_position + Vector2(cos(angle), sin(angle)) * radius

func start_game() -> void:
	upgrade_manager.start_next_wave()
	start_wave(upgrade_manager.current_wave, upgrade_manager.enemies_per_wave)

func start_wave(wave: int, enemy_count: int) -> void:
	current_wave = wave
	enemies_per_wave = enemy_count
	enemies_spawned = 0
	enemies_killed = 0
	spawn_timer_accum = 0.0
	stats_panel.set_wave(current_wave)
	_show_wave_banner(current_wave)
	wave_started.emit(current_wave)

func _show_wave_banner(wave: int) -> void:
	if wave > 0:
		wave_banner.text = "第 %d 波" % wave
		wave_banner.visible = true
	else:
		wave_banner.visible = false

func _on_enemy_killed() -> void:
	enemies_killed += 1
	upgrade_manager.on_enemy_killed()

func _on_wave_completed(wave: int) -> void:
	upgrade_panel.show_upgrades(upgrade_manager.get_random_upgrade_options(3))

func _on_upgrade_selected(option: Dictionary) -> void:
	upgrade_manager.apply_upgrade(option)
	upgrade_manager.start_next_wave()
	start_wave(upgrade_manager.current_wave, upgrade_manager.enemies_per_wave)
	stats_panel.visible = true
	_show_wave_banner(upgrade_manager.current_wave)

func _on_stats_changed(damage: float, fire_rate: float, bullet_speed: float) -> void:
	stats_panel.update_stats(damage, fire_rate, bullet_speed)

func _on_game_won() -> void:
	game_over.emit()

func restart() -> void:
	queue_free()
	var new_level = Level.new()
	get_parent().add_child(new_level)
