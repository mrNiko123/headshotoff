extends CanvasLayer









signal rematch_requested
signal menu_requested

const UITheme = preload("res://scripts/ui_theme.gd")
const DMOnlineCounter = preload("res://scripts/dm_online_counter.gd")

const MATCH_TIME: = 300.0


const FIGHTERS: = 5
const ACCENT: = Color(1.0, 0.55, 0.16, 1.0)
const ACCENT_BRIGHT: = Color(1.0, 0.8, 0.4, 1.0)
const PANEL: = Color(0.03, 0.038, 0.052, 0.93)
const PANEL_2: = Color(0.055, 0.068, 0.09, 0.97)
const PANEL_3: = Color(0.08, 0.096, 0.124, 1.0)
const BORDER: = Color(0.17, 0.205, 0.25, 1.0)
const TEXT: = Color(0.94, 0.93, 0.9, 1.0)
const MUTED: = Color(0.62, 0.665, 0.725, 1.0)
const GREEN: = Color(0.36, 1.0, 0.55, 1.0)
const RED: = Color(1.0, 0.31, 0.27, 1.0)
const CYAN: = Color(0.32, 0.86, 1.0, 1.0)

var _root: Control
var _timer_panel: PanelContainer
var _timer_label: Label
var _timer_bar: ProgressBar


var _timer_shown_second: = -1
var _timer_red: = false
var _timer_fill_red: = false
var _team_label: Label
var _online_count: = 0
var _online_counter

var _last_rows: Array = []

var _popup_box: VBoxContainer
var _announce_label: Label
var _announce_tween: Tween
var _respawn_label: Label
var _guard_label: Label
var _killed_label: Label
var _killed_tween: Tween

var _intro_overlay: Control
var _intro_panel: PanelContainer
var _intro_count: Label

var _scoreboard: Control
var _sb_table: VBoxContainer
var _sb_timer: Label

var _result_overlay: Control
var _result_table: VBoxContainer
var _result_title: Label
var _result_subtitle: Label
var _result_place: Label
var _result_points: Label
var _result_stats: Label
var _result_timer: Label

var _player_name: = "ИГРОК"


func _ready() -> void :
	layer = 20
	_build_root()
	_build_timer_panel()
	_build_popups()
	_build_intro()
	_build_scoreboard()
	_build_result()
	_build_online_counter()
	_build_br_status()


func setup(player_name: String, online: = -1) -> void :
	_player_name = player_name if not player_name.is_empty() else "ИГРОК"
	if online >= 0:
		_online_count = online
	elif _online_counter != null:



		_online_count = int(_online_counter.current_count())


func _build_online_counter() -> void :
	_online_counter = DMOnlineCounter.new()
	add_child(_online_counter)
	_online_counter.updated.connect(_on_online_updated)
	_on_online_updated(_online_counter.current_count())


func _on_online_updated(count: int) -> void :
	_online_count = count




func _build_root() -> void :
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = UITheme.make_theme(ACCENT)
	add_child(_root)


func _box(bg: Color, border: Color, width: = 1, radius: = 10, 
		pad: = 12.0) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = pad
	box.content_margin_right = pad
	box.content_margin_top = pad
	box.content_margin_bottom = pad
	box.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	box.shadow_size = 7
	box.shadow_offset = Vector2(0.0, 3.0)
	return box


func _label(text: String, size: int, color: Color, weight: = 700, 
		display: = false) -> Label:
	var label: = Label.new()
	label.text = text
	label.add_theme_font_override("font", 
		UITheme.display_font(weight) if display else UITheme.ui_font(weight))
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _build_timer_panel() -> void :
	_timer_panel = PanelContainer.new()
	_timer_panel.name = "MatchTimer"
	_timer_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_timer_panel.offset_left = -130.0
	_timer_panel.offset_top = 14.0
	_timer_panel.offset_right = 130.0
	_timer_panel.offset_bottom = 94.0
	_timer_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_timer_panel.add_theme_stylebox_override("panel", 
		_box(Color(0.018, 0.024, 0.034, 0.94), BORDER, 1, 12, 10.0))
	_root.add_child(_timer_panel)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 1)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_timer_panel.add_child(column)

	_timer_label = _label("05:00", 38, TEXT, 700, true)
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_timer_label)

	_timer_bar = ProgressBar.new()
	_timer_bar.max_value = MATCH_TIME
	_timer_bar.value = MATCH_TIME
	_timer_bar.show_percentage = false
	_timer_bar.custom_minimum_size = Vector2(0, 5)
	_timer_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg: = StyleBoxFlat.new()
	bg.bg_color = Color(1.0, 1.0, 1.0, 0.1)
	bg.set_corner_radius_all(3)
	var fill: = StyleBoxFlat.new()
	fill.bg_color = ACCENT
	fill.set_corner_radius_all(3)
	_timer_bar.add_theme_stylebox_override("background", bg)
	_timer_bar.add_theme_stylebox_override("fill", fill)
	column.add_child(_timer_bar)

	_team_label = _label("", 12, TEXT, 700, true)
	_team_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_team_label.visible = false
	column.add_child(_team_label)


func set_team_score(alpha: int, bravo: int) -> void :
	if _team_label == null:
		return
	_team_label.visible = true
	_team_label.text = "СВОИ %d : %d ВРАГ" % [alpha, bravo]
	_team_label.add_theme_color_override("font_color", 
		GREEN if alpha >= bravo else RED)


func _row_style(is_player: bool) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	if is_player:
		box.bg_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.16)
		box.border_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.55)
	else:
		box.bg_color = Color(1.0, 1.0, 1.0, 0.025)
		box.border_color = Color(1.0, 1.0, 1.0, 0.0)
	box.set_border_width_all(1 if is_player else 0)
	box.set_corner_radius_all(5)
	box.content_margin_left = 5.0
	box.content_margin_right = 6.0
	box.content_margin_top = 1.0
	box.content_margin_bottom = 1.0
	return box


func _build_popups() -> void :
	var layer: = Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(layer)

	_popup_box = VBoxContainer.new()
	_popup_box.set_anchors_preset(Control.PRESET_CENTER)
	_popup_box.offset_left = -300.0
	_popup_box.offset_top = -150.0
	_popup_box.offset_right = 300.0
	_popup_box.offset_bottom = 40.0
	_popup_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	_popup_box.add_theme_constant_override("separation", 2)
	_popup_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_popup_box)

	_announce_label = _label("", 34, ACCENT_BRIGHT, 800, true)
	_announce_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_announce_label.offset_left = -380.0
	_announce_label.offset_top = 148.0
	_announce_label.offset_right = 380.0
	_announce_label.offset_bottom = 200.0
	_announce_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_announce_label.add_theme_constant_override("outline_size", 14)
	_announce_label.add_theme_color_override("font_outline_color", 
		Color(0.02, 0.01, 0.0, 0.9))
	_announce_label.modulate.a = 0.0
	layer.add_child(_announce_label)

	_respawn_label = _label("", 22, ACCENT_BRIGHT, 800, true)
	_respawn_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_respawn_label.offset_left = -280.0
	_respawn_label.offset_top = -168.0
	_respawn_label.offset_right = 280.0
	_respawn_label.offset_bottom = -128.0
	_respawn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_respawn_label.add_theme_constant_override("outline_size", 10)
	_respawn_label.add_theme_color_override("font_outline_color", 
		Color(0.02, 0.01, 0.0, 0.85))
	_respawn_label.visible = false
	layer.add_child(_respawn_label)



	_guard_label = _label("", 16, CYAN, 800, true)
	_guard_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_guard_label.offset_left = -300.0
	_guard_label.offset_top = -246.0
	_guard_label.offset_right = 300.0
	_guard_label.offset_bottom = -214.0
	_guard_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_guard_label.add_theme_constant_override("outline_size", 8)
	_guard_label.add_theme_color_override("font_outline_color", 
		Color(0.0, 0.03, 0.05, 0.9))
	_guard_label.visible = false
	layer.add_child(_guard_label)

	_killed_label = _label("", 18, RED, 800)
	_killed_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_killed_label.offset_left = -320.0
	_killed_label.offset_top = -204.0
	_killed_label.offset_right = 320.0
	_killed_label.offset_bottom = -172.0
	_killed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_killed_label.add_theme_constant_override("outline_size", 8)
	_killed_label.add_theme_color_override("font_outline_color", 
		Color(0.02, 0.0, 0.0, 0.9))
	_killed_label.visible = false
	layer.add_child(_killed_label)


func _build_intro() -> void :
	_intro_overlay = Control.new()
	_intro_overlay.name = "Intro"
	_intro_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro_overlay.visible = false
	_root.add_child(_intro_overlay)

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.008, 0.01, 0.016, 0.66)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro_overlay.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro_overlay.add_child(center)

	_intro_panel = PanelContainer.new()
	_intro_panel.custom_minimum_size = Vector2(700, 0)
	_intro_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro_panel.add_theme_stylebox_override("panel", 
		_box(Color(0.024, 0.03, 0.042, 0.985), Color(0.42, 0.26, 0.1, 1.0), 
			2, 14, 26.0))
	center.add_child(_intro_panel)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro_panel.add_child(column)

	var kicker: = _label("ЛЮБИТЕЛЬСКИЙ РЕЖИМ  ·  РЕЙТИНГ НЕ ВЛИЯЕТ", 10, 
		ACCENT_BRIGHT, 800)
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(kicker)

	var title: = _label("DEATHMATCH", 58, TEXT, 800, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)

	var map_line: = _label("ПЕРЕУЛОК «ПЛЮЩ»  ·  %d БОЙЦОВ  ·  5 МИНУТ" % FIGHTERS, 12, 
		MUTED, 700)
	map_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(map_line)

	var rule: = ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 1)
	rule.color = Color(1.0, 1.0, 1.0, 0.1)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(rule)

	var rules: = _label(
		"УБИЙСТВО +100   ·   ХЕДШОТ +50   ·   ПОМОЩЬ +25   ·   ПЕРВАЯ КРОВЬ +25", 
		11, TEXT, 700)
	rules.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(rules)

	var tip: = _label(
		"Побеждает тот, кто наберёт больше всех очков за матч. "
			+ "Смерть не выключает из боя: после возрождения даётся "
			+ "короткий щит, он снимается вашим первым выстрелом.", 
		11, MUTED, 600)
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(560, 0)
	column.add_child(tip)

	_intro_count = _label("3", 54, ACCENT_BRIGHT, 800, true)
	_intro_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intro_count.custom_minimum_size = Vector2(0, 66)
	_intro_count.add_theme_constant_override("outline_size", 14)
	_intro_count.add_theme_color_override("font_outline_color", 
		Color(0.02, 0.01, 0.0, 0.9))
	_intro_count.visible = false
	column.add_child(_intro_count)


func _build_scoreboard() -> void :
	_scoreboard = Control.new()
	_scoreboard.name = "FullTable"
	_scoreboard.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scoreboard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scoreboard.visible = false
	_root.add_child(_scoreboard)

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.006, 0.008, 0.012, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scoreboard.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scoreboard.add_child(center)

	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(780, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", 
		_box(Color(0.022, 0.028, 0.04, 0.985), BORDER, 1, 12, 22.0))
	center.add_child(panel)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(column)

	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(head)
	var title: = _label("DEATHMATCH  ·  ТАБЛИЦА МАТЧА", 14, ACCENT_BRIGHT, 800)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	_sb_timer = _label("05:00", 18, TEXT, 800, true)
	head.add_child(_sb_timer)

	var rule: = ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 1)
	rule.color = Color(1.0, 1.0, 1.0, 0.1)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(rule)

	_sb_table = VBoxContainer.new()
	_sb_table.add_theme_constant_override("separation", 2)
	_sb_table.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_sb_table)


func _build_result() -> void :
	_result_overlay = Control.new()
	_result_overlay.name = "Result"
	_result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_result_overlay.visible = false
	_root.add_child(_result_overlay)

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.006, 0.008, 0.012, 0.9)
	_result_overlay.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_result_overlay.add_child(center)

	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(860, 0)
	panel.add_theme_stylebox_override("panel", 
		_box(Color(0.022, 0.028, 0.04, 0.995), Color(0.42, 0.26, 0.1, 1.0), 
			2, 14, 26.0))
	center.add_child(panel)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	panel.add_child(column)

	_result_title = _label("МАТЧ ЗАВЕРШЁН", 34, TEXT, 800, true)
	_result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_result_title)

	_result_subtitle = _label("DEATHMATCH  ·  ПЕРЕУЛОК «ПЛЮЩ»  ·  БЕЗ РЕЙТИНГА", 10, 
		MUTED, 700)
	_result_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_result_subtitle)

	var hero: = HBoxContainer.new()
	hero.add_theme_constant_override("separation", 22)
	hero.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(hero)

	_result_place = _label("1 МЕСТО", 30, ACCENT_BRIGHT, 800, true)
	hero.add_child(_result_place)

	var points_column: = VBoxContainer.new()
	points_column.add_theme_constant_override("separation", -3)
	hero.add_child(points_column)
	var points_caption: = _label("ВАШИ ОЧКИ", 9, MUTED, 700)
	points_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	points_column.add_child(points_caption)
	_result_points = _label("0", 34, TEXT, 800, true)
	_result_points.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	points_column.add_child(_result_points)

	_result_timer = _label("", 11, MUTED, 700)
	_result_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_result_timer)

	_result_stats = _label("", 11, TEXT, 600)
	_result_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_result_stats)

	var rule: = ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 1)
	rule.color = Color(1.0, 1.0, 1.0, 0.1)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(rule)

	_result_table = VBoxContainer.new()
	_result_table.add_theme_constant_override("separation", 2)
	_result_table.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_result_table)

	var buttons: = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons)

	var again: = Button.new()
	again.text = "СЫГРАТЬ ЕЩЁ"
	again.custom_minimum_size = Vector2(200, 44)
	again.add_theme_font_override("font", UITheme.display_font(700))
	again.add_theme_font_size_override("font_size", 16)
	again.add_theme_color_override("font_color", Color(0.06, 0.04, 0.02, 1.0))
	again.add_theme_color_override("font_hover_color", Color(0.06, 0.04, 0.02, 1.0))
	again.add_theme_stylebox_override("normal", _button_style(ACCENT, ACCENT))
	again.add_theme_stylebox_override("hover", _button_style(ACCENT_BRIGHT, 
		ACCENT_BRIGHT))
	again.add_theme_stylebox_override("pressed", _button_style(ACCENT_BRIGHT, 
		ACCENT_BRIGHT))
	again.pressed.connect(Sfx.play_click)
	again.pressed.connect( func() -> void : rematch_requested.emit())
	buttons.add_child(again)

	var menu: = Button.new()
	menu.text = "В МЕНЮ"
	menu.custom_minimum_size = Vector2(170, 44)
	menu.add_theme_font_override("font", UITheme.display_font(700))
	menu.add_theme_font_size_override("font_size", 16)
	menu.add_theme_stylebox_override("normal", _button_style(PANEL_2, BORDER))
	menu.add_theme_stylebox_override("hover", _button_style(PANEL_3, 
		Color(0.35, 0.4, 0.48, 1.0)))
	menu.add_theme_stylebox_override("pressed", _button_style(PANEL_3, 
		Color(0.35, 0.4, 0.48, 1.0)))
	menu.pressed.connect(Sfx.play_click)
	menu.pressed.connect( func() -> void : menu_requested.emit())
	buttons.add_child(menu)


func _button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(8)
	box.content_margin_left = 18.0
	box.content_margin_right = 18.0
	box.content_margin_top = 10.0
	box.content_margin_bottom = 10.0
	return box




func override_result_title(text: String) -> void :
	if _result_title != null and is_instance_valid(_result_title):
		_result_title.text = text
		_result_title.add_theme_color_override("font_color", 
			Color(0.32, 0.86, 1.0, 1.0))


func set_timer(seconds: float) -> void :
	var value: = clampf(seconds, 0.0, MATCH_TIME)
	var total: = int(ceil(value))
	var red: = value <= 30.0
	if total != _timer_shown_second:
		_timer_shown_second = total
		var text: = "%02d:%02d" % [int(total / 60.0), total % 60]
		if _timer_label != null:
			_timer_label.text = text
		if _sb_timer != null:
			_sb_timer.text = text
	if red != _timer_red:
		_timer_red = red
		if _timer_label != null:
			_timer_label.add_theme_color_override("font_color", 
				RED if red else TEXT)
	if _timer_bar != null:
		_timer_bar.value = value
		if red != _timer_fill_red:
			_timer_fill_red = red
			var fill: = _timer_bar.get_theme_stylebox("fill") as StyleBoxFlat
			if fill != null:
				fill.bg_color = RED if red else ACCENT


func set_leaderboard(rows: Array) -> void :
	_last_rows = rows
	if _scoreboard != null and _scoreboard.visible:
		_rebuild_scoreboard_table()


func popup(text: String, color: = ACCENT_BRIGHT) -> void :
	if _popup_box == null:
		return
	var label: = _label(text, 26, color, 800, true)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_constant_override("outline_size", 10)
	label.add_theme_color_override("font_outline_color", 
		Color(0.02, 0.01, 0.0, 0.85))
	label.modulate.a = 0.0
	label.pivot_offset = Vector2(300.0, 18.0)
	label.scale = Vector2(0.86, 0.86)
	_popup_box.add_child(label)
	var tween: = label.create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(label, "scale", Vector2.ONE, 0.2)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.95)
	tween.tween_property(label, "modulate:a", 0.0, 0.38)
	tween.tween_callback(label.queue_free)


func announce(text: String, color: = ACCENT_BRIGHT) -> void :
	if _announce_label == null:
		return
	if _announce_tween != null and _announce_tween.is_valid():
		_announce_tween.kill()
	_announce_label.text = text
	_announce_label.add_theme_color_override("font_color", color)
	_announce_label.modulate.a = 0.0
	_announce_label.scale = Vector2(1.08, 1.08)
	_announce_label.pivot_offset = _announce_label.size * 0.5
	_announce_tween = create_tween()
	_announce_tween.set_parallel(true)
	_announce_tween.tween_property(_announce_label, "modulate:a", 1.0, 0.14)
	_announce_tween.tween_property(_announce_label, "scale", Vector2.ONE, 0.26)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_announce_tween.chain().tween_interval(1.1)
	_announce_tween.chain().tween_property(_announce_label, "modulate:a", 0.0, 0.4)


func show_respawn(seconds: float) -> void :
	if _respawn_label == null:
		return
	_respawn_label.visible = true
	_respawn_label.text = "ВОЗРОЖДЕНИЕ  %.1f" % maxf(seconds, 0.0)


func update_respawn(seconds: float) -> void :
	if _respawn_label == null or not _respawn_label.visible:
		return
	_respawn_label.text = "ВОЗРОЖДЕНИЕ  %.1f" % maxf(seconds, 0.0)


func hide_respawn() -> void :
	if _respawn_label != null:
		_respawn_label.visible = false



func show_guard(seconds: float) -> void :
	if _guard_label == null:
		return
	_guard_label.visible = true
	_guard_label.text = "ЩИТ СПАВНА  ·  %.1f" % maxf(seconds, 0.0)


func update_guard(seconds: float) -> void :
	if _guard_label == null or not _guard_label.visible:
		return
	_guard_label.text = "ЩИТ СПАВНА  ·  %.1f" % maxf(seconds, 0.0)


func hide_guard() -> void :
	if _guard_label != null:
		_guard_label.visible = false


func show_killed_by(killer: String, weapon: String) -> void :
	if _killed_label == null:
		return
	_killed_label.text = "ВАС УБИЛ %s   ·   %s" % [killer.to_upper(), weapon.to_upper()]
	_killed_label.visible = true
	_killed_label.modulate.a = 1.0
	if _killed_tween != null and _killed_tween.is_valid():
		_killed_tween.kill()
	_killed_tween = create_tween()
	_killed_tween.tween_interval(2.4)
	_killed_tween.tween_property(_killed_label, "modulate:a", 0.0, 0.4)
	_killed_tween.tween_callback( func() -> void : _killed_label.visible = false)


func hide_killed_by() -> void :
	if _killed_tween != null and _killed_tween.is_valid():
		_killed_tween.kill()
	if _killed_label != null:
		_killed_label.visible = false




func show_intro() -> void :
	if _intro_overlay == null:
		return
	_intro_overlay.visible = true
	_intro_overlay.modulate.a = 0.0
	var tween: = create_tween()
	tween.tween_property(_intro_overlay, "modulate:a", 1.0, 0.22)




func set_intro_countdown(text: String) -> void :
	if _intro_count == null:
		return
	_intro_count.text = text
	_intro_count.visible = true
	_intro_count.pivot_offset = _intro_count.size * 0.5
	_intro_count.modulate.a = 0.0
	_intro_count.scale = Vector2(0.84, 0.84)
	var tween: = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_intro_count, "modulate:a", 1.0, 0.1)
	tween.tween_property(_intro_count, "scale", Vector2.ONE, 0.2)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)




func set_match_hud_visible(on: bool) -> void :
	for node in [_timer_panel, _popup_box, _announce_label]:
		if node != null and is_instance_valid(node):
			(node as CanvasItem).visible = on
	if not on:
		hide_respawn()
		hide_killed_by()
		hide_guard()


func hide_intro() -> void :
	if _intro_overlay == null or not _intro_overlay.visible:
		return
	if _intro_count != null:
		_intro_count.visible = false
	var tween: = create_tween()
	tween.tween_property(_intro_overlay, "modulate:a", 0.0, 0.22)
	await tween.finished
	_intro_overlay.visible = false


func show_scoreboard() -> void :
	if _scoreboard == null or _result_overlay.visible:
		return
	_rebuild_scoreboard_table()
	_scoreboard.visible = true


func hide_scoreboard() -> void :
	if _scoreboard != null:
		_scoreboard.visible = false


func _rebuild_scoreboard_table() -> void :
	if _sb_table == null:
		return
	for child in _sb_table.get_children():
		_sb_table.remove_child(child)
		child.queue_free()
	if _last_rows.is_empty():
		return
	_sb_table.add_child(_table_header())
	for data in _last_rows:
		_sb_table.add_child(_table_row(data))


func _table_header() -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var cells: = [
		["#", 40, HORIZONTAL_ALIGNMENT_LEFT], 
		["БОЕЦ", 0, HORIZONTAL_ALIGNMENT_LEFT], 
		["ОЧКИ", 82, HORIZONTAL_ALIGNMENT_RIGHT], 
		["УБИЙСТВА", 76, HORIZONTAL_ALIGNMENT_RIGHT], 
		["СМЕРТИ", 70, HORIZONTAL_ALIGNMENT_RIGHT], 
		["ПОМОЩЬ", 70, HORIZONTAL_ALIGNMENT_RIGHT], 
	]
	for cell in cells:
		var label: = _label(str(cell[0]), 9, MUTED, 800)
		var width: = int(cell[1])
		if width > 0:
			label.custom_minimum_size = Vector2(width, 0)
		else:
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = int(cell[2])
		row.add_child(label)
	return row


func _table_row(data: Dictionary, compact: = false) -> Control:
	var is_player: = bool(data.get("is_player", false))
	var panel: = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _row_style(is_player))
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)
	row.add_child(_cell(str(int(data.get("rank", 0))), 40, 
		HORIZONTAL_ALIGNMENT_LEFT, ACCENT_BRIGHT if is_player else MUTED, 10))
	var name_cell: = _cell(str(data.get("name", "—")), 0, 
		HORIZONTAL_ALIGNMENT_LEFT, ACCENT_BRIGHT if is_player else TEXT, 12)
	name_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_cell.clip_text = true
	row.add_child(name_cell)
	row.add_child(_cell(_fmt(int(data.get("points", 0))), 82, 
		HORIZONTAL_ALIGNMENT_RIGHT, ACCENT_BRIGHT if is_player else TEXT, 14))
	row.add_child(_cell(str(int(data.get("kills", 0))), 76, 
		HORIZONTAL_ALIGNMENT_RIGHT, TEXT, 12))
	row.add_child(_cell(str(int(data.get("deaths", 0))), 70, 
		HORIZONTAL_ALIGNMENT_RIGHT, MUTED, 12))
	row.add_child(_cell(str(int(data.get("assists", 0))), 70, 
		HORIZONTAL_ALIGNMENT_RIGHT, MUTED, 12))
	if compact:
		row.custom_minimum_size = Vector2(0, 22)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _cell(text: String, width: int, align: int, color: Color, 
		size: int) -> Label:
	var label: = _label(text, size, color, 700)
	if width > 0:
		label.custom_minimum_size = Vector2(width, 0)
	label.horizontal_alignment = align
	return label




func show_result(rows: Array, player_row: Dictionary, match_stats: Dictionary) -> void :
	if _result_overlay == null:
		return
	hide_scoreboard()
	hide_respawn()
	hide_killed_by()
	_result_overlay.visible = true
	_result_overlay.modulate.a = 0.0
	var rank: = int(player_row.get("rank", rows.size()))
	var points: = int(player_row.get("points", 0))
	var kills: = int(player_row.get("kills", 0))
	var deaths: = int(player_row.get("deaths", 0))
	var assists: = int(player_row.get("assists", 0))
	var headshots: = int(player_row.get("headshots", 0))
	_result_place.text = "%d МЕСТО" % rank
	_result_place.add_theme_color_override("font_color", 
		ACCENT_BRIGHT if rank == 1 else TEXT)
	_result_points.text = _fmt(points)
	_result_title.text = "ПОБЕДА" if rank == 1 else "МАТЧ ЗАВЕРШЁН"
	_result_title.add_theme_color_override("font_color", 
		ACCENT_BRIGHT if rank == 1 else TEXT)
	_result_timer.text = "ИЗ %d БОЙЦОВ  ·  БЕЗ РЕЙТИНГА  ·  ОНЛАЙН %d" % [
		rows.size(), _online_count]
	var shots: = int(match_stats.get("shots", 0))
	var hits: = int(match_stats.get("hits", 0))
	var accuracy: = 0.0
	if shots > 0:
		accuracy = float(hits) / float(shots) * 100.0
	_result_stats.text = (
		"УБИЙСТВА %d   ·   СМЕРТИ %d   ·   ПОМОЩИ %d   ·   ХЕДШОТЫ %d\n"
		+ "ТОЧНОСТЬ %.0f%%   ·   УРОН %d   ·   ПОЛУЧЕНО %d"
	) % [
		kills, deaths, assists, headshots, accuracy, 
		int(match_stats.get("damage", 0.0)), 
		int(match_stats.get("damage_taken", 0.0)), 
	]

	for child in _result_table.get_children():
		_result_table.remove_child(child)
		child.queue_free()
	_result_table.add_child(_table_header())
	for data in rows:
		_result_table.add_child(_table_row(data, true))

	var tween: = create_tween()
	tween.tween_property(_result_overlay, "modulate:a", 1.0, 0.28)




func _unhandled_input(event: InputEvent) -> void :
	if _result_overlay != null and _result_overlay.visible:
		return
	if event.is_action_pressed("scoreboard"):
		show_scoreboard()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("scoreboard"):
		hide_scoreboard()
		get_viewport().set_input_as_handled()


func _fmt(value: int) -> String:
	var text: = str(maxi(value, 0))
	var out: = ""
	var count: = 0
	for i in range(text.length() - 1, -1, -1):
		out = text[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = " " + out
	return out


# ---------- БАТЛ РОЯЛЬ: панель статуса (живые / зона) ----------

var _br_panel: PanelContainer
var _br_alive_label: Label
var _br_zone_label: Label
var _br_zone_timer: Label


func _build_br_status() -> void :
	_br_panel = PanelContainer.new()
	_br_panel.name = "BrStatus"
	_br_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_br_panel.offset_left = 16.0
	_br_panel.offset_top = 14.0
	_br_panel.offset_right = 246.0
	_br_panel.offset_bottom = 118.0
	_br_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_br_panel.add_theme_stylebox_override("panel", 
		_box(Color(0.02, 0.03, 0.05, 0.9), Color(0.55, 0.3, 1.0, 0.7), 1, 12, 
		10.0))
	_br_panel.visible = false
	_root.add_child(_br_panel)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_br_panel.add_child(column)

	_br_alive_label = _label("ЖИВЫХ: 20/20", 20, TEXT, 700, true)
	_br_alive_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_br_alive_label)

	_br_zone_label = _label("ЗОНА СЖИМАЕТСЯ", 12, 
		Color(0.78, 0.55, 1.0, 1.0), 700, true)
	_br_zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_br_zone_label)

	_br_zone_timer = _label("—", 24, ACCENT_BRIGHT, 700, true)
	_br_zone_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_br_zone_timer)


func set_br_status(alive: int, total: int, zone_text: String, 
		timer_text: String) -> void :
	if _br_panel == null:
		_build_br_status()
	_br_alive_label.text = "ЖИВЫХ: %d/%d" % [alive, total]
	_br_zone_label.text = zone_text
	_br_zone_timer.text = timer_text


func set_br_panel_visible(on: bool) -> void :
	if _br_panel != null:
		_br_panel.visible = on


func set_timer_visible(on: bool) -> void :
	if _timer_panel != null:
		_timer_panel.visible = on
