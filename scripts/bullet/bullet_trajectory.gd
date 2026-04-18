class_name BulletTrajectory
extends RefCounted

var player_position: Vector2 = Vector2.ZERO

func _init(player_pos: Vector2 = Vector2.ZERO) -> void:
	player_position = player_pos

func set_player_position(pos: Vector2) -> void:
	player_position = pos

func update_all(bullets: Array[BulletData], delta: float) -> void:
	for bullet: BulletData in bullets:
		if not bullet.alive:
			continue
		_update(bullet, delta)

func _update(bullet: BulletData, delta: float) -> void:
	bullet.lifetime += delta
	match bullet.trajectory_type:
		BulletData.TrajectoryType.LINEAR:
			_update_linear(bullet, delta)
		BulletData.TrajectoryType.SPIRAL:
			_update_spiral(bullet, delta)
		BulletData.TrajectoryType.HOMING:
			_update_homing(bullet, delta)
		BulletData.TrajectoryType.CURVED:
			_update_curved(bullet, delta)
		BulletData.TrajectoryType.BOOMERANG:
			_update_boomerang(bullet, delta)
		BulletData.TrajectoryType.ORBITING:
			_update_orbiting(bullet, delta)
		BulletData.TrajectoryType.DROPPING:
			_update_dropping(bullet, delta)

func _update_linear(bullet: BulletData, delta: float) -> void:
	bullet.velocity = bullet.velocity.normalized() * bullet.speed
	bullet.position += bullet.velocity * delta

func _update_spiral(bullet: BulletData, delta: float) -> void:
	bullet.trajectory_angle += delta * 5.0
	bullet.velocity = Vector2(cos(bullet.trajectory_angle), sin(bullet.trajectory_angle)) * bullet.speed
	bullet.position += bullet.velocity * delta

func _update_homing(bullet: BulletData, delta: float) -> void:
	if bullet.velocity.length() > 0:
		var to_target: Vector2 = (player_position - bullet.position).normalized()
		bullet.velocity = bullet.velocity.lerp(to_target * bullet.speed, 0.1)
	bullet.position += bullet.velocity * delta

func _update_curved(bullet: BulletData, delta: float) -> void:
	bullet.velocity.y += bullet.gravity * delta
	bullet.velocity = bullet.velocity.normalized() * bullet.speed
	bullet.position += bullet.velocity * delta

func _update_boomerang(bullet: BulletData, delta: float) -> void:
	if not bullet.has_returned:
		var to_source: Vector2 = (bullet.source_position - bullet.position)
		if to_source.length() < 30.0:
			bullet.has_returned = true
		bullet.velocity = to_source.normalized() * bullet.speed
	else:
		var to_player: Vector2 = (player_position - bullet.position)
		if to_player.length() < 20.0:
			bullet.alive = false
		bullet.velocity = to_player.normalized() * bullet.speed
	bullet.position += bullet.velocity * delta

func _update_orbiting(bullet: BulletData, delta: float) -> void:
	bullet.orbiting_angle += delta * bullet.orbiting_speed
	var center: Vector2 = bullet.orbiting_center
	if bullet.orbiting_follow_player:
		center = player_position
	bullet.position = center + Vector2(cos(bullet.orbiting_angle), sin(bullet.orbiting_angle)) * bullet.orbiting_radius
	bullet.velocity = Vector2.ZERO

func _update_dropping(bullet: BulletData, delta: float) -> void:
	bullet.velocity = Vector2(0, bullet.speed)
	bullet.position += bullet.velocity * delta
	bullet.lifetime += delta
	if bullet.lifetime > 0.5:
		bullet.alive = false