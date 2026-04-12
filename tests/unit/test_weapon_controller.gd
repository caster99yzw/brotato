extends BrotatoTest

var _controller: Node

func before_each():
	_controller = WeaponController.new()
	_controller.player = PlayerController.new()
	_controller.bullet_scene = null

func after_each():
	if _controller != null:
		_controller.queue_free()

func test_fire_rate_defaults_to_three():
	assert_eq(_controller.fire_rate, 3.0, "fire_rate should default to 3.0")

func test_bullet_speed_defaults_to_five_hundred():
	assert_eq(_controller.bullet_speed, 500.0, "bullet_speed should default to 500.0")

func test_damage_defaults_to_ten():
	assert_eq(_controller.damage, 10.0, "damage should default to 10.0")
