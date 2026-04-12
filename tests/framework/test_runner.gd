class_name TestRunner
extends Node2D

signal tests_finished()

var _test_scripts: Array = []
var _prefix: String = "test_"
var _suffix: String = ".gd"
var _pass_count: int = 0
var _fail_count: int = 0
var _current_test: Node = null

func _ready() -> void:
	print("\n=== Brotato Test Runner ===\n")

func add_directory(path: String, include_subdirs: bool = false) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("Could not open directory: " + path)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(_suffix) and file_name.begins_with(_prefix):
			var full_path := path + "/" + file_name
			_test_scripts.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

func add_script(path: String) -> void:
	_test_scripts.append(path)

func run_tests() -> void:
	_pass_count = 0
	_fail_count = 0
	
	print("Found %d test scripts\n" % _test_scripts.size())
	
	for script_path in _test_scripts:
		await _run_script(script_path)
	
	_print_summary()
	tests_finished.emit()

func _run_script(script_path: String) -> void:
	print("--- Running: %s ---" % script_path)
	
	var script := load(script_path)
	if script == null:
		print("FAILED to load: %s\n" % script_path)
		_fail_count += 1
		return
	
	var test_inst: Node = script.new()
	if not (test_inst is BrotatoTest):
		push_warning("Script %s does not extend BrotatoTest, skipping" % script_path)
		test_inst.queue_free()
		return
	
	test_inst.set_test(self)
	add_child(test_inst)
	_current_test = test_inst
	
	await _run_before_all(test_inst)
	await _run_tests(test_inst)
	await _run_after_all(test_inst)
	
	_current_test.queue_free()
	_current_test = null

func _run_before_all(inst: Node) -> void:
	if inst.has_method("before_all"):
		await inst.before_all()

func _run_after_all(inst: Node) -> void:
	if inst.has_method("after_all"):
		await inst.after_all()

func _run_tests(inst: Node) -> void:
	var method_list := inst.get_method_list()
	for method_data in method_list:
		var method_name: String = method_data["name"]
		if method_name.begins_with(_prefix) and method_name != "_test":
			await _run_test_method(inst, method_name, method_data)

func _run_test_method(inst: Node, method_name: String, method_data: Dictionary) -> void:
	var args: Array = method_data.get("args", [])
	var is_parametric = args.size() > 0
	
	inst.clear_last_error()
	inst._param_tests.clear()
	await _run_before_each(inst)
	
	if is_parametric:
		await _run_parametric_test(inst, method_name)
	else:
		await _run_normal_test(inst, method_name)
	
	await _run_after_each(inst)

func _run_parametric_test(inst: Node, method_name: String) -> void:
	var idx = 0
	while true:
		inst._param_index = idx
		print("  %s [%d]" % [method_name, idx])
		inst.clear_last_error()
		inst.call(method_name)
		
		if inst.has_last_error():
			print("    FAILED: %s" % inst.get_last_error())
			_fail_count += 1
			return
		
		idx += 1
		if idx >= inst._param_tests.size():
			break
	
	_pass_count += 1

func _run_normal_test(inst: Node, method_name: String) -> void:
	print("  %s" % method_name)
	inst.call(method_name)
	
	if inst.has_last_error():
		print("    FAILED: %s" % inst.get_last_error())
		_fail_count += 1
	else:
		_pass_count += 1

func _run_before_each(inst: Node) -> void:
	if inst.has_method("before_each"):
		await inst.before_each()

func _run_after_each(inst: Node) -> void:
	if inst.has_method("after_each"):
		await inst.after_each()

func _print_summary() -> void:
	print("\n=== Test Summary ===")
	print("Passed: %d" % _pass_count)
	print("Failed: %d" % _fail_count)
	print("Total:  %d" % (_pass_count + _fail_count))
	
	if _fail_count > 0:
		print("\nTESTS FAILED")
	else:
		print("\nALL TESTS PASSED")
