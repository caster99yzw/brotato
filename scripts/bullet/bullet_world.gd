class_name BulletWorld
extends Node2D

var bullets: Array[BulletData] = []
var player_position: Vector2 = Vector2.ZERO
var enemy_world: EnemyWorld

var _trajectory
var _collision
var _sprite_cache: Dictionary = {}
var _texture_cache: Dictionary = {}

const _BulletTrajectory = preload("res://scripts/bullet/bullet_trajectory.gd")
const _BulletCollision = preload("res://scripts/bullet/bullet_collision.gd")

func _ready() -> void:
	_init_modules()

func _init_modules() -> void:
	if _trajectory == null:
		_trajectory = _BulletTrajectory.new()
	if _collision == null:
		_collision = _BulletCollision.new()
		if enemy_world != null:
			_collision.set_find_enemies_callback(enemy_world.find_enemies_near)

func _process(delta: float) -> void:
	_init_modules()
	_trajectory.set_player_position(player_position)

	update_trajectories(delta)
	update_collisions()
	remove_dead_bullets()
	update_sprites()

func update_trajectories(delta: float) -> void:
	_trajectory.update_all(bullets, delta)

func update_collisions() -> void:
	if _collision == null:
		return
	var new_bullets = _collision.update_all(bullets)
	for bullet in bullets:
		if not new_bullets.has(bullet) and _sprite_cache.has(bullet):
			_sprite_cache[bullet].queue_free()
			_sprite_cache.erase(bullet)
	bullets = new_bullets

func remove_dead_bullets() -> void:
	for bullet in bullets:
		if not bullet.alive or bullet.lifetime > bullet.max_lifetime:
			if _sprite_cache.has(bullet):
				_sprite_cache[bullet].queue_free()
				_sprite_cache.erase(bullet)
	bullets = bullets.filter(func(b: BulletData): return b.alive and b.lifetime <= b.max_lifetime)

func update_sprites() -> void:
	for bullet: BulletData in bullets:
		if not bullet.alive:
			_hide_sprite(bullet)
			continue

		if not _sprite_cache.has(bullet):
			_create_sprite(bullet)

		var sprite: Sprite2D = _sprite_cache[bullet]
		sprite.visible = true
		sprite.position = bullet.position

		match bullet.bullet_sprite:
			"missile_bullet", "rifle_bullet":
				if bullet.velocity.length() > 0:
					sprite.rotation = bullet.velocity.angle()
			"boomerang_bullet", "spinner_bullet":
				sprite.rotation = bullet.trajectory_angle
			"slash_bullet":
				sprite.rotation = bullet.orbiting_angle
			_:
				pass

func _create_sprite(bullet: BulletData) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = _get_texture(bullet.bullet_sprite)
	sprite.centered = true
	sprite.rotation = bullet.velocity.angle() if bullet.velocity.length() > 0 else bullet.trajectory_angle
	add_child(sprite)
	_sprite_cache[bullet] = sprite

func _hide_sprite(bullet: BulletData) -> void:
	if _sprite_cache.has(bullet):
		_sprite_cache[bullet].visible = false

func _get_texture(sprite_name: String) -> Texture2D:
	if _texture_cache.has(sprite_name):
		return _texture_cache[sprite_name]
	var path: String = "res://resources/sprites/bullets/" + sprite_name + ".png"
	var texture: Texture2D = load(path) if FileAccess.file_exists(path) else load("res://resources/sprites/bullets/pistol_bullet.png")
	_texture_cache[sprite_name] = texture
	return texture

func add_bullet(bullet: BulletData) -> void:
	bullets.append(bullet)

func set_player_position(pos: Vector2) -> void:
	player_position = pos

func set_enemy_world(world: EnemyWorld) -> void:
	enemy_world = world
	if _collision != null:
		_collision.set_find_enemies_callback(world.find_enemies_near)

func clear() -> void:
	for sprite: Sprite2D in _sprite_cache.values():
		sprite.queue_free()
	_sprite_cache.clear()
	bullets.clear()