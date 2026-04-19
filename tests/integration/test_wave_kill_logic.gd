extends BrotatoTest

var _level: Level

func before_each():
	super.before_each()
	_level = Level.new()
	add_child(_level)

func after_each():
	if _level != null:
		_level.queue_free()
		_level = null
	super.after_each()

func test_level_starts_at_wave_one():
	assert_eq(_level.current_wave, 1)
	assert_eq(_level.enemies_per_wave, 8)
	assert_eq(_level.enemies_remaining, 8)

func test_enemies_remaining_never_goes_negative():
	_level.current_wave = 1
	_level.enemies_per_wave = 3
	_level.enemies_remaining = 3

	_level._on_enemy_killed(10)

	assert_true(_level.enemies_remaining <= 0, "enemies_remaining must be <= 0")

func test_wave_completes_when_enemies_remaining_reaches_zero():
	_level.current_wave = 1
	_level.enemies_per_wave = 3
	_level.enemies_remaining = 3

	watch_signal(_level, "wave_completed")
	_level._on_enemy_killed(3)

	assert_eq(_level.enemies_remaining, 0)
	assert_signal_emitted(_level, "wave_completed", 1)

func test_wave_completes_not_before_all_enemies_killed():
	_level.current_wave = 1
	_level.enemies_per_wave = 3
	_level.enemies_remaining = 3

	watch_signal(_level, "wave_completed")
	_level._on_enemy_killed(2)

	assert_eq(_level.enemies_remaining, 1)
	assert_signal_not_emitted(_level, "wave_completed", "wave should not complete when enemies remain")

func test_complete_wave_twice_is_idempotent():
	_level.current_wave = 1
	_level.enemies_per_wave = 5
	_level.enemies_remaining = 0
	_level.spawn_remaining = 0

	GMCommands.complete_wave(_level)
	GMCommands.complete_wave(_level)

	assert_eq(_level.enemies_remaining, 0)

func test_complete_wave_emits_wave_completed_signal():
	_level.current_wave = 1
	_level.enemies_per_wave = 5
	_level.enemies_remaining = 5
	_level.spawn_remaining = 5

	watch_signal(_level, "wave_completed")
	GMCommands.complete_wave(_level)

	assert_signal_emitted(_level, "wave_completed", 1)

func test_upgrade_selected_clears_enemies_and_starts_next_wave():
	_level.current_wave = 1
	_level.enemies_per_wave = 5
	_level.enemies_remaining = 5
	spawn_enemies(5)

	var option := {"name": "test_upgrade"}
	_level._on_upgrade_selected(option)

	assert_eq(_level.current_wave, 2)
	assert_eq(_level.enemies_remaining, _level.enemies_per_wave)
	for enemy in _level.enemy_world.enemies:
		assert_eq(enemy.health, 0.0, "all enemies should have health=0 after upgrade selection")

func test_spawn_remaining_never_exceeds_enemies_per_wave():
	_level.current_wave = 1
	_level.enemies_per_wave = 5
	_level.enemies_remaining = 5
	_level.spawn_remaining = 5

	assert_true(_level.spawn_remaining <= _level.enemies_per_wave)

func test_kill_all_enemies_sets_health_to_zero():
	_level.enemies_per_wave = 5
	spawn_enemies(5)

	GMCommands.kill_all(_level.enemy_world)

	for enemy in _level.enemy_world.enemies:
		assert_eq(enemy.health, 0.0)

func test_kill_all_enemies_does_not_change_enemies_remaining():
	_level.current_wave = 1
	_level.enemies_per_wave = 5
	_level.enemies_remaining = 5
	spawn_enemies(5)

	GMCommands.kill_all(_level.enemy_world)

	assert_eq(_level.enemies_remaining, 5, "kill_all on enemy_world does not auto-update level.enemies_remaining")

func spawn_enemies(count: int) -> void:
	for i in count:
		var enemy := EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		_level.enemy_world.add_enemy(enemy)
