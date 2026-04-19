extends BrotatoTest

var _level: Level

func before_each():
	_level = Level.new()
	add_child(_level)

func after_each():
	if _level != null:
		_level.queue_free()

func test_level_weapon_equipped_after_ready():
	assert_gt(_level.weapon.equipped_weapons.size(), 0, "weapon should be equipped")

func test_level_has_enemy_world():
	assert_true(_level.enemy_world != null, "enemy_world should exist")

func test_level_has_upgrade_manager():
	assert_true(_level.upgrade_manager != null, "upgrade_manager should exist")

func test_level_has_bullet_world():
	assert_true(_level.bullet_world != null, "bullet_world should exist")

func test_level_weapon_can_fire():
	_level.weapon.player.set_aim_direction(Vector2.RIGHT)
	_level.weapon.shoot()
	assert_gt(_level.bullet_world.bullets.size(), 0, "bullet should be created")

func test_level_spawns_enemies_on_wave_start():
	_level.enemies_per_wave = 5
	_level.spawn_interval = 0.01
	_level.enemies_remaining = 5
	watch_signal(_level, "wave_started")
	_level.start_wave(1, 5)
	for i in 20:
		_level._process(0.1)
	assert_gt(_level.enemy_world.enemies.size(), 0, "enemies should spawn")
	assert_signal_emitted(_level, "wave_started", 1, "wave_started should be emitted")

func test_level_wave_completes_when_all_enemies_killed():
	_level.enemies_per_wave = 3
	_level.enemies_remaining = 3
	_level.current_wave = 1
	_level.start_wave(1, 3)

	for i in 3:
		var enemy = EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		enemy.health = 30.0
		_level.enemy_world.add_enemy(enemy)

	for enemy in _level.enemy_world.enemies:
		enemy.health = 0
		_level.enemy_world.enemy_killed.emit(1)

	assert_eq(_level.enemies_remaining, 0, "all enemies should be tracked as killed")
