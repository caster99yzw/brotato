class_name SignalSpy
extends Node

var _watchers: Dictionary = {}

func watch(obj: Object, signal_name: String):
	if not obj.has_signal(signal_name):
		push_error("Object does not have signal: " + signal_name)
		return null

	var SignalWatcher = load("res://tests/framework/signal_watcher.gd")
	var watcher = SignalWatcher.new(signal_name)
	_watchers[obj] = watcher
	obj.connect(signal_name, watcher._on_signal)
	return watcher

func unwatch(obj: Object, signal_name: String) -> void:
	if _watchers.has(obj):
		var watcher = _watchers[obj]
		if obj.has_signal(signal_name):
			obj.disconnect(signal_name, watcher._on_signal)
		_watchers.erase(obj)

func get_watcher(obj: Object):
	return _watchers.get(obj)

func get_emit_count(obj: Object) -> int:
	var watcher = _watchers.get(obj)
	return watcher.emit_count if watcher else 0

func was_called(obj: Object) -> bool:
	return get_emit_count(obj) > 0

func get_all_params(obj: Object) -> Array:
	var watcher = _watchers.get(obj)
	return watcher.get_all_params() if watcher else []

func get_last_params(obj: Object) -> Array:
	var watcher = _watchers.get(obj)
	return watcher.get_last_params() if watcher else []

func clear() -> void:
	for obj in _watchers.keys():
		unwatch(obj, "")
	_watchers.clear()

func reset_watcher(obj: Object) -> void:
	if _watchers.has(obj):
		var watcher = _watchers[obj]
		watcher.emit_count = 0
		watcher.last_params.clear()
		watcher.all_params.clear()
