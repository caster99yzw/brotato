extends BrotatoTest

var _level: Level
var _enemy_world: EnemyWorld
var _player: PlayerController

const _GMCommands = preload("res://scripts/gm/gm_commands.gd")

func before_each():
	super.before_each()
	_level = Level.new()
	add_child(_level)
	_player = _level.weapon.player
	_enemy_world = _level.enemy_world

func after_each():
	if _level != null:
		_level.queue_free()
		_level = null
	super.after_each()

func test_give_weapon_increments_equipped_count():
	var initial_count: int = _level.weapon.equipped_weapons.size()
	var result: bool = _GMCommands.give_weapon(_level.weapon, "SHOTGUN")
	assert_true(result)
	assert_eq(_level.weapon.equipped_weapons.size(), initial_count + 1)

func test_remove_weapon_decrements_equipped_count():
	_GMCommands.give_weapon(_level.weapon, "SHOTGUN")
	var initial_count: int = _level.weapon.equipped_weapons.size()
	_GMCommands.remove_weapon(_level.weapon, 1)
	assert_eq(_level.weapon.equipped_weapons.size(), initial_count - 1)

func test_spawn_enemies_increases_enemy_count():
	_GMCommands.spawn_enemies(_enemy_world, 5)
	assert_eq(_GMCommands.get_enemy_count(_enemy_world), 5)

func test_kill_all_enemies_sets_health_to_zero():
	_GMCommands.spawn_enemies(_enemy_world, 3)
	_GMCommands.kill_all(_enemy_world)
	for enemy in _enemy_world.enemies:
		assert_eq(enemy.health, 0.0)

func test_kill_all_preserves_enemy_count():
	_GMCommands.spawn_enemies(_enemy_world, 3)
	var count_before: int = _enemy_world.enemies.size()
	_GMCommands.kill_all(_enemy_world)
	assert_eq(_enemy_world.enemies.size(), count_before)

func test_set_wave_changes_wave_number():
	_GMCommands.set_wave(_level, 3)
	assert_eq(_GMCommands.get_wave(_level), 3)

func test_complete_wave_resets_enemies_remaining():
	_GMCommands.set_wave(_level, 1)
	_level.enemies_remaining = _level.enemies_per_wave

	_GMCommands.complete_wave(_level)

	assert_eq(_level.enemies_remaining, 0)

func test_complete_wave_emits_wave_completed_signal():
	_GMCommands.set_wave(_level, 1)
	_level.enemies_remaining = _level.enemies_per_wave

	watch_signal(_level, "wave_completed")
	_GMCommands.complete_wave(_level)

	assert_signal_emitted(_level, "wave_completed", 1)

func test_complete_wave_then_kill_all_keeps_remaining_at_zero():
	_GMCommands.set_wave(_level, 1)
	spawn_enemies(3)

	_GMCommands.complete_wave(_level)
	assert_eq(_level.enemies_remaining, 0)

	_GMCommands.kill_all(_enemy_world)
	assert_eq(_level.enemies_remaining, 0, "remaining should not go negative")

func test_god_mode_disables_player_collision():
	_GMCommands.god_mode(_player, true)
	assert_false(_player.get_collision_layer_value(1), "collision layer should be disabled")

func test_god_mode_restores_player_collision():
	var original_layer: bool = _player.get_collision_layer_value(1)
	_GMCommands.god_mode(_player, true)
	_GMCommands.god_mode(_player, false)
	assert_eq(_player.get_collision_layer_value(1), original_layer)

func test_get_enemy_count_returns_spawned_count():
	_GMCommands.spawn_enemies(_enemy_world, 7)
	assert_eq(_GMCommands.get_enemy_count(_enemy_world), 7)

func test_set_game_speed_changes_engine_time_scale():
	var original_speed: float = Engine.time_scale
	_GMCommands.set_game_speed(2.0)
	assert_eq(Engine.time_scale, 2.0)
	_GMCommands.set_game_speed(original_speed)

func spawn_enemies(count: int) -> void:
	for i in count:
		var enemy := EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		_enemy_world.add_enemy(enemy)
