class_name StatsPanel
extends Control

@onready var damage_label: Label = $Panel/Labels/Damage
@onready var fire_rate_label: Label = $Panel/Labels/FireRate
@onready var bullet_speed_label: Label = $Panel/Labels/BulletSpeed
@onready var dps_label: Label = $Panel/Labels/DPS
@onready var wave_label: Label = $Panel/Labels/Wave

func _ready() -> void:
	damage_label.text = "伤害: 10.0"
	fire_rate_label.text = "射速: 3.0"
	bullet_speed_label.text = "弹速: 500"
	dps_label.text = "DPS: 30.0"
	wave_label.text = "波次 0 / 10"

func update_stats(damage: float, fire_rate: float, bullet_speed: float) -> void:
	damage_label.text = "伤害: %.1f" % damage
	fire_rate_label.text = "射速: %.1f" % fire_rate
	bullet_speed_label.text = "弹速: %.0f" % bullet_speed
	dps_label.text = "DPS: %.1f" % (damage * fire_rate)

func set_wave(wave: int) -> void:
	wave_label.text = "波次 %d / 10" % wave
