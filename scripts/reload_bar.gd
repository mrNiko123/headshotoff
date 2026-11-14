extends Control





var progress: = 0.0
var accent: = Color(0.886, 0.651, 0.239, 1.0)


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_progress(value: float) -> void :
	var clamped: = clampf(value, 0.0, 1.0)
	if absf(clamped - progress) < 0.002:
		return
	progress = clamped
	queue_redraw()


func set_accent(color: Color) -> void :
	accent = color
	queue_redraw()


func _draw() -> void :
	if size.x < 2.0 or size.y < 2.0:
		return
	var box: = Rect2(Vector2.ZERO, size)

	draw_rect(box, Color(0.0, 0.0, 0.0, 0.46), true)
	draw_rect(box, Color(accent.r, accent.g, accent.b, 0.55), false, 1.0)
	if progress <= 0.0:
		return
	var inner: = Rect2(Vector2(1.0, 1.0), 
		Vector2((size.x - 2.0) * progress, size.y - 2.0))
	draw_rect(inner, accent, true)
