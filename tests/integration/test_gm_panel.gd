extends BrotatoTest

var _level: Level
var _gm_panel: GMPanel

func before_each():
	super.before_each()
	_level = Level.new()
	add_child(_level)

	_gm_panel = load("res://scenes/ui/gm_panel.tscn").instantiate()
	add_child(_gm_panel)
	_gm_panel.level = _level

func after_each():
	if _gm_panel != null:
		_gm_panel.queue_free()
		_gm_panel = null
	if _level != null:
		_level.queue_free()
		_level = null
	super.after_each()

func test_gm_panel_button_spawn_enemies():
	_gm_panel._on_button_pressed("spawn_enemies")
	assert_eq(_level.enemy_world.enemies.size(), 5)

func test_gm_panel_button_spawn_enemies_10():
	_gm_panel._on_button_pressed("spawn_enemies_10")
	assert_eq(_level.enemy_world.enemies.size(), 10)

func test_gm_panel_button_kill_all():
	GMCommands.spawn_enemies(_level.enemy_world, 5)
	assert_eq(_level.enemy_world.enemies.size(), 5)

	_gm_panel._on_button_pressed("kill_all")

	for enemy in _level.enemy_world.enemies:
		assert_eq(enemy.health, 0.0)

func test_gm_panel_button_set_wave():
	assert_eq(_level.current_wave, 1)

	_gm_panel._on_button_pressed("set_wave")

	assert_eq(_level.current_wave, 5)
	assert_eq(_level.enemies_per_wave, 5 + 5 * 3)

func test_gm_panel_button_god_mode():
	_gm_panel._on_button_pressed("god_mode")
	assert_false(_level.player.get_collision_layer_value(1), "collision should be disabled")

func test_gm_panel_button_god_mode_off():
	_gm_panel._on_button_pressed("god_mode")
	assert_false(_level.player.get_collision_layer_value(1))

	_gm_panel._on_button_pressed("god_mode_off")
	assert_true(_level.player.get_collision_layer_value(1), "collision should be restored")

func test_gm_panel_button_set_game_speed_2():
	_gm_panel._on_button_pressed("set_game_speed_2")
	assert_eq(Engine.time_scale, 2.0)

func test_gm_panel_button_set_game_speed_1():
	Engine.time_scale = 2.0
	_gm_panel._on_button_pressed("set_game_speed_1")
	assert_eq(Engine.time_scale, 1.0)

func test_gm_panel_button_give_weapon_pistol():
	var initial_count: int = _level.weapon.equipped_weapons.size()
	_gm_panel._on_button_pressed("give_weapon_pistol")
	assert_eq(_level.weapon.equipped_weapons.size(), initial_count + 1)

func test_gm_panel_button_give_weapon_shotgun():
	var initial_count: int = _level.weapon.equipped_weapons.size()
	_gm_panel._on_button_pressed("give_weapon_shotgun")
	assert_eq(_level.weapon.equipped_weapons.size(), initial_count + 1)

func test_gm_panel_button_remove_weapon():
	_gm_panel._on_button_pressed("give_weapon_shotgun")
	var count_after_add: int = _level.weapon.equipped_weapons.size()
	assert_eq(count_after_add, 2)

	_gm_panel._on_button_pressed("remove_weapon")
	assert_eq(_level.weapon.equipped_weapons.size(), count_after_add - 1)
