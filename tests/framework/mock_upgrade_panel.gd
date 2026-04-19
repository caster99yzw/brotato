class_name MockUpgradePanel
extends Control

signal option_selected_signal(option: Dictionary)

var _calls: Array = []
var _last_options: Array = []
var _selected_options: Array = []
var _show_called: bool = false

func show_upgrades(opts: Array) -> void:
	_calls.append(opts.duplicate())
	_last_options = opts.duplicate()
	_show_called = true

func was_shown() -> bool:
	return _show_called

func was_called() -> bool:
	return _calls.size() > 0

func get_call_count() -> int:
	return _calls.size()

func get_last_options() -> Array:
	return _last_options.duplicate()

func get_all_calls() -> Array:
	return _calls.duplicate()

func get_options_at_call(index: int) -> Array:
	if index < 0 or index >= _calls.size():
		return []
	return _calls[index].duplicate()

func was_shown_with_options_count(count: int) -> bool:
	if not _show_called:
		return false
	return _last_options.size() == count

func select_option(option: Dictionary) -> void:
	_selected_options.append(option)
	option_selected_signal.emit(option)

func get_selected_options() -> Array:
	return _selected_options.duplicate()

func get_last_selected_option() -> Dictionary:
	if _selected_options.size() == 0:
		return {}
	return _selected_options[-1]

func reset() -> void:
	_calls.clear()
	_last_options.clear()
	_selected_options.clear()
	_show_called = false
