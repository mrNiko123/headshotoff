extends Control



@export var preview_scale: = 1.0
@export var show_hitmarker: = true

var _kick_spread: = 0.0
var _target_kick: = 0.0
var _move_spread: = 0.0
var _target_move: = 0.0
var _hit_time: = 0.0
var _headshot: = false
var _scope_active: = false


var _weapon_hidden: = false
var _hit_drawn: = false

const CARDINALS: = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
const DIAGONALS: = [Vector2(1.0, 1.0), Vector2(1.0, -1.0), Vector2(-1.0, 1.0), Vector2(-1.0, -1.0)]


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Settings.settings_changed.connect(_on_settings_changed)
	Settings.display_changed.connect(_on_settings_changed)
	var viewport: = get_viewport()
	if viewport != null:
		viewport.size_changed.connect(_on_settings_changed)


	set_process(false)





func _screen_scale() -> Vector2:
	var window: = get_window()
	if window == null:
		return Vector2.ONE
	var content: = Vector2(window.content_scale_size)
	if content.x < 1.0 or content.y < 1.0:
		content = get_viewport().get_visible_rect().size
	if content.x < 1.0 or content.y < 1.0:
		return Vector2.ONE
	var window_size: = Vector2(window.size)
	if window_size.x < 1.0 or window_size.y < 1.0:
		window_size = Vector2(DisplayServer.window_get_size())
	if window_size.x < 1.0 or window_size.y < 1.0:
		return Vector2.ONE
	var raw: = window_size / content
	match window.content_scale_aspect:
		Window.CONTENT_SCALE_ASPECT_IGNORE:
			return raw
		Window.CONTENT_SCALE_ASPECT_EXPAND:
			var expand: = maxf(raw.x, raw.y)
			return Vector2(expand, expand)
		Window.CONTENT_SCALE_ASPECT_KEEP_WIDTH:
			return Vector2(raw.x, raw.x)
		Window.CONTENT_SCALE_ASPECT_KEEP_HEIGHT:
			return Vector2(raw.y, raw.y)
		_:
			var keep: = minf(raw.x, raw.y)
			return Vector2(keep, keep)





func _screen_offset(scale: Vector2) -> Vector2:
	var window: = get_window()
	if window == null:
		return Vector2.ZERO
	if window.content_scale_aspect == Window.CONTENT_SCALE_ASPECT_IGNORE:
		return Vector2.ZERO
	var content: = Vector2(window.content_scale_size)
	if content.x < 1.0 or content.y < 1.0:
		content = get_viewport().get_visible_rect().size
	var window_size: = Vector2(window.size)
	if window_size.x < 1.0 or window_size.y < 1.0:
		window_size = Vector2(DisplayServer.window_get_size())
	return (window_size - content * scale) * 0.5


func _process(delta: float) -> void :
	var shown_spread: = _kick_spread + _move_spread
	_kick_spread = lerpf(_kick_spread, _target_kick, 1.0 - exp(-22.0 * delta))
	_target_kick = lerpf(_target_kick, 0.0, 1.0 - exp(-7.0 * delta))
	_move_spread = lerpf(_move_spread, _target_move, 1.0 - exp(-12.0 * delta))
	_hit_time = maxf(0.0, _hit_time - delta)



	var changed: = _hit_time > 0.0 or _hit_drawn
	_hit_drawn = _hit_time > 0.0
	if Settings.crosshair_dynamic\
	and absf((_kick_spread + _move_spread) - shown_spread) > 0.002:
		changed = true
	if changed:
		queue_redraw()

	if not changed and absf(_kick_spread - _target_kick) < 0.02\
	and absf(_move_spread - _target_move) < 0.02\
	and absf(_target_kick) < 0.05:
		set_process(false)


func kick(strength: = 5.0) -> void :
	_target_kick = minf(_target_kick + strength, 26.0)
	set_process(true)


func set_movement_spread(value: float) -> void :
	_target_move = clampf(value, 0.0, 18.0)
	set_process(true)


func flash_hit(was_headshot: = false) -> void :
	_hit_time = 0.18
	_headshot = was_headshot
	set_process(true)
	queue_redraw()



func set_scope_active(value: bool) -> void :
	if _scope_active == value:
		return
	_scope_active = value
	queue_redraw()



func set_weapon(weapon_id: String) -> void :
	var hidden: = weapon_id == "awp"
	if _weapon_hidden == hidden:
		return
	_weapon_hidden = hidden
	queue_redraw()


func _on_settings_changed() -> void :
	queue_redraw()


func _draw() -> void :



	var screen: = _screen_scale()
	if screen.x < 0.001 or screen.y < 0.001:
		screen = Vector2.ONE





	var unit: = screen.x * preview_scale
	var gap_screen: = Settings.crosshair_gap * unit
	if Settings.crosshair_dynamic:
		gap_screen += (_kick_spread + _move_spread) * unit
	var length_screen: = Settings.crosshair_length * unit
	var color: = Settings.crosshair_color

	var outline_color: = Color(0.0, 0.0, 0.0, 0.55)
	if color.v < 0.2:
		outline_color = Color(1.0, 1.0, 1.0, 0.45)





	var local_center: = Vector2(size.x, size.y) * 0.5
	var screen_center: = _screen_offset(screen) + (global_position + local_center) * screen



	var snapped: = screen_center.round()
	var origin: = local_center + (snapped - screen_center) / screen
	draw_set_transform(origin, 0.0, Vector2(1.0 / screen.x, 1.0 / screen.y))




	var thickness: = _even_pixels(Settings.crosshair_thickness * unit)
	var half: = thickness * 0.5

	var inner: = roundf(half + gap_screen)
	if inner < half + 1.0:
		inner = half + 1.0
	var arm: = maxf(1.0, roundf(length_screen))

	if not _scope_active and not _weapon_hidden and length_screen > 0.01:
		if Settings.crosshair_outline:

			for direction in CARDINALS:
				_arm(direction, inner - 1.0, arm + 2.0, thickness + 2.0, outline_color)

		for direction in CARDINALS:
			_arm(direction, inner, arm, thickness, color)

		if Settings.crosshair_dot:

			if Settings.crosshair_outline:
				draw_circle(Vector2.ZERO, 
					maxf(2.2 * unit, thickness * 0.9 + 1.2 * unit), outline_color)
			draw_circle(Vector2.ZERO, maxf(1.2 * unit, thickness * 0.72), color)

	if show_hitmarker and _hit_time > 0.0:
		var alpha: = clampf(_hit_time / 0.18, 0.0, 1.0)
		var hit_color: = Color(1.0, 0.3, 0.26, alpha) if _headshot else Color(0.95, 0.97, 1.0, alpha)
		var hit_inner: = inner + arm + 4.0 * unit
		var hit_outer: = hit_inner + 8.0 * unit
		for direction in DIAGONALS:
			var normalized: Vector2 = direction.normalized()
			draw_line(
				normalized * hit_inner, 
				normalized * hit_outer, 
				hit_color, maxf(1.8, 2.2 * unit), true)





func _arm(direction: Vector2, from: float, length: float, thickness: float, 
		color: Color) -> void :
	var half: = thickness * 0.5
	if absf(direction.x) > 0.5:
		var x0: float = direction.x * from
		var x1: float = direction.x * (from + length)
		draw_rect(Rect2(minf(x0, x1), - half, absf(x1 - x0), thickness), color, true)
		return
	var y0: float = direction.y * from
	var y1: float = direction.y * (from + length)
	draw_rect(Rect2( - half, minf(y0, y1), thickness, absf(y1 - y0)), color, true)




func _even_pixels(value: float) -> float:
	return maxf(2.0, 2.0 * roundf(value * 0.5))
