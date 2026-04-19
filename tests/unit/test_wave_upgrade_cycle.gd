extends BrotatoTest

var _level: Level
var _enemy_world: EnemyWorld

func before_each():
	super.before_each()
	_level = Level.new()
	add_child(_level)
	_enemy_world = _level.enemy_world

func after_each():
	if _level != null:
		_level.queue_free()
		_level = null
	super.after_each()

func test_wave_starts_at_one():
	assert_eq(_level.current_wave, 1)

func test_initial_wave_has_eight_enemies():
	assert_eq(_level.enemies_per_wave, 8)

func test_start_next_wave_increments_wave_number():
	var initial_wave: int = _level.current_wave
	_level.start_next_wave()
	assert_eq(_level.current_wave, initial_wave + 1)

func test_start_next_wave_increases_enemy_count():
	var initial_count: int = _level.enemies_per_wave
	_level.start_next_wave()
	assert_gt(_level.enemies_per_wave, initial_count)

func test_start_next_wave_resets_enemies_remaining():
	_level.enemies_remaining = 0
	_level.start_next_wave()
	assert_eq(_level.enemies_remaining, _level.enemies_per_wave)

func test_spawn_remaining_equals_enemies_per_wave_after_wave_start():
	_level.start_next_wave()
	assert_eq(_level.spawn_remaining, _level.enemies_per_wave)

func test_upgrade_applies_to_weapon_damage():
	var initial_damage: float = _level.weapon.get_total_damage()
	var upgrade := {"name": "Test", "damage": 0.5, "fire_rate": 0.0, "bullet_speed": 0.0}
	_level.upgrade_manager.apply_upgrade(upgrade)
	var new_damage: float = _level.weapon.get_total_damage()
	assert_gt(new_damage, initial_damage)

func test_upgrade_applies_to_weapon_fire_rate():
	var initial_fire_rate: float = _level.weapon.get_total_fire_rate()
	var upgrade := {"name": "Test", "damage": 0.0, "fire_rate": 0.5, "bullet_speed": 0.0}
	_level.upgrade_manager.apply_upgrade(upgrade)
	var new_fire_rate: float = _level.weapon.get_total_fire_rate()
	assert_gt(new_fire_rate, initial_fire_rate)

func test_multiple_upgrades_stack():
	var initial_damage: float = _level.weapon.get_total_damage()
	var upgrade1 := {"name": "Test1", "damage": 0.5, "fire_rate": 0.0, "bullet_speed": 0.0}
	var upgrade2 := {"name": "Test2", "damage": 0.5, "fire_rate": 0.0, "bullet_speed": 0.0}
	_level.upgrade_manager.apply_upgrade(upgrade1)
	_level.upgrade_manager.apply_upgrade(upgrade2)
	var final_damage: float = _level.weapon.get_total_damage()
	assert_gt(final_damage, initial_damage + 0.5)
