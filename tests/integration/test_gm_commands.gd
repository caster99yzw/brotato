extends BrotatoTest

var _level: Level
var _player: PlayerController
var _enemy_world: EnemyWorld

const _GMCommands = preload("res://scripts/gm/gm_commands.gd")

func before_each():
	_level = Level.new()
	add_child(_level)
	_player = _level.weapon.player
	_enemy_world = _level.enemy_world

func after_each():
	if _level != null:
		_level.queue_free()

func test_gm_give_weapon():
	var initial_count = _level.weapon.equipped_weapons.size()
	var result = _GMCommands.give_weapon(_level.weapon, "SHOTGUN")
	assert_true(result, "give_weapon should return true")
	assert_eq(_level.weapon.equipped_weapons.size(), initial_count + 1, "weapon should be added")

func test_gm_remove_weapon():
	_GMCommands.give_weapon(_level.weapon, "SHOTGUN")
	var initial_count = _level.weapon.equipped_weapons.size()
	_GMCommands.remove_weapon(_level.weapon, 1)
	assert_eq(_level.weapon.equipped_weapons.size(), initial_count - 1, "weapon should be removed")

func test_gm_list_weapons():
	_GMCommands.give_weapon(_level.weapon, "SHOTGUN")
	var weapons = _GMCommands.list_weapons(_level.weapon)
	assert_eq(weapons.size(), 2, "should list 2 weapons")

func test_gm_spawn_enemies():
	_GMCommands.spawn_enemies(_enemy_world, 5)
	assert_eq(_GMCommands.get_enemy_count(_enemy_world), 5, "should spawn 5 enemies")

func test_gm_kill_all():
	_GMCommands.spawn_enemies(_enemy_world, 3)
	_GMCommands.kill_all(_enemy_world)
	for enemy in _enemy_world.enemies:
		assert_eq(enemy.health, 0, "all enemies should be dead")

func test_gm_set_wave():
	_GMCommands.set_wave(_level, 3)
	var wave = _GMCommands.get_wave(_level)
	assert_eq(wave, 3, "wave should be set to 3")

func test_gm_complete_wave():
	_GMCommands.set_wave(_level, 1)
	_GMCommands.spawn_enemies(_enemy_world, _level.enemies_per_wave)
	var initial_remaining = _level.enemies_remaining
	watch_signal(_level, "wave_completed")
	_GMCommands.complete_wave(_level)
	assert_eq(_level.enemies_remaining, 0, "all enemies should be marked as killed")
	assert_signal_emitted(_level, "wave_completed", 1, "wave_completed should be emitted")

func test_gm_complete_wave_then_kill_all_no_double_count():
	_GMCommands.set_wave(_level, 1)
	var enemies_per_wave = _level.enemies_per_wave
	for i in 3:
		var enemy := EnemyData.new()
		enemy.position = Vector2(randf() * 800, randf() * 600)
		_enemy_world.add_enemy(enemy)

	watch_signal(_level, "wave_completed")
	_GMCommands.complete_wave(_level)
	assert_eq(_level.enemies_remaining, 0, "enemies_remaining should be 0 after complete_wave")

	_GMCommands.kill_all(_enemy_world)
	assert_eq(_level.enemies_remaining, 0, "kill_all after complete_wave should not change remaining")

func test_gm_god_mode():
	var original_layer = _player.get_collision_layer_value(1)
	_GMCommands.god_mode(_player, true)
	assert_false(_player.get_collision_layer_value(1), "collision layer should be disabled in god mode")
	_GMCommands.god_mode(_player, false)
	assert_eq(_player.get_collision_layer_value(1), original_layer, "collision layer should be restored")

func test_gm_get_enemy_count():
	_GMCommands.spawn_enemies(_enemy_world, 7)
	var count = _GMCommands.get_enemy_count(_enemy_world)
	assert_eq(count, 7, "enemy count should be 7")

func test_gm_get_wave():
	_GMCommands.set_wave(_level, 5)
	var wave = _GMCommands.get_wave(_level)
	assert_eq(wave, 5, "wave should be 5")

func test_gm_set_game_speed():
	var original_speed = Engine.time_scale
	_GMCommands.set_game_speed(2.0)
	assert_eq(Engine.time_scale, 2.0, "game speed should be 2.0")
	_GMCommands.set_game_speed(original_speed)
	assert_eq(Engine.time_scale, original_speed, "game speed should be restored")
