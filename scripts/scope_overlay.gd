extends Control






const SCOPE_SHADER = preload("res://shaders/scope_overlay.gdshader")

const MAX_RADIUS: = 0.94
const FADE_IN_SPEED: = 26.0

var _progress: = 0.0
var _target: = 0.0
var _mask: ColorRect
var _material: ShaderMaterial

var _pixel_scale: = Vector2.ONE


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_mask = ColorRect.new()
	_mask.name = "Mask"
	_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mask.show_behind_parent = true
	_material = ShaderMaterial.new()
	_material.shader = SCOPE_SHADER
	_material.set_shader_parameter("progress", 0.0)
	_material.set_shader_parameter("max_radius", MAX_RADIUS)
	_mask.material = _material
	add_child(_mask)

	Settings.settings_changed.connect(_apply_style)
	_apply_style()
	resized.connect(_refresh_scale)


	get_viewport().size_changed.connect(_refresh_scale)
	_refresh_scale()

	visible = false




func _apply_style() -> void :
	if _mask != null:
		_mask.visible = not Settings.scope_transparent
	queue_redraw()




func _screen_scale() -> Vector2:
	if size.x < 1.0 or size.y < 1.0:
		return Vector2.ONE
	var window: = get_window()
	var window_size: = Vector2(window.size)
	if window_size.x < 1.0 or window_size.y < 1.0:
		window_size = Vector2(DisplayServer.window_get_size())
	if window_size.x < 1.0 or window_size.y < 1.0:
		return Vector2.ONE
	var raw: = window_size / size
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


func _refresh_scale() -> void :
	_pixel_scale = _screen_scale()
	if _material != null:
		_material.set_shader_parameter("rect_size", size)
		_material.set_shader_parameter("pixel_scale", _pixel_scale)
	queue_redraw()


func set_active(active: bool) -> void :
	var target: = 1.0 if active else 0.0
	if is_equal_approx(_target, target):
		return
	_target = target
	if not active:

		_progress = 0.0
		_material.set_shader_parameter("progress", 0.0)
		visible = false
		set_process(false)
		queue_redraw()
		return
	_refresh_scale()
	visible = true
	set_process(true)





func warmup() -> void :
	if _material == null:
		return
	visible = true
	_progress = 0.0
	_target = 0.0
	_material.set_shader_parameter("progress", 0.0)
	await get_tree().process_frame
	await get_tree().process_frame
	if is_equal_approx(_target, 0.0):
		visible = false


func _process(delta: float) -> void :
	_progress = lerpf(_progress, _target, 1.0 - exp( - FADE_IN_SPEED * delta))
	if absf(_progress - _target) < 0.002:
		_progress = _target
	_material.set_shader_parameter("progress", _progress)


	queue_redraw()



	if is_equal_approx(_progress, _target):
		if _target <= 0.0:
			visible = false
		set_process(false)


func _draw() -> void :
	if _progress <= 0.01 or size.y <= 0.0:
		return

	var pixel_scale: = _pixel_scale
	if pixel_scale.x < 0.001 or pixel_scale.y < 0.001:
		pixel_scale = Vector2.ONE


	var extent_px: = minf(size.x * pixel_scale.x, size.y * pixel_scale.y)
	var radius: = extent_px * 0.5 * MAX_RADIUS * _progress

	var unit: = maxf(1.0, extent_px / 720.0)
	var reticle: = Color(0.008, 0.01, 0.013, 0.96)


	var halo: = Color(0.72, 0.82, 0.88, 
		0.42 if Settings.scope_transparent else 0.14)




	draw_set_transform(size * 0.5, 0.0, 
		Vector2(1.0 / pixel_scale.x, 1.0 / pixel_scale.y))



	var edge_color: = Color(0.0, 0.0, 0.0, 0.86)
	var glass_glow: = Color(0.62, 0.8, 0.86, 0.055)
	if Settings.scope_transparent:
		edge_color = Color(0.0, 0.0, 0.0, 0.4)
		glass_glow = Color(0.72, 0.84, 0.92, 0.16)
	draw_arc(Vector2.ZERO, radius - 1.2 * unit, 0.0, TAU, 160, 
		edge_color, 2.2 * unit, true)
	draw_arc(Vector2.ZERO, radius - 4.0 * unit, 0.0, TAU, 160, 
		glass_glow, 1.2 * unit, true)

	var gap: = 2.0 * unit
	var thin: = 1.15 * unit


	_line(Vector2( - radius, 0.0), Vector2( - gap, 0.0), thin, reticle, halo)
	_line(Vector2(gap, 0.0), Vector2(radius, 0.0), thin, reticle, halo)
	_line(Vector2(0.0, - radius), Vector2(0.0, - gap), thin, reticle, halo)
	_line(Vector2(0.0, gap), Vector2(0.0, radius), thin, reticle, halo)


	var post: = radius * 0.56
	var post_width: = 3.4 * unit
	_line(Vector2( - radius, 0.0), Vector2( - post, 0.0), post_width, reticle, halo)
	_line(Vector2(post, 0.0), Vector2(radius, 0.0), post_width, reticle, halo)
	_line(Vector2(0.0, - radius), Vector2(0.0, - post), post_width, reticle, halo)
	_line(Vector2(0.0, post), Vector2(0.0, radius), post_width, reticle, halo)


	for i in range(1, 6):
		var dot_y: = radius * 0.085 * float(i)
		var dot_r: = (2.0 - float(i) * 0.1) * unit
		draw_circle(Vector2(0.0, dot_y), dot_r + 0.8 * unit, halo)
		draw_circle(Vector2(0.0, dot_y), dot_r, reticle)


	for i in range(1, 4):
		var tick_x: = radius * 0.085 * float(i)
		var tick: = 2.4 * unit
		_line(Vector2( - tick_x, - tick), Vector2( - tick_x, tick), 
			1.0 * unit, reticle, halo)
		_line(Vector2(tick_x, - tick), Vector2(tick_x, tick), 
			1.0 * unit, reticle, halo)

	draw_circle(Vector2.ZERO, 0.85 * unit + 0.8 * unit, halo)
	draw_circle(Vector2.ZERO, 0.85 * unit, reticle)


func _line(from: Vector2, to: Vector2, width: float, color: Color, 
		glow: Color) -> void :
	draw_line(from, to, glow, width + 1.6, true)
	draw_line(from, to, color, width, true)
