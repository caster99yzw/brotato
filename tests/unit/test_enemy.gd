extends BrotatoTest

var _enemy: Node
var _target: Node

func before_each() -> void:
	_enemy = Enemy.new()
	_target = Node2D.new()

func after_each() -> void:
	if _enemy != null:
		_enemy.queue_free()
	if _target != null:
		_target.queue_free()

func test_given_target_left_when_physics_process_then_velocity_x_is_negative():
	_target.position = Vector2(-100, 0)
	_enemy.setup(_target)
	_enemy._physics_process(0.016)
	assert_lt(_enemy.velocity.x, 0, "Target left should result in negative X velocity")

func test_given_target_right_when_physics_process_then_velocity_x_is_positive():
	_target.position = Vector2(100, 0)
	_enemy.setup(_target)
	_enemy._physics_process(0.016)
	assert_gt(_enemy.velocity.x, 0, "Target right should result in positive X velocity")

func test_given_target_above_when_physics_process_then_velocity_y_is_negative():
	_target.position = Vector2(0, -100)
	_enemy.setup(_target)
	_enemy._physics_process(0.016)
	assert_lt(_enemy.velocity.y, 0, "Target above should result in negative Y velocity")

func test_given_target_below_when_physics_process_then_velocity_y_is_positive():
	_target.position = Vector2(0, 100)
	_enemy.setup(_target)
	_enemy._physics_process(0.016)
	assert_gt(_enemy.velocity.y, 0, "Target below should result in positive Y velocity")

func test_given_take_damage_when_health_reduces():
	_enemy.health = 30.0
	_enemy.take_damage(10.0)
	assert_eq(_enemy.health, 20.0, "Damage should reduce health by amount")

func test_given_take_damage_when_health_reaches_zero():
	_enemy.health = 10.0
	_enemy.take_damage(10.0)
	assert_le(_enemy.health, 0, "Health should be zero or negative after lethal damage")

func test_given_lethal_damage_then_enemy_is_queued_for_deletion():
	_enemy.health = 10.0
	_enemy.take_damage(10.0)
	assert_true(_enemy.is_queued_for_deletion(), "Enemy should be queued for deletion after lethal damage")

func test_speed_defaults_to_eighty():
	assert_eq(_enemy.speed, 80.0, "speed should default to 80.0")

func test_health_defaults_to_thirty():
	assert_eq(_enemy.health, 30.0, "health should default to 30.0")
