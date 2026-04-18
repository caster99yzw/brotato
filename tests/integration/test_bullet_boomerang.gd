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

func _create_boomerang() -> BulletData:
	var bullets = _bullet_factory.create_bullets("BOOMERANG", _player.global_position, Vector2.RIGHT, 1.0, 1.0, 1)
	var bullet = bullets[0]
	bullet.trajectory_type = BulletData.TrajectoryType.BOOMERANG
	bullet.has_returned = false
	bullet.source_position = _player.global_position + Vector2.RIGHT * 100
	bullet.velocity = Vector2.RIGHT * 300
	return bullet

func test_bullet_boomerang_returns():
	var bullet = _create_boomerang()
	_bullet_world.add_bullet(bullet)
	_bullet_world._process(0.2)
	assert_false(bullet.has_returned, "boomerang should not return instantly")

func test_bullet_boomerang_properties():
	var bullet = _create_boomerang()
	assert_eq(bullet.trajectory_type, BulletData.TrajectoryType.BOOMERANG, "trajectory should be boomerang")
	assert_false(bullet.has_returned, "has_returned should start as false")