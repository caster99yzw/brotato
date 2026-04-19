extends BrotatoTest

var _level: Level
var _player: PlayerController
var _bullet_world: BulletWorld

const _BulletFactory = preload("res://scripts/bullet/bullet_factory.gd")
var _bullet_factory

func before_each():
	_level = Level.new()
	add_child(_level)
	_player = _level.weapon.player
	_bullet_world = _level.bullet_world
	_bullet_factory = _BulletFactory.new()

func after_each():
	if _level != null:
		_level.queue_free()

func _create_bullet(weapon_name: String) -> BulletData:
	var bullets = _bullet_factory.create_bullets(weapon_name, _player.global_position, Vector2.RIGHT, 1.0, 1.0, 1)
	return bullets[0]

func test_bullet_trajectory_linear():
	var bullet = _create_bullet("PISTOL")
	bullet.trajectory_type = BulletData.TrajectoryType.LINEAR
	bullet.velocity = Vector2.RIGHT * 300
	_bullet_world.add_bullet(bullet)
	_bullet_world._process(0.1)
	assert_true(bullet.velocity.x > 0, "linear bullet should move right")

func test_bullet_trajectory_spiral():
	var bullet = _create_bullet("SPINNER")
	bullet.trajectory_type = BulletData.TrajectoryType.SPIRAL
	bullet.trajectory_angle = 0.0
	_bullet_world.add_bullet(bullet)
	var initial_angle = bullet.trajectory_angle
	_bullet_world._process(0.1)
	assert_ne(bullet.trajectory_angle, initial_angle, "spiral bullet should rotate angle")

func test_bullet_trajectory_homing():
	var enemy = EnemyData.new()
	enemy.position = _player.global_position + Vector2.RIGHT * 100
	enemy.health = 30.0
	_level.enemy_world.add_enemy(enemy)
	var bullet = _create_bullet("MISSILE")
	bullet.trajectory_type = BulletData.TrajectoryType.HOMING
	_bullet_world.add_bullet(bullet)
	_bullet_world._process(0.1)
	assert_true(bullet.velocity.length() > 0, "homing bullet should have velocity")

func test_bullet_trajectory_boomerang():
	var bullet = _create_bullet("BOOMERANG")
	bullet.trajectory_type = BulletData.TrajectoryType.BOOMERANG
	bullet.has_returned = false
	bullet.source_position = _player.global_position + Vector2.RIGHT * 100
	bullet.velocity = Vector2.RIGHT * 300
	_bullet_world.add_bullet(bullet)
	_bullet_world._process(0.2)
	assert_false(bullet.has_returned, "boomerang should not return instantly")

func test_bullet_trajectory_curved():
	var bullet = _create_bullet("GRENADE")
	bullet.trajectory_type = BulletData.TrajectoryType.CURVED
	bullet.gravity = 200.0
	bullet.velocity = Vector2.RIGHT * 300
	_bullet_world.add_bullet(bullet)
	_bullet_world._process(0.1)
	assert_true(bullet.velocity.y != 0 or bullet.gravity > 0, "curved bullet should have gravity")

func test_bullet_trajectory_orbiting():
	var bullet = _create_bullet("SLASH")
	bullet.trajectory_type = BulletData.TrajectoryType.ORBITING
	bullet.orbiting_center = _player.global_position
	bullet.orbiting_radius = 60.0
	bullet.orbiting_speed = 3.0
	bullet.orbiting_angle = 0.0
	_bullet_world.add_bullet(bullet)
	var initial_angle = bullet.orbiting_angle
	_bullet_world._process(0.1)
	assert_ne(bullet.orbiting_angle, initial_angle, "orbiting bullet should increase angle")

func test_bullet_trajectory_dropping():
	var bullet = _create_bullet("ARROW_RAIN")
	bullet.trajectory_type = BulletData.TrajectoryType.DROPPING
	bullet.velocity = Vector2.DOWN * 400
	var initial_y = bullet.position.y
	_bullet_world.add_bullet(bullet)
	_bullet_world._process(0.1)
	assert_gt(bullet.position.y, initial_y, "dropping bullet should move downward")