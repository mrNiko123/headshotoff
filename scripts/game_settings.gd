extends CanvasLayer




signal closed

const UITheme = preload("res://scripts/ui_theme.gd")
const ColorWheel = preload("res://scripts/color_wheel.gd")
const LayoutEditor = preload("res://scripts/mobile_layout_editor.gd")
const HudLayoutEditor = preload("res://scripts/hud_layout_editor.gd")
const ViewmodelPreview = preload("res://scripts/viewmodel_preview.gd")
const ConfigCodeUI = preload("res://scripts/config_code_ui.gd")



const TAB_ORDER: = ["game", "controls", "crosshair", "colors", "hands", "screen"]
const TAB_CAPTIONS: = {
	"game": "ИГРА", 
	"controls": "УПРАВЛЕНИЕ", 
	"crosshair": "ПРИЦЕЛ", 
	"colors": "ЦВЕТА", 
	"hands": "РУКИ", 
	"screen": "ЭКРАН", 
}
const TAB_HINTS: = {
	"game": "Чувствительность, FOV, манекены, громкость и таймер сессии.", 
	"controls": "Переназначение клавиш и кнопок мыши для всех действий.", 
	"crosshair": "Цвет, форма и поведение прицела, прозрачная оптика AWP.", 
	"colors": "Акцент HUD, небо, рукав и кисть: пресеты или любой цвет.", 
	"hands": "Положение и размер рук, покачивание и левая рука.", 
	"screen": "Растяжение кадра, FPS, графика, экран и расположение HUD.", 
}

var _root: Control
var _body: VBoxContainer
var _scroll: ScrollContainer
var _close_button: Button
var _wheel_popup: PopupPanel
var _tab_bar: HBoxContainer
var _tab_hint: Label
var _settings_tab: = "game"
var _rebind_action: = ""
var _rebind_button: Button
var _theme_accent: = Color.BLACK
var _built: = false
var _is_mobile: = false
var _mobile_box: VBoxContainer
var _vm_preview


func _ready() -> void :
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


	_is_mobile = _detect_mobile_platform()
	Settings.settings_changed.connect(_on_settings_changed)
	_build()
	_apply_platform_visibility()


func _detect_mobile_platform() -> bool:
	if OS.has_feature("mobile") or OS.get_name() == "Android":
		return true
	if OS.get_name() == "iOS":
		return true

	return OS.get_cmdline_user_args().has("--mobile-preview")


func open() -> void :
	if not _built:
		_build()
		_built = true
	_theme_accent = Settings.hud_accent
	_root.theme = UITheme.make_theme(_theme_accent)
	_apply_platform_visibility()
	visible = true
	_scroll.scroll_vertical = 0
	_close_button.grab_focus()

	if _vm_preview != null:
		_vm_preview.set_active(true)






func _apply_platform_visibility() -> void :
	# Мобильный блок (раскладка кнопок) теперь виден на всех платформах,
	# гироскоп внутри прячется на ПК отдельно.
	pass




func _rebuild() -> void :
	_vm_preview = null
	_mobile_box = null
	_tab_bar = null
	_tab_hint = null
	if _root != null:
		_root.queue_free()
		_root = null
	_wheel_popup = null
	_build()
	if _vm_preview != null:
		_vm_preview.set_active(visible)


func close() -> void :
	if not visible:
		return
	if _vm_preview != null:
		_vm_preview.set_active(false)
	visible = false
	if is_instance_valid(_wheel_popup) and _wheel_popup.visible:
		_wheel_popup.hide()
	closed.emit()


func _input(event: InputEvent) -> void :
	if not visible:
		return
	if _rebind_action != "":
		if event is InputEventKey:
			var key_event: = event as InputEventKey
			if not key_event.pressed or key_event.echo:
				return
			if key_event.keycode == KEY_ESCAPE:
				_cancel_settings_rebind()
			else:
				_finish_settings_rebind(key_event.physical_keycode)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton:
			var mouse_event: = event as InputEventMouseButton
			if not mouse_event.pressed:
				return
			_finish_settings_rebind(- int(mouse_event.button_index))
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):

		if Settings.mobile_editor_open:
			return

		if Settings.hud_editor_open:
			return

		if is_instance_valid(_wheel_popup) and _wheel_popup.visible:
			return
		close()
		get_viewport().set_input_as_handled()


func _render_controls() -> void :
	_body.add_child(_section_header("УПРАВЛЕНИЕ"))
	_body.add_child(_hint(
		"Клик по кнопке, затем нажмите новую клавишу или кнопку мыши "
		+ "(ЛКМ, ПКМ, СКМ, колесо). ESC — отменить."))
	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 7)
	_body.add_child(grid)
	for entry in Settings.BIND_ORDER:
		var action: = str(entry[0])
		var caption: = _label(str(entry[1]), &"Label", 12, 
			UITheme.MENU_TEXT)
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(caption)
		var button: = Button.new()
		button.text = Settings.get_key_label(action)
		button.theme_type_variation = &"SmallButton"
		button.custom_minimum_size = Vector2(118, 30)
		button.pressed.connect( func() -> void :
			_begin_settings_rebind(action, button))
		grid.add_child(button)
		_rebind_button_store[action] = button
	var reset_binds: = Button.new()
	reset_binds.text = "СБРОСИТЬ РАСКЛАДКУ"
	reset_binds.theme_type_variation = &"SmallButton"
	reset_binds.custom_minimum_size = Vector2(220, 34)
	reset_binds.pressed.connect( func() -> void :
		Settings.reset_keybinds()
		refresh_control_buttons())
	_body.add_child(reset_binds)
	_body.add_child(_hint("Раскладка сохраняется вместе с профилем."))


var _rebind_button_store: Dictionary = {}


func _begin_settings_rebind(action: String, button: Button) -> void :
	if _rebind_action != "":
		_cancel_settings_rebind()
	_rebind_action = action
	_rebind_button = button
	button.text = "…"


func _cancel_settings_rebind() -> void :
	_refresh_control_button(_rebind_action)
	_rebind_action = ""
	_rebind_button = null


func _finish_settings_rebind(code: int) -> void :
	var action: = _rebind_action
	Settings.set_keybind(action, code)
	_rebind_action = ""
	_rebind_button = null
	for stored_action in _rebind_button_store:
		_refresh_control_button(str(stored_action))


func _refresh_control_button(action: String) -> void :
	var button: Button = _rebind_button_store.get(action)
	if button != null and is_instance_valid(button):
		button.text = Settings.get_key_label(action)


func refresh_control_buttons() -> void :
	for stored_action in _rebind_button_store:
		_refresh_control_button(str(stored_action))


func _on_settings_changed() -> void :
	if not _built or Settings.hud_accent == _theme_accent:
		return
	_theme_accent = Settings.hud_accent
	_root.theme = UITheme.make_theme(_theme_accent)


func _build() -> void :
	_root = Control.new()
	_root.name = "SettingsRoot"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.theme = UITheme.make_theme(_theme_accent)
	add_child(_root)

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.008, 0.012, 0.016, 0.88)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)

	var sheet: = PanelContainer.new()
	sheet.custom_minimum_size = Vector2(1000, 640)
	sheet.add_theme_stylebox_override("panel", _flat_box(
		Color(0.048, 0.058, 0.071, 0.99), UITheme.BORDER, 1, 4))
	center.add_child(sheet)

	var margin: = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	sheet.add_child(margin)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var header: = HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	column.add_child(header)

	var title: = _label("НАСТРОЙКИ", &"DisplayLabel", 30, UITheme.TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	_close_button = Button.new()
	_close_button.text = "ЗАКРЫТЬ"
	_close_button.theme_type_variation = &"SmallButton"
	_close_button.custom_minimum_size = Vector2(112, 36)
	_close_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_close_button.pressed.connect(Sfx.play_click)
	_close_button.pressed.connect(close)
	header.add_child(_close_button)

	column.add_child(HSeparator.new())



	_tab_bar = HBoxContainer.new()
	_tab_bar.add_theme_constant_override("separation", 6)
	column.add_child(_tab_bar)

	_tab_hint = _label("", &"KickerLabel", 13, UITheme.MUTED_BRIGHT)
	column.add_child(_tab_hint)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(_scroll)

	var body_margin: = MarginContainer.new()
	body_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_margin.add_theme_constant_override("margin_right", 16)
	_scroll.add_child(body_margin)

	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 6)
	body_margin.add_child(_body)

	_render()
	_built = true

	if _vm_preview != null:
		_vm_preview.set_active(visible)




func _render() -> void :
	_fill_tabs()
	_render_tab()


func _fill_tabs() -> void :
	for child in _tab_bar.get_children():
		_tab_bar.remove_child(child)
		child.queue_free()
	for entry in TAB_ORDER:
		var tab_name: = str(entry)
		var button: = Button.new()
		button.text = str(TAB_CAPTIONS.get(tab_name, tab_name))
		button.theme_type_variation = &"AccentButton"\
		if _settings_tab == tab_name else &"SmallButton"
		button.custom_minimum_size = Vector2(0, 40)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 15)
		button.add_theme_font_override("font", UITheme.ui_font(800))
		button.tooltip_text = str(TAB_HINTS.get(tab_name, ""))
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.pressed.connect(_select_tab.bind(tab_name))
		_tab_bar.add_child(button)
	_tab_hint.text = str(TAB_HINTS.get(_settings_tab, ""))


func _select_tab(tab_name: String) -> void :
	if _settings_tab == tab_name:
		return
	_settings_tab = tab_name
	_fill_tabs()
	_render_tab()
	if _scroll != null:
		_scroll.scroll_vertical = 0


func _render_tab() -> void :
	_clear_body()
	match _settings_tab:
		"crosshair":
			_render_crosshair()
		"colors":
			_render_colors()
		"hands":
			_render_hands()
		"screen":
			_render_screen()
		"controls":
			_render_controls()
		_:
			_render_game()
	if _vm_preview != null:
		_vm_preview.set_active(visible)




func _clear_body() -> void :
	_vm_preview = null
	_mobile_box = null
	for child in _body.get_children():
		_body.remove_child(child)
		child.queue_free()


func _render_game() -> void :
	_body.add_child(_section_header("ИГРА"))
	_add_slider("ЧУВСТВИТЕЛЬНОСТЬ", Settings.SENS_MIN, Settings.SENS_MAX, 
		0.01, Settings.mouse_sensitivity, "×%.2f", func(value: float) -> void :
			Settings.set_mouse_sensitivity(value))

	_add_slider("УГОЛ ОБЗОРА (FOV)", Settings.FOV_MIN, Settings.FOV_MAX, 1.0, 
		Settings.fov, "%.0f°", func(value: float) -> void :
			Settings.set_fov(value))
	_add_slider("ГРОМКОСТЬ", 0.0, 1.0, 0.01, Settings.master_volume, "%d%%", 
		func(value: float) -> void : Settings.set_master_volume(value))
	_body.add_child(_toggle("ПРИСЕД И ПРИЦЕЛ: НАЖАТИЕ", 
		Settings.tap_crouch_aim, func(value: bool) -> void :
			Settings.set_tap_crouch_aim(value)))
	_body.add_child(_hint(
		"Выключено — удержание. Включено — одно нажатие переключает "
		+ "присед и прицел. Работает на ПК и телефоне."))
	_body.add_child(_toggle("ТАЙМЕР СЕССИИ", Settings.session_timer, 
		func(value: bool) -> void : Settings.set_session_timer(value)))
	_color_row("ЦВЕТ МАНЕКЕНА", Settings.mannequin_color, 
		Settings.MANNEQUIN_PRESETS, Settings.set_mannequin_color)
	_body.add_child(_toggle("РАЗНОЦВЕТНЫЙ · ПЕРЕЛИВАЕТСЯ", 
		Settings.mannequin_rainbow, func(value: bool) -> void :
			Settings.set_mannequin_rainbow(value)))

	_render_mobile_settings()


func _render_crosshair() -> void :
	_body.add_child(_section_header("ПРИЦЕЛ"))
	_color_row("ЦВЕТ ПРИЦЕЛА", Settings.crosshair_color, Settings.CROSSHAIR_PRESETS, 
		Settings.set_crosshair_color)
	_add_slider("ЗАЗОР", 0.0, 18.0, 0.5, Settings.crosshair_gap, "%.1f", 
		func(value: float) -> void : Settings.set_crosshair_gap(value))
	_add_slider("ДЛИНА", 0.0, 18.0, 0.5, Settings.crosshair_length, "%.1f", 
		func(value: float) -> void : Settings.set_crosshair_length(value))
	_add_slider("ТОЛЩИНА", 1.0, 6.0, 0.5, Settings.crosshair_thickness, "%.1f", 
		func(value: float) -> void : Settings.set_crosshair_thickness(value))

	var cross_toggles: = HBoxContainer.new()
	cross_toggles.add_theme_constant_override("separation", 18)
	_body.add_child(cross_toggles)
	cross_toggles.add_child(_toggle("ТОЧКА", Settings.crosshair_dot, 
		func(value: bool) -> void : Settings.set_crosshair_dot(value)))
	cross_toggles.add_child(_toggle("ОБВОДКА", Settings.crosshair_outline, 
		func(value: bool) -> void : Settings.set_crosshair_outline(value)))
	_add_option("ПОВЕДЕНИЕ ПРИЦЕЛА", ["ДИНАМИЧНЫЙ", "СТАТИЧНЫЙ"], 
		0 if Settings.crosshair_dynamic else 1, 
		func(index: int) -> void : Settings.set_crosshair_dynamic(index == 0))
	_body.add_child(_toggle("ПРОЗРАЧНЫЙ ПРИЦЕЛ AWP", Settings.scope_transparent, 
		func(value: bool) -> void : Settings.set_scope_transparent(value)))
	_body.add_child(_hint(
		"Прозрачная оптика: круг и перекрестие без чёрных полей."))

	var reset_crosshair: = Button.new()
	reset_crosshair.text = "СБРОСИТЬ ПРИЦЕЛ"
	reset_crosshair.theme_type_variation = &"SmallButton"
	reset_crosshair.custom_minimum_size = Vector2(220, 34)
	reset_crosshair.pressed.connect( func() -> void :
		Settings.reset_crosshair()
		_rebuild())
	_body.add_child(reset_crosshair)

	var code: = ConfigCodeUI.new()
	code.setup("КОД ПРИЦЕЛА", 
		"Скопируйте код и отправьте другу: у него будет такой же прицел. "
		+ "Вставьте чужой код и нажмите «ПРИМЕНИТЬ».", 
		Settings.get_crosshair_code, _apply_crosshair_code)
	_body.add_child(code)


func _render_screen() -> void :
	var mobile: = _is_mobile
	_body.add_child(_section_header("ЭКРАН И ГРАФИКА"))
	_add_slider("РАСТЯЖЕНИЕ ЭКРАНА", Settings.STRETCH_MIN, Settings.STRETCH_MAX, 
		0.01, Settings.screen_stretch, "%d%%", func(value: float) -> void :
			Settings.set_screen_stretch(value))
	_body.add_child(_hint("0% — исходные пропорции, 100% — растянутое 4:3, "
		+ "200% — максимальное растяжение."))
	_add_option("ЛИМИТ FPS", Settings.FPS_LABELS, _fps_index(), 
		func(index: int) -> void : Settings.set_fps_limit(int(Settings.FPS_VALUES[index])))
	var hud_toggles: = HBoxContainer.new()
	hud_toggles.add_theme_constant_override("separation", 18)
	_body.add_child(hud_toggles)
	hud_toggles.add_child(_toggle("ПОКАЗЫВАТЬ FPS", Settings.show_fps, 
		func(value: bool) -> void : Settings.set_show_fps(value)))
	var keys_toggle: = _toggle("КЛАВИШИ И МЫШЬ", Settings.show_input_overlay, 
		func(value: bool) -> void : Settings.set_show_input_overlay(value))

	keys_toggle.visible = not mobile
	hud_toggles.add_child(keys_toggle)
	var console_button: = Button.new()
	console_button.text = "КОНСОЛЬ [`]"
	console_button.focus_mode = Control.FOCUS_NONE
	console_button.pressed.connect(func() -> void :
		var console: = get_node_or_null("/root/Console")
		if console != null:
			console.call("open_console"))
	hud_toggles.add_child(console_button)
	_body.add_child(_hint(
		"FPS — счётчик кадров справа сверху. «Клавиши и мышь» — WASD, ЛКМ/ПКМ "
		+ "и пробел слева снизу."))
	_body.add_child(_section_header("ВИДЖЕТ РЕЙТИНГА"))
	_body.add_child(_hint(
		"Компактная карточка профиля слева сверху: уровень, ник, эло, форма "
		+ "последних матчей и счёт. Включите виджет и отметьте нужные строки. "
		+ "Положение и размер меняются в «РАСПОЛОЖЕНИЕ HUD»."))
	var rating_row: = HBoxContainer.new()
	rating_row.add_theme_constant_override("separation", 18)
	_body.add_child(rating_row)
	rating_row.add_child(_toggle("ПОКАЗЫВАТЬ", Settings.show_rating_widget, 
		func(value: bool) -> void : Settings.set_show_rating_widget(value)))
	var rating_parts: = HBoxContainer.new()
	rating_parts.add_theme_constant_override("separation", 18)
	_body.add_child(rating_parts)
	rating_parts.add_child(_toggle("УРОВЕНЬ", Settings.rating_widget_level, 
		func(value: bool) -> void : Settings.set_rating_widget_level(value)))
	rating_parts.add_child(_toggle("НИК", Settings.rating_widget_nickname, 
		func(value: bool) -> void : Settings.set_rating_widget_nickname(value)))
	rating_parts.add_child(_toggle("ЭЛО", Settings.rating_widget_elo, 
		func(value: bool) -> void : Settings.set_rating_widget_elo(value)))
	var rating_parts_second: = HBoxContainer.new()
	rating_parts_second.add_theme_constant_override("separation", 18)
	_body.add_child(rating_parts_second)
	rating_parts_second.add_child(_toggle("ФОРМА", Settings.rating_widget_form, 
		func(value: bool) -> void : Settings.set_rating_widget_form(value)))
	rating_parts_second.add_child(_toggle("СЧЁТ", Settings.rating_widget_record, 
		func(value: bool) -> void : Settings.set_rating_widget_record(value)))
	_add_option("ВИД ВИДЖЕТА", Settings.RATING_WIDGET_STYLES, 
		Settings.rating_widget_style, 
		func(index: int) -> void : Settings.set_rating_widget_style(index))
	_body.add_child(_hint(
		"«МИНИМАЛЬНЫЙ» — тонкая подпись, «КЛАССИКА» — компактная карточка "
		+ "с колонками статистики, «ШИРОКИЙ» — большой профиль, «ПРОГРЕСС» — "
		+ "эло с трендом и полосой уровня, «CS» — вертикальная карточка."))
	_add_option("СГЛАЖИВАНИЕ (MSAA)", Settings.MSAA_LABELS, Settings.msaa_level, 
		func(index: int) -> void : Settings.set_msaa_level(index))
	_add_option("ЭФФЕКТЫ", Settings.EFFECTS_LABELS, Settings.effects_quality, 
		func(index: int) -> void : Settings.set_effects_quality(index))
	var perf_toggles: = HBoxContainer.new()
	perf_toggles.add_theme_constant_override("separation", 18)
	_body.add_child(perf_toggles)
	perf_toggles.add_child(_toggle("АДАПТИВНОЕ РАЗРЕШЕНИЕ", 
		Settings.adaptive_resolution, func(value: bool) -> void :
			Settings.set_adaptive_resolution(value)))
	perf_toggles.add_child(_toggle("РЕЖИМ ЗАПИСИ / СТРИМА", Settings.stream_mode, 
		func(value: bool) -> void : Settings.set_stream_mode(value)))
	_body.add_child(_hint(
		"Первое снижает разрешение 3D при просадках, второе держит 60 FPS "
		+ "и запас GPU для OBS."))
	var perf_button: = Button.new()
	perf_button.text = "РЕЖИМ ПРОИЗВОДИТЕЛЬНОСТИ"
	perf_button.theme_type_variation = &"SmallButton"
	perf_button.custom_minimum_size = Vector2(260, 34)
	perf_button.pressed.connect( func() -> void :
		Settings.apply_performance_preset()
		_rebuild())
	_body.add_child(perf_button)
	_body.add_child(_toggle("РЕЖИМ СОВМЕСТИМОСТИ", 
		Settings.safe_mode, func(value: bool) -> void :
			Settings.set_safe_mode(value)))
	_body.add_child(_hint(
		"Минимальная графика для слабых устройств и восстановления после "
		+ "падения. Карта, управление и прогресс не меняются."))
	var screen_toggles: = HBoxContainer.new()
	screen_toggles.add_theme_constant_override("separation", 18)
	_body.add_child(screen_toggles)
	var fullscreen_toggle: = _toggle("ПОЛНЫЙ ЭКРАН", Settings.fullscreen, 
		func(value: bool) -> void : Settings.set_fullscreen(value))

	fullscreen_toggle.visible = not mobile
	screen_toggles.add_child(fullscreen_toggle)
	screen_toggles.add_child(_toggle("VSYNC", Settings.vsync, 
		func(value: bool) -> void : Settings.set_vsync(value)))
	screen_toggles.add_child(_toggle("ТУМАН", Settings.fog_enabled, 
		func(value: bool) -> void : Settings.set_fog_enabled(value)))
	_add_slider("ЯРКОСТЬ", Settings.BRIGHTNESS_MIN, Settings.BRIGHTNESS_MAX, 0.01, 
		Settings.brightness, "%d%%", func(value: float) -> void :
			Settings.set_brightness(value))

	_body.add_child(_section_header("РАСПОЛОЖЕНИЕ HUD"))
	_body.add_child(_hint(
		"Двигайте блоки HUD и меняйте их размер: киллфид, череп с патронами, "
		+ "слоты оружия, таймер, стрейф, FPS, клавиши, подсказку и виджет "
		+ "рейтинга."))
	var hud_layout_button: = Button.new()
	hud_layout_button.text = "НАСТРОИТЬ HUD"
	hud_layout_button.theme_type_variation = &"SmallButton"
	hud_layout_button.custom_minimum_size = Vector2(240, 38)
	hud_layout_button.pressed.connect(_open_hud_layout_editor)
	_body.add_child(hud_layout_button)


func _render_colors() -> void :
	_body.add_child(_section_header("КАСТОМИЗАЦИЯ"))
	_body.add_child(_hint(
		"Цвета применяются к HUD, небу арены, рукам и карте в игре."))
	_color_row("ЦВЕТ HUD", Settings.hud_accent, Settings.HUD_PRESETS, 
		Settings.set_hud_accent)
	_color_row("НЕБО · ВЕРХ", Settings.sky_top, Settings.SKY_PRESETS, 
		Settings.set_sky_top)
	_color_row("НЕБО · ГОРИЗОНТ", Settings.sky_horizon, Settings.SKY_PRESETS, 
		Settings.set_sky_horizon)
	_color_row("РУКАВ", Settings.arm_sleeve, Settings.ARM_PRESETS, 
		Settings.set_arm_sleeve)
	_color_row("КИСТЬ", Settings.arm_glove, Settings.GLOVE_PRESETS, 
		Settings.set_arm_glove)
	_body.add_child(_toggle("РЕЗКИЙ ПЕРЕХОД РУК", Settings.arm_sharp_split, 
		func(value: bool) -> void : Settings.set_arm_sharp_split(value)))
	_body.add_child(_hint(
		"Резкая граница «перчатка / рукав» вместо плавного градиента."))

	_body.add_child(_section_header("МИР"))
	_body.add_child(_toggle("ПЕРЕКРАШИВАТЬ КАРТУ", Settings.world_tint_enabled, 
		func(value: bool) -> void : Settings.set_world_tint_enabled(value)))
	_body.add_child(_hint(
		"Все поверхности карты окрашиваются в выбранный цвет. "
		+ "Светотень и швы сохраняются, HUD и оружие не меняются."))
	_color_row("ЦВЕТ КАРТЫ", Settings.world_tint_color, Settings.WORLD_TINT_PRESETS, 
		Settings.set_world_tint_color)

	var reset_colors: = Button.new()
	reset_colors.text = "СБРОСИТЬ ЦВЕТА"
	reset_colors.theme_type_variation = &"SmallButton"
	reset_colors.custom_minimum_size = Vector2(220, 34)
	reset_colors.pressed.connect( func() -> void :
		Settings.reset_colors()
		_rebuild())
	_body.add_child(reset_colors)

	var code: = ConfigCodeUI.new()
	code.setup("КОД ЦВЕТОВ", 
		"Акцент HUD, небо, рукав, кисть и цвет карты одним кодом. Работает "
		+ "и на телефоне, и на ПК — получатель увидит те же цвета.", 
		Settings.get_colors_code, _apply_colors_code)
	_body.add_child(code)


func _render_hands() -> void :
	_body.add_child(_section_header("РУКИ И ОРУЖИЕ"))
	_body.add_child(_hint(
		"Положение рук и оружия от первого лица. «ЛЕВАЯ РУКА» зеркалит вьюмодель."))



	var hands: BoxContainer
	if _is_mobile:
		hands = VBoxContainer.new()
	else:
		hands = HBoxContainer.new()
	hands.add_theme_constant_override("separation", 16)
	_body.add_child(hands)
	var vm_preview: = ViewmodelPreview.new()
	hands.add_child(vm_preview)
	_vm_preview = vm_preview
	if not _is_mobile:
		vm_preview.custom_minimum_size = Vector2(360.0, 
			vm_preview.custom_minimum_size.y)
		vm_preview.size_flags_horizontal = Control.SIZE_FILL
		vm_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var vm_rows: = VBoxContainer.new()
	vm_rows.add_theme_constant_override("separation", 8)
	vm_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hands.add_child(vm_rows)
	_add_slider_in(vm_rows, "СМЕЩЕНИЕ ВПРАВО", Settings.VM_OFFSET_MIN, 
		Settings.VM_OFFSET_MAX, 0.005, Settings.vm_offset.x, "%.2f", 
		func(value: float) -> void :
			Settings.set_vm_offset(Vector3(value, Settings.vm_offset.y, 
				Settings.vm_offset.z)))
	_add_slider_in(vm_rows, "СМЕЩЕНИЕ ВВЕРХ", Settings.VM_OFFSET_MIN, 
		Settings.VM_OFFSET_MAX, 0.005, Settings.vm_offset.y, "%.2f", 
		func(value: float) -> void :
			Settings.set_vm_offset(Vector3(Settings.vm_offset.x, value, 
				Settings.vm_offset.z)))
	_add_slider_in(vm_rows, "БЛИЖЕ / ДАЛЬШЕ", Settings.VM_DEPTH_MIN, 
		Settings.VM_DEPTH_MAX, 0.005, Settings.vm_offset.z, "%.2f", 
		func(value: float) -> void :
			Settings.set_vm_offset(Vector3(Settings.vm_offset.x, Settings.vm_offset.y, 
				value)))
	_add_slider_in(vm_rows, "ПОВОРОТ ВЛЕВО / ВПРАВО", Settings.VM_ROTATION_MIN, 
		Settings.VM_ROTATION_MAX, 1.0, Settings.vm_rotation.y, "%.0f°", 
		func(value: float) -> void :
			Settings.set_vm_rotation(Vector3(Settings.vm_rotation.x, value, 
				Settings.vm_rotation.z)))
	_add_slider_in(vm_rows, "ПОВОРОТ ВВЕРХ / ВНИЗ", Settings.VM_ROTATION_MIN, 
		Settings.VM_ROTATION_MAX, 1.0, Settings.vm_rotation.x, "%.0f°", 
		func(value: float) -> void :
			Settings.set_vm_rotation(Vector3(value, Settings.vm_rotation.y, 
				Settings.vm_rotation.z)))
	_add_slider_in(vm_rows, "НАКЛОН", Settings.VM_ROTATION_MIN, 
		Settings.VM_ROTATION_MAX, 1.0, Settings.vm_rotation.z, "%.0f°", 
		func(value: float) -> void :
			Settings.set_vm_rotation(Vector3(Settings.vm_rotation.x, 
				Settings.vm_rotation.y, value)))
	_add_slider_in(vm_rows, "МАСШТАБ РУК", Settings.VM_SCALE_MIN, 
		Settings.VM_SCALE_MAX, 0.01, Settings.vm_scale, "×%.2f", 
		func(value: float) -> void :
			Settings.set_vm_scale(value))
	_add_slider_in(vm_rows, "ПОКАЧИВАНИЕ", Settings.VM_SWAY_MIN, 
		Settings.VM_SWAY_MAX, 0.05, Settings.vm_sway, "×%.2f", 
		func(value: float) -> void :
			Settings.set_vm_sway(value))
	vm_rows.add_child(_toggle("ЛЕВАЯ РУКА", Settings.left_hand, 
		func(value: bool) -> void : Settings.set_left_hand(value)))
	var vm_reset: = Button.new()
	vm_reset.text = "СБРОСИТЬ ПОЛОЖЕНИЕ РУК"
	vm_reset.theme_type_variation = &"SmallButton"
	vm_reset.custom_minimum_size = Vector2(240, 34)
	vm_reset.pressed.connect( func() -> void :
		Settings.reset_viewmodel()
		_rebuild())
	vm_rows.add_child(vm_reset)

	var hands_code: = ConfigCodeUI.new()
	hands_code.setup("КОД РУК", 
		"Переносит смещение, поворот, масштаб, покачивание и сторону рук.", 
		Settings.get_hands_code, _apply_hands_code)
	_body.add_child(hands_code)





func _render_mobile_settings() -> void :
	_mobile_box = VBoxContainer.new()
	_mobile_box.name = "MobileControlsSettings"
	_mobile_box.add_theme_constant_override("separation", 6)
	_body.add_child(_mobile_box)
	# Раскладка доступна и на ПК — настройка заранее под телефон.
	_mobile_box.visible = true

	_mobile_box.add_child(_section_header("МОБИЛЬНОЕ УПРАВЛЕНИЕ"))
	_mobile_box.add_child(_hint(
		"Три раскладки сохраняются отдельно. Размер и прозрачность "
		+ "настраиваются у каждой кнопки отдельно — тапом в редакторе."))

	var slot_row: = HBoxContainer.new()
	slot_row.add_theme_constant_override("separation", 6)
	var slot_caption: = _label("РАСКЛАДКА", &"Label", 12, UITheme.TEXT)
	slot_caption.custom_minimum_size = Vector2(96, 0)
	slot_row.add_child(slot_caption)
	for i in Settings.MOBILE_SLOT_COUNT:
		var slot_button: = Button.new()
		slot_button.text = str(i + 1)
		slot_button.custom_minimum_size = Vector2(0, 32)
		slot_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_button.theme_type_variation = &"AccentButton"\
		if i == Settings.mobile_slot else &"SmallButton"
		slot_button.tooltip_text = "Активная раскладка %d." % (i + 1)
		slot_button.pressed.connect(_select_mobile_slot.bind(i))
		slot_row.add_child(slot_button)

	var preset: = OptionButton.new()
	preset.custom_minimum_size = Vector2(148, 32)
	preset.tooltip_text = "Заменить активную раскладку готовым пресетом."


	preset.add_item("ПРЕСЕТ")
	preset.set_item_disabled(0, true)
	for entry in Settings.MOBILE_PRESETS:
		preset.add_item(str(entry))
	preset.select(0)
	preset.item_selected.connect( func(index: int) -> void :
		if index <= 0:
			return
		Settings.set_mobile_preset(index - 1)
		preset.select(0))
	slot_row.add_child(preset)
	_mobile_box.add_child(slot_row)

	var gyro_row: = HBoxContainer.new()
	gyro_row.add_theme_constant_override("separation", 8)
	gyro_row.add_child(_toggle("ГИРОСКОП", Settings.gyro_enabled, 
		func(value: bool) -> void : Settings.set_gyro_enabled(value)))
	gyro_row.add_child(_expander())
	var calibrate: = Button.new()
	calibrate.text = "КАЛИБРОВАТЬ"
	calibrate.theme_type_variation = &"SmallButton"
	calibrate.custom_minimum_size = Vector2(170, 32)
	calibrate.tooltip_text = "Положите телефон ровно и откалибруйте ноль гироскопа."
	calibrate.pressed.connect( func() -> void :
		Settings.request_gyro_calibration())
	gyro_row.add_child(calibrate)
	gyro_row.visible = _is_mobile
	_mobile_box.add_child(gyro_row)
	var gyro_slider_row: HBoxContainer = _add_slider("СИЛА ГИРОСКОПА", Settings.GYRO_SENS_MIN,
		Settings.GYRO_SENS_MAX, 0.05, Settings.gyro_sensitivity, "×%.2f",
		func(value: float) -> void : Settings.set_gyro_sensitivity(value), _mobile_box)
	gyro_slider_row.visible = _is_mobile

	var customize: = Button.new()
	customize.name = "CustomizeUIButton"
	customize.text = "НАСТРОИТЬ КНОПКИ И ДЖОЙСТИК"
	customize.custom_minimum_size = Vector2(0, 42)
	customize.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	customize.tooltip_text = "Перетаскивайте виджеты и настраивайте каждый тапом."
	customize.pressed.connect(_open_mobile_editor)
	_mobile_box.add_child(customize)

	var ui_code: = ConfigCodeUI.new()
	ui_code.setup("КОД РАСКЛАДОК", 
		"Переносит все три раскладки, размеры и прозрачность кнопок.", 
		Settings.get_mobile_code, _apply_mobile_code)
	_mobile_box.add_child(ui_code)





func _apply_crosshair_code(code: String) -> bool:
	if not Settings.apply_crosshair_code(code):
		return false
	call_deferred("_rebuild")
	return true


func _apply_colors_code(code: String) -> bool:
	if not Settings.apply_colors_code(code):
		return false
	call_deferred("_rebuild")
	return true


func _apply_mobile_code(code: String) -> bool:
	if not Settings.apply_mobile_code(code):
		return false
	call_deferred("_rebuild")
	return true


func _apply_hands_code(code: String) -> bool:
	if not Settings.apply_hands_code(code):
		return false
	call_deferred("_rebuild")
	return true


func _select_mobile_slot(index: int) -> void :
	Settings.select_mobile_slot(index)
	_rebuild()


func _open_mobile_editor() -> void :
	LayoutEditor.new().open(self, func() -> void : _rebuild())




func _open_hud_layout_editor() -> void :
	var hud: Node = null
	var host: = get_parent()
	if host != null:
		hud = host.get_node_or_null("HUD")
	HudLayoutEditor.new().open(self, hud)


func _section_header(text: String) -> Control:
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	var label: = _label(text, &"AccentLabel", 15, UITheme.ACCENT_BRIGHT)
	label.add_theme_font_override("font", UITheme.ui_font(800))
	box.add_child(label)
	box.add_child(HSeparator.new())
	return box


func _add_slider(caption: String, min_value: float, max_value: float, step: float, 
		value: float, fmt: String, on_change: Callable, 
		parent: VBoxContainer = null) -> HBoxContainer:
	var host: VBoxContainer = parent if parent != null else _body
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	host.add_child(row)

	var name_label: = _label(caption, &"Label", 15, UITheme.TEXT)
	name_label.custom_minimum_size = Vector2(150, 0)
	row.add_child(name_label)

	var slider: = HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(slider)

	var value_label: = _label(fmt % (value * 100.0 if fmt.contains("%%") else value), 
		&"KickerLabel", 15, UITheme.ACCENT_BRIGHT)
	value_label.add_theme_font_override("font", UITheme.ui_font(800))
	value_label.custom_minimum_size = Vector2(54, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)

	slider.value_changed.connect( func(new_value: float) -> void :
		var shown: = new_value * 100.0 if fmt.contains("%%") else new_value
		value_label.text = fmt % shown
		on_change.call(new_value))
	return row




func _add_slider_in(host: VBoxContainer, caption: String, min_value: float, 
		max_value: float, step: float, value: float, fmt: String, 
		on_change: Callable) -> HBoxContainer:
	return _add_slider(caption, min_value, max_value, step, value, fmt, 
		on_change, host)


func _add_option(caption: String, labels: Array, selected: int, 
		on_change: Callable, parent: VBoxContainer = null) -> void :
	var host: VBoxContainer = parent if parent != null else _body
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	host.add_child(row)

	var name_label: = _label(caption, &"Label", 15, UITheme.TEXT)
	name_label.custom_minimum_size = Vector2(150, 0)
	row.add_child(name_label)

	var option: = OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.add_theme_font_override("font", UITheme.ui_font(800))
	option.add_theme_font_size_override("font_size", 15)
	option.get_popup().add_theme_font_override("font", UITheme.ui_font(800))
	option.get_popup().add_theme_font_size_override("font_size", 15)
	for entry in labels:
		option.add_item(str(entry))
	option.selected = clampi(selected, 0, maxi(labels.size() - 1, 0))
	option.item_selected.connect( func(index: int) -> void : on_change.call(index))
	row.add_child(option)


func _toggle(caption: String, value: bool, on_change: Callable) -> CheckButton:
	var toggle: = CheckButton.new()
	toggle.text = caption
	toggle.button_pressed = value
	toggle.add_theme_font_override("font", UITheme.ui_font(800))
	toggle.add_theme_font_size_override("font_size", 15)
	toggle.add_theme_color_override("font_color", UITheme.TEXT)
	toggle.toggled.connect( func(pressed: bool) -> void : on_change.call(pressed))
	return toggle


func _expander() -> Control:
	var node: = Control.new()
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node


func _color_row(caption: String, current: Color, presets: Array, 
		setter: Callable) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_body.add_child(row)

	var name_label: = _label(caption, &"Label", 15, UITheme.TEXT)
	name_label.custom_minimum_size = Vector2(150, 0)
	row.add_child(name_label)

	var current_box: = PanelContainer.new()
	current_box.custom_minimum_size = Vector2(26, 24)
	current_box.add_theme_stylebox_override("panel", 
		_flat_box(current, UITheme.TEXT, 1, 3))
	row.add_child(current_box)

	var live: = {"color": current}
	var apply: = func(color: Color) -> void :
		live["color"] = color
		setter.call(color)
		current_box.add_theme_stylebox_override("panel", 
			_flat_box(color, UITheme.TEXT, 1, 3))

	for preset in presets:
		var color: Color = preset
		var swatch: = Button.new()
		swatch.custom_minimum_size = Vector2(30, 26)
		var box: = _flat_box(color, UITheme.BORDER_LIGHT, 1, 3)
		swatch.add_theme_stylebox_override("normal", box)
		var hover: = box.duplicate() as StyleBoxFlat
		hover.border_color = UITheme.TEXT
		hover.set_border_width_all(2)
		swatch.add_theme_stylebox_override("hover", hover)
		swatch.add_theme_stylebox_override("pressed", hover)
		swatch.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		swatch.pressed.connect( func() -> void : apply.call(color))
		row.add_child(swatch)

	var wheel: = Button.new()
	wheel.text = "ЛЮБОЙ ЦВЕТ"
	wheel.theme_type_variation = &"SmallButton"
	wheel.custom_minimum_size = Vector2(136, 26)
	wheel.tooltip_text = "RGB-круг: выбрать любой оттенок"
	wheel.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	wheel.pressed.connect( func() -> void :
		_wheel_popup = ColorWheel.open(_root, _root.theme, live["color"], apply, current_box))
	row.add_child(wheel)


func _fps_index() -> int:
	return maxi(Settings.FPS_VALUES.find(Settings.fps_limit), 0)


func _hint(text: String) -> Label:
	return _label(text, &"KickerLabel", 13, UITheme.MUTED_BRIGHT)


func _label(text: String, variation: StringName, size: int, color: Color) -> Label:
	var label: = Label.new()
	label.text = text
	if variation != &"" and variation != &"Label":
		label.theme_type_variation = variation


	var shown_size: = size
	match variation:
		&"Label":
			label.add_theme_font_override("font", UITheme.ui_font(800))
			shown_size = maxi(size, 15)
		&"KickerLabel":
			label.add_theme_font_override("font", UITheme.ui_font(700))
			shown_size = maxi(size, 13)
		&"AccentLabel":
			label.add_theme_font_override("font", UITheme.ui_font(800))
			shown_size = maxi(size, 15)


	if variation == &"KickerLabel" and text.length() > 44:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size.x = 0.0
	label.add_theme_font_size_override("font_size", shown_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _flat_box(bg: Color, border: Color, border_width: int, 
		radius: int) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	return box
