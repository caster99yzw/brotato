extends Node2D

var level: Level

func _ready() -> void:
	start_game()

func start_game() -> void:
	level = Level.new()
	level.game_over.connect(_on_game_over)
	add_child(level)

func _on_game_over() -> void:
	print("Game Over - restarting in 2 seconds")
	await get_tree().create_timer(2.0).timeout
	level.queue_free()
	start_game()
