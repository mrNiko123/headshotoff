extends CanvasLayer




signal resume_requested
signal restart_requested
signal menu_requested
signal settings_requested


signal duel_menu_requested

const UITheme = preload("res://scripts/ui_theme.gd")
const UIIcon = preload("res://scripts/ui_icon.gd")
const WeaponData = preload("res://scripts/weapon_data.gd")
const HUDWeaponIcon = preload("res://scripts/hud_weapon_icon.gd")
const WeaponPreview = preload("res://scripts/weapon_preview.gd")
const ReloadBar = preload("res://scripts/reload_bar.gd")
const FpsCounter = preload("res://scripts/fps_counter.gd")
const InputOverlay = preload("res://scripts/input_overlay.gd")
const LevelBadge = preload("res://scripts/level_badge.gd")
const CountryFlag = preload("res://scripts/country_flag.gd")
const KillVignetteShader = preload("res://shaders/kill_vignette.gdshader")
const DeathFxShader = preload("res://shaders/death_fx.gdshader")

const MAX_KILL_CARDS: = 5




const KILLFEED_ROWS: = 5
const KILL_CARD_STEP: = 48.0
const KILL_CARD_ANGLE: = 8.0
const KILL_CARD_DROP: = 3.0


const KILL_CARD_HEIGHT: = 56.0

const KILL_CARD_FAN_HEIGHT: = 68.0


const KILL_CARD_IDLE: = 5.0

const KILL_CARD_FOLD_TIME: = 0.22
const KILL_CARD_FALL_TIME: = 0.42

const KILL_CARD_LIFT: = 6.0
const STRAFE_METER_MIN: = 4.0
const STRAFE_METER_MAX: = 30.0



const WEAPON_SLOTS: = [
	{"kind": "primary", "action": "slot_primary"}, 
	{"kind": "pistol", "action": "slot_secondary"}, 
	{"kind": "knife", "action": "slot_melee"}, 
]



const WEAPON_SLOT_SIZE: = Vector2(208.0, 66.0)
const WEAPON_SLOT_NUMBER_WIDTH: = 22.0
const WEAPON_SLOT_FONT: = 18
const WEAPON_SLOT_SEPARATION: = 4.0
const WEAPON_SLOT_ROW_GAP: = 10.0
const WEAPON_SLOT_BASE_HEIGHT: = 720.0
const WEAPON_SLOT_MAX_SCALE: = 1.5
const RELOAD_BAR_WIDTH: = 100.0
const RELOAD_BAR_HEIGHT: = 4.0



const STREAMER_SIZES: = [
	Vector2(264.0, 68.0), 
	Vector2(340.0, 116.0), 
	Vector2(452.0, 154.0), 
	Vector2(292.0, 202.0), 
	Vector2(252.0, 312.0), 
]
const STREAMER_TEXT: = Color(0.955, 0.95, 0.935, 1.0)
const STREAMER_MUTED: = Color(0.6, 0.64, 0.69, 1.0)
const STREAMER_GREEN: = Color(0.42, 1.0, 0.56, 1.0)
const STREAMER_RED: = Color(1.0, 0.32, 0.26, 1.0)

var _last_ammo: = -1
var _last_magazine: = -1
var _last_melee: = false
var _score: = 0
var _kills: = 0
var _headshots: = 0
var _shots: = 0
var _hits: = 0
var _accuracy: = 0.0
var _speed: = 0.0
var _online: = 0
var _toast_tween: Tween
var _hint_tween: Tween
var _badge_tween: Tween
var _strafe_tween: Tween
var _kill_cards: Array[Control] = []


var _kill_card_streak: = 0
var _kill_card_idle_tween: Tween
var _kill_card_collapse_tween: Tween
var _cards_collapsing: = false

var _scoreboard: Control



var _scoreboard_enabled: = true


var _pause_stats_override: = ""
var _badge: Control
var _kill_counter: Label


var _kill_counter_row: Control
var _cards_fan: Control
var _fx_layer: Control

var _kill_vignette: ColorRect
var _kill_vignette_material: ShaderMaterial
var _kill_popup_layer: Control


var _health_panel: Control
var _health_label: Label
var _health_fill: ColorRect
var _damage_vignette: ColorRect
var _damage_material: ShaderMaterial
var _damage_tween: Tween
var _death_fx: ColorRect
var _death_material: ShaderMaterial
var _death_tween: Tween
var _countdown_label: Label
var _countdown_tween: Tween
var _duel_banner: Label
var _duel_banner_tween: Tween


var _weapon_roll_layer: Control
var _weapon_roll_backdrop: ColorRect
var _weapon_roll_caption: Label
var _weapon_roll_hint: Label
var _weapon_roll_cards: Array[Dictionary] = []
var _weapon_roll_token: = 0
var _duel_score_panel: PanelContainer
var _duel_score_label: Label


var _skull_row: Control

var _score_player_avatar: TextureRect
var _score_bot_avatar: TextureRect



var _streamer_panel: PanelContainer
var _streamer_refs: Dictionary = {}
var _streamer_style: = -1
var _result_overlay: Control
var _result_title: Label
var _result_subtitle: Label
var _result_delta: Label
var _result_rating: Label
var _result_stats: Label
var _result_note: Label
var _result_menu: Button


var _ring_pool: Array[Control] = []
var _burst_pool: Array[Control] = []
var _popup_pool: Array[Label] = []


var _headshot_popup_pool: Array[Label] = []


var _card_pool: Array[Control] = []


var _card_order_cache: Array = []
var _strafe_meter: Control
var _strafe_kicker: Label
var _strafe_value: Label
var _strafe_fill: ColorRect
var _strafe_track: ColorRect
var _strafe_width: = 140.0
var _strafe_visible: = false
var _strafe_shown_speed: = -1.0
var _strafe_shown_chain: = -1
var _strafe_shown_ratio: = -1.0
var _strafe_shown_hot: = false
var _strafe_text_ms: = 0
var _last_spread: = -999.0
var _theme_accent: = Color.BLACK
var _sb_values: Dictionary = {}
var _session_label: Label
var _session_time: = 0.0
var _session_shown: = -1.0


var _weapon_icons: Array[Control] = []
var _weapon_numbers: Array[Label] = []
var _weapon_rows: Array[HBoxContainer] = []
var _weapon_list_column: VBoxContainer
var _weapon_slot_scale: = 1.0
var _weapon_slot_scaled: = false
var _weapon_active: = -1
var _reload_bar: Control
var _reload_bar_shown: = false
var _reload_tween: Tween

var _reload_time_label: Label



var _killfeed_rows: Array[PanelContainer] = []
var _killfeed_next: = 0


var _fps_counter: Label
var _input_overlay: Control



var _hud_widgets: Dictionary = {}
var _hud_defaults: Dictionary = {}
var _hud_layout_ready: = false


var _editor_preview: = false

@onready var root: Control = $Root
@onready var crosshair = %Crosshair
@onready var scope = %ScopeOverlay


var ammo_value: Label
var reserve_value: Label
var reload_label: Label
@onready var killfeed: VBoxContainer = %KillFeed
@onready var kill_zone: Control = %KillZone
@onready var toast_label: Label = %Toast
@onready var hint: Label = %Hint
@onready var pause_overlay: Control = %PauseOverlay
@onready var pause_stats: Label = %PauseStats
@onready var fade: ColorRect = %Fade


func _ready() -> void :
	_theme_accent = Settings.hud_accent
	root.theme = UITheme.make_theme(_theme_accent)
	pause_overlay.hide()
	fade.visible = false
	fade.color = UITheme.BG
	toast_label.modulate.a = 0.0

	_build_session_timer()
	_build_strafe_meter()
	_build_kill_fx()
	_build_kill_zone()
	_warm_kill_pools()
	_build_scoreboard()
	_build_weapon_list()
	_build_reload_bar()
	_build_hud_widgets()
	_build_streamer_widget()


	_build_health_panel()
	_build_duel_overlays()
	_register_hud_widgets()

	root.move_child(fade, root.get_child_count() - 1)

	%ResumeButton.pressed.connect(Sfx.play_click)
	%ResumeButton.pressed.connect( func() -> void : resume_requested.emit())
	%PauseSettingsButton.pressed.connect(Sfx.play_click)
	%PauseSettingsButton.pressed.connect( func() -> void : settings_requested.emit())
	%PauseMenuButton.pressed.connect(Sfx.play_click)
	%PauseMenuButton.pressed.connect( func() -> void : menu_requested.emit())

	Settings.settings_changed.connect(_on_settings_changed)

	_refresh_key_hints()
	if Settings.is_mobile():
		hint.text = "ДЖОЙСТИК — ДВИЖЕНИЕ  ·  СВАЙП — ОБЗОР  ·  ОГОНЬ / ПРЫЖОК / ПРИЦЕЛ / ПРИСЕСТЬ / ОСМОТР / ЛЕВАЯ / ТАБЛО / НОЖ  ·  РАСКЛАДКУ МОЖНО ИЗМЕНИТЬ В НАСТРОЙКАХ"
		%ExitHint.text = "II — ПАУЗА В БОЮ"
	_hint_tween = create_tween()
	_hint_tween.tween_interval(14.0)
	_hint_tween.tween_property(hint, "modulate:a", 0.0, 1.4)


	_warm_effect_shaders()





func _warm_effect_shaders() -> void :
	var warmed: Array[CanvasItem] = []
	for item in [_kill_vignette, _damage_vignette, _death_fx]:
		var rect: = item as CanvasItem
		if rect == null or rect.visible:
			continue
		rect.visible = true
		warmed.append(rect)



	if _death_fx != null:
		_death_fx.modulate.a = 0.0
	if _death_material != null:
		_death_material.set_shader_parameter("progress", 0.0)
	if scope != null and scope.has_method("warmup"):
		scope.call("warmup")
	await get_tree().process_frame
	await get_tree().process_frame
	for rect in warmed:
		if is_instance_valid(rect):
			rect.visible = false
	if is_instance_valid(_death_fx):
		_death_fx.modulate.a = 1.0




func _refresh_key_hints() -> void :
	for i in _weapon_numbers.size():
		_weapon_numbers[i].text = Settings.get_key_label_compact(
			str(WEAPON_SLOTS[i]["action"]))
	if not _weapon_numbers.is_empty():


		_weapon_slot_scaled = false
		_apply_slot_scale()
	if Settings.is_mobile():
		return
	hint.text = "%s — БАННИХОП  ·  %s/%s В ВОЗДУХЕ — СТРЕЙФ  ·  %s — ПРИСЕСТЬ  ·  ПКМ — СКОУП AWP  ·  %s — ОРУЖИЕ  ·  %s — НОЖ  ·  %s — ОСМОТР  ·  %s — ПЕРЕЗАРЯДКА  ·  %s — ТАБЛО" % [
		Settings.get_key_label_compact("jump"), 
		Settings.get_key_label_compact("move_left"), 
		Settings.get_key_label_compact("move_right"), 
		Settings.get_key_label_compact("crouch"), 
		Settings.get_key_label_compact("slot_primary"), 
		Settings.get_key_label_compact("slot_melee"), 
		Settings.get_key_label_compact("inspect"), 
		Settings.get_key_label_compact("reload"), 
		Settings.get_key_label_compact("scoreboard"), 
	]


func _on_settings_changed() -> void :
	_refresh_key_hints()
	_refresh_streamer_widget()
	if _reload_bar != null:
		_reload_bar.call("set_accent", Settings.hud_accent)
	if Settings.hud_accent == _theme_accent:
		if _session_label != null:
			_session_label.visible = Settings.session_timer
		return
	_theme_accent = Settings.hud_accent
	root.theme = UITheme.make_theme(_theme_accent)
	_style_streamer_panel()
	if _kill_vignette_material != null:
		_kill_vignette_material.set_shader_parameter("glow_color", _accent_bright())


	for popup in _popup_pool:
		popup.add_theme_color_override("font_color", _accent_bright())
	for row in _killfeed_rows:
		var labels: Dictionary = row.get_meta("labels")
		var weapon_icon: Control = labels.get("weapon_icon")
		if weapon_icon != null:
			weapon_icon.set("tint", _accent())
	if reload_label != null:
		reload_label.add_theme_color_override("font_color", _accent())
	if _reload_time_label != null:
		_reload_time_label.add_theme_color_override("font_color", _accent())
	if _weapon_icons.size() > 0:
		_refresh_weapon_tints()
	if _session_label != null:
		_session_label.visible = Settings.session_timer
		_session_label.add_theme_color_override("font_color", _accent_bright())
	if _strafe_kicker != null:
		_strafe_kicker.add_theme_color_override("font_color", _accent())
	if _strafe_track != null:
		_strafe_track.color = Color(_accent().r, _accent().g, _accent().b, 0.16)
	if _badge != null:
		_badge.queue_redraw()


func _unhandled_input(event: InputEvent) -> void :
	if pause_overlay.visible and event.is_action_pressed("ui_cancel"):
		resume_requested.emit()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("scoreboard"):
		if _scoreboard_enabled:
			_show_scoreboard()
			get_viewport().set_input_as_handled()
	elif event.is_action_released("scoreboard"):
		if _scoreboard_enabled:
			_hide_scoreboard()
			get_viewport().set_input_as_handled()






func _build_session_timer() -> void :
	_session_label = Label.new()
	_session_label.name = "SessionTimer"
	_session_label.text = "СЕССИЯ 00:00"
	_session_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_session_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_session_label.offset_left = -130.0
	_session_label.offset_top = 72.0
	_session_label.offset_right = 130.0
	_session_label.offset_bottom = 96.0
	_session_label.add_theme_font_override("font", UITheme.ui_font(600))
	_session_label.add_theme_font_size_override("font_size", 12)
	_session_label.add_theme_color_override("font_color", _accent_bright())
	_session_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_session_label.visible = Settings.session_timer
	root.add_child(_session_label)



func set_session_time(seconds: float) -> void :
	_session_time = maxf(seconds, 0.0)
	if (_session_label == null) or absf(_session_time - _session_shown) < 0.5:
		return
	_session_shown = _session_time
	var total: = int(_session_time)
	var minutes: = int(total / 60.0)
	_session_label.text = "СЕССИЯ %02d:%02d" % [minutes, total % 60]





func _build_weapon_list() -> void :
	var column: = VBoxContainer.new()
	column.name = "WeaponList"
	column.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	column.alignment = BoxContainer.ALIGNMENT_END
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(column)
	_weapon_list_column = column

	for slot in WEAPON_SLOTS:
		var row: = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_END
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(row)
		_weapon_rows.append(row)

		var icon: = Control.new()
		icon.set_script(HUDWeaponIcon)


		var kind: = str(slot["kind"])
		if kind == "primary":
			kind = Settings.weapon_id
		elif kind == "pistol":
			kind = Settings.pistol_id
		icon.set("kind", kind)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)

		var number: = Label.new()
		number.text = Settings.get_key_label_compact(str(slot["action"]))



		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.add_theme_font_override("font", UITheme.display_font(600))
		number.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.55))
		number.add_theme_constant_override("outline_size", 4)
		number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		number.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(number)

		_weapon_icons.append(icon)
		_weapon_numbers.append(number)

	_apply_slot_scale()
	get_viewport().size_changed.connect(_apply_slot_scale)
	Settings.display_changed.connect(_apply_slot_scale)

	set_active_slot(0)







func _apply_slot_scale() -> void :
	if _weapon_icons.is_empty() or _weapon_list_column == null:
		return
	var view: = get_viewport().get_visible_rect().size
	if view.y <= 0.0:
		return
	var factor: = clampf(view.y / WEAPON_SLOT_BASE_HEIGHT, 1.0, WEAPON_SLOT_MAX_SCALE)
	if _weapon_slot_scaled and is_equal_approx(factor, _weapon_slot_scale):
		return
	_weapon_slot_scale = factor
	_weapon_slot_scaled = true

	var icon_size: = WEAPON_SLOT_SIZE * factor
	var number_width: = WEAPON_SLOT_NUMBER_WIDTH * factor
	var number_font_size: = int(round(WEAPON_SLOT_FONT * factor))


	var number_font: = UITheme.display_font(600)
	for number in _weapon_numbers:
		var text_width: = number_font.get_string_size(str(number.text), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, number_font_size).x
		number_width = maxf(number_width, text_width + 4.0 * factor)
	var separation: = WEAPON_SLOT_SEPARATION * factor
	var row_gap: = WEAPON_SLOT_ROW_GAP * factor
	var margin_right: = 26.0 * factor
	var margin_bottom: = 22.0 * factor
	var rows: = float(_weapon_rows.size())
	var rows_height: = rows * icon_size.y + maxf(rows - 1.0, 0.0) * row_gap

	var column: = _weapon_list_column
	var natural_size: = Vector2(icon_size.x + separation + number_width, rows_height)
	var custom: = _hud_layout_ready and Settings.hud_layout.has("weapons")
	if custom:


		_hud_defaults["weapons"]["size"] = natural_size
		_place_hud_widget("weapons", Settings.hud_layout["weapons"])
	else:
		column.offset_right = - margin_right


		column.offset_left = - margin_right - icon_size.x - separation - number_width
		column.offset_bottom = - margin_bottom
		column.offset_top = column.offset_bottom - rows_height
	column.add_theme_constant_override("separation", int(round(row_gap)))

	for row in _weapon_rows:
		row.add_theme_constant_override("separation", int(round(separation)))

	for i in _weapon_icons.size():
		_weapon_icons[i].custom_minimum_size = icon_size
		var number: = _weapon_numbers[i]
		number.custom_minimum_size = Vector2(number_width, 0.0)
		number.add_theme_font_size_override("font_size", number_font_size)



func set_active_slot(slot: int) -> void :
	if slot == _weapon_active:
		return
	_weapon_active = slot
	for i in _weapon_icons.size():
		var active: = i == slot
		var tint: = _slot_tint(active)
		var icon: Control = _weapon_icons[i]
		icon.set("tint", tint)
		_weapon_numbers[i].add_theme_color_override("font_color", tint)




func set_primary_weapon(weapon_id: String) -> void :
	if weapon_id.is_empty():
		return


	if not _weapon_icons.is_empty():
		if weapon_id == "knife":
			_weapon_icons[2].set("kind", "knife")
		elif Settings.is_pistol(weapon_id):
			_weapon_icons[1].set("kind", weapon_id)
		else:
			_weapon_icons[0].set("kind", weapon_id)
	if crosshair != null:
		crosshair.set_weapon(weapon_id)






func _slot_tint(active: bool) -> Color:
	if active:
		return _accent_bright()
	var accent: = Settings.hud_accent.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.55)
	return Color(accent.r, accent.g, accent.b, 0.85)




func _refresh_weapon_tints() -> void :
	var index: = _weapon_active
	_weapon_active = -1
	set_active_slot(index)





func _build_reload_bar() -> void :
	_reload_bar = Control.new()
	_reload_bar.name = "ReloadBar"
	_reload_bar.set_script(ReloadBar)
	_reload_bar.set_anchors_preset(Control.PRESET_CENTER)
	_reload_bar.offset_left = - RELOAD_BAR_WIDTH * 0.5
	_reload_bar.offset_top = 26.0
	_reload_bar.offset_right = RELOAD_BAR_WIDTH * 0.5
	_reload_bar.offset_bottom = 26.0 + RELOAD_BAR_HEIGHT
	_reload_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reload_bar.modulate.a = 0.0
	_reload_bar.call("set_accent", _accent())
	root.add_child(_reload_bar)



	_reload_time_label = Label.new()
	_reload_time_label.name = "ReloadTimeLabel"
	_reload_time_label.set_anchors_preset(Control.PRESET_CENTER)
	_reload_time_label.offset_left = -44.0
	_reload_time_label.offset_top = 26.0 + RELOAD_BAR_HEIGHT + 3.0
	_reload_time_label.offset_right = 44.0
	_reload_time_label.offset_bottom = 26.0 + RELOAD_BAR_HEIGHT + 19.0
	_reload_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reload_time_label.add_theme_font_override("font", UITheme.ui_font(700))
	_reload_time_label.add_theme_font_size_override("font_size", 11)
	_reload_time_label.add_theme_color_override("font_color", _accent())
	_reload_time_label.add_theme_color_override("font_outline_color", 
		Color(0.0, 0.0, 0.0, 0.8))
	_reload_time_label.add_theme_constant_override("outline_size", 4)
	_reload_time_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reload_time_label.modulate.a = 0.0
	root.add_child(_reload_time_label)


func set_reload_progress(value: float, remaining: = 0.0) -> void :
	if _reload_bar == null:
		return
	var progress: = clampf(value, 0.0, 1.0)
	var visible_now: = progress > 0.0
	if visible_now:
		_reload_bar.call("set_progress", progress)
		if _reload_time_label != null:
			_reload_time_label.text = "%.1f с" % maxf(remaining, 0.0)
	if visible_now == _reload_bar_shown:
		return
	_reload_bar_shown = visible_now
	if _reload_tween != null and _reload_tween.is_valid():
		_reload_tween.kill()
	_reload_tween = create_tween()
	if visible_now:
		_reload_tween.tween_property(_reload_bar, "modulate:a", 1.0, 0.1)
		if _reload_time_label != null:
			_reload_tween.parallel().tween_property(_reload_time_label, 
				"modulate:a", 1.0, 0.1)
		return


	_reload_tween.tween_property(_reload_bar, "modulate:a", 0.0, 0.26)
	if _reload_time_label != null:
		_reload_tween.parallel().tween_property(_reload_time_label, 
			"modulate:a", 0.0, 0.26)
	_reload_tween.tween_callback( func() -> void :
		_reload_bar.call("set_progress", 0.0))






func _build_hud_widgets() -> void :
	_fps_counter = FpsCounter.new()
	_fps_counter.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_fps_counter.offset_left = -170.0
	_fps_counter.offset_top = 16.0
	_fps_counter.offset_right = -26.0
	_fps_counter.offset_bottom = 40.0
	root.add_child(_fps_counter)

	_input_overlay = InputOverlay.new()
	_input_overlay.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_input_overlay.offset_left = 34.0
	_input_overlay.offset_top = -138.0 - InputOverlay.HEIGHT
	_input_overlay.offset_right = 34.0 + InputOverlay.WIDTH
	_input_overlay.offset_bottom = -138.0
	root.add_child(_input_overlay)





func _style_streamer_panel() -> void :
	if _streamer_panel == null:
		return
	var style: = StyleBoxFlat.new()
	var accent: = _accent()
	var index: = clampi(Settings.rating_widget_style, 0, 
		STREAMER_SIZES.size() - 1)
	style.bg_color = Color(0.01, 0.013, 0.017, 0.88 if index == 0 else 0.93)
	style.border_color = Color(accent.r, accent.g, accent.b, 
		0.85 if index == 0 else 0.3)
	if index == 0:
		style.border_width_top = 0
		style.border_width_left = 0
		style.border_width_right = 0
		style.border_width_bottom = 2
	else:
		style.set_border_width_all(1)
	style.set_corner_radius_all(10 if index >= 1 else 8)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = 6 if index >= 1 else 5
	_streamer_panel.add_theme_stylebox_override("panel", style)


func _streamer_box(bg: Color, border: Color, width: int, radius: int, 
		margin_h: = 0.0, margin_v: = 0.0) -> StyleBoxFlat:
	var style: = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = margin_h
	style.content_margin_right = margin_h
	style.content_margin_top = margin_v
	style.content_margin_bottom = margin_v
	return style


func _streamer_label(text: String, font_size: int, color: Color, 
		weight: = 600, display: = false) -> Label:
	var label: = Label.new()
	label.text = text
	label.add_theme_font_override("font", 
		UITheme.display_font(weight) if display else UITheme.ui_font(weight))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _streamer_stat(key: String, caption: String, value_size: = 13, 
		caption_size: = 8) -> VBoxContainer:
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", -1)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var value: = _streamer_label("—", value_size, STREAMER_TEXT, 700, true)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(value)
	var cap: = _streamer_label(caption, caption_size, STREAMER_MUTED, 600)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(cap)
	_streamer_refs[key] = value
	return box


func _streamer_divider(height: = 34.0) -> ColorRect:
	var line: = ColorRect.new()
	line.color = Color(1.0, 1.0, 1.0, 0.1)
	line.custom_minimum_size = Vector2(1.0, height)
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return line


func _streamer_add_to(key: String, node: Control) -> void :
	var group: Array = _streamer_refs.get(key, [])
	group.append(node)
	_streamer_refs[key] = group


func _streamer_nickname() -> String:
	var text: = Settings.nickname.strip_edges().to_upper()
	return text if not text.is_empty() else "HEADSHOT"



func _format_streamer_number(value: int) -> String:
	var digits: = str(absi(value))
	var out: = ""
	var count: = 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = " " + out
	return ("-" if value < 0 else "") + out


func _streamer_chip(key: String, caption: String, tint: Color, 
		width: = 58.0, value_size: = 18) -> PanelContainer:
	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(width, 48.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _streamer_box(
		Color(tint.r, tint.g, tint.b, 0.1), 
		Color(tint.r, tint.g, tint.b, 0.6), 1, 7, 6.0, 4.0))
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", -2)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)
	var value: = _streamer_label("0", value_size, tint, 700, true)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(value)
	var cap: = _streamer_label(caption, 8, tint, 700)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(cap)
	_streamer_refs[key] = value
	return panel


func _streamer_delta_chip() -> PanelContainer:
	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(76.0, 48.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _streamer_box(
		Color(STREAMER_MUTED.r, STREAMER_MUTED.g, STREAMER_MUTED.b, 0.1), 
		Color(STREAMER_MUTED.r, STREAMER_MUTED.g, STREAMER_MUTED.b, 0.5), 
		1, 7, 6.0, 4.0))
	var label: = _streamer_label("—", 18, STREAMER_MUTED, 700, true)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	_streamer_refs["delta"] = label
	_streamer_refs["delta_chip"] = panel
	return panel




func _streamer_flag(width: = 18.0, height: = 12.0) -> Control:
	var flag: = CountryFlag.new()
	flag.custom_minimum_size = Vector2(width, height)
	flag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	flag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flag.set_country(Settings.country)
	_streamer_refs["flag"] = flag
	return flag




func _rebuild_streamer_widget() -> void :
	if _streamer_panel == null:
		return
	for child in _streamer_panel.get_children():
		_streamer_panel.remove_child(child)
		child.queue_free()
	_streamer_refs.clear()
	_streamer_style = clampi(Settings.rating_widget_style, 0, 
		STREAMER_SIZES.size() - 1)
	_style_streamer_panel()
	var target: Vector2 = STREAMER_SIZES[_streamer_style]
	_streamer_panel.offset_right = _streamer_panel.offset_left + target.x
	_streamer_panel.offset_bottom = _streamer_panel.offset_top + target.y
	match _streamer_style:
		0:
			_build_streamer_minimal()
		1:
			_build_streamer_classic()
		2:
			_build_streamer_wide()
		3:
			_build_streamer_progress()
		_:
			_build_streamer_cs()
	_refresh_streamer_widget()





func _build_streamer_widget() -> void :
	_streamer_panel = PanelContainer.new()
	_streamer_panel.name = "RatingWidget"
	_streamer_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_streamer_panel.offset_left = 26.0
	_streamer_panel.offset_top = 52.0
	_streamer_panel.offset_right = 290.0
	_streamer_panel.offset_bottom = 120.0
	_streamer_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_streamer_panel)
	_rebuild_streamer_widget()



func _build_streamer_minimal() -> void :
	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_streamer_panel.add_child(content)

	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(top)

	var badge: = LevelBadge.new()
	badge.custom_minimum_size = Vector2(32.0, 32.0)
	badge.current = true
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(badge)
	_streamer_refs["badge"] = badge
	_streamer_add_to("level_nodes", badge)

	var info: = VBoxContainer.new()
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_theme_constant_override("separation", -1)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(info)

	var name_row: = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 5)
	name_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(name_row)

	var flag: = _streamer_flag(14.0, 10.0)
	name_row.add_child(flag)
	_streamer_add_to("name_nodes", name_row)

	var name_label: = _streamer_label("HEADSHOT", 11, STREAMER_TEXT, 700)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_row.add_child(name_label)
	_streamer_refs["name"] = name_label

	var level_label: = _streamer_label("LVL 1 · НОВИЧОК", 8, STREAMER_MUTED, 600)
	level_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	info.add_child(level_label)
	_streamer_refs["level"] = level_label
	_streamer_add_to("level_nodes", level_label)

	var elo_box: = VBoxContainer.new()
	elo_box.alignment = BoxContainer.ALIGNMENT_CENTER
	elo_box.add_theme_constant_override("separation", -2)
	elo_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(elo_box)

	var elo: = _streamer_label("1000", 15, STREAMER_TEXT, 700, true)
	elo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	elo_box.add_child(elo)
	_streamer_refs["elo"] = elo
	_streamer_add_to("elo_nodes", elo)

	var elo_caption: = _streamer_label("ELO", 8, STREAMER_MUTED, 700)
	elo_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	elo_box.add_child(elo_caption)
	_streamer_add_to("elo_nodes", elo_caption)

	var bottom: = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 7)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(bottom)
	_streamer_refs["bottom_row"] = bottom

	var form_caption: = _streamer_label("ФОРМА", 8, STREAMER_MUTED, 700)
	form_caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bottom.add_child(form_caption)
	_streamer_add_to("form_nodes", form_caption)

	var form: = HBoxContainer.new()
	form.add_theme_constant_override("separation", 3)
	form.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(form)
	_streamer_add_to("form_nodes", form)

	var bars: Array[ColorRect] = []
	for i in 5:
		var bar: = ColorRect.new()
		bar.custom_minimum_size = Vector2(11.0, 3.0)
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.color = STREAMER_MUTED
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		form.add_child(bar)
		bars.append(bar)
	_streamer_refs["form_bars"] = bars

	var spacer: = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(spacer)

	var stats: = _streamer_label("0–0", 9, Color(0.72, 0.76, 0.8, 1.0), 600)
	bottom.add_child(stats)
	_streamer_refs["stats"] = stats
	_streamer_add_to("record_nodes", stats)




func _build_streamer_classic() -> void :
	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_streamer_panel.add_child(content)

	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(top)

	var badge: = LevelBadge.new()
	badge.custom_minimum_size = Vector2(40.0, 40.0)
	badge.current = true
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(badge)
	_streamer_refs["badge"] = badge
	_streamer_add_to("level_nodes", badge)

	var elo: = _streamer_label("1 000", 26, STREAMER_TEXT, 700, true)
	elo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(elo)
	_streamer_refs["elo"] = elo
	_streamer_add_to("elo_nodes", elo)

	var spacer: = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spacer)

	var globe: = GlobeIcon.new()
	globe.custom_minimum_size = Vector2(15.0, 15.0)
	globe.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	globe.tint = STREAMER_MUTED
	globe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(globe)
	_streamer_add_to("record_nodes", globe)

	var best: = _streamer_label("#1 000", 12, STREAMER_MUTED, 700, true)
	best.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(best)
	_streamer_refs["best"] = best
	_streamer_refs["best_format"] = "#%s"
	_streamer_add_to("record_nodes", best)

	var stats_row: = HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 10)
	stats_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(stats_row)
	_streamer_add_to("record_nodes", stats_row)

	stats_row.add_child(_streamer_stat("winrate", "ВИНРЕЙТ", 13, 8))
	stats_row.add_child(_streamer_divider(28.0))
	stats_row.add_child(_streamer_stat("accuracy", "ТОЧН. / HS", 13, 8))
	stats_row.add_child(_streamer_divider(28.0))
	stats_row.add_child(_streamer_stat("damage", "СР. УРОН", 13, 8))

	var bottom: = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 7)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(bottom)
	_streamer_refs["bottom_row"] = bottom
	_streamer_refs["bottom_name"] = true

	var flag: = _streamer_flag()
	bottom.add_child(flag)
	_streamer_add_to("name_nodes", flag)

	var name_label: = _streamer_label("HEADSHOT", 10, STREAMER_TEXT, 700)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	bottom.add_child(name_label)
	_streamer_refs["name"] = name_label
	_streamer_add_to("name_nodes", name_label)

	var form: = HBoxContainer.new()
	form.add_theme_constant_override("separation", 4)
	form.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(form)
	_streamer_add_to("form_nodes", form)

	var letters: Array = []
	for i in 6:
		var letter: = _streamer_label("W", 11, STREAMER_GREEN, 700, true)
		letter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		form.add_child(letter)
		letters.append(letter)
	_streamer_refs["form_letters"] = letters




func _build_streamer_wide() -> void :
	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_streamer_panel.add_child(content)

	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 9)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(top)

	var badge: = LevelBadge.new()
	badge.custom_minimum_size = Vector2(42.0, 42.0)
	badge.current = true
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(badge)
	_streamer_refs["badge"] = badge
	_streamer_add_to("level_nodes", badge)

	var elo_box: = VBoxContainer.new()
	elo_box.alignment = BoxContainer.ALIGNMENT_CENTER
	elo_box.add_theme_constant_override("separation", -4)
	elo_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(elo_box)

	var elo: = _streamer_label("1 000", 30, STREAMER_TEXT, 700, true)
	elo_box.add_child(elo)
	_streamer_refs["elo"] = elo
	_streamer_add_to("elo_nodes", elo)

	var name_row: = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 5)
	name_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elo_box.add_child(name_row)

	var flag: = _streamer_flag(14.0, 10.0)
	name_row.add_child(flag)
	_streamer_add_to("name_nodes", name_row)

	var name_label: = _streamer_label("HEADSHOT", 8, STREAMER_MUTED, 600)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_row.add_child(name_label)
	_streamer_refs["name"] = name_label

	top.add_child(_streamer_divider(32.0))

	var kdr: = _streamer_label("СЕРИЯ 0", 14, STREAMER_MUTED, 700, true)
	kdr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(kdr)
	_streamer_refs["kdr"] = kdr
	_streamer_add_to("record_nodes", kdr)

	var spacer: = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spacer)

	var globe: = GlobeIcon.new()
	globe.custom_minimum_size = Vector2(17.0, 17.0)
	globe.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	globe.tint = STREAMER_TEXT
	globe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(globe)
	_streamer_add_to("record_nodes", globe)

	var best: = _streamer_label("#1 000", 17, STREAMER_TEXT, 700, true)
	best.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(best)
	_streamer_refs["best"] = best
	_streamer_refs["best_format"] = "#%s"
	_streamer_add_to("record_nodes", best)

	var sub: = PanelContainer.new()
	sub.add_theme_stylebox_override("panel", _streamer_box(
		Color(1.0, 1.0, 1.0, 0.035), Color(1.0, 1.0, 1.0, 0.06), 1, 8, 8.0, 6.0))
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(sub)
	_streamer_add_to("record_nodes", sub)

	var sub_box: = VBoxContainer.new()
	sub_box.add_theme_constant_override("separation", 2)
	sub_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub.add_child(sub_box)

	var sub_caption: = _streamer_label("СТАТИСТИКА · 0 МАТЧЕЙ", 9, STREAMER_MUTED, 700)
	sub_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_box.add_child(sub_caption)
	_streamer_refs["sub_caption"] = sub_caption

	var stats_row: = HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 10)
	stats_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_box.add_child(stats_row)

	stats_row.add_child(_streamer_stat("winrate", "ВИНРЕЙТ", 15, 9))
	stats_row.add_child(_streamer_divider(32.0))
	stats_row.add_child(_streamer_stat("accuracy", "ТОЧН. / HS", 15, 9))
	stats_row.add_child(_streamer_divider(32.0))
	stats_row.add_child(_streamer_stat("damage", "СР. УРОН", 15, 9))




func _build_streamer_progress() -> void :
	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_streamer_panel.add_child(content)

	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(top)

	var elo: = _streamer_label("1 000", 34, STREAMER_TEXT, 700, true)
	elo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(elo)
	_streamer_refs["elo"] = elo
	_streamer_add_to("elo_nodes", elo)

	var spacer: = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spacer)

	var spark: = Sparkline.new()
	spark.custom_minimum_size = Vector2(66.0, 26.0)
	spark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	spark.tint = _accent_bright()
	spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(spark)
	_streamer_refs["sparkline"] = spark
	_streamer_add_to("form_nodes", spark)

	var name_row: = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 5)
	name_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(name_row)
	_streamer_add_to("name_nodes", name_row)

	var flag: = _streamer_flag(14.0, 10.0)
	name_row.add_child(flag)

	var name_label: = _streamer_label("HEADSHOT", 10, STREAMER_MUTED, 600)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_row.add_child(name_label)
	_streamer_refs["name"] = name_label

	var chips: = HBoxContainer.new()
	chips.add_theme_constant_override("separation", 6)
	chips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(chips)
	_streamer_add_to("record_nodes", chips)

	chips.add_child(_streamer_delta_chip())
	chips.add_child(_streamer_chip("wins", "ПОБЕД", STREAMER_GREEN, 62.0))
	chips.add_child(_streamer_chip("losses", "ПОРАЖ.", STREAMER_RED, 62.0))

	var level_row: = HBoxContainer.new()
	level_row.add_theme_constant_override("separation", 8)
	level_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(level_row)
	_streamer_add_to("level_nodes", level_row)

	var badge: = LevelBadge.new()
	badge.custom_minimum_size = Vector2(36.0, 36.0)
	badge.current = true
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_row.add_child(badge)
	_streamer_refs["badge"] = badge

	var bar: = ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 0.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0.0, 14.0)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background", _streamer_box(
		Color(0.07, 0.074, 0.082, 1.0), Color(1.0, 1.0, 1.0, 0.08), 1, 6))
	bar.add_theme_stylebox_override("fill", _streamer_box(
		_accent(), _accent(), 0, 6))
	level_row.add_child(bar)
	_streamer_refs["progress"] = bar

	var next: = _streamer_label("+0 до следующего уровня", 10, STREAMER_MUTED, 600)
	next.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(next)
	_streamer_refs["next"] = next
	_streamer_add_to("level_nodes", next)




func _build_streamer_cs() -> void :
	var overlay: = Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_streamer_panel.add_child(overlay)

	var watermark: = CsWatermark.new()
	watermark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	watermark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(watermark)

	var content: = VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 7)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(content)

	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 6)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(top)

	var flag: = _streamer_flag(14.0, 10.0)
	top.add_child(flag)
	_streamer_add_to("name_nodes", flag)

	var kicker: = _streamer_label("HEADSHOT", 10, Color(1.0, 1.0, 1.0, 0.35), 700)
	kicker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kicker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	kicker.custom_minimum_size = Vector2(40.0, 0.0)
	kicker.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	top.add_child(kicker)
	_streamer_refs["name"] = kicker
	_streamer_add_to("name_nodes", kicker)

	var badge: = LevelBadge.new()
	badge.custom_minimum_size = Vector2(44.0, 44.0)
	badge.current = true
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(badge)
	_streamer_refs["badge"] = badge
	_streamer_add_to("level_nodes", badge)

	var elo: = _streamer_label("1 000", 38, STREAMER_TEXT, 700, true)
	content.add_child(elo)
	_streamer_refs["elo"] = elo
	_streamer_add_to("elo_nodes", elo)

	var middle: = HBoxContainer.new()
	middle.add_theme_constant_override("separation", 8)
	middle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(middle)

	var chips: = VBoxContainer.new()
	chips.add_theme_constant_override("separation", 5)
	chips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	middle.add_child(chips)
	chips.add_child(_streamer_chip("wins", "ПОБЕД", STREAMER_GREEN, 64.0, 20))
	chips.add_child(_streamer_chip("losses", "ПОРАЖ.", STREAMER_RED, 64.0, 20))
	_streamer_add_to("record_nodes", chips)

	var stats: = VBoxContainer.new()
	stats.add_theme_constant_override("separation", 3)
	stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	middle.add_child(stats)
	_streamer_add_to("record_nodes", stats)

	stats.add_child(_streamer_label("СР. УРОН", 8, STREAMER_MUTED, 700))
	var damage: = _streamer_label("0", 18, STREAMER_TEXT, 700, true)
	stats.add_child(damage)
	_streamer_refs["damage"] = damage
	stats.add_child(_streamer_label("ТОЧН. / HS", 8, STREAMER_MUTED, 700))
	var accuracy: = _streamer_label("0 / 0%", 15, STREAMER_TEXT, 700, true)
	stats.add_child(accuracy)
	_streamer_refs["accuracy"] = accuracy

	var spacer2: = Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(spacer2)

	var bottom: = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 8)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(bottom)
	_streamer_add_to("record_nodes", bottom)

	var best: = _streamer_label("РЕКОРД #1 000", 9, STREAMER_MUTED, 600)
	best.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(best)
	_streamer_refs["best"] = best
	_streamer_refs["best_format"] = "РЕКОРД #%s"

	var matches: = _streamer_label("МАТЧЕЙ 0", 9, STREAMER_MUTED, 600)
	bottom.add_child(matches)
	_streamer_refs["matches"] = matches





func set_editor_preview(value: bool) -> void :
	_editor_preview = value
	_refresh_streamer_widget()


func _refresh_streamer_widget() -> void :
	if _streamer_panel == null:
		return
	if Settings.rating_widget_style != _streamer_style:
		_rebuild_streamer_widget()
		return
	var show_level: = Settings.rating_widget_level
	var show_name: = Settings.rating_widget_nickname
	var show_elo: = Settings.rating_widget_elo
	var show_form: = Settings.rating_widget_form
	var show_record: = Settings.rating_widget_record
	var has_content: = show_level or show_name or show_elo or show_form or show_record
	_streamer_panel.visible = (Settings.show_rating_widget or _editor_preview)\
	and has_content
	if not _streamer_panel.visible:
		return
	var refs: = _streamer_refs
	if refs.is_empty():
		return
	var level: = Settings.rating_level()
	var recent: Array = Settings.recent_results

	if refs.has("badge"):
		refs["badge"].level = level
	if refs.has("level"):
		refs["level"].text = "LVL %d · %s" % [level, Settings.rating_level_name()]
	if refs.has("name"):
		refs["name"].text = _streamer_nickname()
	if refs.has("flag"):
		refs["flag"].set_country(Settings.country)
	if refs.has("elo"):
		refs["elo"].text = _format_streamer_number(Settings.rating_elo)
	if refs.has("best"):
		var best_format: = str(refs.get("best_format", "#%s"))
		refs["best"].text = best_format % _format_streamer_number(Settings.rating_best)
	if refs.has("matches"):
		refs["matches"].text = "МАТЧЕЙ %d" % Settings.rating_matches
	if refs.has("winrate"):
		refs["winrate"].text = "%d%%" % int(round(Settings.rating_winrate()))
	if refs.has("accuracy"):
		refs["accuracy"].text = "%.0f / %.0f%%" % [
			Settings.rating_accuracy(), Settings.rating_headshot_rate()
		]
	if refs.has("damage"):
		refs["damage"].text = "%.0f" % Settings.rating_avg_damage()
	if refs.has("kdr"):
		refs["kdr"].text = "СЕРИЯ %d" % Settings.rating_streak
	if refs.has("wins"):
		refs["wins"].text = str(Settings.rating_wins)
	if refs.has("losses"):
		refs["losses"].text = str(Settings.rating_losses)
	if refs.has("stats"):
		refs["stats"].text = "%d–%d · %.0f%%" % [
			Settings.rating_wins, Settings.rating_losses, 
			Settings.rating_winrate()
		]
	if refs.has("delta"):
		_update_streamer_delta(refs)
	if refs.has("progress"):
		var bar: ProgressBar = refs["progress"]
		bar.value = Settings.rating_level_progress() * 100.0
		bar.add_theme_stylebox_override("fill", _streamer_box(
			_accent(), _accent(), 0, 6))
	if refs.has("next"):
		if level >= 10:
			refs["next"].text = "МАКСИМАЛЬНЫЙ УРОВЕНЬ"
		else:
			var bounds: = Settings.rating_level_bounds()
			refs["next"].text = "+%d до следующего уровня" % maxi(
				int(bounds["high"]) - Settings.rating_elo, 0)
	if refs.has("sub_caption"):
		var count: = mini(maxi(Settings.rating_matches, 
			Settings.recent_results.size()), 20)
		refs["sub_caption"].text = "СТАТИСТИКА · %d МАТЧЕЙ" % count
	if refs.has("form_bars"):
		_update_streamer_bars(refs["form_bars"], recent)
	if refs.has("form_letters"):
		_update_streamer_letters(refs["form_letters"], recent)
	if refs.has("sparkline"):
		var spark = refs["sparkline"]
		spark.values = _streamer_spark_values(recent)
		spark.tint = _accent_bright()
		spark.queue_redraw()

	_set_streamer_visible(refs.get("level_nodes", []), show_level)
	_set_streamer_visible(refs.get("name_nodes", []), show_name)
	_set_streamer_visible(refs.get("elo_nodes", []), show_elo)
	_set_streamer_visible(refs.get("form_nodes", []), show_form)
	_set_streamer_visible(refs.get("record_nodes", []), show_record)
	if refs.has("bottom_row"):
		var bottom_show: = show_form or show_record
		if bool(refs.get("bottom_name", false)):
			bottom_show = bottom_show or show_name
		refs["bottom_row"].visible = bottom_show


func _set_streamer_visible(nodes: Array, value: bool) -> void :
	for node in nodes:
		if is_instance_valid(node):
			node.visible = value


func _update_streamer_bars(bars: Array, recent: Array) -> void :
	var muted: = Color(STREAMER_MUTED.r, STREAMER_MUTED.g, STREAMER_MUTED.b, 0.3)
	for i in bars.size():
		var bar: ColorRect = bars[i]
		if i >= recent.size():
			bar.color = muted
			continue
		bar.color = STREAMER_GREEN if bool(recent[i]) else STREAMER_RED


func _update_streamer_letters(letters: Array, recent: Array) -> void :
	for i in letters.size():
		var letter: Label = letters[i]
		if i >= recent.size():
			letter.visible = false
			continue
		letter.visible = true
		var won: = bool(recent[i])
		letter.text = "W" if won else "L"
		letter.add_theme_color_override("font_color", 
			STREAMER_GREEN if won else STREAMER_RED)


func _update_streamer_delta(refs: Dictionary) -> void :
	var delta: = Settings.last_rating_delta
	var tint: = STREAMER_MUTED
	var text: = "—"
	if delta > 0:
		tint = STREAMER_GREEN
		text = "↑ %d" % delta
	elif delta < 0:
		tint = STREAMER_RED
		text = "↓ %d" % absi(delta)
	var label: Label = refs["delta"]
	label.text = text
	label.add_theme_color_override("font_color", tint)
	var chip: PanelContainer = refs.get("delta_chip")
	if chip != null:
		chip.add_theme_stylebox_override("panel", _streamer_box(
			Color(tint.r, tint.g, tint.b, 0.1), 
			Color(tint.r, tint.g, tint.b, 0.6), 1, 7, 6.0, 4.0))




func _streamer_spark_values(recent: Array) -> Array:
	var values: Array = []
	var score: = 0.0
	for i in range(recent.size() - 1, -1, -1):
		score += 1.0 if bool(recent[i]) else -1.0
		values.append(score)
	if values.size() < 2:
		values = [0.0, 0.0]
	return values





func _register_hud_widgets() -> void :
	_hud_widgets = {
		"session": _session_label, 
		"killfeed": killfeed.get_parent() as Control, 
		"killzone": kill_zone, 
		"weapons": _weapon_list_column, 
		"strafe": _strafe_meter, 
		"fps": _fps_counter, 
		"input_overlay": _input_overlay, 
		"streamer": _streamer_panel, 
		"hint": hint, 
	}
	if not Settings.hud_layout_changed.is_connected(_on_hud_layout_changed):
		Settings.hud_layout_changed.connect(_on_hud_layout_changed)
	call_deferred("_init_hud_layout")


func _init_hud_layout() -> void :
	if _hud_layout_ready:
		return
	for key in _hud_widgets:
		var control: Control = _hud_widgets[key]
		if control == null:
			continue
		_hud_defaults[key] = {
			"size": control.size, 
			"anchor_left": control.anchor_left, 
			"anchor_top": control.anchor_top, 
			"anchor_right": control.anchor_right, 
			"anchor_bottom": control.anchor_bottom, 
			"offset_left": control.offset_left, 
			"offset_top": control.offset_top, 
			"offset_right": control.offset_right, 
			"offset_bottom": control.offset_bottom, 
			"grow_horizontal": control.grow_horizontal, 
			"grow_vertical": control.grow_vertical, 
			"pivot_offset": control.pivot_offset, 
		}
	_hud_layout_ready = true
	_apply_hud_layout(Settings.hud_layout)
	get_viewport().size_changed.connect(_on_hud_viewport_resized)


func _on_hud_viewport_resized() -> void :
	if _hud_layout_ready:
		_apply_hud_layout(Settings.hud_layout)


func _on_hud_layout_changed() -> void :
	_apply_hud_layout(Settings.hud_layout)




func _apply_hud_layout(layout: Dictionary) -> void :
	if not _hud_layout_ready:
		return
	for key in _hud_widgets:
		var entry: Variant = layout.get(key)
		if entry is Dictionary:
			_place_hud_widget(key, entry)
		else:
			_restore_hud_widget(key)


func _place_hud_widget(key: String, entry: Dictionary) -> void :
	var control: Control = _hud_widgets.get(key)
	var base_info: Variant = _hud_defaults.get(key)
	if control == null or not (base_info is Dictionary):
		return
	var view: = get_viewport().get_visible_rect().size
	var base: Vector2 = (base_info as Dictionary).get("size", control.size)
	var factor: = clampf(float(entry.get("scale", 1.0)), 
		Settings.HUD_SCALE_MIN, Settings.HUD_SCALE_MAX)
	var center: = Vector2(float(entry.get("x", 0.5)) * view.x, 
		float(entry.get("y", 0.5)) * view.y)
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.size = base
	control.pivot_offset = base * 0.5
	control.scale = Vector2(factor, factor)
	control.position = center - base * 0.5


func _restore_hud_widget(key: String) -> void :
	var control: Control = _hud_widgets.get(key)
	var base_info: Variant = _hud_defaults.get(key)
	if control == null or not (base_info is Dictionary):
		return
	var info: Dictionary = base_info
	control.scale = Vector2.ONE
	control.pivot_offset = info.get("pivot_offset", Vector2.ZERO)
	control.anchor_left = info.get("anchor_left", 0.0)
	control.anchor_top = info.get("anchor_top", 0.0)
	control.anchor_right = info.get("anchor_right", 0.0)
	control.anchor_bottom = info.get("anchor_bottom", 0.0)
	control.offset_left = info.get("offset_left", 0.0)
	control.offset_top = info.get("offset_top", 0.0)
	control.offset_right = info.get("offset_right", 0.0)
	control.offset_bottom = info.get("offset_bottom", 0.0)
	control.grow_horizontal = info.get("grow_horizontal", 1)
	control.grow_vertical = info.get("grow_vertical", 1)



func get_hud_editor_rects() -> Dictionary:
	var rects: Dictionary = {}
	for key in _hud_widgets:
		var control: Control = _hud_widgets[key]
		if control == null:
			continue
		rects[key] = Rect2(control.global_position, control.size * control.scale)
	return rects




func get_hud_editor_layout() -> Dictionary:
	var layout: Dictionary = {}
	var view: = get_viewport().get_visible_rect().size
	var rects: = get_hud_editor_rects()
	for key in rects:
		var control: Control = _hud_widgets.get(key)
		if control == null:
			continue
		var rect: Rect2 = rects[key]
		layout[key] = {
			"x": clampf((rect.position.x + rect.size.x * 0.5) / maxf(view.x, 1.0), 
				0.0, 1.0), 
			"y": clampf((rect.position.y + rect.size.y * 0.5) / maxf(view.y, 1.0), 
				0.0, 1.0), 
			"scale": control.scale.x, 
		}
	return layout



func apply_hud_layout_preview(layout: Dictionary) -> void :
	_apply_hud_layout(layout)





func _build_strafe_meter() -> void :
	_strafe_meter = VBoxContainer.new()
	_strafe_meter.name = "StrafeMeter"
	_strafe_meter.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_strafe_meter.offset_left = 34.0
	_strafe_meter.offset_top = -124.0
	_strafe_meter.offset_right = 214.0
	_strafe_meter.offset_bottom = -34.0
	_strafe_meter.add_theme_constant_override("separation", 1)
	_strafe_meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strafe_meter.modulate.a = 0.0
	root.add_child(_strafe_meter)

	_strafe_kicker = Label.new()
	_strafe_kicker.text = "СТРЕЙФ"
	_strafe_kicker.add_theme_font_override("font", UITheme.ui_font(600))
	_strafe_kicker.add_theme_font_size_override("font_size", 10)
	_strafe_kicker.add_theme_color_override("font_color", _accent())
	_strafe_kicker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strafe_meter.add_child(_strafe_kicker)

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strafe_meter.add_child(row)

	_strafe_value = Label.new()
	_strafe_value.text = "0.0"
	_strafe_value.add_theme_font_override("font", UITheme.display_font(600))
	_strafe_value.add_theme_font_size_override("font_size", 26)
	_strafe_value.add_theme_color_override("font_color", UITheme.TEXT)
	_strafe_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_strafe_value)

	var unit: = Label.new()
	unit.text = "М/С"
	unit.add_theme_font_override("font", UITheme.ui_font(600))
	unit.add_theme_font_size_override("font_size", 10)
	unit.add_theme_color_override("font_color", UITheme.MUTED)
	unit.size_flags_vertical = Control.SIZE_SHRINK_END
	unit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(unit)

	var track: = ColorRect.new()
	track.color = Color(_accent().r, _accent().g, _accent().b, 0.16)
	track.custom_minimum_size = Vector2(_strafe_width, 3)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strafe_meter.add_child(track)
	_strafe_track = track

	_strafe_fill = ColorRect.new()
	_strafe_fill.color = _accent_bright()
	_strafe_fill.size = Vector2(0.0, 3.0)
	_strafe_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(_strafe_fill)


func _accent() -> Color:
	return Settings.hud_accent


func _accent_bright() -> Color:
	return Settings.hud_accent.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.34)


func _accent_dark() -> Color:
	return Settings.hud_accent.darkened(0.46)





func _build_kill_fx() -> void :
	_kill_vignette = ColorRect.new()
	_kill_vignette.name = "KillVignette"
	_kill_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_kill_vignette.color = Color.WHITE
	_kill_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_kill_vignette.visible = false
	_kill_vignette_material = ShaderMaterial.new()
	_kill_vignette_material.shader = KillVignetteShader
	_kill_vignette_material.set_shader_parameter("glow_color", _accent_bright())
	_kill_vignette_material.set_shader_parameter("strength", 0.55)
	_kill_vignette_material.set_shader_parameter("opacity", 0.0)
	_kill_vignette.material = _kill_vignette_material
	root.add_child(_kill_vignette)
	root.move_child(_kill_vignette, 0)

	_kill_popup_layer = Control.new()
	_kill_popup_layer.name = "KillPopups"
	_kill_popup_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_kill_popup_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_kill_popup_layer)


func _build_kill_zone() -> void :
	_fx_layer = Control.new()
	_fx_layer.name = "KillBursts"
	_fx_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kill_zone.add_child(_fx_layer)

	var column: = VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.alignment = BoxContainer.ALIGNMENT_END
	column.add_theme_constant_override("separation", 6)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kill_zone.add_child(column)

	_cards_fan = Control.new()
	_cards_fan.clip_contents = false
	_cards_fan.custom_minimum_size = Vector2(0, KILL_CARD_FAN_HEIGHT)
	_cards_fan.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cards_fan.resized.connect(_layout_kill_cards)
	column.add_child(_cards_fan)

	var row: = Control.new()
	row.name = "SkullRow"
	row.custom_minimum_size = Vector2(0, 66)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(row)
	_skull_row = row



	_badge = Control.new()
	_badge.set_script(UIIcon)
	_badge.set("kind", "skull_badge")
	_badge.set_anchors_preset(Control.PRESET_CENTER)
	_badge.offset_left = -33.0
	_badge.offset_top = -33.0
	_badge.offset_right = 33.0
	_badge.offset_bottom = 33.0
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_badge)

	var kills: = HBoxContainer.new()
	kills.name = "Kills"
	_kill_counter_row = kills
	kills.anchor_left = 0.5
	kills.anchor_top = 0.5
	kills.anchor_right = 0.5
	kills.anchor_bottom = 0.5
	kills.offset_left = -215.0
	kills.offset_top = -33.0
	kills.offset_right = -45.0
	kills.offset_bottom = 33.0
	kills.alignment = BoxContainer.ALIGNMENT_END
	kills.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(kills)

	_kill_counter = Label.new()
	_kill_counter.text = "0"
	_kill_counter.add_theme_font_override("font", UITheme.display_font(600))
	_kill_counter.add_theme_font_size_override("font_size", 34)
	_kill_counter.add_theme_color_override("font_color", UITheme.TEXT)
	_kill_counter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_kill_counter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kills.add_child(_kill_counter)

	var ammo: = HBoxContainer.new()
	ammo.name = "Ammo"
	ammo.anchor_left = 0.5
	ammo.anchor_top = 0.5
	ammo.anchor_right = 0.5
	ammo.anchor_bottom = 0.5
	ammo.offset_left = 45.0
	ammo.offset_top = -33.0
	ammo.offset_right = 215.0
	ammo.offset_bottom = 33.0
	ammo.alignment = BoxContainer.ALIGNMENT_BEGIN
	ammo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(ammo)

	_build_ammo_block(ammo)




func _build_ammo_block(row: HBoxContainer) -> void :
	var block: = VBoxContainer.new()
	block.name = "AmmoBlock"
	block.add_theme_constant_override("separation", 0)
	block.alignment = BoxContainer.ALIGNMENT_CENTER
	block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(block)

	var line: = HBoxContainer.new()
	line.alignment = BoxContainer.ALIGNMENT_CENTER
	line.add_theme_constant_override("separation", 4)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	block.add_child(line)

	ammo_value = Label.new()
	ammo_value.name = "AmmoValue"
	ammo_value.text = "05"
	ammo_value.add_theme_font_override("font", UITheme.display_font(600))
	ammo_value.add_theme_font_size_override("font_size", 28)
	ammo_value.add_theme_color_override("font_color", UITheme.TEXT)
	ammo_value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ammo_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(ammo_value)

	reserve_value = Label.new()
	reserve_value.name = "ReserveValue"
	reserve_value.text = "/ 05"
	reserve_value.add_theme_font_override("font", UITheme.ui_font(500))
	reserve_value.add_theme_font_size_override("font_size", 13)
	reserve_value.add_theme_color_override("font_color", UITheme.MUTED)
	reserve_value.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	reserve_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(reserve_value)

	reload_label = Label.new()
	reload_label.name = "ReloadLabel"
	reload_label.text = ""
	reload_label.visible = false
	reload_label.add_theme_font_override("font", UITheme.ui_font(700))
	reload_label.add_theme_font_size_override("font_size", 9)
	reload_label.add_theme_color_override("font_color", _accent())
	reload_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reload_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	block.add_child(reload_label)


func _make_kill_card(index: int) -> Control:
	var card: = PanelContainer.new()
	var style: = StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.066, 0.082, 0.92)
	style.border_color = _accent_dark()
	style.set_border_width_all(1)
	style.border_width_bottom = 2
	style.set_corner_radius_all(3)
	style.content_margin_left = 3.0
	style.content_margin_right = 4.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	card.add_theme_stylebox_override("panel", style)
	card.set_meta("kill_style", style)
	card.custom_minimum_size = Vector2(40, KILL_CARD_HEIGHT)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var content: = HBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 2)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(content)

	var icon: = Control.new()
	icon.set_script(UIIcon)
	icon.set("kind", "skull")
	icon.set("tint", _accent_bright())
	icon.custom_minimum_size = Vector2(16, 16)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(icon)

	var label: = Label.new()
	label.text = str(index)
	label.add_theme_font_override("font", UITheme.display_font(600))
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", UITheme.TEXT)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(label)
	card.set_meta("card_label", label)
	card.set_meta("card_index", index)
	return card








func register_kill(total: int, headshot: = false) -> void :
	_kills = total
	_kill_card_streak += 1


	_cancel_kill_card_collapse()
	var quality: = Settings.effects_quality
	_flash_badge()
	_spawn_kill_popup("HEADSHOT" if headshot else "+1", headshot)
	if quality > 0:
		var center: = _skull_center()
		if quality >= 2:
			_flash_kill_screen(headshot, quality)
		_spawn_shockwave(center, 0.0, 1.0 if headshot else 0.9)
		if headshot and quality >= 2:
			_spawn_shockwave(center, 0.09, 1.4)
		_spawn_burst(center, 1.45 if headshot else 1.05)



	var wave: = 3 if quality >= 2 else 1
	var first: = maxi(0, _kill_cards.size() - wave)
	for i in range(first, _kill_cards.size()):
		_pulse_kill_card(_kill_cards[i], 0.035 * float(i - first), 0.55)
	_sync_kill_cards()


	_restart_kill_card_idle()




func _skull_center() -> Vector2:
	if _badge == null:
		return kill_zone.global_position + kill_zone.size * 0.5
	var parent: = _badge.get_parent() as Control
	var base: = parent.global_position if parent != null else Vector2.ZERO
	return base + _badge.position + _badge.size * 0.5






func _flash_kill_screen(headshot: bool, quality: = 2) -> void :
	if _kill_vignette == null or _kill_vignette_material == null:
		return
	var color: = Color(1.0, 0.97, 0.92, 1.0) if headshot else _accent_bright()
	_kill_vignette.visible = true
	_kill_vignette_material.set_shader_parameter("glow_color", color)
	_kill_vignette_material.set_shader_parameter("strength", 0.82 if headshot else 0.55)
	if _kill_vignette.has_meta("tween"):
		var old = _kill_vignette.get_meta("tween")
		if old is Tween and old.is_valid():
			old.kill()
	var tween: = create_tween()
	_kill_vignette.set_meta("tween", tween)
	_kill_vignette_material.set_shader_parameter("opacity", 0.0)



	tween.tween_method(_set_vignette_opacity, 0.0, 1.0, 0.07)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)



	var fade: = (1.2 if headshot else 1.0) if quality >= 2\
	else (0.55 if headshot else 0.45)
	tween.tween_method(_set_vignette_opacity, 1.0, 0.0, fade)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


	tween.tween_callback( func() -> void :
		_kill_vignette.visible = false)


func _set_vignette_opacity(value: float) -> void :
	if _kill_vignette_material != null:
		_kill_vignette_material.set_shader_parameter("opacity", value)




func _spawn_shockwave(center: Vector2, delay: float, strength: float) -> void :
	if _fx_layer == null:
		return
	var ring: Control
	if _ring_pool.is_empty():
		ring = _make_ring()
	else:
		ring = _ring_pool.pop_back()
	if ring.has_meta("fx"):
		var stale: Tween = ring.get_meta("fx")
		if stale != null and stale.is_valid():
			stale.kill()
	ring.visible = true


	ring.size = Vector2(190.0, 190.0) * strength
	ring.pivot_offset = ring.size * 0.5
	ring.scale = Vector2(0.34, 0.34)
	ring.modulate.a = 0.0


	ring.position = center - _fx_layer.global_position - ring.size * 0.5
	var tween: = create_tween()
	tween.tween_interval(delay)


	tween.tween_property(ring, "modulate:a", 1.0, 0.05)
	tween.parallel().tween_property(ring, "scale", Vector2(2.45, 2.45), 0.46)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.46).set_delay(0.12)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback( func() -> void :
		ring.visible = false
		_ring_pool.append(ring))
	ring.set_meta("fx", tween)




func _make_ring() -> Control:
	var ring: = Control.new()
	ring.set_script(UIIcon)
	ring.set("kind", "ring")
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx_layer.add_child(ring)
	return ring






func _spawn_kill_popup(_text: String, headshot: bool) -> void :
	if _kill_popup_layer == null:
		return
	var pool: = _headshot_popup_pool if headshot else _popup_pool
	var label: Label
	if pool.is_empty():
		label = _make_popup_label(headshot)
	else:
		label = pool.pop_back()
	label.visible = true
	var origin: = _skull_center() - _kill_popup_layer.global_position
	label.pivot_offset = label.size * 0.5
	label.position = origin - label.size * 0.5 + Vector2(0.0, -140.0)
	label.scale = Vector2(0.72, 0.72)
	label.modulate.a = 0.0


	if label.has_meta("tween"):
		var stale: Tween = label.get_meta("tween")
		if stale != null and stale.is_valid():
			stale.kill()
	var tween: = create_tween()
	label.set_meta("tween", tween)
	tween.tween_property(label, "modulate:a", 1.0, 0.07)
	tween.parallel().tween_property(label, "scale", Vector2.ONE, 0.2)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "position:y", label.position.y - 10.0, 0.68)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.22)
	tween.tween_callback( func() -> void :
		label.visible = false
		if headshot:
			_headshot_popup_pool.append(label)
		else:
			_popup_pool.append(label))





func _make_popup_label(headshot: = false) -> Label:
	var label: = Label.new()
	label.add_theme_font_override("font", UITheme.display_font(700))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.65))
	label.add_theme_constant_override("outline_size", 4)
	label.text = "HEADSHOT" if headshot else "+1"
	label.add_theme_font_size_override("font_size", 30 if headshot else 24)
	label.add_theme_color_override("font_color", 
		Color(1.0, 0.96, 0.9, 1.0) if headshot else _accent_bright())
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_kill_popup_layer.add_child(label)
	label.reset_size()
	return label






func _pulse_kill_card(card: Control, delay: = 0.0, strength: = 1.0) -> void :
	if not is_instance_valid(card):
		return
	var old_scale = card.get_meta("pulse_scale") if card.has_meta("pulse_scale") else null
	if old_scale is Tween and old_scale.is_valid():
		old_scale.kill()
	card.scale = Vector2.ONE
	var boost: = 1.0 + 0.1 * strength
	var pop: = card.create_tween()
	card.set_meta("pulse_scale", pop)
	if delay > 0.0:
		pop.tween_interval(delay)


	var hot: = Color(1.0 + 0.22 * strength, 1.0 + 0.22 * strength, 
		1.0 + 0.18 * strength, 1.0)
	card.modulate = hot
	pop.tween_property(card, "scale", Vector2(boost, boost), 0.11)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	pop.tween_property(card, "scale", Vector2.ONE, 0.3)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.parallel().tween_property(card, "modulate", Color.WHITE, 0.55)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _flash_badge() -> void :
	if _badge == null:
		return
	if _badge_tween != null and _badge_tween.is_valid():
		_badge_tween.kill()
	_badge.set("lit", 1.0)
	_badge.pivot_offset = Vector2(33.0, 33.0)
	_badge.scale = Vector2(1.18, 1.18)
	_badge_tween = create_tween()
	_badge_tween.tween_property(_badge, "scale", Vector2.ONE, 0.32)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_badge_tween.parallel().tween_method(_set_badge_lit, 1.0, 0.28, 1.1)\
	.set_delay(0.2)
	_kill_counter.text = str(_kills)



	_kill_counter.pivot_offset = _kill_counter.size * 0.5
	_kill_counter.scale = Vector2(1.2, 1.2)
	_badge_tween.parallel().tween_property(_kill_counter, "scale", Vector2.ONE, 0.3)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _set_badge_lit(value: float) -> void :
	if _badge != null:
		_badge.set("lit", value)


func _sync_kill_cards() -> void :
	if _cards_fan == null:
		return
	if _kills <= 0:


		_stop_kill_card_idle()
		_clear_kill_cards()
		_kill_counter.text = "0"
		if _badge != null:
			_badge.set("lit", 0.0)
		return

	_kill_counter.text = str(_kills)
	if _kill_card_streak <= 0 or _kill_card_streak > MAX_KILL_CARDS:
		return
	while _kill_cards.size() < _kill_card_streak:
		var index: = _kill_cards.size() + 1
		_spawn_kill_card(index)





func _clear_kill_cards() -> void :


	if _kill_card_collapse_tween != null and _kill_card_collapse_tween.is_valid():
		_kill_card_collapse_tween.kill()
	_kill_card_collapse_tween = null
	for card in _kill_cards:
		if is_instance_valid(card):



			for key in ["fly", "pulse_scale", "collapse"]:
				if card.has_meta(key):
					var stale: Tween = card.get_meta(key)
					if stale != null and stale.is_valid():
						stale.kill()
			card.visible = false
			card.scale = Vector2.ONE
			card.rotation = 0.0
			card.modulate = Color.WHITE
			card.modulate.a = 0.0
			_card_pool.append(card)
	_kill_cards.clear()
	_kill_card_streak = 0
	_cards_collapsing = false



func _layout_kill_cards() -> void :
	if _cards_fan == null:
		return

	if _cards_collapsing:
		return
	var count: = _kill_cards.size()
	if count == 0:
		return
	var span: = _cards_fan.size.x
	if span <= 1.0:
		span = kill_zone.size.x
	var middle: = count * 0.5 - 0.5



	var origin_x: = span * 0.5


	var base_y: = _cards_fan.size.y - KILL_CARD_HEIGHT - KILL_CARD_LIFT
	if base_y < 0.0:
		base_y = 0.0
	base_y -= KILL_CARD_DROP * (count - 1) * 0.5
	for i in count:
		var card: = _kill_cards[i]
		if not is_instance_valid(card):
			continue



		if card.has_meta("fly"):
			var stale: Tween = card.get_meta("fly")
			if stale != null and stale.is_valid():
				stale.kill()
		card.scale = Vector2.ONE
		card.modulate = Color.WHITE
		var card_size: = card.size
		if card_size.x <= 1.0 or card_size.y <= 1.0:
			card_size = card.get_combined_minimum_size()
			card.size = card_size
		var rel: = float(i) - middle
		card.pivot_offset = Vector2(card_size.x * 0.5, card_size.y)
		card.position = Vector2(
			origin_x + rel * KILL_CARD_STEP - card_size.x * 0.5, 
			base_y + absf(rel) * KILL_CARD_DROP)
		card.rotation = deg_to_rad(rel * KILL_CARD_ANGLE)


	var order: = _card_order(count)
	for slot in count:
		_cards_fan.move_child(_kill_cards[order[slot]], slot)





func _card_order(count: int) -> Array:
	while _card_order_cache.size() <= count:
		var n: = _card_order_cache.size()
		var order: = range(n)
		var middle: = n * 0.5 - 0.5
		order.sort_custom( func(a: int, b: int) -> bool:
			return absf(float(a) - middle) > absf(float(b) - middle))
		_card_order_cache.append(order)
	return _card_order_cache[count]





func _restart_kill_card_idle() -> void :
	_stop_kill_card_idle()
	if _kill_cards.is_empty():
		return
	_kill_card_idle_tween = create_tween()
	_kill_card_idle_tween.tween_interval(KILL_CARD_IDLE)
	_kill_card_idle_tween.tween_callback(_collapse_kill_cards)


func _stop_kill_card_idle() -> void :
	if _kill_card_idle_tween != null and _kill_card_idle_tween.is_valid():
		_kill_card_idle_tween.kill()
	_kill_card_idle_tween = null





func _collapse_kill_cards() -> void :
	_kill_card_idle_tween = null
	if _cards_fan == null or _kill_cards.is_empty() or _cards_collapsing:
		return
	_cards_collapsing = true
	var count: = _kill_cards.size()
	var span: = _cards_fan.size.x
	if span <= 1.0:
		span = kill_zone.size.x
	var origin_x: = span * 0.5
	var middle: = count * 0.5 - 0.5
	var base_y: = _cards_fan.size.y - KILL_CARD_HEIGHT - KILL_CARD_LIFT
	if base_y < 0.0:
		base_y = 0.0
	base_y -= KILL_CARD_DROP * (count - 1) * 0.5
	var total: = 0.0
	for i in count:
		var card: = _kill_cards[i]
		if not is_instance_valid(card):
			continue


		for key in ["fly", "pulse_scale"]:
			if card.has_meta(key):
				var stale: Tween = card.get_meta(key)
				if stale != null and stale.is_valid():
					stale.kill()
		card.modulate = Color.WHITE
		var rel: = float(i) - middle
		var delay: = 0.035 * absf(rel)
		var stack: = Vector2(
			origin_x + rel * 1.5 - card.size.x * 0.5, 
			base_y - absf(rel) * 1.0)
		var tween: = create_tween()
		card.set_meta("collapse", tween)
		if delay > 0.0:
			tween.tween_interval(delay)
		tween.tween_property(card, "position", stack, KILL_CARD_FOLD_TIME)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(card, "rotation", 0.0, KILL_CARD_FOLD_TIME)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(card, "scale", Vector2(0.86, 0.86), 
			KILL_CARD_FOLD_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "position:y", stack.y + 84.0, KILL_CARD_FALL_TIME)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(card, "scale", Vector2(0.58, 0.58), 
			KILL_CARD_FALL_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(card, "modulate:a", 0.0, 
			KILL_CARD_FALL_TIME * 0.82).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		total = maxf(total, delay + KILL_CARD_FOLD_TIME + KILL_CARD_FALL_TIME)
	_kill_card_collapse_tween = create_tween()
	_kill_card_collapse_tween.tween_interval(total + 0.02)
	_kill_card_collapse_tween.tween_callback(_finish_kill_card_collapse)


func _finish_kill_card_collapse() -> void :
	_kill_card_collapse_tween = null
	_cards_collapsing = false
	_clear_kill_cards()




func _cancel_kill_card_collapse() -> void :
	if not _cards_collapsing:
		return
	if _kill_card_collapse_tween != null and _kill_card_collapse_tween.is_valid():
		_kill_card_collapse_tween.kill()
	_kill_card_collapse_tween = null
	_cards_collapsing = false
	for card in _kill_cards:
		if not is_instance_valid(card):
			continue
		if card.has_meta("collapse"):
			var stale: Tween = card.get_meta("collapse")
			if stale != null and stale.is_valid():
				stale.kill()
		card.visible = true
		card.scale = Vector2.ONE
		card.modulate = Color.WHITE
		card.rotation = 0.0
	_layout_kill_cards()





func _spawn_kill_card(index: int) -> void :
	var card: = _take_kill_card(index)
	if card == null:
		return
	_kill_cards.append(card)
	_layout_kill_cards()
	var target: = card.position
	var target_rotation: = card.rotation
	var target_size: = card.size

	card.position = _skull_center() - _cards_fan.global_position\
	- card.pivot_offset * 0.58 - target_size * 0.21
	card.rotation = 0.0
	card.scale = Vector2(0.42, 0.42)
	card.modulate.a = 1.0

	var tween: = create_tween()
	card.set_meta("fly", tween)
	tween.tween_property(card, "position", target, 0.36)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card, "scale", Vector2.ONE, 0.36)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card, "rotation", target_rotation, 0.36)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


	tween.tween_callback( func() -> void :
		if not is_instance_valid(card):
			return
		card.scale = Vector2.ONE
		card.modulate = Color.WHITE
		_pulse_kill_card(card, 0.0, 1.0)
		if Settings.effects_quality > 0:
			_spawn_burst(card.get_global_transform() * (target_size * 0.5), 1.15))





func _take_kill_card(index: int) -> Control:
	for i in _card_pool.size():
		var card: Control = _card_pool[i]
		if int(card.get_meta("card_index", 0)) == index:
			_card_pool.remove_at(i)
			for key in ["fly", "pulse_scale"]:
				if card.has_meta(key):
					var stale: Tween = card.get_meta(key)
					if stale != null and stale.is_valid():
						stale.kill()
			card.scale = Vector2.ONE
			card.modulate = Color.WHITE
			card.visible = true
			return card
	return null


func _spawn_burst(center: Vector2, strength: = 1.0) -> void :
	if _fx_layer == null:
		return
	var burst: Control
	if _burst_pool.is_empty():
		burst = _make_burst()
	else:
		burst = _burst_pool.pop_back()
	if burst.has_meta("fx"):
		var stale: Tween = burst.get_meta("fx")
		if stale != null and stale.is_valid():
			stale.kill()
	burst.visible = true
	burst.size = Vector2(150.0, 150.0) * strength
	burst.modulate.a = 1.0
	burst.pivot_offset = burst.size * 0.5
	burst.scale = Vector2(0.35, 0.35)
	burst.position = center - _fx_layer.global_position - burst.size * 0.5
	var tween: = create_tween()
	tween.tween_property(burst, "scale", Vector2(1.55, 1.55), 0.44)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(burst, "modulate:a", 0.0, 0.44)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback( func() -> void :
		burst.visible = false
		_burst_pool.append(burst))
	burst.set_meta("fx", tween)


func _make_burst() -> Control:
	var burst: = Control.new()
	burst.set_script(UIIcon)
	burst.set("kind", "burst")
	burst.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx_layer.add_child(burst)
	return burst





func _warm_kill_pools() -> void :
	if _fx_layer != null:
		for i in 4:
			var ring: = _make_ring()
			ring.visible = false
			_ring_pool.append(ring)
		for i in 2:
			var burst: = _make_burst()
			burst.visible = false
			_burst_pool.append(burst)
	if _kill_popup_layer != null:
		for i in 2:
			var popup: = _make_popup_label(false)
			popup.visible = false
			_popup_pool.append(popup)
		for i in 2:
			var head_popup: = _make_popup_label(true)
			head_popup.visible = false
			_headshot_popup_pool.append(head_popup)
	if killfeed != null:
		for i in KILLFEED_ROWS:
			var row: = _make_killfeed_row()
			row.visible = false
			row.modulate.a = 0.0
			killfeed.add_child(row)
			_killfeed_rows.append(row)
		_warm_weapon_models()

	if _cards_fan != null:
		for i in MAX_KILL_CARDS:
			var card: = _make_kill_card(i + 1)
			_cards_fan.add_child(card)
			card.visible = false
			card.reset_size()
			_card_pool.append(card)
	_warm_kill_draw.call_deferred()





func _warm_weapon_models() -> void :
	if _killfeed_rows.is_empty():
		return
	var labels: Dictionary = _killfeed_rows[0].get_meta("labels", {})
	var icon: Control = labels.get("weapon_icon")
	if icon == null:
		return
	for weapon_id in ["awp", "ak47", "m4a1", "knife"]:
		icon.set("kind", weapon_id)
	icon.set("kind", "awp")






func _warm_kill_draw() -> void :
	for card in _card_pool:
		card.visible = true
		card.modulate.a = 0.0
	for ring in _ring_pool:
		ring.size = Vector2(190.0, 190.0)
		ring.visible = true
		ring.modulate.a = 0.0
	for burst in _burst_pool:
		burst.size = Vector2(150.0, 150.0)
		burst.visible = true
		burst.modulate.a = 0.0
	if _kill_vignette != null and _kill_vignette_material != null:
		_kill_vignette_material.set_shader_parameter("opacity", 0.0)
		_kill_vignette.visible = true
	for popup in _popup_pool:
		popup.visible = true
		popup.modulate.a = 0.0
	for popup in _headshot_popup_pool:
		popup.visible = true
		popup.modulate.a = 0.0


	for row in _killfeed_rows:
		row.visible = true
		row.modulate.a = 0.0



	var marks: Label = null
	if _kill_popup_layer != null:
		marks = Label.new()
		marks.text = "💀 🦘 🙈"
		marks.add_theme_font_override("font", UITheme.ui_font(500))
		marks.add_theme_font_size_override("font_size", 14)
		marks.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marks.modulate.a = 0.0
		_kill_popup_layer.add_child(marks)

	await get_tree().process_frame
	await get_tree().process_frame

	for card in _card_pool:
		card.visible = false
		card.modulate.a = 1.0
	for ring in _ring_pool:
		ring.visible = false
		ring.modulate.a = 1.0
	for burst in _burst_pool:
		burst.visible = false
		burst.modulate.a = 1.0
	if _kill_vignette != null:
		_kill_vignette.visible = false
	for popup in _popup_pool:
		popup.visible = false
	for popup in _headshot_popup_pool:
		popup.visible = false
	for row in _killfeed_rows:
		row.visible = false
		row.modulate.a = 0.0
	if marks != null:
		marks.queue_free()


func _build_scoreboard() -> void :
	_scoreboard = Control.new()
	_scoreboard.name = "Scoreboard"
	_scoreboard.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scoreboard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scoreboard.visible = false
	root.add_child(_scoreboard)

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.004, 0.008, 0.012, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scoreboard.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_scoreboard.add_child(center)

	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(760, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.03, 0.038, 0.048, 0.985)
	box.border_color = UITheme.BORDER_LIGHT
	box.set_border_width_all(1)
	box.border_width_top = 3
	box.set_corner_radius_all(3)
	box.content_margin_left = 26.0
	box.content_margin_right = 26.0
	box.content_margin_top = 18.0
	box.content_margin_bottom = 18.0
	panel.add_theme_stylebox_override("panel", box)
	center.add_child(panel)

	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)

	var header: = HBoxContainer.new()
	content.add_child(header)

	var title: = Label.new()
	title.text = "HEADSHOT  ·  СЕССИЯ"
	title.add_theme_font_override("font", UITheme.display_font(600))
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UITheme.TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var tab_hint: = Label.new()
	tab_hint.text = "TAB"
	tab_hint.add_theme_font_override("font", UITheme.ui_font(600))
	tab_hint.add_theme_font_size_override("font_size", 11)
	tab_hint.add_theme_color_override("font_color", _accent())
	tab_hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(tab_hint)

	content.add_child(HSeparator.new())

	var grid: = GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 34)
	grid.add_theme_constant_override("v_separation", 7)
	content.add_child(grid)

	var headers: = ["ИГРОК", "ОЧКИ", "УБИЙСТВА", "ХЕДШОТЫ", "ТОЧНОСТЬ"]
	for text in headers:
		var cell: = Label.new()
		cell.text = str(text)
		cell.add_theme_font_override("font", UITheme.ui_font(600))
		cell.add_theme_font_size_override("font_size", 10)
		cell.add_theme_color_override("font_color", UITheme.MUTED)
		grid.add_child(cell)

	var name_cell: = Label.new()
	name_cell.text = Settings.nickname.to_upper()
	name_cell.add_theme_font_override("font", UITheme.ui_font(600))
	name_cell.add_theme_font_size_override("font_size", 15)
	name_cell.add_theme_color_override("font_color", _accent_bright())
	grid.add_child(name_cell)
	_sb_values["name"] = name_cell

	for key in ["score", "kills", "headshots", "accuracy"]:
		var cell: = Label.new()
		cell.text = "0"
		cell.add_theme_font_override("font", UITheme.ui_font(500))
		cell.add_theme_font_size_override("font_size", 15)
		cell.add_theme_color_override("font_color", UITheme.TEXT)
		grid.add_child(cell)
		_sb_values[key] = cell

	content.add_child(HSeparator.new())

	var footer: = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 18)
	content.add_child(footer)

	var targets: = Label.new()
	targets.text = "ЦЕЛЕЙ НА АРЕНЕ: 0"
	targets.add_theme_font_override("font", UITheme.ui_font(500))
	targets.add_theme_font_size_override("font_size", 11)
	targets.add_theme_color_override("font_color", UITheme.MUTED)
	targets.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(targets)
	_sb_values["targets"] = targets


func _show_scoreboard() -> void :
	if pause_overlay.visible:
		return
	_refresh_scoreboard()
	_scoreboard.visible = true


func _hide_scoreboard() -> void :
	_scoreboard.visible = false


func _refresh_scoreboard() -> void :
	if _scoreboard == null:
		return
	_sb_values["name"].text = Settings.nickname.to_upper()
	_sb_values["score"].text = "%d" % _score
	_sb_values["kills"].text = "%d" % _kills
	_sb_values["headshots"].text = "%d" % _headshots
	_sb_values["accuracy"].text = "%.1f%%" % _accuracy
	_sb_values["targets"].text = "ЦЕЛЕЙ НА АРЕНЕ: %d" % _online


func set_score(value: int) -> void :
	_score = value
	if _scoreboard != null and _scoreboard.visible:
		_refresh_scoreboard()


func set_accuracy(value: float) -> void :
	_accuracy = value
	if _scoreboard != null and _scoreboard.visible:
		_refresh_scoreboard()


func set_counters(kill_count: int, headshot_count: int, shot_count: int, hit_count: int) -> void :
	var decreased: = kill_count < _kills
	_kills = kill_count
	_headshots = headshot_count
	_shots = shot_count
	_hits = hit_count
	if decreased or kill_count == 0:
		_sync_kill_cards()
		if kill_count == 0:
			_clear_killfeed()
	if pause_overlay.visible:
		_update_pause_stats()


func update_scoreboard(online: int) -> void :
	if online == _online:
		return
	_online = online
	if _scoreboard != null and _scoreboard.visible:
		_refresh_scoreboard()



func set_movement(speed: float, chain: int, on_floor: bool) -> void :
	_speed = speed
	if _strafe_meter == null:
		return
	var flying: = not on_floor and speed > 1.0
	var ratio: = clampf((speed - STRAFE_METER_MIN) / (STRAFE_METER_MAX - STRAFE_METER_MIN), 
		0.0, 1.0)


	var now: = Time.get_ticks_msec()
	if absf(speed - _strafe_shown_speed) >= 0.1 and now - _strafe_text_ms >= 80:
		_strafe_shown_speed = speed
		_strafe_text_ms = now
		_strafe_value.text = "%04.1f" % speed
	if absf(ratio - _strafe_shown_ratio) > 0.01:
		_strafe_shown_ratio = ratio
		_strafe_fill.size = Vector2(_strafe_width * ratio, 3.0)
	if chain != _strafe_shown_chain:
		_strafe_shown_chain = chain
		_strafe_kicker.text = ("СТРЕЙФ  ×%d" % chain) if chain > 1 else "СТРЕЙФ"
	var hot: = speed > STRAFE_METER_MIN
	if hot != _strafe_shown_hot:
		_strafe_shown_hot = hot
		_strafe_fill.color = _accent_bright() if hot else _accent()
	_set_strafe_visible(flying)


func _set_strafe_visible(visible_now: bool) -> void :
	if visible_now == _strafe_visible:
		return
	_strafe_visible = visible_now
	if _strafe_tween != null and _strafe_tween.is_valid():
		_strafe_tween.kill()
	_strafe_tween = create_tween()
	_strafe_tween.tween_property(_strafe_meter, "modulate:a", 
		1.0 if visible_now else 0.0, 0.14)


func set_spread(scale: float) -> void :


	var spread: = (scale - 1.0) * 5.5
	if absf(spread - _last_spread) < 0.02:
		return
	_last_spread = spread
	crosshair.set_movement_spread(spread)




func set_scope(active: bool) -> void :
	scope.set_active(active)
	crosshair.set_scope_active(active)


func set_ammo(state: Dictionary) -> void :
	var ammo: = int(state.get("ammo", 0))
	var magazine: = int(state.get("magazine", 0))
	var reloading: = bool(state.get("reloading", false))
	var melee: = bool(state.get("melee", false))

	set_primary_weapon(str(state.get("weapon", "")))
	set_active_slot(int(state.get("slot", 2 if melee else 0)))
	if melee != _last_melee:
		_last_melee = melee
		if melee:
			ammo_value.text = "∞"
			ammo_value.add_theme_color_override("font_color", _accent())
			reserve_value.text = "НОЖ"
			reload_label.text = ""
			reload_label.visible = false
			_last_ammo = -1
			_last_magazine = -1
			return
	if melee:
		return
	if ammo != _last_ammo:
		_last_ammo = ammo
		ammo_value.text = "%02d" % ammo
		if ammo <= 1:
			ammo_value.add_theme_color_override("font_color", UITheme.DANGER)
		else:
			ammo_value.add_theme_color_override("font_color", UITheme.TEXT)
	if magazine != _last_magazine:
		_last_magazine = magazine
		reserve_value.text = "/ %02d" % magazine
	reload_label.visible = reloading
	reload_label.text = "ПЕРЕЗАРЯДКА..." if reloading else ""


func flash_hit(headshot: bool) -> void :
	crosshair.flash_hit(headshot)


func kick_crosshair(strength: = 5.0) -> void :
	crosshair.kick(strength)









func add_killfeed(hit: Dictionary, killed: = true, 
		victim_name: = "МАНЕКЕН") -> void :
	var weapon: = str(hit.get("weapon", "awp"))
	var marks: = _killfeed_marks(hit, killed)
	var row: = _take_killfeed_row()
	var labels: Dictionary = row.get_meta("labels")
	var killer: Label = labels["killer"]
	var killer_name: = Settings.nickname.to_upper()
	if killer_name.is_empty():
		killer_name = "ИГРОК"


	if killer.text != killer_name:
		killer.text = killer_name
	var victim: Label = labels["victim"]
	if victim.text != victim_name:
		victim.text = victim_name


	var weapon_icon: Control = labels["weapon_icon"]
	weapon_icon.set("kind", weapon)
	var mark_label: Label = labels["marks"]
	if mark_label.text != marks:
		mark_label.text = marks
	mark_label.visible = not marks.is_empty()
	_present_killfeed_row(row)




func add_duel_killfeed(player_kill: bool, player_name: String, bot_name: String, 
		weapon: String, headshot: bool) -> void :
	var row: = _take_killfeed_row()
	var labels: Dictionary = row.get_meta("labels")
	var accent: = Color(0.42, 0.95, 0.56, 1.0) if player_kill\
	else Color(0.98, 0.38, 0.34, 1.0)
	var killer: Label = labels["killer"]
	var killer_name: = player_name if player_kill else bot_name
	if killer.text != killer_name:
		killer.text = killer_name
	killer.add_theme_color_override("font_color", accent)
	var victim: Label = labels["victim"]
	var victim_name: = bot_name if player_kill else player_name
	if victim.text != victim_name:
		victim.text = victim_name
	var weapon_icon: Control = labels["weapon_icon"]
	weapon_icon.set("kind", weapon)
	var mark_label: Label = labels["marks"]
	mark_label.visible = headshot
	mark_label.text = "💀" if headshot else ""
	_present_killfeed_row(row, 3.0)




func add_dm_killfeed(killer_name: String, victim_name: String, weapon: String, 
		headshot: bool, accent: Color) -> void :
	var row: = _take_killfeed_row()
	var labels: Dictionary = row.get_meta("labels")
	var killer: Label = labels["killer"]
	if killer.text != killer_name:
		killer.text = killer_name
	killer.add_theme_color_override("font_color", accent)
	var victim: Label = labels["victim"]
	if victim.text != victim_name:
		victim.text = victim_name
	var victim_color: = Color(0.94, 0.9, 0.84, 1.0)
	if victim != null:
		victim.add_theme_color_override("font_color", victim_color)
	var weapon_icon: Control = labels["weapon_icon"]
	weapon_icon.set("kind", weapon)
	var mark_label: Label = labels["marks"]
	mark_label.visible = headshot
	mark_label.text = "💀" if headshot else ""
	_present_killfeed_row(row, 3.0)




func set_duel_panel_visible(on: bool) -> void :
	if _duel_score_panel != null:
		_duel_score_panel.visible = on


func set_rating_widget_visible(on: bool) -> void :
	if _streamer_panel != null:
		_streamer_panel.visible = on


func set_session_timer_visible(on: bool) -> void :
	if _session_label != null:
		_session_label.visible = on


func set_scoreboard_enabled(on: bool) -> void :
	_scoreboard_enabled = on
	if not on:
		_hide_scoreboard()




func clear_death_fx() -> void :
	if _damage_tween != null and _damage_tween.is_valid():
		_damage_tween.kill()
	if _death_tween != null and _death_tween.is_valid():
		_death_tween.kill()
	if _damage_vignette != null:
		_damage_vignette.visible = false
	if _death_fx != null:
		_death_fx.visible = false
	if _death_material != null:
		_death_material.set_shader_parameter("progress", 0.0)
	if _countdown_label != null:
		_countdown_label.visible = false




func _present_killfeed_row(row: PanelContainer, hold: = 2.6) -> void :
	killfeed.move_child(row, killfeed.get_child_count() - 1)
	row.modulate.a = 0.0
	if row.has_meta("fade"):
		var previous: Tween = row.get_meta("fade")
		if previous != null and previous.is_valid():
			previous.kill()
	var tween: = row.create_tween()
	row.set_meta("fade", tween)
	tween.tween_property(row, "modulate:a", 1.0, 0.12)
	tween.tween_interval(hold)
	tween.tween_property(row, "modulate:a", 0.0, 0.5)
	tween.tween_callback(_hide_killfeed_row.bind(row))




func _take_killfeed_row() -> PanelContainer:
	var count: = _killfeed_rows.size()
	if count == 0:
		var fallback: = _make_killfeed_row()
		killfeed.add_child(fallback)
		_killfeed_rows.append(fallback)
		return fallback
	var picked: = -1
	for offset in count:
		var i: = (_killfeed_next + offset) % count
		if not _killfeed_rows[i].visible:
			picked = i
			break
	if picked < 0:
		picked = _killfeed_next % count
	_killfeed_next = (picked + 1) % count
	var row: = _killfeed_rows[picked]
	if row.has_meta("fade"):
		var old: Tween = row.get_meta("fade")
		if old != null and old.is_valid():
			old.kill()
	row.visible = true
	return row


func _hide_killfeed_row(row: Control) -> void :
	if row == null or not is_instance_valid(row):
		return
	row.visible = false
	row.modulate.a = 0.0



func _clear_killfeed() -> void :
	for row in _killfeed_rows:
		if row.has_meta("fade"):
			var tween: Tween = row.get_meta("fade")
			if tween != null and tween.is_valid():
				tween.kill()
		row.visible = false
		row.modulate.a = 0.0
	_killfeed_next = 0




func _make_killfeed_row() -> PanelContainer:
	var row: = PanelContainer.new()
	row.theme_type_variation = &"CardPanel"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.size_flags_horizontal = Control.SIZE_SHRINK_END
	var box: = HBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	row.add_child(box)

	var killer: = Label.new()
	killer.add_theme_font_override("font", UITheme.ui_font(700))
	killer.add_theme_font_size_override("font_size", 13)
	killer.add_theme_color_override("font_color", UITheme.TEXT)
	box.add_child(killer)




	var weapon_icon: = Control.new()
	weapon_icon.set_script(HUDWeaponIcon)
	weapon_icon.set("compact", true)
	weapon_icon.set("kind", "awp")
	weapon_icon.set("tint", _accent())
	weapon_icon.custom_minimum_size = Vector2(44.0, 16.0)
	weapon_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	weapon_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(weapon_icon)

	var cross: = Label.new()
	cross.text = "×"
	cross.add_theme_font_override("font", UITheme.ui_font(500))
	cross.add_theme_font_size_override("font_size", 11)
	cross.add_theme_color_override("font_color", UITheme.MUTED)
	box.add_child(cross)

	var victim: = Label.new()
	victim.text = "МАНЕКЕН"
	victim.add_theme_font_override("font", UITheme.ui_font(500))
	victim.add_theme_font_size_override("font_size", 12)
	victim.add_theme_color_override("font_color", UITheme.MUTED)
	box.add_child(victim)

	var mark_label: = Label.new()
	mark_label.add_theme_font_override("font", UITheme.ui_font(500))
	mark_label.add_theme_font_size_override("font_size", 14)
	mark_label.add_theme_color_override("font_color", UITheme.TEXT)
	mark_label.visible = false
	box.add_child(mark_label)

	row.set_meta("labels", {
		"killer": killer, 
		"weapon_icon": weapon_icon, 
		"victim": victim, 
		"marks": mark_label, 
	})
	return row




func _killfeed_marks(hit: Dictionary, killed: bool) -> String:
	if not killed:
		return ""
	var parts: = PackedStringArray()
	if bool(hit.get("headshot", false)):
		parts.append("💀")
	if bool(hit.get("airborne", false)):
		parts.append("🦘")
	if bool(hit.get("noscope", false)):
		parts.append("🙈")
	return " ".join(parts)


func toast(text: String) -> void :
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()
	toast_label.text = text
	toast_label.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(1.15)
	_toast_tween.tween_property(toast_label, "modulate:a", 0.0, 0.4)


func show_pause() -> void :
	_hide_scoreboard()
	pause_overlay.show()
	_update_pause_stats()
	%ResumeButton.grab_focus()


func hide_pause() -> void :
	pause_overlay.hide()


func _update_pause_stats() -> void :
	if not _pause_stats_override.is_empty():
		pause_stats.text = _pause_stats_override
		return
	pause_stats.text = "СЧЁТ %d   ·   %d/%d ПОПАДАНИЙ   ·   %d ХЕДШОТОВ   ·   %.1f%%" % [
		_score, _hits, _shots, _headshots, _accuracy
	]



func set_pause_stats(text: String) -> void :
	_pause_stats_override = text


func fade_out(duration: = 0.3) -> void :
	fade.visible = true
	fade.modulate.a = 0.0
	var tween: = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, duration)
	await tween.finished








func _build_health_panel() -> void :
	if _skull_row == null:
		return
	_health_panel = VBoxContainer.new()
	_health_panel.name = "DuelHealth"
	_health_panel.set_anchors_preset(Control.PRESET_CENTER)
	_health_panel.offset_left = -168.0
	_health_panel.offset_top = -22.0
	_health_panel.offset_right = -42.0
	_health_panel.offset_bottom = 34.0
	_health_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	_health_panel.add_theme_constant_override("separation", 1)
	_health_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_health_panel.visible = false
	_skull_row.add_child(_health_panel)

	_health_label = Label.new()
	_health_label.name = "HealthValue"
	_health_label.text = "100"
	_health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_health_label.add_theme_font_override("font", UITheme.display_font(700))
	_health_label.add_theme_font_size_override("font_size", 30)
	_health_label.add_theme_color_override("font_color", Color(0.55, 0.96, 0.62, 1.0))
	_health_label.add_theme_color_override("font_outline_color", 
		Color(0.01, 0.02, 0.02, 0.75))
	_health_label.add_theme_constant_override("outline_size", 4)
	_health_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_health_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_health_panel.add_child(_health_label)

	var track: = Control.new()
	track.name = "HealthTrack"


	var health_font: = _health_label.get_theme_font("font")
	var health_font_size: = _health_label.get_theme_font_size("font_size")
	var bar_width: = health_font.get_string_size("100", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, health_font_size).x
	track.custom_minimum_size = Vector2(ceilf(bar_width), 7.0)
	track.size_flags_horizontal = Control.SIZE_SHRINK_END
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_health_panel.add_child(track)

	var track_bg: = ColorRect.new()
	track_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	track_bg.color = Color(1.0, 1.0, 1.0, 0.12)
	track_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(track_bg)



	_health_fill = ColorRect.new()
	_health_fill.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_health_fill.anchor_left = 1.0
	_health_fill.offset_left = 0.0
	_health_fill.color = Color(0.55, 0.96, 0.62, 1.0)
	_health_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.add_child(_health_fill)



func _health_color(ratio: float) -> Color:
	var green: = Color(0.36, 0.96, 0.46, 1.0)
	var yellow: = Color(1.0, 0.8, 0.2, 1.0)
	var red: = Color(1.0, 0.2, 0.16, 1.0)
	var t: = clampf(ratio, 0.0, 1.0)


	if t >= 0.5:
		return yellow.lerp(green, smoothstep(0.5, 1.0, t))
	return red.lerp(yellow, smoothstep(0.0, 0.5, t))




func _build_duel_overlays() -> void :
	_damage_vignette = ColorRect.new()
	_damage_vignette.name = "DuelDamageVignette"
	_damage_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_damage_vignette.color = Color.WHITE
	_damage_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_damage_vignette.visible = false
	_damage_material = ShaderMaterial.new()
	_damage_material.shader = KillVignetteShader
	_damage_material.set_shader_parameter("glow_color", Color(0.95, 0.1, 0.08, 1.0))
	_damage_material.set_shader_parameter("strength", 0.9)
	_damage_material.set_shader_parameter("inner", 0.5)
	_damage_material.set_shader_parameter("outer", 1.38)
	_damage_material.set_shader_parameter("opacity", 0.0)
	_damage_vignette.material = _damage_material
	root.add_child(_damage_vignette)

	_death_fx = ColorRect.new()
	_death_fx.name = "DuelDeathFx"
	_death_fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_death_fx.color = Color.WHITE
	_death_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_death_fx.visible = false
	_death_material = ShaderMaterial.new()
	_death_material.shader = DeathFxShader
	_death_material.set_shader_parameter("progress", 0.0)
	_death_material.set_shader_parameter("vignette", 1.0)
	_death_fx.material = _death_material
	root.add_child(_death_fx)




	_duel_score_panel = PanelContainer.new()
	_duel_score_panel.name = "DuelScore"
	_duel_score_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_duel_score_panel.offset_left = -142.0
	_duel_score_panel.offset_top = 26.0
	_duel_score_panel.offset_right = 142.0
	_duel_score_panel.offset_bottom = 86.0
	_duel_score_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_duel_score_panel.visible = false
	var score_style: = StyleBoxFlat.new()
	score_style.bg_color = Color(0.115, 0.08, 0.042, 0.9)
	score_style.border_color = Color(0.88, 0.72, 0.4, 0.66)
	score_style.set_border_width_all(1)


	score_style.border_width_top = 2
	score_style.set_corner_radius_all(11)
	score_style.content_margin_left = 12.0
	score_style.content_margin_right = 12.0
	score_style.content_margin_top = 6.0
	score_style.content_margin_bottom = 7.0
	score_style.shadow_color = Color(0.04, 0.02, 0.005, 0.5)
	score_style.shadow_size = 9
	score_style.shadow_offset = Vector2(0.0, 4.0)
	_duel_score_panel.add_theme_stylebox_override("panel", score_style)
	root.add_child(_duel_score_panel)

	var score_row: = HBoxContainer.new()
	score_row.alignment = BoxContainer.ALIGNMENT_CENTER
	score_row.add_theme_constant_override("separation", 16)
	score_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_duel_score_panel.add_child(score_row)

	_score_player_avatar = _add_duel_avatar(score_row, 
		Settings.get_avatar_texture(), Color(0.44, 0.93, 0.58, 1.0))

	_duel_score_label = Label.new()
	_duel_score_label.text = "0 : 0"
	_duel_score_label.custom_minimum_size = Vector2(88.0, 0.0)
	_duel_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_duel_score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_duel_score_label.add_theme_font_override("font", UITheme.display_font(700))
	_duel_score_label.add_theme_font_size_override("font_size", 30)
	_duel_score_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.72, 1.0))
	_duel_score_label.add_theme_color_override("font_outline_color", 
		Color(0.1, 0.06, 0.02, 0.85))
	_duel_score_label.add_theme_constant_override("outline_size", 5)
	_duel_score_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_row.add_child(_duel_score_label)

	var bot_avatar: Texture2D = null
	var avatar_pool: Array = Settings.AVATARS
	if not avatar_pool.is_empty():
		var bot_index: = (Settings.avatar_index + 1) % avatar_pool.size()
		bot_avatar = load(str(avatar_pool[bot_index])) as Texture2D
	_score_bot_avatar = _add_duel_avatar(score_row, bot_avatar, 
		Color(0.94, 0.42, 0.3, 1.0))

	_countdown_label = Label.new()
	_countdown_label.name = "DuelCountdown"
	_countdown_label.anchor_left = 0.0
	_countdown_label.anchor_right = 1.0
	_countdown_label.anchor_top = 0.5
	_countdown_label.anchor_bottom = 0.5
	_countdown_label.offset_top = -88.0
	_countdown_label.offset_bottom = 88.0
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_countdown_label.add_theme_font_override("font", UITheme.display_font(700))
	_countdown_label.add_theme_font_size_override("font_size", 96)
	_countdown_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.42, 1.0))
	_countdown_label.add_theme_color_override("font_outline_color", Color(0.03, 0.02, 0.01, 0.96))
	_countdown_label.add_theme_constant_override("outline_size", 18)
	_countdown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_countdown_label.visible = false
	root.add_child(_countdown_label)

	_duel_banner = Label.new()
	_duel_banner.name = "DuelBanner"
	_duel_banner.anchor_left = 0.0
	_duel_banner.anchor_right = 1.0
	_duel_banner.anchor_top = 0.5
	_duel_banner.anchor_bottom = 0.5
	_duel_banner.offset_top = -176.0
	_duel_banner.offset_bottom = -62.0
	_duel_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_duel_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_duel_banner.add_theme_font_override("font", UITheme.display_font(700))
	_duel_banner.add_theme_font_size_override("font_size", 78)
	_duel_banner.add_theme_color_override("font_color", Color(0.42, 1.0, 0.56, 1.0))
	_duel_banner.add_theme_color_override("font_outline_color", Color(0.015, 0.035, 0.02, 0.98))
	_duel_banner.add_theme_constant_override("outline_size", 20)
	_duel_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_duel_banner.visible = false
	root.add_child(_duel_banner)

	_build_weapon_roll()
	_build_result_overlay()




func _build_weapon_roll() -> void :
	_weapon_roll_layer = Control.new()
	_weapon_roll_layer.name = "DuelWeaponRoll"
	_weapon_roll_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_weapon_roll_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_weapon_roll_layer.visible = false
	root.add_child(_weapon_roll_layer)

	_weapon_roll_backdrop = ColorRect.new()
	_weapon_roll_backdrop.name = "WeaponRollBackdrop"
	_weapon_roll_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_weapon_roll_backdrop.color = Color(0.012, 0.009, 0.006, 0.0)
	_weapon_roll_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_weapon_roll_layer.add_child(_weapon_roll_backdrop)

	var center: = VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 14)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_weapon_roll_layer.add_child(center)

	_weapon_roll_caption = Label.new()
	_weapon_roll_caption.text = "СЛУЧАЙНОЕ ОРУЖИЕ МАТЧА"
	_weapon_roll_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_weapon_roll_caption.add_theme_font_override("font", UITheme.display_font(700))
	_weapon_roll_caption.add_theme_font_size_override("font_size", 30)
	_weapon_roll_caption.add_theme_color_override("font_color", UITheme.GOLD_BRIGHT)
	_weapon_roll_caption.add_theme_color_override("font_outline_color", 
		Color(0.1, 0.05, 0.01, 0.94))
	_weapon_roll_caption.add_theme_constant_override("outline_size", 9)
	_weapon_roll_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_weapon_roll_caption)

	var row: = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 22)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(row)

	for id in ["awp", "ak47", "m4a1", "deagle"]:
		var card: = PanelContainer.new()
		card.custom_minimum_size = Vector2(250.0, 176.0)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style: = StyleBoxFlat.new()
		style.bg_color = Color(0.07, 0.05, 0.02, 0.92)
		style.border_color = Color(0.3, 0.2, 0.06, 0.85)
		style.set_border_width_all(1)
		style.set_corner_radius_all(12)
		style.content_margin_left = 8.0
		style.content_margin_right = 8.0
		style.content_margin_top = 8.0
		style.content_margin_bottom = 8.0
		style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
		style.shadow_size = 10
		style.shadow_offset = Vector2(0.0, 3.0)
		card.add_theme_stylebox_override("panel", style)
		row.add_child(card)

		var column: = VBoxContainer.new()
		column.alignment = BoxContainer.ALIGNMENT_CENTER
		column.add_theme_constant_override("separation", 4)
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(column)




		var skins: Dictionary = WeaponData.get_weapon(id).get("skins", {})
		var base_skin: = str(skins.keys()[0]) if not skins.is_empty() else "default"
		var preview: = WeaponPreview.new()
		preview.setup(id, base_skin)
		preview.custom_minimum_size = Vector2(230.0, 118.0)
		preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		preview.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		column.add_child(preview)

		var name_label: = Label.new()
		name_label.text = str(WeaponData.get_weapon(id).get("name", id.to_upper()))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_override("font", UITheme.display_font(600))
		name_label.add_theme_font_size_override("font_size", 19)
		name_label.add_theme_color_override("font_color", UITheme.MENU_MUTED)
		name_label.add_theme_color_override("font_outline_color", 
			Color(0.08, 0.04, 0.01, 0.9))
		name_label.add_theme_constant_override("outline_size", 5)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(name_label)

		_weapon_roll_cards.append({
			"panel": card, "style": style, "preview": preview, 
			"label": name_label, "id": id, 
		})

	_weapon_roll_hint = Label.new()
	_weapon_roll_hint.text = "ОДИНАКОВО ДЛЯ ВАС И СОПЕРНИКА"
	_weapon_roll_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_weapon_roll_hint.add_theme_font_override("font", UITheme.display_font(500))
	_weapon_roll_hint.add_theme_font_size_override("font_size", 13)
	_weapon_roll_hint.add_theme_color_override("font_color", UITheme.MUTED)
	_weapon_roll_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_weapon_roll_hint)



func _set_weapon_roll_highlight(index: int, chosen: = false) -> void :
	for i in _weapon_roll_cards.size():
		var entry: Dictionary = _weapon_roll_cards[i]
		var style: StyleBoxFlat = entry["style"]
		var preview: Control = entry["preview"]
		var label: Label = entry["label"]
		var active: = i == index
		if active:
			var border: = UITheme.GOLD_BRIGHT if chosen else UITheme.GOLD
			style.border_color = border
			style.set_border_width_all(3 if chosen else 2)
			style.bg_color = Color(0.165, 0.105, 0.022, 0.98)
			style.shadow_color = Color(border.r, border.g, border.b, 
				0.38 if chosen else 0.2)
			style.shadow_size = 22 if chosen else 12


			preview.modulate = Color.WHITE if chosen\
			else Color(0.94, 0.88, 0.74, 1.0)
			label.add_theme_color_override("font_color", UITheme.GOLD_BRIGHT)
		else:
			style.border_color = Color(0.3, 0.2, 0.06, 0.85)
			style.set_border_width_all(1)
			style.bg_color = Color(0.07, 0.05, 0.02, 0.92)
			style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
			style.shadow_size = 10
			preview.modulate = Color(0.52, 0.52, 0.52, 1.0)
			label.add_theme_color_override("font_color", UITheme.MENU_MUTED)





func show_duel_weapon_roll(weapon_id: String) -> void :
	if _weapon_roll_layer == null or _weapon_roll_cards.is_empty():
		return
	_weapon_roll_token += 1
	var token: = _weapon_roll_token
	var target: = 0
	for i in _weapon_roll_cards.size():
		if str(_weapon_roll_cards[i]["id"]) == weapon_id:
			target = i
			break

	_weapon_roll_layer.visible = true
	_weapon_roll_layer.modulate.a = 1.0
	_weapon_roll_backdrop.color = Color(0.012, 0.009, 0.006, 0.0)
	_set_weapon_roll_highlight(-1)
	_weapon_roll_caption.modulate.a = 0.0
	_weapon_roll_hint.modulate.a = 0.0

	var fade: = create_tween()
	fade.set_parallel(true)
	fade.tween_property(_weapon_roll_backdrop, "color:a", 0.74, 0.24)
	fade.tween_property(_weapon_roll_caption, "modulate:a", 1.0, 0.26)

	var entrance: = create_tween()
	entrance.set_parallel(true)
	for i in _weapon_roll_cards.size():
		var card: Control = _weapon_roll_cards[i]["panel"]
		card.pivot_offset = card.custom_minimum_size * 0.5
		card.modulate.a = 0.0
		card.scale = Vector2(0.9, 0.9)
		var delay: = 0.04 * float(i)
		entrance.tween_property(card, "modulate:a", 1.0, 0.18)\
		.set_delay(delay)
		entrance.tween_property(card, "scale", Vector2.ONE, 0.26)\
		.set_delay(delay).set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.36, false).timeout
	if token != _weapon_roll_token or not is_inside_tree():
		return



	var steps: = 13
	var count: = _weapon_roll_cards.size()
	var start: = posmod(target - (steps - 1), count)
	var delay: = 0.055
	for step in steps:
		if token != _weapon_roll_token or not is_inside_tree():
			return
		var index: = (start + step) % count
		_set_weapon_roll_highlight(index, step == steps - 1)
		Sfx.play_click()
		await get_tree().create_timer(delay, false).timeout
		delay = lerpf(0.055, 0.26, float(step) / float(maxi(steps - 1, 1)))
	if token != _weapon_roll_token or not is_inside_tree():
		return

	var chosen: Control = _weapon_roll_cards[target]["panel"]
	chosen.pivot_offset = chosen.custom_minimum_size * 0.5
	var pop: = create_tween()
	pop.tween_property(chosen, "scale", Vector2(1.09, 1.09), 0.12)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(chosen, "scale", Vector2.ONE, 0.22)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var hint_tween: = create_tween()
	hint_tween.tween_property(_weapon_roll_hint, "modulate:a", 1.0, 0.2)
	Sfx.play_ui()
	await get_tree().create_timer(0.64, false).timeout
	if token != _weapon_roll_token or not is_inside_tree():
		return

	var out: = create_tween()
	out.set_parallel(true)
	out.tween_property(_weapon_roll_layer, "modulate:a", 0.0, 0.24)
	out.tween_property(_weapon_roll_backdrop, "color:a", 0.0, 0.24)
	await get_tree().create_timer(0.26, false).timeout
	if token != _weapon_roll_token:
		return
	_weapon_roll_layer.visible = false
	_weapon_roll_layer.modulate.a = 1.0


func _add_duel_avatar(parent: Container, texture: Texture2D, 
		accent: Color) -> TextureRect:
	var frame: = PanelContainer.new()
	frame.custom_minimum_size = Vector2(48.0, 48.0)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.075, 0.04, 0.96)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(9)
	style.content_margin_left = 2.0
	style.content_margin_right = 2.0
	style.content_margin_top = 2.0
	style.content_margin_bottom = 2.0
	frame.add_theme_stylebox_override("panel", style)
	parent.add_child(frame)

	var rect: = TextureRect.new()
	rect.texture = texture
	rect.custom_minimum_size = Vector2(40.0, 40.0)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(rect)
	return rect




func set_duel_roster(_player_name: String, player_avatar: Texture2D, 
		_bot_name: String, bot_avatar: Texture2D) -> void :
	if _score_player_avatar != null:
		_score_player_avatar.texture = player_avatar
	if _score_bot_avatar != null:
		_score_bot_avatar.texture = bot_avatar




func set_duel_bot_level(_level: int, _elo: int) -> void :
	pass


func _build_result_overlay() -> void :
	_result_overlay = Control.new()
	_result_overlay.name = "DuelResult"
	_result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_result_overlay.visible = false
	root.add_child(_result_overlay)

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.008, 0.012, 0.016, 0.78)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_result_overlay.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_result_overlay.add_child(center)

	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 0.0)
	var style: = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.04, 0.048, 0.985)
	style.border_color = Color(_accent().r, _accent().g, _accent().b, 0.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 34.0
	style.content_margin_right = 34.0
	style.content_margin_top = 28.0
	style.content_margin_bottom = 28.0
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	panel.add_child(content)

	_result_title = Label.new()
	_result_title.text = "ПОБЕДА"
	_result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_title.add_theme_font_override("font", UITheme.display_font(700))
	_result_title.add_theme_font_size_override("font_size", 50)
	_result_title.add_theme_color_override("font_color", Color(0.42, 1.0, 0.56, 1.0))
	content.add_child(_result_title)

	_result_subtitle = Label.new()
	_result_subtitle.text = "РЕЙТИНГОВАЯ ДУЭЛЬ 1×1"
	_result_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_subtitle.add_theme_font_override("font", UITheme.ui_font(600))
	_result_subtitle.add_theme_font_size_override("font_size", 11)
	_result_subtitle.add_theme_color_override("font_color", UITheme.MUTED)
	content.add_child(_result_subtitle)

	_result_delta = Label.new()
	_result_delta.text = "+20 ELO"
	_result_delta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_delta.add_theme_font_override("font", UITheme.display_font(600))
	_result_delta.add_theme_font_size_override("font_size", 32)
	_result_delta.add_theme_color_override("font_color", Color(0.42, 1.0, 0.56, 1.0))
	content.add_child(_result_delta)

	_result_rating = Label.new()
	_result_rating.text = "1000 ELO · УРОВЕНЬ 1 · НОВИЧОК"
	_result_rating.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_rating.add_theme_font_override("font", UITheme.ui_font(600))
	_result_rating.add_theme_font_size_override("font_size", 13)
	_result_rating.add_theme_color_override("font_color", UITheme.TEXT)
	content.add_child(_result_rating)

	content.add_child(HSeparator.new())

	_result_stats = Label.new()
	_result_stats.text = ""
	_result_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_stats.add_theme_font_override("font", UITheme.ui_font(500))
	_result_stats.add_theme_font_size_override("font_size", 12)
	_result_stats.add_theme_color_override("font_color", UITheme.MUTED)
	_result_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_result_stats)

	_result_note = Label.new()
	_result_note.text = ""
	_result_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_note.add_theme_font_override("font", UITheme.ui_font(700))
	_result_note.add_theme_font_size_override("font_size", 11)
	_result_note.add_theme_color_override("font_color", _accent_bright())
	_result_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_result_note)

	var spacer: = Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 6.0)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(spacer)

	var buttons: = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 12)
	content.add_child(buttons)



	_result_menu = Button.new()
	_result_menu.text = "В ГЛАВНОЕ МЕНЮ"
	_result_menu.focus_mode = Control.FOCUS_NONE
	_result_menu.custom_minimum_size = Vector2(280.0, 52.0)
	var menu_box: = StyleBoxFlat.new()
	menu_box.bg_color = Color(0.105, 0.078, 0.032, 0.98)
	menu_box.border_color = _accent_bright()
	menu_box.set_border_width_all(1)
	menu_box.set_corner_radius_all(6)
	menu_box.content_margin_left = 24.0
	menu_box.content_margin_right = 24.0
	var menu_hover: = menu_box.duplicate() as StyleBoxFlat
	menu_hover.bg_color = Color(_accent().r, _accent().g, _accent().b, 0.24)
	menu_hover.border_color = _accent_bright()
	menu_hover.set_border_width_all(2)
	var menu_pressed: = menu_box.duplicate() as StyleBoxFlat
	menu_pressed.bg_color = Color(_accent().r, _accent().g, _accent().b, 0.42)
	_result_menu.add_theme_stylebox_override("normal", menu_box)
	_result_menu.add_theme_stylebox_override("hover", menu_hover)
	_result_menu.add_theme_stylebox_override("pressed", menu_pressed)
	_result_menu.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for state in ["font_color", "font_hover_color", "font_pressed_color", 
			"font_focus_color"]:
		_result_menu.add_theme_color_override(state, Color(1.0, 1.0, 1.0, 1.0))
	_result_menu.add_theme_font_override("font", UITheme.ui_font(700))
	_result_menu.add_theme_font_size_override("font_size", 19)
	_result_menu.pressed.connect(Sfx.play_click)
	_result_menu.pressed.connect( func() -> void : duel_menu_requested.emit())
	buttons.add_child(_result_menu)


func show_health_panel(on: bool) -> void :
	if _health_panel != null:
		_health_panel.visible = on
	if _kill_counter_row != null:


		_kill_counter_row.visible = not on
	if _duel_score_panel != null:
		_duel_score_panel.visible = on


func set_health(health: float, max_health: = 100.0) -> void :
	if _health_label == null:
		return
	var maximum: = maxf(max_health, 1.0)
	var ratio: = clampf(health / maximum, 0.0, 1.0)
	_health_label.text = str(int(round(health)))
	var color: = _health_color(ratio)
	if _health_fill != null:

		_health_fill.anchor_left = 1.0 - ratio
		_health_fill.offset_left = 0.0
		_health_fill.color = color
		_health_label.add_theme_color_override("font_color", 
			color.lerp(Color.WHITE, 0.18))


func set_rating(_elo: int, _level: int, _level_name: String) -> void :


	pass


func set_duel_header(_text: String) -> void :
	pass



func set_duel_score(player_score: int, bot_score: int, _target: = 5) -> void :
	if _duel_score_label == null:
		return
	_duel_score_label.text = "%d : %d" % [player_score, bot_score]
	var lead: = player_score - bot_score
	var color: = UITheme.TEXT
	if lead > 0:
		color = Color(0.42, 1.0, 0.56, 1.0)
	elif lead < 0:
		color = Color(1.0, 0.4, 0.32, 1.0)
	_duel_score_label.add_theme_color_override("font_color", color)


func set_duel_match_over(_player_score: int, _bot_score: int) -> void :
	pass



func clear_duel_fx() -> void :
	_clear_killfeed()
	if _damage_tween != null and _damage_tween.is_valid():
		_damage_tween.kill()
	if _death_tween != null and _death_tween.is_valid():
		_death_tween.kill()
	if _damage_vignette != null:
		_damage_vignette.visible = false
	if _death_fx != null:
		_death_fx.visible = false
	if _death_material != null:
		_death_material.set_shader_parameter("progress", 0.0)
	if _duel_banner != null:
		_duel_banner.visible = false
	if _weapon_roll_layer != null:
		_weapon_roll_token += 1
		_weapon_roll_layer.visible = false
		_weapon_roll_layer.modulate.a = 1.0
	if _countdown_label != null:
		_countdown_label.visible = false


func fade_in(duration: = 0.3) -> void :
	fade.color = UITheme.BG
	fade.visible = true
	fade.modulate.a = 1.0
	var tween: = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, duration)
	await tween.finished
	fade.visible = false


func flash_damage(strength: = 1.0) -> void :
	if _damage_material == null or _damage_vignette == null:
		return
	if _damage_tween != null and _damage_tween.is_valid():
		_damage_tween.kill()
	var peak: = clampf(0.62 * strength, 0.0, 1.0)
	_damage_vignette.visible = true
	_damage_material.set_shader_parameter("opacity", peak)
	_damage_tween = create_tween()
	_damage_tween.tween_method(_set_damage_opacity, peak, 0.0, 0.46)
	_damage_tween.tween_callback( func() -> void : _damage_vignette.visible = false)


func _set_damage_opacity(value: float) -> void :
	if _damage_material != null:
		_damage_material.set_shader_parameter("opacity", value)


func set_countdown(text: String) -> void :
	if _countdown_label == null:
		return
	if _countdown_tween != null and _countdown_tween.is_valid():
		_countdown_tween.kill()
	_countdown_label.text = text
	_countdown_label.visible = true
	_countdown_label.pivot_offset = _countdown_label.size * 0.5
	_countdown_label.scale = Vector2(1.16, 1.16)
	_countdown_label.modulate.a = 0.0
	_countdown_tween = create_tween()
	_countdown_tween.set_parallel(true)
	_countdown_tween.tween_property(_countdown_label, "modulate:a", 1.0, 0.1)
	_countdown_tween.tween_property(_countdown_label, "scale", Vector2.ONE, 0.16)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_duel_intro() -> void :
	if _countdown_label != null:
		_countdown_label.visible = false


func show_duel_banner(text: String, color: Color) -> void :
	if _duel_banner == null:
		return
	if _duel_banner_tween != null and _duel_banner_tween.is_valid():
		_duel_banner_tween.kill()
	_duel_banner.text = text
	_fit_duel_banner_font(text)
	_duel_banner.add_theme_color_override("font_color", color)
	_duel_banner.visible = true
	_duel_banner.pivot_offset = _duel_banner.size * 0.5
	_duel_banner.scale = Vector2(1.1, 1.1)
	_duel_banner.modulate.a = 0.0
	_duel_banner_tween = create_tween()
	_duel_banner_tween.set_parallel(true)
	_duel_banner_tween.tween_property(_duel_banner, "modulate:a", 1.0, 0.16)
	_duel_banner_tween.tween_property(_duel_banner, "scale", Vector2.ONE, 0.3)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)




func _fit_duel_banner_font(text: String) -> void :
	var font: = _duel_banner.get_theme_font("font")
	var font_size: = 78
	if font == null:
		_duel_banner.add_theme_font_size_override("font_size", font_size)
		return
	var available: = maxf(_duel_banner.size.x, 
		get_viewport().get_visible_rect().size.x)
	if available <= 1.0:
		available = 1280.0
	available *= 0.9
	while font_size > 28 and font.get_string_size(
			text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x > available:
		font_size -= 2
	_duel_banner.add_theme_font_size_override("font_size", font_size)

	var outline: = clampi(int(round(20.0 * float(font_size) / 78.0)), 8, 20)
	_duel_banner.add_theme_constant_override("outline_size", outline)


func show_death_fx() -> void :
	if _death_fx == null or _death_material == null:
		return
	_death_fx.visible = true
	_death_material.set_shader_parameter("progress", 0.0)
	if _death_tween != null and _death_tween.is_valid():
		_death_tween.kill()
	_death_tween = create_tween()
	_death_tween.tween_method(_set_death_progress, 0.0, 1.0, 1.8)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _set_death_progress(value: float) -> void :
	if _death_material != null:
		_death_material.set_shader_parameter("progress", value)


func show_duel_result(data: Dictionary) -> void :
	if _result_overlay == null:
		return
	if _countdown_label != null:
		_countdown_label.visible = false
	if _duel_banner != null:
		_duel_banner.visible = false

	var won: = bool(data.get("won", false))
	var delta: = int(data.get("delta", 0))
	var elo: = int(data.get("elo", 0))
	var best: = int(data.get("best", 0))
	var level: = int(data.get("level", 1))
	var level_name: = str(data.get("level_name", "НОВИЧОК"))

	_result_title.text = "ПОБЕДА" if won else "ПОРАЖЕНИЕ"
	_result_title.add_theme_color_override("font_color", 
		Color(0.42, 1.0, 0.56, 1.0) if won else Color(1.0, 0.28, 0.24, 1.0))
	_result_subtitle.text = "РЕЙТИНГОВАЯ ДУЭЛЬ 1×1  ·  МАТЧ %d : %d" % [
		int(data.get("rounds_won", 0)), int(data.get("rounds_lost", 0))
	]
	var opponent_elo: = int(data.get("opponent_elo", 0))
	if opponent_elo > 0:
		_result_subtitle.text += "  ·  СОПЕРНИК %d ELO" % opponent_elo
	_result_delta.text = ("+%d ELO" % delta) if delta >= 0 else ("%d ELO" % delta)
	_result_delta.add_theme_color_override("font_color", 
		Color(0.42, 1.0, 0.56, 1.0) if delta >= 0 else Color(1.0, 0.34, 0.28, 1.0))
	_result_rating.text = "%d ELO   ·   УРОВЕНЬ %d   ·   %s" % [elo, level, level_name]
	var accuracy: = float(data.get("accuracy", 0.0)) * 100.0
	var shots: = int(data.get("shots", 0))
	var hits: = int(data.get("hits", 0))
	var headshots: = int(data.get("headshots", 0))
	var damage: = int(data.get("damage", 0))
	_result_stats.text = "ТОЧНОСТЬ %.0f%%  (%d/%d)   ·   ХЕДШОТЫ %d   ·   УРОН %d" % [
		accuracy, hits, shots, headshots, damage
	]
	_result_stats.text += "\nПОБЕДЫ %d   ·   ПОРАЖЕНИЯ %d   ·   ВИНРЕЙТ %.1f%%   ·   СЕРИЯ %d" % [
		int(data.get("wins", 0)), int(data.get("losses", 0)), 
		Settings.rating_winrate(), int(data.get("streak", 0))
	]

	var parts: Array[String] = []
	var base_delta: = int(data.get("base_delta", 0))
	var strength_delta: = int(data.get("strength_delta", 0))
	if won:
		parts.append("БАЗА +%d" % base_delta)
		for pair in [
			["ТОЧНОСТЬ", int(data.get("accuracy_bonus", 0))], 
			["ХЕДШОТЫ", int(data.get("headshot_bonus", 0))], 
			["УРОН", int(data.get("damage_bonus", 0))], 
			["РАУНДЫ", int(data.get("margin_bonus", 0))], 
		]:
			if int(pair[1]) > 0:
				parts.append("%s +%d" % [pair[0], pair[1]])
	else:
		parts.append("ШТРАФ %d" % base_delta)
		var mitigation: = int(data.get("mitigation", 0))
		if mitigation > 0:
			parts.append("СМЯГЧЕНИЕ +%d" % mitigation)
	if strength_delta != 0:
		parts.append("СОПЕРНИК %s%d" % [
			"+" if strength_delta > 0 else "", strength_delta
		])
	var note: = "   ·   ".join(parts)
	var extras: Array[String] = []
	if bool(data.get("level_up", false)):
		extras.append("НОВЫЙ УРОВЕНЬ — %s" % level_name)
	elif bool(data.get("level_down", false)):
		extras.append("УРОВЕНЬ СНИЖЕН — %s" % level_name)
	if won and elo >= best:
		extras.append("НОВЫЙ РЕКОРД ЭЛО")
	elif best > 0:
		extras.append("РЕКОРД %d ELO" % best)


	if level >= 10:
		extras.append("МАКСИМАЛЬНЫЙ УРОВЕНЬ · ЭЛО РАСТЁТ ДАЛЬШЕ")
	else:
		var bounds: = Settings.rating_level_bounds()
		var need: = maxi(int(bounds["high"]) - elo, 0)
		extras.append("ДО УРОВНЯ %d — %d ELO" % [level + 1, need])
	if not extras.is_empty():
		note += "\n" + "   ·   ".join(extras)
	_result_note.text = note

	_result_overlay.visible = true
	_result_overlay.modulate.a = 0.0
	var tween: = create_tween()
	tween.tween_property(_result_overlay, "modulate:a", 1.0, 0.22)





class GlobeIcon extends Control:
	var tint: = Color.WHITE

	func _draw() -> void :
		var radius: = minf(size.x, size.y) * 0.5 - 1.0
		if radius <= 1.0:
			return
		var center: = size * 0.5
		draw_circle(center, radius, tint)
		var dark: = Color(0.04, 0.05, 0.06, 0.55)
		draw_arc(center, radius, 0.0, TAU, 32, dark, 1.0, true)
		draw_line(center + Vector2( - radius, 0.0), 
			center + Vector2(radius, 0.0), dark, 1.0, true)
		draw_line(center + Vector2(0.0, - radius), 
			center + Vector2(0.0, radius), dark, 1.0, true)
		draw_arc(center, radius * 0.52, 0.0, TAU, 24, dark, 1.0, true)


class Sparkline extends Control:
	var values: Array = []
	var tint: = Color.WHITE

	func _draw() -> void :
		if values.size() < 2:
			return
		var low: = INF
		var high: = - INF
		for value in values:
			low = minf(low, float(value))
			high = maxf(high, float(value))
		var span: = maxf(high - low, 0.0001)
		var points: = PackedVector2Array()
		for i in values.size():
			var x: = float(i) / float(values.size() - 1) * size.x
			var y: = size.y - (float(values[i]) - low) / span\
			* (size.y - 4.0) - 2.0
			points.append(Vector2(x, y))
		draw_polyline(points, Color(tint.r, tint.g, tint.b, 0.85), 2.0, true)
		for point in points:
			draw_circle(point, 2.1, tint, true, -1.0, true)


class CsWatermark extends Control:
	var tint: = Color(1.0, 1.0, 1.0, 0.06)

	func _draw() -> void :
		var w: = size.x
		var h: = size.y
		if w < 8.0 or h < 8.0:
			return
		var s: = minf(w, h)


		draw_circle(Vector2(w * 0.34, h * 0.13), s * 0.055, tint)
		draw_colored_polygon(PackedVector2Array([
			Vector2(w * 0.29, h * 0.19), Vector2(w * 0.4, h * 0.19), 
			Vector2(w * 0.43, h * 0.45), Vector2(w * 0.37, h * 0.62), 
			Vector2(w * 0.31, h * 0.62), Vector2(w * 0.26, h * 0.45), 
		]), tint)
		draw_line(Vector2(w * 0.37, h * 0.27), 
			Vector2(w * 0.61, h * 0.23), tint, s * 0.03, true)
		draw_line(Vector2(w * 0.61, h * 0.23), 
			Vector2(w * 0.78, h * 0.29), tint, s * 0.022, true)
		draw_line(Vector2(w * 0.46, h * 0.21), 
			Vector2(w * 0.82, h * 0.21), tint, s * 0.016, true)
		draw_line(Vector2(w * 0.33, h * 0.6), 
			Vector2(w * 0.25, h * 0.84), tint, s * 0.045, true)
		draw_line(Vector2(w * 0.35, h * 0.6), 
			Vector2(w * 0.43, h * 0.84), tint, s * 0.045, true)
