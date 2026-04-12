extends BrotatoTest

var _player: Node
var _fake_input: FakeInput

func before_each():
	_player = PlayerController.new()
	_fake_input = FakeInput.new()
	_player.input = _fake_input

func after_each():
	if _player != null:
		_player.queue_free()

func test_aim_direction(data = use_parameters([
	["aim RIGHT", Vector2.RIGHT],
	["aim DOWN", Vector2.DOWN],
	["aim LEFT", Vector2.LEFT],
	["aim UP", Vector2.UP]
])):
	var name: String = data[0]
	var expected: Vector2 = data[1]
	_player.set_aim_direction(expected)
	assert_eq(_player.aim_direction, expected, name)

func test_given_no_input_when_physics_process_then_velocity_is_zero():
	_player._physics_process(0.016)
	assert_eq(_player.velocity, Vector2.ZERO, "No input should result in zero velocity")

func test_given_w_key_pressed_when_physics_process_then_velocity_y_is_negative():
	_fake_input.press_key(KEY_W)
	_player._physics_process(0.016)
	assert_lt(_player.velocity.y, 0, "W key should result in negative Y velocity")

func test_given_s_key_pressed_when_physics_process_then_velocity_y_is_positive():
	_fake_input.press_key(KEY_S)
	_player._physics_process(0.016)
	assert_gt(_player.velocity.y, 0, "S key should result in positive Y velocity")

func test_given_w_and_d_pressed_when_physics_process_then_diagonal_velocity():
	_fake_input.press_key(KEY_W)
	_fake_input.press_key(KEY_D)
	_player._physics_process(0.016)
	var expected_speed = _player.speed
	var actual_speed = _player.velocity.length()
	assert_eq(actual_speed, expected_speed, "Diagonal movement should be normalized to speed")

func test_given_a_and_s_pressed_when_physics_process_then_diagonal_velocity():
	_fake_input.press_key(KEY_A)
	_fake_input.press_key(KEY_S)
	_player._physics_process(0.016)
	var expected_speed = _player.speed
	var actual_speed = _player.velocity.length()
	assert_eq(actual_speed, expected_speed, "Diagonal movement should be normalized to speed")

func test_set_aim_direction_updates_rotation():
	_player.set_aim_direction(Vector2.LEFT)
	assert_eq(_player.rotation, Vector2.LEFT.angle(), "rotation should match aim direction angle")

func test_set_aim_direction_zero_does_not_update_rotation():
	var initial_rotation = _player.rotation
	_player.set_aim_direction(Vector2.ZERO)
	assert_eq(_player.rotation, initial_rotation, "rotation should not change when aim is zero")
