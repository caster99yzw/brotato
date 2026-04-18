class_name MockUpgradePanel
extends Control

var _calls: Array = []
var _last_options: Array = []

func show_upgrades(opts: Array) -> void:
	_calls.append(opts)
	_last_options = opts

func was_shown() -> bool:
	return _calls.size() > 0

func get_call_count() -> int:
	return _calls.size()

func get_last_options() -> Array:
	return _last_options