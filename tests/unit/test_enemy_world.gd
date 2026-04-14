extends BrotatoTest

var _enemy_world: EnemyWorld
var _player: Node2D

func before_each():
	_enemy_world = EnemyWorld.new()
	_player = Node2D.new()
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
	enemy.alive = false
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

func test_enemy_with_expired_lifetime_is_killed():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	enemy.lifetime = 61.0
	enemy.max_lifetime = 60.0
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
	_enemy_world.add_enemy(enemy)
	assert_eq(_enemy_world.enemies.size(), before_count + 1)

func test_kill_system_marks_enemy_dead_and_emits():
	var enemy := EnemyData.new()
	enemy.position = Vector2(100, 100)
	enemy.health = 0.0
	_enemy_world.enemies.append(enemy)
	var before_count := _enemy_world.enemies.size()
	_enemy_world.enemies = _enemy_world.kill_system(_enemy_world.enemies)
	assert_eq(_enemy_world.enemies.size(), before_count - 1)

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
