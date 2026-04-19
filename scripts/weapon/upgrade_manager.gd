class_name UpgradeManager
extends Node2D

signal upgrade_selected(option_name: String, damage_mult: float, fire_rate_mult: float, bullet_speed_mult: float)

var weapon_controller: WeaponController
var upgrade_options: Array = []

func _ready() -> void:
	load_upgrades()

func load_upgrades() -> void:
	var file := FileAccess.open("res://resources/weapon/upgrades.json", FileAccess.READ)
	if not file:
		push_error("Failed to open upgrades.json")
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		push_error("Failed to parse upgrades.json")
		return

	var data := json.get_data() as Dictionary
	if data.has("upgrades"):
		upgrade_options = data["upgrades"]

func get_random_upgrade_options(count: int = 3) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	var remaining: Array = upgrade_options.duplicate()
	var total_weight := 0
	for opt in remaining:
		total_weight += opt["weight"]

	for i in range(count):
		if remaining.is_empty():
			break
		var roll := randf() * total_weight
		var cumulative := 0.0
		var selected_idx := 0
		for j in range(remaining.size()):
			cumulative += float(remaining[j]["weight"])
			if roll <= cumulative:
				selected_idx = j
				break
		options.append(remaining[selected_idx])
		total_weight -= float(remaining[selected_idx]["weight"])
		remaining.remove_at(selected_idx)

	return options

func apply_upgrade(option: Dictionary) -> void:
	if weapon_controller:
		weapon_controller.apply_upgrade(option["damage"], option["fire_rate"], option["bullet_speed"])
	upgrade_selected.emit(option["name"], option["damage"], option["fire_rate"], option["bullet_speed"])
