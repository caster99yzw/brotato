class_name GameFlowTest
extends BrotatoTest

var _level: Level = null
var _mock_upgrade_panel = null
var _selected_upgrades: Array = []

func before_each():
	super.before_each()
	_level = Level.new()
	add_child(_level)
	_mock_upgrade_panel = load("res://tests/framework/mock_upgrade_panel.gd").new()
	add_child(_mock_upgrade_panel)
	_level.upgrade_panel = _mock_upgrade_panel

func after_each():
	_selected_upgrades.clear()
	if _mock_upgrade_panel != null:
		_mock_upgrade_panel.reset()
		_mock_upgrade_panel.queue_free()
		_mock_upgrade_panel = null
	if _level != null:
		_level.queue_free()
		_level = null
	super.after_each()

func setup_wave(wave: int, enemies_per_wave: int) -> void:
	_level.current_wave = wave
	_level.enemies_per_wave = enemies_per_wave
	_level.enemies_remaining = enemies_per_wave

func spawn_nemies(count: int) -> void:
	for i in count:
		var enemy := EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		_level.enemy_world.add_enemy(enemy)

func kill_all_enemies() -> void:
	GMCommands.kill_all(_level.enemy_world)

func complete_wave() -> void:
	GMCommands.complete_wave(_level)

func select_upgrade(option_index: int = 0) -> void:
	var options = _mock_upgrade_panel.get_last_options()
	if option_index >= 0 and option_index < options.size():
		var option = options[option_index]
		_selected_upgrades.append(option)
		_mock_upgrade_panel.select_option(option)
		_level._on_upgrade_selected(option)

func get_level() -> Level:
	return _level

func get_upgrade_manager() -> UpgradeManager:
	return _level.upgrade_manager

func get_enemy_world() -> EnemyWorld:
	return _level.enemy_world

func get_mock_upgrade_panel():
	return _mock_upgrade_panel

func get_selected_upgrades() -> Array:
	return _selected_upgrades.duplicate()

func verify_wave_state(wave: int, enemies_per_wave: int, enemies_remaining: int) -> bool:
	return assert_state_matches(_level, {
		"current_wave": wave,
		"enemies_per_wave": enemies_per_wave,
		"enemies_remaining": enemies_remaining
	}, "Wave state mismatch")

func verify_no_enemies() -> bool:
	return assert_eq(_level.enemy_world.enemies.size(), 0, "Expected no enemies")

func verify_has_enemies(count: int) -> bool:
	return assert_eq(_level.enemy_world.enemies.size(), count, "Expected %d enemies" % count)

func wait_for_spawns(expected_count: int, timeout: float = 5.0) -> bool:
	var start_time = Time.get_ticks_msec() / 1000.0
	var last_count = 0
	while _level.enemy_world.enemies.size() < expected_count:
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - start_time > timeout:
			push_error("Timeout waiting for spawns: got %d, expected %d" % [_level.enemy_world.enemies.size(), expected_count])
			return false
		_level._process(0.1)
		await get_tree().process_frame
	return true
