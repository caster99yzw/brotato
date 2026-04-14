extends BrotatoTest

var _enemy: EnemyData

func before_each():
	_enemy = EnemyData.new()

func after_each():
	_enemy = null

func test_enemy_initial_values():
	assert_eq(_enemy.position, Vector2.ZERO)
	assert_eq(_enemy.velocity, Vector2.ZERO)
	assert_eq(_enemy.speed, 80.0)
	assert_eq(_enemy.health, 30.0)
	assert_eq(_enemy.max_health, 30.0)
	assert_eq(_enemy.damage, 10.0)
	assert_true(_enemy.alive)
	assert_null(_enemy.target)
	assert_eq(_enemy.lifetime, 0.0)
	assert_eq(_enemy.max_lifetime, 60.0)

func test_enemy_health_can_be_modified():
	_enemy.health = 50.0
	assert_eq(_enemy.health, 50.0)

func test_enemy_alive_flag_can_be_set_manually():
	_enemy.alive = false
	assert_false(_enemy.alive)

func test_enemy_position_can_be_set():
	_enemy.position = Vector2(100, 200)
	assert_eq(_enemy.position, Vector2(100, 200))

func test_enemy_velocity_can_be_set():
	_enemy.velocity = Vector2(50, 50)
	assert_eq(_enemy.velocity, Vector2(50, 50))

func test_enemy_max_health_can_be_set():
	_enemy.max_health = 100.0
	assert_eq(_enemy.max_health, 100.0)

func test_enemy_damage_value():
	_enemy.damage = 20.0
	assert_eq(_enemy.damage, 20.0)

func test_enemy_lifetime_accumulates():
	_enemy.lifetime = 5.0
	assert_eq(_enemy.lifetime, 5.0)

func test_enemy_max_lifetime():
	_enemy.max_lifetime = 120.0
	assert_eq(_enemy.max_lifetime, 120.0)

func test_enemy_target_can_be_set():
	var target := Node2D.new()
	target.global_position = Vector2(100, 100)
	_enemy.target = target
	assert_not_null(_enemy.target)
	target.queue_free()
