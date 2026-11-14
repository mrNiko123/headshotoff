extends CanvasLayer

# Консоль разработчика в стиле CS2. Autoload "Console".
# Открытие: клавиша ` (или через настройки). Паузит игру, пока открыта.

const MapData: = preload("res://scripts/map_data.gd")
const WeaponData: = preload("res://scripts/weapon_data.gd")
const ACCENT: = Color(0.35, 1.0, 0.5)
const WARN: = Color(1.0, 0.75, 0.3)
const ERROR: = Color(1.0, 0.4, 0.35)
const TEXT: = Color(0.85, 0.88, 0.92)
const BG: = Color(0.07, 0.08, 0.1, 0.96)

var open: = false
var _panel: PanelContainer
var _output: RichTextLabel
var _field: LineEdit
var _hint: Label
var _history: PackedStringArray = PackedStringArray()
var _history_index: = 0
var _cheats: = false
var _prev_mouse_mode: = Input.MOUSE_MODE_VISIBLE
var _candidates: PackedStringArray = PackedStringArray()
var _candidate_index: = 0


func _ready() -> void :
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	visible = false


func _build_ui() -> void :
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.custom_minimum_size = Vector2(0.0, 380.0)
	_panel.offset_top = -380.0
	var style: = StyleBoxFlat.new()
	style.bg_color = BG
	style.border_color = ACCENT * Color(1.0, 1.0, 1.0, 0.35)
	style.border_width_bottom = 2
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	_panel.add_child(column)

	_hint = Label.new()
	_hint.add_theme_font_size_override("font_size", 12)
	_hint.add_theme_color_override("font_color", ACCENT * Color(1.0, 1.0, 1.0, 0.6))
	column.add_child(_hint)

	_output = RichTextLabel.new()
	_output.bbcode_enabled = true
	_output.scroll_following = true
	_output.selection_enabled = true
	_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_output.add_theme_font_size_override("normal_font_size", 15)
	column.add_child(_output)

	_field = LineEdit.new()
	_field.add_theme_font_size_override("font_size", 16)
	_field.placeholder_text = "введите команду..."
	_field.text_submitted.connect(_on_submit)
	_field.text_changed.connect(_on_text_changed)
	_field.gui_input.connect(_on_input_gui)
	column.add_child(_field)

	log_line("HEADSHOT OFF console — введите help для списка команд.", ACCENT)


func _input(event: InputEvent) -> void :
	if not (event is InputEventKey):
		return
	var key: = event as InputEventKey
	if not key.pressed or key.echo:
		return
	if key.physical_keycode == KEY_QUOTELEFT:
		get_viewport().set_input_as_handled()
		if open:
			close_console()
		else:
			open_console()
	elif open and key.physical_keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		close_console()


func open_console() -> void :
	if open:
		return
	open = true
	_prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	visible = true
	_field.grab_focus()


func close_console() -> void :
	if not open:
		return
	open = false
	visible = false
	get_tree().paused = false
	Input.mouse_mode = _prev_mouse_mode


func log_line(text: String, color: Color = TEXT) -> void :
	var hex: = color.to_html(false)
	_output.append_text("[color=#%s]%s[/color]\n" % [hex, text.replace("[", "[lb]")])
	_output.scroll_to_line(_output.get_line_count())


func _on_submit(text: String) -> void :
	var command: = text.strip_edges()
	_field.text = ""
	_hint.text = ""
	if command.is_empty():
		return
	_history.append(command)
	_history_index = _history.size()
	log_line("> " + command, ACCENT)
	execute(command)


func _on_text_changed(text: String) -> void :
	_update_candidates(text.strip_edges())


func _on_input_gui(event: InputEvent) -> void :
	if event is InputEventKey and (event as InputEventKey).pressed:
		var key: = event as InputEventKey
		if key.physical_keycode == KEY_TAB and not _candidates.is_empty():
			_field.text = _candidates[_candidate_index % _candidates.size()]
			_candidate_index += 1
			_field.caret_column = _field.text.length()
			_update_candidates(_field.text)
			_field.accept_event()
		elif key.physical_keycode == KEY_UP:
			if _history_index > 0:
				_history_index -= 1
				_field.text = _history[_history_index]
				_field.caret_column = _field.text.length()
			_field.accept_event()
		elif key.physical_keycode == KEY_DOWN:
			if _history_index < _history.size() - 1:
				_history_index += 1
				_field.text = _history[_history_index]
			else:
				_history_index = _history.size()
				_field.text = ""
			_field.caret_column = _field.text.length()
			_field.accept_event()


func _update_candidates(prefix: String) -> void :
	_candidates = PackedStringArray()
	_candidate_index = 0
	if prefix.is_empty():
		_hint.text = ""
		return
	for name in _commands():
		if name.begins_with(prefix) and name != prefix:
			_candidates.append(name)
	if _candidates.is_empty():
		_hint.text = ""
	else:
		_hint.text = "TAB: " + "  ".join(_candidates.slice(0, 8))


# ===================== КОМАНДЫ =====================

func _commands() -> Dictionary:
	return {
		"sensitivity": {"desc": "чувствительность мыши (0.2-3.0)", "get": func() -> float: return Settings.mouse_sensitivity, 
			"set": func(v: float) -> void : Settings.mouse_sensitivity = v}, 
		"fov": {"desc": "поле зрения 60-120", "get": func() -> float: return Settings.fov, 
			"set": func(v: float) -> void : Settings.fov = clampf(v, 60.0, 120.0)}, 
		"volume": {"desc": "громкость 0-1", "get": func() -> float: return Settings.master_volume, 
			"set": func(v: float) -> void : Settings.master_volume = clampf(v, 0.0, 1.0)}, 
		"cl_showfps": {"desc": "показывать FPS 0/1", "get": func() -> float: return 1.0 if Settings.show_fps else 0.0, 
			"set": func(v: float) -> void : Settings.show_fps = v > 0.5}, 
		"fps_max": {"desc": "лимит FPS (0 = без лимита)", "get": func() -> float: return float(Settings.fps_limit), 
			"set": func(v: float) -> void : Settings.fps_limit = int(clampf(v, 0.0, 1000.0))}, 
		"vsync": {"desc": "вертикальная синхронизация 0/1", "get": func() -> float: return 1.0 if Settings.vsync else 0.0, 
			"set": func(v: float) -> void : Settings.vsync = v > 0.5}, 
		"r_fullscreen": {"desc": "полноэкранный режим 0/1", "get": func() -> float: return 1.0 if Settings.fullscreen else 0.0, 
			"set": func(v: float) -> void : Settings.fullscreen = v > 0.5}, 
		"brightness": {"desc": "яркость 0.7-1.4", "get": func() -> float: return Settings.brightness, 
			"set": func(v: float) -> void : Settings.brightness = clampf(v, 0.7, 1.4)}, 
		"fog_enable": {"desc": "туман 0/1", "get": func() -> float: return 1.0 if Settings.fog_enabled else 0.0, 
			"set": func(v: float) -> void : Settings.fog_enabled = v > 0.5}, 
		"cl_crosshair_gap": {"desc": "зазор прицела", "get": func() -> float: return Settings.crosshair_gap, 
			"set": func(v: float) -> void : Settings.crosshair_gap = clampf(v, 0.0, 30.0)}, 
		"cl_crosshair_size": {"desc": "длина прицела", "get": func() -> float: return Settings.crosshair_length, 
			"set": func(v: float) -> void : Settings.crosshair_length = clampf(v, 0.0, 40.0)}, 
		"cl_crosshair_thickness": {"desc": "толщина прицела", "get": func() -> float: return Settings.crosshair_thickness, 
			"set": func(v: float) -> void : Settings.crosshair_thickness = clampf(v, 0.5, 10.0)}, 
		"cl_crosshair_dot": {"desc": "точка в центре 0/1", "get": func() -> float: return 1.0 if Settings.crosshair_dot else 0.0, 
			"set": func(v: float) -> void : Settings.crosshair_dot = v > 0.5}, 
		"cl_crosshair_outline": {"desc": "обводка прицела 0/1", "get": func() -> float: return 1.0 if Settings.crosshair_outline else 0.0, 
			"set": func(v: float) -> void : Settings.crosshair_outline = v > 0.5}, 
		"cl_crosshair_dynamic": {"desc": "динамический прицел 0/1", "get": func() -> float: return 1.0 if Settings.crosshair_dynamic else 0.0, 
			"set": func(v: float) -> void : Settings.crosshair_dynamic = v > 0.5}, 
		"sv_cheats": {"desc": "чит-переменные 0/1", "get": func() -> float: return 1.0 if _cheats else 0.0, 
			"set": func(v: float) -> void : _cheats = v > 0.5}, 
		"host_timescale": {"desc": "скорость игры 0.1-3 (нужен sv_cheats 1)", "get": func() -> float: return Engine.time_scale, 
			"set": func(v: float) -> void : Engine.time_scale = clampf(v, 0.1, 3.0)}, 
		"bot_count": {"desc": "число мишеней 1-12 (применится после смены карты)", "get": func() -> float: return float(Settings.mannequin_count), 
			"set": func(v: float) -> void : Settings.mannequin_count = int(clampf(v, 1.0, 12.0))}, 
	}


func execute(raw: String) -> void :
	var parts: = raw.split(" ", false)
	if parts.is_empty():
		return
	var name: = parts[0].to_lower()
	var args: = parts.slice(1)
	var commands: = _commands()

	if commands.has(name):
		_run_cvar(name, args, commands[name])
		Settings.queue_save_settings()
		return

	match name:
		"help":
			_run_help(args)
		"find":
			_run_find(args)
		"clear":
			_output.clear()
		"echo":
			log_line(" ".join(args))
		"status":
			_run_status()
		"map":
			_run_map(args)
		"cl_righthand":
			log_line("cl_righthand недоступен в этой сборке (руки всегда справа).", WARN)
		"give":
			log_line("give: выберите оружие в меню закупки (B). Предметы: %s" % ", ".join(_weapon_ids()), WARN)
		"quit":
			get_tree().quit()
		"disconnect":
			_run_disconnect()
		"console":
			if args.size() > 0 and str(args[0]) == "0":
				close_console()
			else:
				log_line("консоль уже открыта.", WARN)
		_:
			log_line('Unknown command: "%s"' % name, ERROR)


func _run_cvar(name: String, args: Array, info: Dictionary) -> void :
	var getter: Callable = info["get"]
	var setter: Callable = info["set"]
	if args.is_empty():
		log_line("%s = %s" % [name, _fmt(getter.call())])
		log_line("  %s" % str(info["desc"]), WARN)
		return
	if _cheats_blocked(name):
		log_line('Can\'t change "%s" while sv_cheats is 0.' % name, ERROR)
		return
	var text: = str(args[0]).replace("\"", "")
	var value: Variant = _parse_number(text)
	if value == null:
		log_line('Invalid value: "%s" для %s' % [text, name], ERROR)
		return
	setter.call(value)
	log_line("%s = %s" % [name, _fmt(getter.call())])


func _cheats_blocked(name: String) -> bool:
	return name == "host_timescale" and not _cheats


func _parse_number(text: String) -> Variant:
	if text.is_valid_float():
		return text.to_float()
	return null


func _fmt(value: Variant) -> String:
	if value is float:
		return "%.2f" % value
	return str(value)


func _run_help(args: Array) -> void :
	if not args.is_empty():
		var name: = str(args[0]).to_lower()
		var commands: = _commands()
		if commands.has(name):
			log_line("%s — %s" % [name, str(commands[name]["desc"])], ACCENT)
		else:
			log_line('Unknown command: "%s"' % name, ERROR)
		return
	log_line("Переменные (имя — значение — описание):", ACCENT)
	var commands: = _commands()
	var names: = commands.keys()
	names.sort()
	for name in names:
		log_line("  %s = %s — %s" % [name, _fmt(commands[name]["get"].call()), str(commands[name]["desc"])])
	log_line("Команды: help find clear echo status map disconnect quit give cl_righthand console", ACCENT)


func _run_find(args: Array) -> void :
	if args.is_empty():
		log_line("Usage: find <текст>", WARN)
		return
	var needle: = str(args[0]).to_lower()
	var commands: = _commands()
	var names: = commands.keys()
	names.sort()
	for name in names:
		if name.find(needle) != -1 or str(commands[name]["desc"]).to_lower().find(needle) != -1:
			log_line("  %s = %s — %s" % [name, _fmt(commands[name]["get"].call()), str(commands[name]["desc"])])


func _run_status() -> void :
	log_line("HEADSHOT OFF v%s" % str(ProjectSettings.get_setting("application/config/version", "0")), ACCENT)
	log_line("  карта: %s | режим: %s" % [Settings.map_id, Settings.game_mode])
	log_line("  sens: %.2f | fov: %.0f | volume: %.0f%%" % [Settings.mouse_sensitivity, Settings.fov, Settings.master_volume * 100.0])
	log_line("  fps: %d | платформа: %s" % [Engine.get_frames_per_second(), OS.get_name()])


func _run_map(args: Array) -> void :
	if args.is_empty():
		log_line("Usage: map <yard|mesa|lego>", WARN)
		return
	var id: = str(args[0]).to_lower().replace("de_", "").replace("cs_", "")
	if not MapData.has_map(id):
		log_line('Unknown map: "%s" (доступны: yard, mesa, lego)' % str(args[0]), ERROR)
		return
	Settings.map_id = id
	Settings.queue_save_settings()
	log_line("Карта: %s (%s)" % [id, str(MapData.get_map(id)["name"])], ACCENT)
	var scene: = get_tree().current_scene
	if scene != null and scene.scene_file_path != "res://main_menu.tscn":
		log_line("Перезагрузка сцены...", WARN)
		get_tree().paused = false
		open = false
		visible = false
		get_tree().change_scene_to_file(scene.scene_file_path)
	else:
		log_line("Применится при запуске игры.", WARN)


func _run_disconnect() -> void :
	var scene: = get_tree().current_scene
	if scene != null and scene.scene_file_path == "res://main_menu.tscn":
		log_line("Вы уже в меню.", WARN)
		return
	get_tree().paused = false
	open = false
	visible = false
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _weapon_ids() -> Array:
	return WeaponData.WEAPONS.keys()
