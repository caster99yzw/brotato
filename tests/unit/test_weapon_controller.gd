extends BrotatoTest

var _controller: WeaponController
var _fake_timer: FakeTimer
var _bullet_world: BulletWorld

func before_each():
	_bullet_world = BulletWorld.new()
	_controller = WeaponController.new()
	_controller.player = PlayerController.new()
	_controller.bullet_world = _bullet_world
	_fake_timer = FakeTimer.new()
	_controller.fake_timer = _fake_timer
	_controller._ready()

func after_each():
	if _controller != null:
		_controller.queue_free()
	if _bullet_world != null:
		_bullet_world.queue_free()

func test_fire_rate_defaults_to_three():
	assert_eq(_controller.fire_rate, 3.0, "fire_rate should default to 3.0")

func test_bullet_speed_defaults_to_five_hundred():
	assert_eq(_controller.bullet_speed, 500.0, "bullet_speed should default to 500.0")

func test_damage_defaults_to_ten():
	assert_eq(_controller.damage, 10.0, "damage should default to 10.0")

func test_shoot_disables_can_shoot():
	_controller.shoot()
	assert_false(_controller.can_shoot, "can_shoot should be false after shooting")

func test_shoot_adds_bullet_to_world():
	_controller.player.set_aim_direction(Vector2.RIGHT)
	_controller.shoot()
	assert_eq(_bullet_world.bullets.size(), 1, "should have one bullet in world")

func test_timeout_re_enables_can_shoot():
	_controller.shoot()
	assert_false(_controller.can_shoot)
	_fake_timer.trigger_timeout()
	assert_true(_controller.can_shoot, "can_shoot should be true after timeout")

func test_shoot_twice_adds_two_bullets():
	_controller.player.set_aim_direction(Vector2.RIGHT)
	_controller.shoot()
	_fake_timer.trigger_timeout()
	_controller.player.set_aim_direction(Vector2.UP)
	_controller.shoot()
	assert_eq(_bullet_world.bullets.size(), 2, "should have two bullets in world")
