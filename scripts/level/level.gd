class_name Level
extends Node2D

signal game_over
signal wave_started(wave: int)

@export var player_scene: PackedScene = preload("res://scenes/player.tscn")

var player: PlayerController
var enemy_world: EnemyWorld
var bullet_world: BulletWorld
var bullet_factory
var weapon: WeaponController
var upgrade_manager: UpgradeManager
var upgrade_panel: UpgradePanel
var stats_panel: StatsPanel
var wave_banner: Label
var ui_layer: CanvasLayer

var current_wave: int = 0

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

func setup_bullet_world() -> void:
	const _BulletFactory = preload("res://scripts/bullet/bullet_factory.gd")
	bullet_world = BulletWorld.new()
	add_child(bullet_world)

	bullet_factory = _BulletFactory.new()
	add_child(bullet_factory)

	weapon = WeaponController.new()
	weapon.player = player
	weapon.bullet_world = bullet_world
	weapon.equip_weapon("PISTOL")
	player.add_child(weapon)

	weapon.weapon_fired.connect(_on_weapon_fired)

func setup_enemy_world() -> void:
	enemy_world = EnemyWorld.new()
	enemy_world.set_player(player)
	enemy_world.enemy_killed.connect(_on_enemy_killed)
	add_child(enemy_world)
	bullet_world.set_enemy_world(enemy_world)

func setup_upgrade_system() -> void:
	upgrade_manager = UpgradeManager.new()
	upgrade_manager.weapon_controller = weapon
	upgrade_manager.enemy_world = enemy_world
	upgrade_manager.player = player
	add_child(upgrade_manager)
	
	upgrade_panel.option_selected.connect(_on_upgrade_selected)
	weapon.stats_changed.connect(stats_panel.update_stats)
	upgrade_manager.wave_completed.connect(_on_wave_completed)
	upgrade_manager.game_won.connect(_on_game_won)
	
	player.aim.aim_direction_changed.connect(weapon.set_aim_direction)
	
	var stats: Dictionary = weapon.get_stats()
	stats_panel.update_stats(stats.damage, stats.fire_rate, stats.bullet_speed)

func _process(delta: float) -> void:
	bullet_world.set_player_position(player.global_position)

func start_game() -> void:
	upgrade_manager.start_next_wave()
	start_wave(upgrade_manager.current_wave, upgrade_manager.enemies_per_wave)

func start_wave(wave: int, enemy_count: int) -> void:
	current_wave = wave
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
	upgrade_manager.on_enemy_killed()

func _on_wave_completed(wave: int) -> void:
	upgrade_panel.show_upgrades(upgrade_manager.get_random_upgrade_options(3))

func _on_upgrade_selected(option: Dictionary) -> void:
	upgrade_manager.apply_upgrade(option)
	upgrade_manager.start_next_wave()
	start_wave(upgrade_manager.current_wave, upgrade_manager.enemies_per_wave)
	stats_panel.visible = true
	_show_wave_banner(upgrade_manager.current_wave)

func _on_game_won() -> void:
	game_over.emit()

func _on_weapon_fired(weapon_name: String, spawn_pos: Vector2, direction: Vector2, damage_mult: float, speed_mult: float, bullet_count: int) -> void:
	var bullets: Array[BulletData] = bullet_factory.create_bullets(weapon_name, spawn_pos, direction, damage_mult, speed_mult, bullet_count)
	for bullet: BulletData in bullets:
		bullet_world.add_bullet(bullet)

func restart() -> void:
	queue_free()
	var new_level = Level.new()
	get_parent().add_child(new_level)
