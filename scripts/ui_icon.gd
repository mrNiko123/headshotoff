extends Control




@export_enum("skull_badge", "skull", "lock", "burst", "ring") var kind: = "skull_badge"
var tint: = Color(0.62, 0.66, 0.72, 1.0)
var lit: = 0.0
var plate: = Color(0.055, 0.065, 0.08, 0.95)
var ring: = Color(0.24, 0.27, 0.31, 1.0)


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func set_lit(value: float) -> void :
	if is_equal_approx(lit, value):
		return
	lit = clampf(value, 0.0, 1.0)
	queue_redraw()


func _draw() -> void :
	var c: = size * 0.5
	var r: = minf(size.x, size.y) * 0.5
	if r <= 1.0:
		return
	match kind:
		"skull_badge":
			_draw_skull_badge(c, r)
		"skull":
			_draw_skull(c, r * 0.92, tint)
		"lock":
			_draw_lock(c, r * 0.9, tint)
		"burst":
			_draw_burst(c, r)
		"ring":
			_draw_ring(c, r)


func _draw_skull_badge(c: Vector2, r: float) -> void :
	var hot: = Settings.hud_accent.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.3)
	var cold: = Color(0.4, 0.45, 0.52, 1.0)
	var accent: = cold.lerp(hot, lit)

	draw_circle(c, r, Color(0.03, 0.038, 0.048, 0.95))
	draw_arc(c, r - 2.0, 0.0, TAU, 48, accent, 2.0, true)
	if lit > 0.02:
		draw_arc(c, r - 1.0, 0.0, TAU, 48, 
			Color(hot.r, hot.g, hot.b, 0.35 * lit), 5.0, true)

	var skull_color: = Color(0.72, 0.76, 0.82, 1.0).lerp(Color(1.0, 0.94, 0.82, 1.0), lit)
	_draw_skull(c, r * 0.62, skull_color, Color(0.03, 0.038, 0.048, 1.0))


func _draw_skull(center: Vector2, radius: float, color: Color, hole: = Color(0, 0, 0, 0)) -> void :
	if hole.a <= 0.01:
		hole = plate

	draw_circle(center + Vector2(0.0, - radius * 0.2), radius * 0.74, color)

	draw_rect(Rect2(center + Vector2( - radius * 0.46, radius * 0.22), 
		Vector2(radius * 0.92, radius * 0.52)), color)

	draw_circle(center + Vector2( - radius * 0.3, - radius * 0.16), radius * 0.22, hole)
	draw_circle(center + Vector2(radius * 0.3, - radius * 0.16), radius * 0.22, hole)

	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0.0, radius * 0.02), 
		center + Vector2( - radius * 0.12, radius * 0.22), 
		center + Vector2(radius * 0.12, radius * 0.22), 
	]), hole)

	draw_rect(Rect2(center + Vector2( - radius * 0.055, radius * 0.3), 
		Vector2(radius * 0.11, radius * 0.4)), hole)


func _draw_lock(center: Vector2, radius: float, color: Color) -> void :
	var body: = Rect2(center + Vector2( - radius * 0.52, radius * 0.02), 
		Vector2(radius * 1.04, radius * 0.82))
	draw_rect(body, color)
	draw_arc(center + Vector2(0.0, radius * 0.04), radius * 0.4, 
		PI, TAU, 24, color, radius * 0.2, true)
	var keyhole: = Color(0.055, 0.065, 0.08, 1.0)
	draw_circle(center + Vector2(0.0, radius * 0.3), radius * 0.14, keyhole)
	draw_rect(Rect2(center + Vector2( - radius * 0.055, radius * 0.3), 
		Vector2(radius * 0.11, radius * 0.26)), keyhole)



func _draw_burst(center: Vector2, radius: float) -> void :
	var accent: = Settings.hud_accent
	var hot: = accent.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.52)
	for i in 12:
		var angle: = TAU * float(i) / 12.0 + 0.12
		var dir: = Vector2(cos(angle), sin(angle))
		var length: = radius * (0.52 + 0.42 * absf(sin(float(i) * 1.7 + 0.4)))
		draw_line(center + dir * radius * 0.16, center + dir * length, 
			Color(hot.r, hot.g, hot.b, 0.72), maxf(1.4, radius * 0.055), true)
	draw_circle(center, radius * 0.46, Color(hot.r, hot.g, hot.b, 0.2))
	draw_circle(center, radius * 0.28, Color(hot.r, hot.g, hot.b, 0.36))
	draw_circle(center, radius * 0.12, Color(1.0, 1.0, 1.0, 0.85))



func _draw_ring(center: Vector2, radius: float) -> void :
	var accent: = Settings.hud_accent.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.72)
	var glow: = Color(accent.r, accent.g, accent.b, 0.2)
	var line: = Color(accent.r, accent.g, accent.b, 0.95)
	draw_arc(center, radius * 0.8, 0.0, TAU, 72, glow, maxf(3.0, radius * 0.13), true)
	draw_arc(center, radius * 0.8, 0.0, TAU, 72, line, maxf(1.6, radius * 0.045), true)
