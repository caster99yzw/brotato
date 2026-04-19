class_name BulletCollision
extends RefCounted

var find_enemies_callback: Callable

func set_find_enemies_callback(callback: Callable) -> void:
	find_enemies_callback = callback

func check_and_resolve(bullet: BulletData) -> void:
	if not bullet.alive:
		return

	var nearby_enemies: Array[EnemyData] = _find_enemies(bullet.position, 30.0)
	for enemy: EnemyData in nearby_enemies:
		enemy.health -= bullet.damage
		bullet.last_hit_enemy = enemy
		resolve(bullet)
		break

func resolve_single(bullet: BulletData) -> Array[BulletData]:
	var new_bullets: Array[BulletData] = []
	check_and_resolve(bullet)
	if bullet.collision_type == BulletData.CollisionType.SPREADING and not bullet.alive:
		new_bullets.append_array(get_spread_bullets(bullet))
	return new_bullets

func update_all(bullets: Array[BulletData]) -> Array[BulletData]:
	var alive: Array[BulletData] = []
	for bullet: BulletData in bullets:
		if not bullet.alive or bullet.lifetime > bullet.max_lifetime:
			continue
		check_and_resolve(bullet)
		alive.append(bullet)
		if bullet.collision_type == BulletData.CollisionType.SPREADING and not bullet.alive:
			alive.append_array(get_spread_bullets(bullet))
	return alive

func resolve(bullet: BulletData) -> void:
	match bullet.collision_type:
		BulletData.CollisionType.DESTROY:
			bullet.alive = false

		BulletData.CollisionType.PIERCE:
			bullet.pierce_count -= 1
			if bullet.pierce_count <= 0:
				bullet.alive = false

		BulletData.CollisionType.BOUNCE:
			bullet.bounces_left -= 1
			if bullet.bounces_left <= 0:
				bullet.alive = false
			else:
				bullet.velocity = bullet.velocity.bounce(bullet.velocity.normalized())

		BulletData.CollisionType.EXPLOSIVE:
			bullet.alive = false
			_apply_explosive(bullet)

		BulletData.CollisionType.CHAINING:
			var chained: Array[EnemyData] = _apply_chaining(bullet)
			if chained.size() < bullet.chain_count:
				bullet.alive = false

		BulletData.CollisionType.SPREADING:
			bullet.alive = false

		BulletData.CollisionType.BURNING:
			bullet.alive = false
			if bullet.last_hit_enemy != null:
				_apply_burning(bullet.last_hit_enemy, bullet)

func get_spread_bullets(bullet: BulletData) -> Array[BulletData]:
	var spread_count: int = bullet.spread_count if bullet.spread_count > 0 else 3
	var spread_angle: float = bullet.spread_angle if bullet.spread_angle > 0 else 45.0
	var new_bullets: Array[BulletData] = []
	var angle_step: float = deg_to_rad(spread_angle) / float(spread_count - 1) if spread_count > 1 else 0.0
	var base_angle: float = bullet.velocity.angle() - angle_step * float(spread_count - 1) / 2.0
	for i: int in range(spread_count):
		var new_bullet: BulletData = BulletData.new()
		new_bullet.position = bullet.position
		new_bullet.velocity = Vector2.from_angle(base_angle + angle_step * float(i)) * bullet.speed
		new_bullet.speed = bullet.speed
		new_bullet.damage = bullet.damage * 0.5
		new_bullet.trajectory_type = bullet.trajectory_type
		new_bullet.collision_type = bullet.collision_type
		new_bullet.source_position = bullet.source_position
		new_bullet.bullet_sprite = bullet.bullet_sprite
		new_bullets.append(new_bullet)
	return new_bullets

func _apply_explosive(bullet: BulletData) -> void:
	if bullet.explosive_radius <= 0:
		bullet.explosive_radius = 50.0
	var nearby_enemies: Array[EnemyData] = _find_enemies(bullet.position, bullet.explosive_radius)
	for enemy: EnemyData in nearby_enemies:
		if enemy != bullet.last_hit_enemy:
			enemy.health -= bullet.damage * 0.5

func _apply_chaining(bullet: BulletData) -> Array[EnemyData]:
	if bullet.chain_count <= 0:
		bullet.chain_count = 3
	if bullet.chain_range <= 0:
		bullet.chain_range = 100.0
	var chained_enemies: Array[EnemyData] = []
	var nearby_enemies: Array[EnemyData] = _find_enemies(bullet.position, bullet.chain_range)
	for enemy: EnemyData in nearby_enemies:
		if enemy != bullet.last_hit_enemy and chained_enemies.size() < bullet.chain_count:
			chained_enemies.append(enemy)
			enemy.health -= bullet.damage * 0.7
	return chained_enemies

func _find_enemies(pos: Vector2, radius: float) -> Array[EnemyData]:
	if find_enemies_callback.is_valid():
		return find_enemies_callback.call(pos, radius)
	return []

func _apply_burning(enemy: EnemyData, bullet: BulletData) -> void:
	var burn_damage: float = bullet.burn_damage if bullet.burn_damage > 0 else 5.0
	var burn_duration: float = bullet.burn_duration if bullet.burn_duration > 0 else 3.0
	if enemy.has_method("apply_burning_effect"):
		enemy.apply_burning_effect(burn_damage, burn_duration, bullet.burn_tick_rate if bullet.burn_tick_rate > 0 else 1.0)
