extends BrotatoTest

var _bullet_world: BulletWorld
var _enemy_world: EnemyWorld
var _player: Node2D

func before_each():
	_bullet_world = BulletWorld.new()
	_enemy_world = EnemyWorld.new()
	_player = Node2D.new()
	_player.global_position = Vector2(500, 500)
	_enemy_world.set_player(_player)
	_bullet_world.set_enemy_world(_enemy_world)

func after_each():
	if _bullet_world != null:
		_bullet_world.queue_free()
	if _enemy_world != null:
		_enemy_world.queue_free()
	if _player != null:
		_player.queue_free()

func test_bullets_array_initialized():
	assert_eq(_bullet_world.bullets.size(), 0)

func test_add_bullet_increments_count():
	var bullet := BulletData.new()
	bullet.position = Vector2(100, 100)
	_bullet_world.add_bullet(bullet)
	assert_eq(_bullet_world.bullets.size(), 1)

func test_process_moves_bullets():
	var bullet := BulletData.new()
	bullet.position = Vector2(100, 100)
	bullet.velocity = Vector2(500, 0)
	bullet.speed = 500.0
	_bullet_world.add_bullet(bullet)
	var old_pos := bullet.position
	_bullet_world._process(0.1)
	assert_ne(bullet.position, old_pos)

func test_bullet_collision_with_enemy():
	var bullet := BulletData.new()
	bullet.position = Vector2(500, 500)
	bullet.velocity = Vector2(500, 0)
	bullet.speed = 500.0
	bullet.damage = 10.0
	_bullet_world.add_bullet(bullet)
	
	var enemy := EnemyData.new()
	enemy.position = Vector2(500, 500)
	enemy.health = 30.0
	_enemy_world.add_enemy(enemy)
	
	_bullet_world._process(0.016)
	assert_lt(enemy.health, 30.0)

func test_linear_trajectory():
	var bullet := BulletData.new()
	bullet.position = Vector2(0, 0)
	bullet.velocity = Vector2(1, 0).normalized() * 500
	bullet.speed = 500.0
	bullet.trajectory_type = BulletData.TrajectoryType.LINEAR
	_bullet_world.add_bullet(bullet)
	_bullet_world._process(0.016)
	assert_true(bullet.velocity.length() > 0)

func test_bullet_destroy_collision():
	var bullet := BulletData.new()
	bullet.position = Vector2(500, 500)
	bullet.velocity = Vector2(500, 0)
	bullet.speed = 500.0
	bullet.collision_type = BulletData.CollisionType.DESTROY
	bullet.damage = 10.0
	_bullet_world.add_bullet(bullet)
	
	var enemy := EnemyData.new()
	enemy.position = Vector2(500, 500)
	enemy.health = 30.0
	_enemy_world.add_enemy(enemy)
	
	_bullet_world._process(0.016)
	assert_false(bullet.alive)

func test_clear_removes_all_bullets():
	var bullet := BulletData.new()
	bullet.position = Vector2(100, 100)
	_bullet_world.add_bullet(bullet)
	_bullet_world.clear()
	assert_eq(_bullet_world.bullets.size(), 0)
