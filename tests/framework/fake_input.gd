class_name FakeInput
extends RefCounted

var _pressed_keys := {}

func is_key_pressed(key: Key) -> bool:
	return _pressed_keys.get(key, false)

func press_key(key: Key) -> void:
	_pressed_keys[key] = true

func release_key(key: Key) -> void:
	_pressed_keys[key] = false

func release_all() -> void:
	_pressed_keys.clear()
