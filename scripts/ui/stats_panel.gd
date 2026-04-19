class_name StatsPanel
extends Control

@onready var dps_label: Label = $Panel/DPS

func _ready() -> void:
	dps_label.text = "DPS: 30.0"

func update_stats(damage: float, fire_rate: float, bullet_speed: float) -> void:
	dps_label.text = "DPS: %.1f" % (damage * fire_rate)
