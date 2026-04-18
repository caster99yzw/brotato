extends BrotatoTest

var _level: Node2D
var _player: PlayerController
var _weapon: WeaponController
var _bullet_world: BulletWorld
var _enemy_world: EnemyWorld
var _bullet_factory

const _GMCommands = preload("res://scripts/gm/gm_commands.gd")
const _BulletFactory = preload("res://scripts/bullet/bullet_factory.gd")

func before_each():
	_level = Node2D.new()
	add_child(_level)

	_player = PlayerController.new()
	_player.global_position = Vector2(500, 500)
	_level.add_child(_player)

	_enemy_world = EnemyWorld.new()
	_enemy_world.set_player(_player)
	_level.add_child(_enemy_world)

	_bullet_world = BulletWorld.new()
	_bullet_world.set_enemy_world(_enemy_world)
	_level.add_child(_bullet_world)

	_bullet_factory = _BulletFactory.new()

	_weapon = WeaponController.new()
	_weapon.player = _player
	_weapon.bullet_world = _bullet_world
	_weapon._ready()
	_weapon.equip_weapon("PISTOL")
	_weapon.weapon_fired.connect(_on_weapon_fired)

func after_each():
	if _level != null:
		_level.queue_free()

func _on_weapon_fired(bullet_type: String, spawn_pos: Vector2, direction: Vector2, damage_mult: float, speed_mult: float, bullet_count: int):
	var bullets = _bullet_factory.create_bullets(bullet_type, spawn_pos, direction, damage_mult, speed_mult, bullet_count)
	for bullet in bullets:
		_bullet_world.add_bullet(bullet)

func test_weapon_fires_bullet_toward_enemy():
	_GMCommands.spawn_enemies(_enemy_world, 1)
	var enemy = _enemy_world.enemies[0]
	enemy.position = _player.global_position + Vector2.RIGHT * 100

	_player.set_aim_direction(Vector2.RIGHT)
	_weapon.shoot()

	assert_gt(_bullet_world.bullets.size(), 0, "should have bullets in world")

	var bullet = _bullet_world.bullets[0]
	assert_true(bullet.velocity.x > 0, "bullet should move right toward enemy")

func test_bullet_velocity_is_set_correctly():
	_player.set_aim_direction(Vector2.RIGHT)
	_weapon.shoot()

	var bullet = _bullet_world.bullets[0]
	var expected_velocity = Vector2.RIGHT * bullet.speed
	assert_true(bullet.velocity.distance_to(expected_velocity) < 1.0, "bullet velocity should be RIGHT * speed")