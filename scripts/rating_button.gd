extends Button





const UITheme = preload("res://scripts/ui_theme.gd")

const GOLD: = Color(0.949, 0.76, 0.102, 1.0)
const GOLD_HOT: = Color(1.0, 0.855, 0.278, 1.0)
const GOLD_DARK: = Color(0.404, 0.298, 0.031, 1.0)
const GOLD_EDGE: = Color(1.0, 0.93, 0.6, 1.0)

var _clock: = 0.0
var _hover: = 0.0
var _down: = false
var _flash: = 0.0
var _title: Label
var _subtitle: Label
var _arrow: Label


const REDRAW_INTERVAL: = 1.0 / 30.0
var _redraw_clock: = 0.0


func _ready() -> void :
	text = ""
	focus_mode = Control.FOCUS_ALL
	clip_contents = true
	custom_minimum_size = Vector2(0.0, 74.0)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	button_down.connect( func() -> void :
		_down = true
		_flash = 1.0)
	button_up.connect( func() -> void : _down = false)
	_build_labels()
	set_process(true)


func _build_labels() -> void :
	var margin: = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	var column: = VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", -2)
	column.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(column)

	_title = Label.new()
	_title.text = "РЕЙТИНГ"
	_title.add_theme_font_override("font", UITheme.display_font(700))
	_title.add_theme_font_size_override("font_size", 24)
	_title.add_theme_color_override("font_color", Color(1.0, 0.985, 0.945, 1.0))
	_title.add_theme_color_override("font_outline_color", Color(0.02, 0.016, 0.005, 0.96))
	_title.add_theme_constant_override("outline_size", 5)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_title)

	_subtitle = Label.new()
	_subtitle.text = "ДУЭЛЬ 1×1 · УРОВНИ И ЭЛО"
	_subtitle.add_theme_font_override("font", UITheme.ui_font(700))
	_subtitle.add_theme_font_size_override("font_size", 9)
	_subtitle.add_theme_color_override("font_color", Color(1.0, 0.92, 0.6, 1.0))
	_subtitle.add_theme_color_override("font_outline_color", Color(0.02, 0.016, 0.005, 0.92))
	_subtitle.add_theme_constant_override("outline_size", 4)
	_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(_subtitle)

	var spacer: = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)

	_arrow = Label.new()
	_arrow.text = "→"
	_arrow.add_theme_font_override("font", UITheme.display_font(700))
	_arrow.add_theme_font_size_override("font_size", 28)
	_arrow.add_theme_color_override("font_color", Color(1.0, 0.925, 0.55, 1.0))
	_arrow.add_theme_color_override("font_outline_color", Color(0.02, 0.016, 0.005, 0.94))
	_arrow.add_theme_constant_override("outline_size", 5)
	_arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_arrow)


func _process(delta: float) -> void :
	_hover = move_toward(_hover, 1.0 if is_hovered() else 0.0, delta * 6.0)
	_flash = maxf(0.0, _flash - delta * 2.8)
	_clock += delta * lerpf(26.0, 72.0, maxf(_hover, _flash * 0.8))
	_redraw_clock += delta
	if _redraw_clock < REDRAW_INTERVAL:
		return
	_redraw_clock = 0.0
	queue_redraw()


func _draw() -> void :
	var w: = size.x
	var h: = size.y
	if w < 8.0 or h < 8.0:
		return
	var surface: = Rect2(Vector2.ZERO, size)
	var hot: = maxf(_hover, _flash * 0.6)


	draw_rect(surface, Color(0.045, 0.04, 0.028, 1.0))
	draw_rect(Rect2(0.0, 0.0, w, 2.0), Color(0.0, 0.0, 0.0, 0.45))

	var period: = 54.0
	var stripe: = lerpf(19.0, 23.0, hot)
	var slant: = h * tan(deg_to_rad(-25.0))
	var phase: = fposmod(_clock, period)
	var start: = - period - absf(slant) + phase


	var s: = start
	while s < w + period:
		var back: = PackedVector2Array([
			Vector2(s + 3.0, 3.0), 
			Vector2(s + stripe + 3.0, 3.0), 
			Vector2(s + stripe + slant + 3.0, h + 3.0), 
			Vector2(s + slant + 3.0, h + 3.0), 
		])
		draw_colored_polygon(back, Color(0.1, 0.082, 0.018, 0.95))
		s += period


	var gold: = GOLD.lerp(GOLD_HOT, hot)
	s = start
	while s < w + period:
		var quad: = PackedVector2Array([
			Vector2(s, 0.0), 
			Vector2(s + stripe, 0.0), 
			Vector2(s + stripe + slant, h), 
			Vector2(s + slant, h), 
		])
		draw_colored_polygon(quad, gold)
		draw_line(Vector2(s, 0.0), Vector2(s + slant, h), GOLD_EDGE, 1.6, true)
		draw_line(Vector2(s + stripe, 0.0), Vector2(s + stripe + slant, h), 
			GOLD_DARK, 2.4, true)
		s += period


	var sheen_x: = fposmod(_clock * 3.4, w + h + 520.0) - 240.0
	for i in 3:
		var band: = 26.0 + float(i) * 20.0
		var band_pos: = sheen_x + float(i) * 22.0
		var sheen: = PackedVector2Array([
			Vector2(band_pos, -8.0), 
			Vector2(band_pos + band, -8.0), 
			Vector2(band_pos + band + slant, h + 8.0), 
			Vector2(band_pos + slant, h + 8.0), 
		])
		draw_colored_polygon(sheen, 
			Color(1.0, 1.0, 0.94, 0.035 + float(i) * 0.012))


	draw_rect(Rect2(0.0, 0.0, w * 0.66, h), 
		Color(0.022, 0.02, 0.014, 0.46))
	draw_line(Vector2(w * 0.66, 0.0), Vector2(w * 0.66, h), 
		Color(1.0, 0.86, 0.38, 0.12), 1.0)


	var border: = Color(0.95, 0.76, 0.18, 0.55 + 0.4 * hot)
	draw_rect(surface.grow(-0.5), border, false, 1.0)
	if hot > 0.01:
		draw_rect(surface.grow(-2.5), 
			Color(1.0, 0.86, 0.32, 0.22 * hot), false, 1.0)
	if has_focus():
		draw_rect(surface.grow(-3.5), Color(1.0, 1.0, 1.0, 0.65), false, 1.5)
