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

func test_level_initializes_with_player():
	assert_not_null(_level.player)

func test_level_initializes_with_enemy_world():
	assert_not_null(_level.enemy_world)

func test_level_initializes_with_weapon():
	assert_not_null(_level.weapon)
	assert_gt(_level.weapon.equipped_weapons.size(), 0)

func test_level_initializes_with_upgrade_manager():
	assert_not_null(_level.upgrade_manager)

func test_level_initializes_with_bullet_world():
	assert_not_null(_level.bullet_world)

func test_weapon_fire_creates_bullet():
	_level.weapon.player.set_aim_direction(Vector2.RIGHT)
	var initial_bullet_count: int = _level.bullet_world.bullets.size()
	_level.weapon.shoot()
	assert_gt(_level.bullet_world.bullets.size(), initial_bullet_count)

func test_wave_start_spawns_enemies():
	_level.enemies_per_wave = 5
	_level.spawn_interval = 0.01
	_level.enemies_remaining = 5
	_level.start_wave(1, 5)

	for i in 20:
		_level._process(0.1)

	assert_gt(_level.enemy_world.enemies.size(), 0)

func test_wave_starts_at_correct_wave_number():
	_level.start_wave(1, 5)
	assert_eq(_level.current_wave, 1)

func test_start_next_wave_resets_spawn_remaining():
	_level.start_next_wave()
	assert_eq(_level.spawn_remaining, _level.enemies_per_wave)

func test_start_next_wave_resets_enemies_remaining():
	_level.start_next_wave()
	assert_eq(_level.enemies_remaining, _level.enemies_per_wave)

func test_enemy_kill_decrements_enemies_remaining():
	_level.current_wave = 1
	_level.enemies_per_wave = 3
	_level.enemies_remaining = 3
	spawn_enemies(3)

	_level._on_enemy_killed(1)

	assert_eq(_level.enemies_remaining, 2)

func spawn_enemies(count: int) -> void:
	for i in count:
		var enemy := EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		_level.enemy_world.add_enemy(enemy)
