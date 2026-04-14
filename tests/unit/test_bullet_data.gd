extends BrotatoTest

var _bullet: BulletData

func before_each():
	_bullet = BulletData.new()

func after_each():
	_bullet = null

func test_bullet_initial_values():
	assert_eq(_bullet.position, Vector2.ZERO)
	assert_eq(_bullet.velocity, Vector2.ZERO)
	assert_eq(_bullet.speed, 500.0)
	assert_eq(_bullet.damage, 10.0)
	assert_true(_bullet.alive)
	assert_eq(_bullet.trajectory_type, BulletData.TrajectoryType.LINEAR)
	assert_eq(_bullet.trajectory_angle, 0.0)
	assert_eq(_bullet.collision_type, BulletData.CollisionType.DESTROY)
	assert_eq(_bullet.lifetime, 0.0)
	assert_eq(_bullet.max_lifetime, 10.0)

func test_bullet_trajectory_types():
	var linear := BulletData.TrajectoryType.LINEAR
	var spiral := BulletData.TrajectoryType.SPIRAL
	var homing := BulletData.TrajectoryType.HOMING
	assert_true(linear != spiral)
	assert_true(spiral != homing)

func test_bullet_collision_types():
	var destroy := BulletData.CollisionType.DESTROY
	var pierce := BulletData.CollisionType.PIERCE
	var bounce := BulletData.CollisionType.BOUNCE
	assert_true(destroy != pierce)
	assert_true(pierce != bounce)

func test_bullet_can_be_killed():
	_bullet.alive = false
	assert_false(_bullet.alive)

func test_bullet_pierce_count():
	_bullet.collision_type = BulletData.CollisionType.PIERCE
	_bullet.pierce_count = 3
	assert_eq(_bullet.pierce_count, 3)

func test_bullet_bounces_left():
	_bullet.collision_type = BulletData.CollisionType.BOUNCE
	_bullet.bounces_left = 5
	assert_eq(_bullet.bounces_left, 5)

func test_bullet_source_position():
	_bullet.source_position = Vector2(100, 200)
	assert_eq(_bullet.source_position, Vector2(100, 200))

func test_bullet_trajectory_center():
	_bullet.trajectory_center = Vector2(300, 300)
	assert_eq(_bullet.trajectory_center, Vector2(300, 300))
