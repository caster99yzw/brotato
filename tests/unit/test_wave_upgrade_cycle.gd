extends BrotatoTest

var _level: Node2D
var _player: Node2D
var _enemy_world: EnemyWorld
var _bullet_world: BulletWorld
var _weapon: Node2D
var _upgrade_manager: UpgradeManager
var _upgrade_panel: Control
var _stats_panel: Control
var _wave_banner: Label

const _GMCommands = preload("res://scripts/gm/gm_commands.gd")

func before_each():
	_level = Node2D.new()
	add_child(_level)

	_player = Node2D.new()
	_player.global_position = Vector2(500, 500)
	_level.add_child(_player)

	_enemy_world = EnemyWorld.new()
	_enemy_world.set_player(_player)
	_level.add_child(_enemy_world)

	_bullet_world = BulletWorld.new()
	_level.add_child(_bullet_world)

	var upgrade_manager_node = UpgradeManager.new()
	upgrade_manager_node.weapon_controller = null
	upgrade_manager_node.enemy_world = _enemy_world
	upgrade_manager_node.player = _player
	_level.add_child(upgrade_manager_node)
	_upgrade_manager = upgrade_manager_node

	_upgrade_panel = Control.new()
	_level.add_child(_upgrade_panel)

	_stats_panel = Control.new()
	_level.add_child(_stats_panel)

	_wave_banner = Label.new()
	_level.add_child(_wave_banner)

func after_each():
	if _level != null:
		_level.queue_free()

func test_wave_starts_at_1():
	_upgrade_manager.start_next_wave()
	assert_eq(_upgrade_manager.current_wave, 1)
	assert_eq(_upgrade_manager.enemies_per_wave, 8)

func test_enemies_spawn_after_multiple_frames():
	_upgrade_manager.spawn_interval = 0.01
	_upgrade_manager.start_next_wave()
	for i in 10:
		_upgrade_manager._process(0.1)
	assert_gt(_upgrade_manager.enemies_spawned, 0)

func test_kill_all_enemies():
	_upgrade_manager.spawn_interval = 0.01
	_upgrade_manager.start_next_wave()
	for i in 10:
		_upgrade_manager._process(0.1)
	_GMCommands.kill_all(_enemy_world)
	assert_eq(_enemy_world.enemies.filter(func(e): return e.alive).size(), 0)

func test_wave_completes_when_all_enemies_killed():
	_upgrade_manager.current_wave = 1
	_upgrade_manager.enemies_per_wave = 3
	_upgrade_manager.enemies_spawned = 0
	_upgrade_manager.enemies_killed = 0

	for i in 3:
		var enemy = EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		_enemy_world.add_enemy(enemy)

	for enemy in _enemy_world.enemies:
		enemy.alive = false

	_upgrade_manager.on_enemy_killed()
	_upgrade_manager.on_enemy_killed()
	_upgrade_manager.on_enemy_killed()

	assert_eq(_upgrade_manager.enemies_killed, _upgrade_manager.enemies_per_wave)

func test_upgrade_applies_to_weapon():
	var weapon = WeaponController.new()
	weapon.player = _player
	weapon._ready()
	weapon.equip_weapon("PISTOL")
	_upgrade_manager.weapon_controller = weapon

	var initial_damage = weapon.get_total_damage()
	var upgrade = {"name": "Test", "damage": 0.5, "fire_rate": 0.0, "bullet_speed": 0.0}
	_upgrade_manager.apply_upgrade(upgrade)

	var new_damage = weapon.get_total_damage()
	assert_gt(new_damage, initial_damage)