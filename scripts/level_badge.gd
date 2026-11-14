extends Control








const UITheme = preload("res://scripts/ui_theme.gd")

const GREEN: = Color(0.16, 0.9, 0.36, 1.0)
const YELLOW: = Color(1.0, 0.86, 0.1, 1.0)
const ORANGE: = Color(1.0, 0.47, 0.05, 1.0)
const RED: = Color(1.0, 0.16, 0.12, 1.0)

var level: = 1:
	set(value):
		level = clampi(value, 1, 10)
		queue_redraw()

var current: = false:
	set(value):
		current = value
		set_process(value)
		queue_redraw()

var passed: = false:
	set(value):
		passed = value
		queue_redraw()

var _clock: = 0.0



const PULSE_REDRAW_INTERVAL: = 1.0 / 20.0
var _redraw_clock: = 0.0


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_PASS
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(56.0, 56.0)
	set_process(current)


func _process(delta: float) -> void :
	_clock += delta
	_redraw_clock += delta
	if _redraw_clock < PULSE_REDRAW_INTERVAL:
		return
	_redraw_clock = 0.0
	queue_redraw()


static func color_for(value: int) -> Color:
	if value <= 3:
		return GREEN
	if value <= 7:
		return YELLOW
	if value <= 9:
		return ORANGE
	return RED


func _draw() -> void :
	var extent: = minf(size.x, size.y)
	if extent < 6.0:
		return
	var center: = size * 0.5
	var radius: = extent * 0.5 - 2.0
	var ring_width: = maxf(3.0, radius * 0.115)
	var tint: = color_for(level)
	var pulse: = 0.5 + 0.5 * sin(_clock * 2.6)



	if current:
		for i in 4:
			var spread: = 2.0 + float(i) * 2.1
			var alpha: = (0.11 - float(i) * 0.022) * (0.55 + 0.45 * pulse)
			draw_arc(center, radius + spread, 0.0, TAU, 56, 
				Color(tint.r, tint.g, tint.b, alpha), ring_width * 1.4, true)


	draw_circle(center, radius, Color(0.02, 0.023, 0.028, 0.98), true, -1.0, true)
	draw_circle(center, radius - ring_width * 0.35, 
		Color(0.055, 0.06, 0.068, 0.92), true, -1.0, true)
	draw_arc(center, radius, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.07), 
		maxf(1.0, ring_width * 0.18), true)

	var ring_radius: = radius - ring_width * 0.95
	var unlocked: = current or passed




	if unlocked:
		draw_arc(center, ring_radius, 0.0, TAU, 96, 
			Color(tint.r * 0.42, tint.g * 0.42, tint.b * 0.42, 0.85), 
			ring_width, true)
		draw_arc(center, ring_radius, 0.0, TAU, 96, tint, ring_width, true)
		draw_arc(center, ring_radius - ring_width * 0.2, 
			- PI * 0.92, - PI * 0.08, 48, Color(1.0, 1.0, 1.0, 0.2), 
			maxf(1.0, ring_width * 0.22), true)
	else:
		draw_arc(center, ring_radius, 0.0, TAU, 96, 
			Color(tint.r, tint.g, tint.b, 0.34), ring_width, true)





	var digits: = str(level)
	var font_size: = int(radius * (0.98 if level < 10 else 0.82))
	var font: = UITheme.display_font(700)
	var baseline: = center.y + font_size * 0.35
	var digit_color: = tint if unlocked else Color(tint.r, tint.g, tint.b, 0.56)
	draw_string(font, Vector2(0.0, baseline), digits, 
		HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, digit_color)
