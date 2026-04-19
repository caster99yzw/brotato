class_name EnemyWorld
extends Node2D

var enemies: Array[EnemyData] = []
var player: Node2D

signal enemy_spawned
signal enemy_killed

var _grid: Dictionary = {}
var _cell_size: float = 100.0

func _process(delta: float) -> void:
	update_trajectory_system(enemies, delta)
	update_position_system(enemies, delta)
	_grid_rebuild_system()
	enemies = kill_system(enemies)
	queue_redraw()

func set_player(player_node: Node2D) -> void:
	player = player_node

func add_enemy(enemy: EnemyData) -> void:
	enemy.target = player
	enemies.append(enemy)
	_add_to_grid(enemy)
	enemy_spawned.emit()

func _get_cell_key(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / _cell_size), floor(pos.y / _cell_size))

func _add_to_grid(enemy: EnemyData) -> void:
	var key: Vector2i = _get_cell_key(enemy.position)
	if not _grid.has(key):
		_grid[key] = []
	_grid[key].append(enemy)

func is_alive(enemy: EnemyData) -> bool:
	return enemy.health > 0

func _grid_rebuild_system() -> void:
	_grid.clear()
	for enemy: EnemyData in enemies:
		if is_alive(enemy):
			_add_to_grid(enemy)

func find_enemies_near(pos: Vector2, radius: float) -> Array[EnemyData]:
	var result: Array[EnemyData] = []
	var cell_radius: int = int(ceil(radius / _cell_size)) + 1
	var center_cell: Vector2i = _get_cell_key(pos)
	
	for dx in range(-cell_radius, cell_radius + 1):
		for dy in range(-cell_radius, cell_radius + 1):
			var cell_key: Vector2i = center_cell + Vector2i(dx, dy)
			if _grid.has(cell_key):
				for enemy: EnemyData in _grid[cell_key]:
					if enemy.position.distance_to(pos) <= radius:
						result.append(enemy)
	return result

func update_trajectory_system(enemies: Array, delta: float) -> void:
	for enemy: EnemyData in enemies:
		if not is_alive(enemy):
			continue
		if enemy.target and is_instance_valid(enemy.target):
			var to_target: Vector2 = (enemy.target.global_position - enemy.position).normalized()
			enemy.velocity = to_target * enemy.speed

func update_position_system(enemies: Array, delta: float) -> void:
	for enemy: EnemyData in enemies:
		if not is_alive(enemy):
			continue
		enemy.position += enemy.velocity * delta

func kill_system(enemies: Array) -> Array:
	var before_count := enemies.size()
	enemies = enemies.filter(func(e: EnemyData): return is_alive(e))
	var kill_count := before_count - enemies.size()
	if kill_count > 0:
		enemy_killed.emit(kill_count)
	return enemies

func get_active_enemy_count() -> int:
	return enemies.size()

func kill_all() -> int:
	var count := enemies.size()
	for enemy: EnemyData in enemies:
		enemy.health = 0
	return count

func kill_all_no_signal() -> void:
	kill_all()

func _draw() -> void:
	for enemy: EnemyData in enemies:
		if is_alive(enemy):
			draw_circle(enemy.position, 15, Color.RED)
