class_name GMCommands

static func give_weapon(controller: WeaponController, weapon_name: String) -> bool:
	return controller.equip_weapon(weapon_name)

static func remove_weapon(controller: WeaponController, index: int) -> void:
	controller.unequip_weapon(index)

static func list_weapons(controller: WeaponController) -> Array:
	return controller.equipped_weapons

static func spawn_enemies(world: EnemyWorld, count: int) -> void:
	for i in count:
		var enemy := EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		enemy.velocity = Vector2.ZERO
		world.add_enemy(enemy)

static func kill_all(world: EnemyWorld) -> void:
	for enemy in world.enemies:
		enemy.alive = false

static func set_wave(manager: UpgradeManager, wave: int) -> void:
	manager.current_wave = wave
	manager.enemies_per_wave = 5 + (wave * 3)
	manager.enemies_spawned = 0
	manager.enemies_killed = 0

static func complete_wave(manager: UpgradeManager) -> void:
	manager.enemies_killed = manager.enemies_per_wave
	manager.wave_completed.emit(manager.current_wave)

static func god_mode(player: PlayerController, enabled: bool) -> void:
	if enabled:
		player.set_collision_layer_value(1, false)
	else:
		player.set_collision_layer_value(1, true)

static func set_game_speed(speed: float) -> void:
	Engine.time_scale = speed

static func get_enemy_count(world: EnemyWorld) -> int:
	return world.enemies.size()

static func get_wave(manager: UpgradeManager) -> int:
	return manager.current_wave