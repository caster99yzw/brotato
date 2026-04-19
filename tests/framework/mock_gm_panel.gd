class_name MockGMPanel
extends Control

var _last_command: String = ""
var _last_args: Array = []
var _output: String = ""
var _command_history: Array = []

func execute_command(cmd: String, args: Array) -> String:
	_last_command = cmd
	_last_args = args.duplicate()
	_command_history.append({"cmd": cmd, "args": args.duplicate()})
	return _output

func set_output(output: String) -> void:
	_output = output

func get_last_command() -> String:
	return _last_command

func get_last_args() -> Array:
	return _last_args.duplicate()

func get_command_history() -> Array:
	return _command_history.duplicate()

func was_command_called(cmd: String) -> bool:
	return _last_command == cmd

func get_call_count(cmd: String = "") -> int:
	if cmd == "":
		return _command_history.size()
	var count = 0
	for entry in _command_history:
		if entry["cmd"] == cmd:
			count += 1
	return count

func reset() -> void:
	_last_command = ""
	_last_args.clear()
	_output = ""
	_command_history.clear()
