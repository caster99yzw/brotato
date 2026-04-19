class_name BrotatoTest
extends Node

var _test: Node = null
var _last_error: String = ""
var _param_tests: Array = []
var _param_index: int = 0
var _signal_spy = null
var _time_accum: float = 0.0

func set_test(t: Node) -> void:
	_test = t

func before_all() -> void:
	pass

func after_all() -> void:
	pass

func before_each() -> void:
	_param_tests.clear()
	_param_index = 0
	_time_accum = 0.0

func after_each() -> void:
	if _signal_spy != null:
		_signal_spy.queue_free()
		_signal_spy = null

func set_last_error(msg: String) -> void:
	_last_error = msg

func clear_last_error() -> void:
	_last_error = ""

func has_last_error() -> bool:
	return _last_error != ""

func get_last_error() -> String:
	return _last_error

func use_parameters(params: Array):
	if _param_tests.size() == 0:
		_param_tests = params
	var idx = _param_index
	_param_index += 1
	return _param_tests[idx]

func get_signal_spy():
	if _signal_spy == null:
		_signal_spy = load("res://tests/framework/signal_spy.gd").new()
		add_child(_signal_spy)
	return _signal_spy

func watch_signal(obj: Object, signal_name: String):
	return get_signal_spy().watch(obj, signal_name)

func unwatch_signal(obj: Object, signal_name: String) -> void:
	get_signal_spy().unwatch(obj, signal_name)

func assert_signal_emitted(obj: Object, signal_name: String, times: int = 1, message: String = "") -> bool:
	var spy = get_signal_spy()
	if not spy._watchers.has(obj):
		return assert_true(false, message if message else "Signal %s was not watched" % signal_name)
	var watcher = spy._watchers[obj]
	var actual = watcher.emit_count
	var msg = message if message else "Expected signal '%s' to be emitted %d times, got %d" % [signal_name, times, actual]
	return assert_eq(actual, times, msg)

func assert_signal_not_emitted(obj: Object, signal_name: String, message: String = "") -> bool:
	var spy = get_signal_spy()
	if not spy._watchers.has(obj):
		return assert_true(false, message if message else "Signal %s was not watched" % signal_name)
	var watcher = spy._watchers[obj]
	var actual = watcher.emit_count
	var msg = message if message else "Expected signal '%s' to not be emitted, but was emitted %d times" % [signal_name, actual]
	return assert_eq(actual, 0, msg)

func assert_state_matches(obj: Object, expected: Dictionary, message: String = "") -> bool:
	var failures: Array = []
	for key in expected.keys():
		var actual_value = obj.get(key)
		var expected_value = expected[key]
		if actual_value != expected_value:
			failures.append("'%s': expected %s, got %s" % [key, str(expected_value), str(actual_value)])
	
	if failures.size() > 0:
		var full_msg = message if message else "State mismatch: " + ", ".join(failures)
		set_last_error(full_msg)
		push_error(full_msg)
		return false
	return true

func assert_property(obj: Object, property: String, expected, message: String = "") -> bool:
	var actual = obj.get(property)
	var msg = message if message else "Property '%s': expected %s, got %s" % [property, str(expected), str(actual)]
	return assert_eq(actual, expected, msg)

func advance_time(delta: float) -> void:
	_time_accum += delta
	var tree = get_tree()
	if tree != null:
		tree.process_frame.emit()

func simulate_frames(frames: int) -> void:
	for i in frames:
		advance_time(0.016)

func get_time_accumulated() -> float:
	return _time_accum

func assert_true(condition: bool, message: String = "") -> bool:
	if not condition:
		set_last_error("Assertion failed: " + message)
		push_error("Assertion failed: " + message)
		return false
	return true

func assert_eq(actual, expected, message: String = "") -> bool:
	var msg := message if message else "Expected %s, got %s" % [str(expected), str(actual)]
	return assert_true(actual == expected, msg)

func assert_ne(actual, expected, message: String = "") -> bool:
	var msg := message if message else "Expected %s != %s" % [str(expected), str(actual)]
	return assert_true(actual != expected, msg)

func assert_gt(a: float, b: float, message: String = "") -> bool:
	var msg := message if message else "Expected %s > %s" % [str(a), str(b)]
	return assert_true(a > b, msg)

func assert_lt(a: float, b: float, message: String = "") -> bool:
	var msg := message if message else "Expected %s < %s" % [str(a), str(b)]
	return assert_true(a <= b, msg)

func assert_le(a: float, b: float, message: String = "") -> bool:
	var msg := message if message else "Expected %s <= %s" % [str(a), str(b)]
	return assert_true(a <= b, msg)

func assert_null(value, message: String = "") -> bool:
	var msg := message if message else "Expected null"
	return assert_true(value == null, msg)

func assert_not_null(value, message: String = "") -> bool:
	var msg := message if message else "Expected not null"
	return assert_true(value != null, msg)

func assert_false(condition: bool, message: String = "") -> bool:
	return assert_true(not condition, message)
