class_name BrotatoTest
extends Node

var _test: Node = null
var _last_error: String = ""
var _param_tests: Array = []
var _param_index: int = 0

func set_test(t: Node) -> void:
	_test = t

func before_all() -> void:
	pass

func after_all() -> void:
	pass

func before_each() -> void:
	_param_tests.clear()
	_param_index = 0

func after_each() -> void:
	pass

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
	return assert_true(a < b, msg)

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
