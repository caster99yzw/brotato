extends BrotatoTest

var _level: Level
var _player: PlayerController
var _bullet_world: BulletWorld
var _enemy_world: EnemyWorld

const _BulletFactory = preload("res://scripts/bullet/bullet_factory.gd")
var _bullet_factory

func before_each():
	_level = Level.new()
	add_child(_level)
	_player = _level.weapon.player
	_bullet_world = _level.bullet_world
	_enemy_world = _level.enemy_world
	_bullet_factory = _BulletFactory.new()

func after_each():
	if _level != null:
		_level.queue_free()

func _create_bullet(weapon_name: String) -> BulletData:
	var bullets = _bullet_factory.create_bullets(weapon_name, _player.global_position, Vector2.RIGHT, 1.0, 1.0, 1)
	return bullets[0]

func test_bullet_collision_destroy():
	var bullet = _create_bullet("PISTOL")
	bullet.collision_type = BulletData.CollisionType.DESTROY
	assert_eq(bullet.collision_type, BulletData.CollisionType.DESTROY, "collision type should be destroy")

func test_bullet_collision_pierce():
	var bullet = _create_bullet("PISTOL")
	bullet.collision_type = BulletData.CollisionType.PIERCE
	bullet.pierce_count = 3
	assert_eq(bullet.collision_type, BulletData.CollisionType.PIERCE, "collision type should be pierce")
	assert_eq(bullet.pierce_count, 3, "pierce count should be 3")

func test_bullet_collision_bounce():
	var bullet = _create_bullet("PISTOL")
	bullet.collision_type = BulletData.CollisionType.BOUNCE
	bullet.bounces_left = 3
	assert_eq(bullet.collision_type, BulletData.CollisionType.BOUNCE, "collision type should be bounce")
	assert_eq(bullet.bounces_left, 3, "bounces left should be 3")

func test_bullet_collision_explosive():
	var bullet = _create_bullet("GRENADE")
	bullet.collision_type = BulletData.CollisionType.EXPLOSIVE
	bullet.explosive_radius = 100.0
	assert_eq(bullet.collision_type, BulletData.CollisionType.EXPLOSIVE, "collision type should be explosive")
	assert_eq(bullet.explosive_radius, 100.0, "explosive radius should be set")

func test_bullet_collision_chaining():
	var bullet = _create_bullet("MAGIC")
	bullet.collision_type = BulletData.CollisionType.CHAINING
	bullet.chain_count = 2
	bullet.chain_range = 100.0
	assert_eq(bullet.collision_type, BulletData.CollisionType.CHAINING, "collision type should be chaining")
	assert_eq(bullet.chain_count, 2, "chain count should be 2")

func test_bullet_collision_spreading():
	var bullet = _create_bullet("SHOTGUN")
	bullet.collision_type = BulletData.CollisionType.SPREADING
	bullet.spread_count = 3
	bullet.spread_angle = 45.0
	assert_eq(bullet.collision_type, BulletData.CollisionType.SPREADING, "collision type should be spreading")
	assert_eq(bullet.spread_count, 3, "spread count should be 3")

func test_bullet_collision_burning():
	var bullet = _create_bullet("MAGIC")
	bullet.collision_type = BulletData.CollisionType.BURNING
	bullet.burn_damage = 10.0
	bullet.burn_duration = 1.0
	assert_eq(bullet.collision_type, BulletData.CollisionType.BURNING, "collision type should be burning")
	assert_eq(bullet.burn_damage, 10.0, "burn damage should be set")