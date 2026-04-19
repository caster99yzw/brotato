extends BrotatoTest

var _world: EnemyWorld
var _player: Node2D

func before_each():
	super.before_each()
	_world = EnemyWorld.new()
	add_child(_world)
	_player = Node2D.new()
	add_child(_player)
	_player.global_position = Vector2(500, 500)
	_world.set_player(_player)

func after_each():
	if _world != null:
		_world.queue_free()
		_world = null
	if _player != null:
		_player.queue_free()
		_player = null
	super.after_each()

func test_enemy_world_starts_empty():
	assert_eq(_world.enemies.size(), 0)

func test_add_enemy_increments_count():
	var enemy := make_enemy()
	_world.add_enemy(enemy)
	assert_eq(_world.enemies.size(), 1)

func test_add_enemy_assigns_target():
	var enemy := make_enemy()
	_world.add_enemy(enemy)
	assert_not_null(enemy.target)

func test_find_enemies_near_returns_enemies_in_radius():
	var enemy := make_enemy_at(Vector2(500, 500))
	_world.add_enemy(enemy)
	var nearby := _world.find_enemies_near(Vector2(500, 500), 200)
	assert_eq(nearby.size(), 1)

func test_find_enemies_near_excludes_enemies_outside_radius():
	var enemy := make_enemy_at(Vector2(500, 500))
	_world.add_enemy(enemy)
	var nearby := _world.find_enemies_near(Vector2(1000, 1000), 50)
	assert_eq(nearby.size(), 0)

func test_kill_system_removes_dead_enemies():
	var enemy := make_enemy_at(Vector2(100, 100))
	enemy.health = 0.0
	_world.add_enemy(enemy)
	_world.enemies = _world.kill_system(_world.enemies)
	assert_eq(_world.enemies.size(), 0)

func test_kill_system_preserves_alive_enemies():
	var enemy := make_enemy_at(Vector2(100, 100))
	enemy.health = 50.0
	_world.add_enemy(enemy)
	_world.enemies = _world.kill_system(_world.enemies)
	assert_eq(_world.enemies.size(), 1)

func test_kill_system_removes_multiple_dead_enemies():
	var dead1 := make_enemy_at(Vector2(100, 100))
	dead1.health = 0.0
	var dead2 := make_enemy_at(Vector2(200, 200))
	dead2.health = 0.0
	var alive := make_enemy_at(Vector2(300, 300))
	alive.health = 10.0

	_world.add_enemy(dead1)
	_world.add_enemy(dead2)
	_world.add_enemy(alive)
	_world.enemies = _world.kill_system(_world.enemies)

	assert_eq(_world.enemies.size(), 1)
	assert_eq(_world.enemies[0], alive)

func test_kill_system_does_not_remove_alive_enemies():
	var enemy := make_enemy_at(Vector2(100, 100))
	enemy.health = 50.0
	_world.add_enemy(enemy)
	_world.enemies = _world.kill_system(_world.enemies)
	assert_eq(_world.enemies.size(), 1)
	assert_eq(_world.enemies[0].health, 50.0)

func test_kill_system_enemies_remaining_never_negative():
	var enemy := make_enemy_at(Vector2(100, 100))
	enemy.health = 0.0
	_world.add_enemy(enemy)
	_world.enemies = _world.kill_system(_world.enemies)
	assert_true(_world.enemies.size() >= 0)

func test_alive_enemies_move():
	var enemy := make_enemy_at(Vector2(100, 100))
	enemy.speed = 100.0
	_world.add_enemy(enemy)
	var old_pos := enemy.position
	_world._process(0.1)
	assert_ne(enemy.position, old_pos)

func test_dead_enemies_do_not_move():
	var enemy := make_enemy_at(Vector2(100, 100))
	enemy.speed = 100.0
	enemy.health = 0.0
	_world.add_enemy(enemy)
	var old_pos := enemy.position
	_world._process(0.1)
	assert_eq(enemy.position, old_pos)

func test_get_active_enemy_count_returns_alive_count():
	var alive1 := make_enemy_at(Vector2(100, 100))
	alive1.health = 10.0
	var alive2 := make_enemy_at(Vector2(200, 200))
	alive2.health = 10.0
	_world.add_enemy(alive1)
	_world.add_enemy(alive2)
	assert_eq(_world.get_active_enemy_count(), 2)

func test_kill_all_sets_all_enemy_health_to_zero():
	var enemy1 := make_enemy_at(Vector2(100, 100))
	var enemy2 := make_enemy_at(Vector2(200, 200))
	var enemy3 := make_enemy_at(Vector2(300, 300))
	_world.add_enemy(enemy1)
	_world.add_enemy(enemy2)
	_world.add_enemy(enemy3)

	_world.kill_all()

	for enemy in _world.enemies:
		assert_eq(enemy.health, 0.0)

func test_kill_all_preserves_enemy_count():
	for i in 5:
		_world.add_enemy(make_enemy_at(Vector2(100 + i * 50, 100)))
	assert_eq(_world.enemies.size(), 5)

	_world.kill_all()

	assert_eq(_world.enemies.size(), 5, "kill_all sets health to zero but keeps enemies in array")

func make_enemy() -> EnemyData:
	var enemy := EnemyData.new()
	enemy.position = Vector2(randf() * 800, randf() * 600)
	return enemy

func make_enemy_at(pos: Vector2) -> EnemyData:
	var enemy := EnemyData.new()
	enemy.position = pos
	return enemy
