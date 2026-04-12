class_name FakeSignal
extends RefCounted

signal timeout

var emit_count: int = 0
var last_args: Array = []

func connect_to(callable: Callable) -> void:
	timeout.connect(callable)

func start() -> void:
	pass

func trigger_timeout() -> void:
	emit_count += 1
	timeout.emit()
