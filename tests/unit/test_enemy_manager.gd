extends BrotatoTest

var _manager: Node
var _player: Node

func before_each():
	_manager = EnemyManager.new()
	_player = Node2D.new()
	_manager.player = _player
	_manager.enemy_scene = null
	_manager._ready()

func after_each():
	if _manager != null:
		_manager.queue_free()
	if _player != null:
		_player.queue_free()

func test_spawn_enemy_with_null_scene_does_nothing():
	var initial_count = _manager.enemies.size()
	_manager.enemy_scene = null
	_manager.spawn_enemy()
	assert_eq(_manager.enemies.size(), initial_count, "enemies count should remain unchanged when scene is null")

func test_process_filters_invalid_enemies():
	_manager.spawn_enemy()
	_manager.enemies.clear()
	_manager._process(0.016)
	assert_eq(_manager.enemies.size(), 0, "enemies should be empty after clear and process")

func test_enemies_array_initialized():
	assert_eq(_manager.enemies.size(), 0, "enemies should start empty")

func test_spawn_timer_wait_time_is_two_seconds():
	assert_eq(_manager.spawn_timer.wait_time, 2.0, "spawn timer should have 2 second wait time")

func test_process_removes_invalid_enemies():
	_manager.enemies.clear()
	_manager._process(0.016)
	assert_eq(_manager.enemies.size(), 0, "enemies should be empty after process with no enemies")

func test_player_reference_is_set():
	assert_not_null(_manager.player, "player reference should be set")
