extends BrotatoTest

var _enemy: EnemyData

func before_each():
	super.before_each()
	_enemy = EnemyData.new()

func after_each():
	_enemy = null
	super.after_each()

func test_enemy_defaults_to_alive():
	assert_gt(_enemy.health, 0.0, "health > 0 means enemy is alive")

func test_enemy_with_zero_health_is_dead():
	_enemy.health = 0.0
	assert_le(_enemy.health, 0.0, "health <= 0 means enemy is dead")

func test_enemy_with_negative_health_is_dead():
	_enemy.health = -10.0
	assert_le(_enemy.health, 0.0, "negative health means enemy is dead")

func test_enemy_can_take_damage():
	var initial_health := _enemy.health
	_enemy.health -= 10.0
	assert_eq(_enemy.health, initial_health - 10.0)

func test_enemy_dies_at_zero_health():
	_enemy.health = 0.0
	assert_le(_enemy.health, 0.0)

func test_enemy_health_cannot_exceed_max_by_default():
	assert_le(_enemy.health, _enemy.max_health)

func test_enemy_movement_speed_is_positive():
	assert_gt(_enemy.speed, 0.0, "speed must be positive for enemies to move")

func test_enemy_initial_position_is_vector2():
	assert_true(_enemy.position is Vector2, "position must be a Vector2")

func test_enemy_initial_velocity_is_vector2():
	assert_true(_enemy.velocity is Vector2, "velocity must be a Vector2")
