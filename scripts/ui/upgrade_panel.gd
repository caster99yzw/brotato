class_name UpgradePanel
extends Control

signal option_selected(option: Dictionary)

@onready var title_label: Label = $Title
@onready var cards_container: HBoxContainer = $Cards

var options: Array[Dictionary] = []
var option_cards: Array[PanelContainer] = []

func _ready() -> void:
	visible = false
	$Overlay.visible = false

func show_upgrades(upgrade_options: Array[Dictionary]) -> void:
	options = upgrade_options
	clear_options()
	
	for i in range(options.size()):
		var opt := options[i]
		var card := create_card(opt, i)
		cards_container.add_child(card)
		option_cards.append(card)
	
	visible = true
	$Overlay.visible = true

func create_card(opt: Dictionary, index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(200, 280)
	
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	
	var name_label := Label.new()
	name_label.text = opt["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.custom_minimum_size.y = 60
	vbox.add_child(name_label)
	
	var stats_label := Label.new()
	var stats_text := ""
	if opt["damage"] > 0:
		stats_text += "伤害 +%.0f%%\n" % (opt["damage"] * 100)
	if opt["fire_rate"] > 0:
		stats_text += "射速 +%.0f%%\n" % (opt["fire_rate"] * 100)
	if opt["bullet_speed"] > 0:
		stats_text += "弹速 +%.0f%%" % (opt["bullet_speed"] * 100)
	stats_label.text = stats_text
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats_label.custom_minimum_size.y = 120
	vbox.add_child(stats_label)
	
	var btn := Button.new()
	btn.text = "选择"
	btn.custom_minimum_size.y = 50
	btn.pressed.connect(_on_card_selected.bind(index))
	vbox.add_child(btn)
	
	return panel

func clear_options() -> void:
	for card in option_cards:
		card.queue_free()
	option_cards.clear()

func _on_card_selected(index: int) -> void:
	if index < options.size():
		var selected := options[index]
		visible = false
		$Overlay.visible = false
		clear_options()
		option_selected.emit(selected)

func set_wave(wave: int) -> void:
	title_label.text = "选择升级 (第 %d 波)" % wave
