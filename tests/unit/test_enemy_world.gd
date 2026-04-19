extends BrotatoTest

var _enemy_world: EnemyWorld
var _player: Node2D

func before_each():
	_enemy_world = EnemyWorld.new()
	add_child(_enemy_world)
	_player = Node2D.new()
	add_child(_player)
	_player.global_position = Vector2(500, 500)
	_enemy_world.set_player(_player)

func after_each():
	if _enemy_world != null:
		_enemy_world.queue_free()
	if _player != null:
		_player.queue_free()

func test_enemies_array_initialized():
	assert_eq(_enemy_world.enemies.size(), 0)

func test_add_enemy_increments_count():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	_enemy_world.add_enemy(enemy)
	assert_eq(_enemy_world.enemies.size(), 1)

func test_add_enemy_sets_target():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	_enemy_world.add_enemy(enemy)
	assert_not_null(enemy.target)

func test_grid_starts_empty():
	var nearby := _enemy_world.find_enemies_near(Vector2(500, 500), 200)
	assert_eq(nearby.size(), 0)

func test_find_enemies_near_returns_added_enemy():
	var enemy := EnemyData.new()
	enemy.position = Vector2(500, 500)
	_enemy_world.add_enemy(enemy)
	var nearby := _enemy_world.find_enemies_near(Vector2(500, 500), 200)
	assert_eq(nearby.size(), 1)

func test_find_enemies_near_respects_radius():
	var enemy := EnemyData.new()
	enemy.position = Vector2(500, 500)
	_enemy_world.add_enemy(enemy)
	var nearby := _enemy_world.find_enemies_near(Vector2(1000, 1000), 50)
	assert_eq(nearby.size(), 0)

func test_kill_system_removes_dead_enemies():
	var enemy := EnemyData.new()
	enemy.position = Vector2(500, 500)
	enemy.health = 0.0
	_enemy_world.enemies.append(enemy)
	_enemy_world.enemies = _enemy_world.kill_system(_enemy_world.enemies)
	assert_eq(_enemy_world.enemies.size(), 0)

func test_process_moves_enemies():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	enemy.speed = 100.0
	_enemy_world.add_enemy(enemy)
	var old_pos := enemy.position
	_enemy_world._process(0.1)
	assert_ne(enemy.position, old_pos)

func test_get_active_enemy_count():
	var enemy1 := EnemyData.new()
	var enemy2 := EnemyData.new()
	enemy1.position = Vector2(100, 100)
	enemy2.position = Vector2(200, 200)
	_enemy_world.add_enemy(enemy1)
	_enemy_world.add_enemy(enemy2)
	assert_eq(_enemy_world.get_active_enemy_count(), 2)

func test_enemy_with_health_at_zero_is_killed():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	enemy.health = 0.0
	_enemy_world.enemies.append(enemy)
	_enemy_world.enemies = _enemy_world.kill_system(_enemy_world.enemies)
	assert_eq(_enemy_world.enemies.size(), 0)

func test_multiple_enemies_near_position():
	for i in range(5):
		var enemy := EnemyData.new()
		enemy.position = Vector2(500 + i * 10, 500)
		_enemy_world.add_enemy(enemy)
	var nearby := _enemy_world.find_enemies_near(Vector2(500, 500), 100)
	assert_eq(nearby.size(), 5)

func test_grid_rebuild_after_process():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	enemy.speed = 100.0
	_enemy_world.add_enemy(enemy)
	_enemy_world._process(1.0)
	var nearby := _enemy_world.find_enemies_near(enemy.position, 200)
	assert_eq(nearby.size(), 1)

func test_add_enemy_emits_spawned_signal():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	var before_count := _enemy_world.enemies.size()
	watch_signal(_enemy_world, "enemy_spawned")
	_enemy_world.add_enemy(enemy)
	assert_signal_emitted(_enemy_world, "enemy_spawned", 1, "add_enemy should emit enemy_spawned")
	assert_eq(_enemy_world.enemies.size(), before_count + 1)

func test_find_enemies_near_empty_grid():
	var nearby := _enemy_world.find_enemies_near(Vector2(0, 0), 100)
	assert_eq(nearby.size(), 0)

func test_find_enemies_at_cell_boundary():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	_enemy_world.add_enemy(enemy)
	var nearby := _enemy_world.find_enemies_near(Vector2(100, 100), 1)
	assert_eq(nearby.size(), 1)

func test_enemy_moves_across_cells():
	var enemy := EnemyData.new()
	enemy.position = Vector2(50, 50)
	enemy.speed = 500.0
	_enemy_world.add_enemy(enemy)
	var old_nearby := _enemy_world.find_enemies_near(Vector2(50, 50), 200)
	assert_eq(old_nearby.size(), 1)
	_enemy_world._process(1.0)
	var new_nearby := _enemy_world.find_enemies_near(enemy.position, 200)
	assert_eq(new_nearby.size(), 1)

func test_find_enemies_in_different_cells():
	var enemy1 := EnemyData.new()
	enemy1.position = Vector2(50, 50)
	var enemy2 := EnemyData.new()
	enemy2.position = Vector2(150, 150)
	_enemy_world.add_enemy(enemy1)
	_enemy_world.add_enemy(enemy2)
	var near_first := _enemy_world.find_enemies_near(Vector2(50, 50), 10)
	var near_second := _enemy_world.find_enemies_near(Vector2(150, 150), 10)
	assert_eq(near_first.size(), 1)
	assert_eq(near_second.size(), 1)

func test_kill_system_removes_multiple_dead_enemies():
	var enemy1 := EnemyData.new()
	enemy1.position = Vector2(100, 100)
	enemy1.health = 0.0
	var enemy2 := EnemyData.new()
	enemy2.position = Vector2(200, 200)
	enemy2.health = 0.0
	var enemy3 := EnemyData.new()
	enemy3.position = Vector2(300, 300)
	enemy3.health = 10.0
	_enemy_world.enemies.append(enemy1)
	_enemy_world.enemies.append(enemy2)
	_enemy_world.enemies.append(enemy3)
	_enemy_world.enemies = _enemy_world.kill_system(_enemy_world.enemies)
	assert_eq(_enemy_world.enemies.size(), 1)

func test_kill_system_with_mixed_health():
	var enemy_healthy := EnemyData.new()
	enemy_healthy.position = Vector2(100, 100)
	enemy_healthy.health = 10.0
	var enemy_dead := EnemyData.new()
	enemy_dead.position = Vector2(200, 200)
	enemy_dead.health = 0.0
	var enemy_also_healthy := EnemyData.new()
	enemy_also_healthy.position = Vector2(300, 300)
	enemy_also_healthy.health = 5.0
	_enemy_world.enemies.append(enemy_healthy)
	_enemy_world.enemies.append(enemy_dead)
	_enemy_world.enemies.append(enemy_also_healthy)
	_enemy_world.enemies = _enemy_world.kill_system(_enemy_world.enemies)
	assert_eq(_enemy_world.enemies.size(), 2, "2 healthy enemies should remain")

func test_kill_all_clears_all_enemies():
	for i in range(5):
		var enemy := EnemyData.new()
		enemy.position = Vector2(100 + i * 50, 100)
		_enemy_world.add_enemy(enemy)
	assert_eq(_enemy_world.enemies.size(), 5)
	_enemy_world.kill_all()
	for enemy in _enemy_world.enemies:
		assert_eq(enemy.health, 0.0, "all enemies should be dead")

func test_kill_all_sets_health_to_zero():
	var enemies_refs: Array[EnemyData] = []
	for i in range(3):
		var enemy := EnemyData.new()
		enemy.position = Vector2(100 + i * 50, 100)
		enemy.health = 100.0
		_enemy_world.add_enemy(enemy)
		enemies_refs.append(enemy)
	_enemy_world.kill_all()
	for enemy in enemies_refs:
		assert_eq(enemy.health, 0.0, "each enemy should have health=0 after kill_all")

func test_kill_system_does_not_remove_alive_enemies():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	enemy.health = 50.0
	_enemy_world.enemies.append(enemy)
	_enemy_world.enemies = _enemy_world.kill_system(_enemy_world.enemies)
	assert_eq(_enemy_world.enemies.size(), 1, "alive enemy should remain")

func test_kill_system_emits_once_with_total_count():
	var enemy1 := EnemyData.new()
	enemy1.position = Vector2(100, 100)
	enemy1.health = 0.0
	var enemy2 := EnemyData.new()
	enemy2.position = Vector2(200, 200)
	enemy2.health = 0.0
	var enemy3 := EnemyData.new()
	enemy3.position = Vector2(300, 300)
	enemy3.health = 10.0
	_enemy_world.enemies.append(enemy1)
	_enemy_world.enemies.append(enemy2)
	_enemy_world.enemies.append(enemy3)

	watch_signal(_enemy_world, "enemy_killed")
	_enemy_world.enemies = _enemy_world.kill_system(_enemy_world.enemies)

	assert_signal_emitted(_enemy_world, "enemy_killed", 1, "should emit signal once with total kill count")
	assert_eq(_enemy_world.enemies.size(), 1, "should have 1 alive enemy")

func test_kill_system_emits_kill_count():
	var enemy1 := EnemyData.new()
	enemy1.position = Vector2(100, 100)
	enemy1.health = 0.0
	var enemy2 := EnemyData.new()
	enemy2.position = Vector2(200, 200)
	enemy2.health = 0.0
	_enemy_world.enemies.append(enemy1)
	_enemy_world.enemies.append(enemy2)

	watch_signal(_enemy_world, "enemy_killed")
	_enemy_world.enemies = _enemy_world.kill_system(_enemy_world.enemies)

	assert_signal_emitted(_enemy_world, "enemy_killed", 1, "should emit once with count=2")
	assert_eq(_enemy_world.enemies.size(), 0, "no enemies should remain")

func test_kill_all_emits_no_signal():
	for i in range(5):
		var enemy := EnemyData.new()
		enemy.position = Vector2(100 + i * 50, 100)
		_enemy_world.add_enemy(enemy)

	watch_signal(_enemy_world, "enemy_killed")
	_enemy_world.kill_all()

	assert_signal_not_emitted(_enemy_world, "enemy_killed", "kill_all should NOT emit signals - it's a cleanup operation")
	for enemy in _enemy_world.enemies:
		assert_eq(enemy.health, 0.0, "all enemies should be dead")
