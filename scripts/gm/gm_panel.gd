class_name GMPanel
extends PanelContainer

@onready var _header: Button = $VBox/Header
@onready var _content: VBoxContainer = $VBox/Scroll/Content

var level: Level
var config: Dictionary
var expanded: bool = true
var _labels: Dictionary = {}
var _selected_weapon_index: int = 0
var _weapon_dropdown: OptionButton
var _command_input: LineEdit
var _command_output: Label

const _GMCommands = preload("res://scripts/gm/gm_commands.gd")

func _ready() -> void:
	_header.pressed.connect(_on_toggle)
	_load_config()
	_create_ui()

func _process(delta: float) -> void:
	if expanded and is_instance_valid(level):
		_refresh_display()

func _load_config() -> void:
	var file := FileAccess.open("res://resources/gm/gm_panel_config.json", FileAccess.READ)
	if not file:
		push_error("Failed to open gm_panel_config.json")
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		push_error("Failed to parse gm_panel_config.json")
		return
	config = json.get_data()

func _create_ui() -> void:
	if config.has("categories"):
		for category: Dictionary in config["categories"]:
			var category_label := Label.new()
			category_label.text = category["name"]
			category_label.add_theme_color_override("font_color", Color.YELLOW)
			_content.add_child(category_label)

			var hbox := FlowContainer.new()
			_content.add_child(hbox)

			for button_data: Dictionary in category["buttons"]:
				var btn := Button.new()
				btn.text = button_data["label"]
				btn.custom_minimum_size = Vector2(90, 25)
				btn.pressed.connect(_on_button_pressed.bind(button_data["id"]))
				hbox.add_child(btn)

	if config.has("display"):
		var separator := Label.new()
		separator.text = "--- 状态 ---"
		separator.add_theme_color_override("font_color", Color.CYAN)
		_content.add_child(separator)

		for key: String in config["display"]:
			var data: Dictionary = config["display"][key]
			var label := Label.new()
			label.text = "%s: --" % data["label"]
			_labels[key] = label
			_content.add_child(label)

	if config.has("weapon_stats"):
		var separator := Label.new()
		separator.text = "--- 武器 ---"
		separator.add_theme_color_override("font_color", Color.GREEN)
		_content.add_child(separator)

		_weapon_dropdown = OptionButton.new()
		_content.add_child(_weapon_dropdown)
		_weapon_dropdown.item_selected.connect(_on_weapon_selected)

		var stats_container := VBoxContainer.new()
		_content.add_child(stats_container)
		for key: String in config["weapon_stats"]:
			var data: Dictionary = config["weapon_stats"][key]
			var label := Label.new()
			label.text = "%s: --" % data["label"]
			_labels[key] = label
			stats_container.add_child(label)

	if config.get("command_input", false):
		var separator := Label.new()
		separator.text = "--- 命令行 ---"
		separator.add_theme_color_override("font_color", Color.ORANGE)
		_content.add_child(separator)

		var hbox := HBoxContainer.new()
		_content.add_child(hbox)

		_command_input = LineEdit.new()
		_command_input.placeholder_text = "输入指令..."
		_command_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_command_input.text_submitted.connect(_on_command_submit)
		hbox.add_child(_command_input)

		var exec_btn := Button.new()
		exec_btn.text = "执行"
		exec_btn.pressed.connect(_on_command_execute)
		hbox.add_child(exec_btn)

		_command_output = Label.new()
		_command_output.text = ""
		_command_output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_content.add_child(_command_output)

func _on_button_pressed(command_id: String) -> void:
	if not is_instance_valid(level) or not config.has("commands"):
		return
	var cmd: Dictionary = config["commands"].get(command_id, {})
	if cmd.is_empty():
		return
	var method: String = cmd.get("method", "")
	var args: Array = cmd.get("args", [])
	_call_command(method, args)

func _call_command(method: String, args: Array) -> void:
	match method:
		"spawn_enemies":
			_GMCommands.spawn_enemies(level.enemy_world, args[0] as int)
		"kill_all":
			_GMCommands.kill_all(level.enemy_world)
		"complete_wave":
			_GMCommands.complete_wave(level)
		"set_wave":
			_GMCommands.set_wave(level, args[0] as int)
		"god_mode":
			_GMCommands.god_mode(level.player, args[0] as bool)
		"set_game_speed":
			_GMCommands.set_game_speed(args[0] as float)
		"give_weapon":
			_GMCommands.give_weapon(level.weapon, args[0] as String)
		"remove_weapon":
			_GMCommands.remove_weapon(level.weapon, args[0] as int)

func _on_weapon_selected(index: int) -> void:
	_selected_weapon_index = index
	_refresh_weapon_display()

func _on_command_submit(command: String) -> void:
	_on_command_execute()

func _on_command_execute() -> void:
	if not is_instance_valid(level):
		return
	var cmd: String = _command_input.text.strip_edges()
	if cmd.is_empty():
		return
	var parts := cmd.split(" ")
	var command: String = parts[0].to_lower()
	var raw_args: Array = []
	if parts.size() > 1:
		for i in range(1, parts.size()):
			raw_args.append(parts[i])

	var cmd_def: Dictionary = config.get("command_defs", {}).get(command, {})
	if cmd_def.is_empty():
		_command_output.text = "未知指令: %s" % command
		_command_output.add_theme_color_override("font_color", Color.RED)
		_command_input.text = ""
		return

	var result_val: Variant = _GMCommands.execute(level, cmd_def, raw_args)
	var result := _format_result(cmd_def, result_val, raw_args)

	_command_output.text = result
	_command_output.add_theme_color_override("font_color", Color.GREEN)
	_command_input.text = ""
	_refresh_display()

func _format_result(cmd_def: Dictionary, result_val: Variant, args: Array) -> String:
	var template: String = cmd_def.get("result_template", "OK")
	if template == "OK":
		return "OK"

	var result: String = template
	result = result.replace("{arg0}", args[0] if args.size() > 0 else "")
	result = result.replace("{result}", str(result_val))
	result = result.replace("{count}", str(result_val.size() if result_val is Array else result_val))
	return result

func _refresh_display() -> void:
	if not is_instance_valid(level):
		return
	if _labels.has("enemy_count"):
		_labels["enemy_count"].text = "敌人数: %d" % _GMCommands.get_alive_enemy_count(level.enemy_world)
	if _labels.has("wave"):
		_labels["wave"].text = "波次: %d" % level.current_wave
	if _labels.has("enemies_killed"):
		var killed = level.enemies_per_wave - level.enemies_remaining
		_labels["enemies_killed"].text = "已击杀: %d" % killed
	_refresh_weapon_display()

func _refresh_weapon_display() -> void:
	if not is_instance_valid(level) or level.weapon == null:
		return
	var weapons = level.weapon.equipped_weapons
	if weapons.size() == 0:
		_weapon_dropdown.clear()
		_weapon_dropdown.add_item("无武器")
		for key: String in config.get("weapon_stats", {}):
			_labels.get(key).text = "%s: --" % config["weapon_stats"][key]["label"]
		return
	_weapon_dropdown.clear()
	for w in weapons:
		_weapon_dropdown.add_item(w.weapon_name)
	if _selected_weapon_index >= weapons.size():
		_selected_weapon_index = 0
	_weapon_dropdown.selected = _selected_weapon_index
	var stats = level.weapon.get_stats()
	if config.has("weapon_stats"):
		if _labels.has("damage"):
			_labels["damage"].text = "伤害: %.1f" % stats.get("damage", 0)
		if _labels.has("fire_rate"):
			_labels["fire_rate"].text = "射速: %.1f" % stats.get("fire_rate", 0)
		if _labels.has("bullet_speed"):
			_labels["bullet_speed"].text = "弹速: %.0f" % stats.get("bullet_speed", 0)

func _on_toggle() -> void:
	expanded = not expanded
	_content.visible = expanded
	_header.text = "GM Panel ▼" if expanded else "GM Panel ▶"
	if expanded:
		offset_top = -510
		offset_bottom = 10
	else:
		offset_top = -30
		offset_bottom = 10
