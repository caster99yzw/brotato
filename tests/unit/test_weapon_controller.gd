extends BrotatoTest

var _controller: WeaponController
var _fake_timer: FakeTimer
var _bullet_requested_count: int = 0
var _last_bullet_params: Array = []

func before_each():
	_controller = WeaponController.new()
	_controller.player = PlayerController.new()
	_fake_timer = FakeTimer.new()
	_controller.fake_timer = _fake_timer
	_bullet_requested_count = 0
	_last_bullet_params.clear()
	_controller.bullet_requested.connect(_on_bullet_requested)
	_controller._ready()

func after_each():
	if _controller != null:
		_controller.queue_free()

func _on_bullet_requested(direction: Vector2, speed: float, damage: float) -> void:
	_bullet_requested_count += 1
	_last_bullet_params = [direction, speed, damage]

func test_fire_rate_defaults_to_three():
	assert_eq(_controller.fire_rate, 3.0, "fire_rate should default to 3.0")

func test_bullet_speed_defaults_to_five_hundred():
	assert_eq(_controller.bullet_speed, 500.0, "bullet_speed should default to 500.0")

func test_damage_defaults_to_ten():
	assert_eq(_controller.damage, 10.0, "damage should default to 10.0")

func test_shoot_disables_can_shoot():
	_controller.shoot()
	assert_false(_controller.can_shoot, "can_shoot should be false after shooting")

func test_shoot_emits_bullet_requested():
	_controller.player.set_aim_direction(Vector2.RIGHT)
	_controller.shoot()
	assert_eq(_bullet_requested_count, 1, "bullet_requested should be emitted once")
	assert_eq(_last_bullet_params[0], Vector2.RIGHT, "direction should be RIGHT")
	assert_eq(_last_bullet_params[1], 500.0, "speed should be 500")
	assert_eq(_last_bullet_params[2], 10.0, "damage should be 10")

func test_timeout_re_enables_can_shoot():
	_controller.shoot()
	assert_false(_controller.can_shoot)
	_fake_timer.trigger_timeout()
	assert_true(_controller.can_shoot, "can_shoot should be true after timeout")

func test_shoot_twice_only_one_bullet_requested():
	_controller.player.set_aim_direction(Vector2.RIGHT)
	_controller.shoot()
	_fake_timer.trigger_timeout()
	_controller.player.set_aim_direction(Vector2.UP)
	_controller.shoot()
	assert_eq(_bullet_requested_count, 2, "should have two bullet requests")
