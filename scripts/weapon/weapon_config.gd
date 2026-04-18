class_name WeaponConfig
extends Node

var weapon_configs: Dictionary = {}

static var _instance: WeaponConfig = null

static func get_instance() -> WeaponConfig:
	if _instance == null:
		var scene = load("res://scripts/weapon/weapon_config.gd")
		_instance = scene.new()
	return _instance

func _init() -> void:
	load_configs()

func load_configs() -> void:
	var file := FileAccess.open("res://resources/weapon/weapons.json", FileAccess.READ)
	if not file:
		push_error("Failed to open weapons.json")
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		push_error("Failed to parse weapons.json")
		return

	weapon_configs = json.get_data()

func get_config(weapon_name: String) -> Dictionary:
	return weapon_configs.get(weapon_name, {})