class_name SignalWatcher
extends RefCounted

var emit_count: int = 0
var last_params: Array = []
var all_params: Array = []
var _signal_name: String = ""

func _init(sig_name: String):
	_signal_name = sig_name

func get_call_count() -> int:
	return emit_count

func was_called() -> bool:
	return emit_count > 0

func get_last_params() -> Array:
	return last_params

func get_all_params() -> Array:
	return all_params

func _on_signal(...args):
	emit_count += 1
	last_params = args
	all_params.append(args)
