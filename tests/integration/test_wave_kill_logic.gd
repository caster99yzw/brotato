extends BrotatoTest

var _level: Level

func before_each():
	_level = Level.new()
	add_child(_level)

func after_each():
	if _level != null:
		_level.queue_free()

func test_wave_starts_with_correct_enemy_count():
	assert_eq(_level.current_wave, 1, "game should start at wave 1")
	assert_eq(_level.enemies_per_wave, 8, "wave 1 should have 8 enemies (5 + 1*3)")
	assert_eq(_level.enemies_remaining, 8, "remaining should equal enemies_per_wave")

func test_kill_enemy_decrements_remaining():
	_level.enemies_per_wave = 5
	_level.enemies_remaining = 5
	for i in 5:
		_level._process(0.1)

	_level.enemy_world.enemies[0].health = 0
	_level.enemy_world.enemy_killed.emit(1)
	assert_eq(_level.enemies_remaining, 4, "remaining should be 4 after one kill")

func test_wave_completes_when_remaining_reaches_zero():
	_level.current_wave = 1
	_level.enemies_per_wave = 3
	_level.enemies_remaining = 3

	watch_signal(_level, "wave_completed")

	_level._on_enemy_killed(1)
	assert_eq(_level.enemies_remaining, 2, "should be 2 after first kill")
	assert_signal_not_emitted(_level, "wave_completed", "wave should not complete at 2 remaining")

	_level._on_enemy_killed(1)
	assert_eq(_level.enemies_remaining, 1, "should be 1 after second kill")
	assert_signal_not_emitted(_level, "wave_completed", "wave should not complete at 1 remaining")

	_level._on_enemy_killed(1)
	assert_eq(_level.enemies_remaining, 0, "should be 0 after third kill")
	assert_signal_emitted(_level, "wave_completed", 1, "wave should complete at 0 remaining")

func test_kill_all_clears_enemies():
	_level.enemies_per_wave = 5
	for i in 5:
		var enemy := EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		_level.enemy_world.add_enemy(enemy)

	assert_eq(_level.enemy_world.enemies.size(), 5, "should have 5 enemies")
	GMCommands.kill_all(_level.enemy_world)
	for enemy in _level.enemy_world.enemies:
		assert_eq(enemy.health, 0.0, "all enemies should be dead after kill_all")

func test_level_on_enemy_killed_connects_to_upgrade_manager():
	_level.current_wave = 1
	_level.enemies_per_wave = 1
	_level.enemies_remaining = 1

	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	_level.enemy_world.add_enemy(enemy)

	watch_signal(_level, "wave_completed")

	enemy.health = 0
	_level.enemy_world.enemy_killed.emit(1)

	assert_signal_emitted(_level, "wave_completed", 1, "wave should complete after kill")
	assert_eq(_level.enemies_remaining, 0, "enemies_remaining should be 0")

func test_complete_wave_then_kill_all_should_not_spawn():
	_level.current_wave = 1
	_level.enemies_per_wave = 5
	_level.enemies_remaining = 0
	_level.spawn_interval = 0.1
	_level.spawn_timer_accum = 0.0

	watch_signal(_level, "wave_completed")
	GMCommands.complete_wave(_level)

	_level._process(0.5)

	assert_signal_not_emitted(_level, "wave_completed", "wave_completed should not emit again")

func test_on_upgrade_selected_starts_new_wave():
	_level.current_wave = 1
	_level.enemies_per_wave = 5
	_level.enemies_remaining = 0

	for i in 5:
		var enemy := EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		_level.enemy_world.add_enemy(enemy)

	watch_signal(_level, "wave_started")
	var option := {"Name": "test_upgrade"}
	_level._on_upgrade_selected(option)

	assert_eq(_level.current_wave, 2, "wave should advance to 2")
	assert_eq(_level.enemies_remaining, _level.enemies_per_wave, "enemies_remaining should reset for new wave")
	for enemy in _level.enemy_world.enemies:
		assert_eq(enemy.health, 0.0, "all enemies should be dead")

func test_wave_completed_pauses_spawn():
	_level.current_wave = 1
	_level.enemies_per_wave = 5
	_level.enemies_remaining = 0
	_level.spawn_interval = 0.1
	_level.spawn_timer_accum = 0.0

	watch_signal(_level, "wave_completed")
	_level._on_wave_completed(1)

	_level._process(0.5)

	assert_signal_not_emitted(_level, "wave_completed", "wave_completed should not emit again")
