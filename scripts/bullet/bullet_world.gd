class_name BulletWorld
extends Node2D

var bullets: Array[BulletData] = []
var player_position: Vector2 = Vector2.ZERO
var enemy_world: EnemyWorld

func _process(delta: float) -> void:
	update_trajectory_system(bullets, delta)
	update_position_system(bullets, delta)
	check_collision_system(bullets)
	kill_system(bullets)
	queue_redraw()

func add_bullet(bullet: BulletData) -> void:
	bullets.append(bullet)

func set_player_position(pos: Vector2) -> void:
	player_position = pos

func set_enemy_world(world: EnemyWorld) -> void:
	enemy_world = world

func update_trajectory_system(bullets: Array, delta: float) -> void:
	for bullet: BulletData in bullets:
		if not bullet.alive:
			continue
		
		match bullet.trajectory_type:
			BulletData.TrajectoryType.LINEAR:
				bullet.velocity = bullet.velocity.normalized() * bullet.speed
			
			BulletData.TrajectoryType.SPIRAL:
				bullet.trajectory_angle += delta * 5.0
				bullet.velocity = Vector2(
					cos(bullet.trajectory_angle),
					sin(bullet.trajectory_angle)
				) * bullet.speed
			
			BulletData.TrajectoryType.HOMING:
				if bullet.velocity.length() > 0:
					var to_target: Vector2 = (player_position - bullet.position).normalized()
					bullet.velocity = bullet.velocity.lerp(to_target * bullet.speed, 0.1)

func update_position_system(bullets: Array, delta: float) -> void:
	for bullet: BulletData in bullets:
		if not bullet.alive:
			continue
		bullet.position += bullet.velocity * delta
		bullet.lifetime += delta

func check_collision_system(bullets: Array) -> void:
	for bullet: BulletData in bullets:
		if not bullet.alive:
			continue
		
		var nearby_enemies: Array[EnemyData] = enemy_world.find_enemies_near(bullet.position, 30.0)
		for enemy: EnemyData in nearby_enemies:
			enemy.health -= bullet.damage
			handle_collision(bullet)
			break

func handle_collision(bullet: BulletData) -> void:
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

func kill_system(bullets: Array) -> void:
	for bullet: BulletData in bullets:
		if not bullet.alive or bullet.lifetime > bullet.max_lifetime:
			bullet.alive = false
	
	bullets = bullets.filter(func(b: BulletData): return b.alive)

func clear() -> void:
	bullets.clear()

func _draw() -> void:
	for bullet: BulletData in bullets:
		if bullet.alive:
			draw_circle(bullet.position, 3, Color.YELLOW)
