extends Node2D

const TestRunnerScript = preload("res://tests/framework/test_runner.gd")

var _runner: Node

func _ready() -> void:
	_runner = TestRunnerScript.new()
	add_child(_runner)
	_runner.add_directory("res://tests/unit")
	_runner.add_directory("res://tests/integration")
	_runner.tests_finished.connect(_on_tests_finished)
	_runner.run_tests()

func _on_tests_finished() -> void:
	print("\nTests finished. Exiting...")
	get_tree().quit(_runner._fail_count > 0)
