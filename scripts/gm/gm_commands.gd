class_name GMCommands

const HANDLERS := {
	"spawn_enemies": {"target": "enemy_world", "method": "spawn_enemies", "arg_count": 1, "arg_type": TYPE_INT, "default": 5},
	"kill_all": {"target": "enemy_world", "method": "kill_all"},
	"complete_wave": {"target": "level", "method": "complete_wave"},
	"set_wave": {"target": "level", "method": "set_wave", "arg_count": 1, "arg_type": TYPE_INT, "default": 1},
	"god_mode": {"target": "player", "method": "god_mode", "arg_count": 1, "arg_type": TYPE_BOOL, "default": true},
	"set_game_speed": {"target": "engine", "method": "set_game_speed", "arg_count": 1, "arg_type": TYPE_FLOAT, "default": 1.0},
	"give_weapon": {"target": "weapon", "method": "give_weapon", "arg_count": 1, "arg_type": TYPE_STRING, "default": "PISTOL"},
	"remove_weapon": {"target": "weapon", "method": "remove_weapon", "arg_count": 1, "arg_type": TYPE_INT, "default": 0},
	"list_weapons": {"target": "weapon", "method": "list_weapons", "returns": true},
	"get_wave": {"target": "level", "method": "get_wave", "returns": true},
	"get_enemy_count": {"target": "enemy_world", "method": "get_enemy_count", "returns": true},
}

static func _get_target(level: Level, target_name: String) -> Object:
	match target_name:
		"level": return level
		"enemy_world": return level.enemy_world
		"player": return level.player
		"weapon": return level.weapon
		"engine": return null
	return null

static func _convert_arg(arg: String, type: Variant, default: Variant) -> Variant:
	var t: int = type as int if type is int else _type_name_to_constant(type)
	match t:
		TYPE_INT: return int(arg) if not arg.is_empty() else default
		TYPE_FLOAT: return float(arg) if not arg.is_empty() else default
		TYPE_BOOL: return arg.to_lower() in ["true", "1", "yes", "on"] if not arg.is_empty() else default
		TYPE_STRING: return arg.to_upper() if not arg.is_empty() else default
	return default

static func _type_name_to_constant(type_name: Variant) -> int:
	if type_name is String:
		match type_name.to_lower():
			"int": return TYPE_INT
			"float": return TYPE_FLOAT
			"bool": return TYPE_BOOL
			"string": return TYPE_STRING
	return TYPE_NIL

static func execute(level: Level, cmd_def: Dictionary, raw_args: Array) -> Variant:
	var target_name: String = cmd_def.get("target", "")
	var method: String = cmd_def.get("method", "")
	var target: Object = _get_target(level, target_name)

	if cmd_def.get("returns", false):
		if target:
			return target.call(method)
		return null

	var arg_count: int = cmd_def.get("arg_count", 0)
	var arg_type: int = cmd_def.get("arg_type", TYPE_NIL)
	var default_val: Variant = cmd_def.get("default", null)

	var args: Array = []
	if arg_count > 0:
		var raw: String = raw_args[0] if raw_args.size() > 0 else ""
		args.append(_convert_arg(raw, arg_type, default_val))

	if target:
		target.call(method, args[0] if args else default_val)
	return null

static func give_weapon(controller: WeaponController, weapon_name: String) -> bool:
	return controller.equip_weapon(weapon_name)

static func remove_weapon(controller: WeaponController, index: int) -> void:
	controller.unequip_weapon(index)

static func list_weapons(controller: WeaponController) -> Array:
	return controller.equipped_weapons

static func spawn_enemies(world: EnemyWorld, count: int = 5) -> void:
	for i in range(count):
		var enemy := EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		enemy.velocity = Vector2.ZERO
		world.add_enemy(enemy)

static func kill_all(world: EnemyWorld) -> void:
	world.kill_all_no_signal()

static func get_alive_enemy_count(world: EnemyWorld) -> int:
	return world.get_active_enemy_count()

static func set_wave(level: Level, wave: int) -> void:
	level.current_wave = wave
	level.enemies_per_wave = 5 + (wave * 3)
	level.enemies_remaining = level.enemies_per_wave
	level.spawn_remaining = level.enemies_per_wave

static func complete_wave(level: Level) -> void:
	if level.enemies_remaining <= 0:
		return
	level.enemies_remaining = 0
	level.spawn_remaining = 0
	level.wave_completed.emit(level.current_wave)

static func god_mode(player: PlayerController, enabled: bool) -> void:
	if enabled:
		player.set_collision_layer_value(1, false)
	else:
		player.set_collision_layer_value(1, true)

static func set_game_speed(speed: float) -> void:
	Engine.time_scale = speed

static func get_enemy_count(world: EnemyWorld) -> int:
	return world.enemies.size()

static func get_wave(level: Level) -> int:
	return level.current_wave
