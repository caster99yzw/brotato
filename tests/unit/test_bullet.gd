extends BrotatoTest

var _bullet: Node

func before_each():
	_bullet = Bullet.new()

func after_each():
	if _bullet != null:
		_bullet.queue_free()

func test_setup_right_sets_velocity_to_positive_x():
	_bullet.setup(Vector2.RIGHT, 500, 10)
	assert_eq(_bullet.velocity, Vector2(500, 0), "RIGHT direction should set velocity.x to 500")

func test_setup_left_sets_velocity_to_negative_x():
	_bullet.setup(Vector2.LEFT, 500, 10)
	assert_eq(_bullet.velocity, Vector2(-500, 0), "LEFT direction should set velocity.x to -500")

func test_setup_up_sets_velocity_to_negative_y():
	_bullet.setup(Vector2.UP, 500, 10)
	assert_eq(_bullet.velocity, Vector2(0, -500), "UP direction should set velocity.y to -500")

func test_setup_down_sets_velocity_to_positive_y():
	_bullet.setup(Vector2.DOWN, 500, 10)
	assert_eq(_bullet.velocity, Vector2(0, 500), "DOWN direction should set velocity.y to 500")

func test_given_physics_process_then_position_changes():
	_bullet.setup(Vector2.RIGHT, 500, 10)
	var initial_pos = _bullet.position
	_bullet._physics_process(0.016)
	assert_ne(_bullet.position, initial_pos, "Position should change after physics process")

func test_setup_sets_damage_correctly():
	_bullet.setup(Vector2.RIGHT, 500, 25)
	assert_eq(_bullet.damage, 25.0, "damage should be set to 25")

func test_setup_sets_speed_correctly():
	_bullet.setup(Vector2.RIGHT, 750, 10)
	assert_eq(_bullet.speed, 750.0, "speed should be set to 750")

func test_setup_sets_rotation_based_on_direction():
	_bullet.setup(Vector2.UP, 500, 10)
	assert_eq(_bullet.rotation, Vector2.UP.angle(), "rotation should match UP direction angle")
