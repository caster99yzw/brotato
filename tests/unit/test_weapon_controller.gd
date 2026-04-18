extends BrotatoTest

var _controller: WeaponController
var _bullet_world: BulletWorld
var _bullet_factory

const _BulletFactory = preload("res://scripts/bullet/bullet_factory.gd")

func before_each():
	_bullet_world = BulletWorld.new()
	_bullet_factory = _BulletFactory.new()
	_controller = WeaponController.new()
	_controller.player = PlayerController.new()
	_controller.bullet_world = _bullet_world
	_controller._ready()
	_controller.equip_weapon("PISTOL")
	_controller.weapon_fired.connect(_on_weapon_fired)

func after_each():
	if _controller != null:
		_controller.queue_free()
	if _bullet_world != null:
		_bullet_world.queue_free()

func _on_weapon_fired(bullet_type: String, spawn_pos: Vector2, direction: Vector2, damage_mult: float, speed_mult: float, bullet_count: int):
	var bullets = _bullet_factory.create_bullets(bullet_type, spawn_pos, direction, damage_mult, speed_mult, bullet_count)
	for bullet in bullets:
		_bullet_world.add_bullet(bullet)

func test_fire_rate_defaults_to_three():
	assert_eq(_controller.equipped_weapons[0].fire_rate, 3.0, "fire_rate should default to 3.0")

func test_bullet_count_defaults_to_one():
	assert_eq(_controller.equipped_weapons[0].bullet_count, 1, "bullet_count should default to 1")

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
	await _controller.get_tree().create_timer(0.1).timeout
	assert_true(_controller.can_shoot, "can_shoot should be true after timeout")

func test_shoot_twice_adds_two_bullets():
	_controller.player.set_aim_direction(Vector2.RIGHT)
	_controller.shoot()
	await _controller.get_tree().create_timer(0.5).timeout
	_controller.player.set_aim_direction(Vector2.UP)
	_controller.shoot()
	assert_eq(_bullet_world.bullets.size(), 2, "should have two bullets in world")

func test_equip_weapon_adds_to_equipped():
	var initial_count: int = _controller.equipped_weapons.size()
	_controller.equip_weapon("SHOTGUN")
	assert_eq(_controller.equipped_weapons.size(), initial_count + 1, "should have one more weapon")

func test_max_weapons_limit():
	for i in range(WeaponController.MAX_WEAPONS):
		_controller.equip_weapon("PISTOL")
	assert_eq(_controller.equipped_weapons.size(), WeaponController.MAX_WEAPONS, "should respect max weapons limit")
	var result: bool = _controller.equip_weapon("RIFLE")
	assert_false(result, "should not equip beyond max")