extends BrotatoTest

var _level: Level
var _player: PlayerController
var _enemy_world: EnemyWorld
var _upgrade_panel: Control

const _GMCommands = preload("res://scripts/gm/gm_commands.gd")

func before_each():
	_level = Level.new()
	add_child(_level)
	_player = _level.weapon.player
	_enemy_world = _level.enemy_world

	_upgrade_panel = Control.new()
	_level.add_child(_upgrade_panel)

func after_each():
	if _level != null:
		_level.queue_free()

func test_wave_starts_at_1():
	assert_eq(_level.current_wave, 1)
	assert_eq(_level.enemies_per_wave, 8)

func test_enemies_spawn_after_multiple_frames():
	_level.spawn_interval = 0.01
	_level.start_next_wave()
	for i in 10:
		_level._process(0.1)
	assert_gt(_level.enemy_world.enemies.size(), 0, "enemies should spawn")

func test_kill_all_enemies():
	_level.spawn_interval = 0.01
	_level.start_next_wave()
	for i in 10:
		_level._process(0.1)
	_GMCommands.kill_all(_enemy_world)
	assert_eq(_enemy_world.enemies.filter(func(e): return e.health > 0).size(), 0)

func test_wave_completes_when_all_enemies_killed():
	_level.current_wave = 1
	_level.enemies_per_wave = 3
	_level.enemies_remaining = 3

	for i in 3:
		var enemy = EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		_enemy_world.add_enemy(enemy)

	for enemy in _enemy_world.enemies:
		enemy.health = 0

	_level._on_enemy_killed(1)
	_level._on_enemy_killed(1)
	_level._on_enemy_killed(1)

	assert_eq(_level.enemies_remaining, 0)

func test_upgrade_applies_to_weapon():
	var initial_damage = _level.weapon.get_total_damage()
	var upgrade = {"name": "Test", "damage": 0.5, "fire_rate": 0.0, "bullet_speed": 0.0}
	_level.upgrade_manager.apply_upgrade(upgrade)

	var new_damage = _level.weapon.get_total_damage()
	assert_gt(new_damage, initial_damage)
