extends Node










var _source: Camera3D
var _layer: CanvasLayer
var _display: TextureRect
var _viewport: SubViewport
var _camera: Camera3D


var _frozen: = false


func setup(source_camera: Camera3D) -> void :
	_source = source_camera


	process_priority = 1000

	_layer = CanvasLayer.new()
	_layer.name = "WorldLayer"
	_layer.layer = -10
	add_child(_layer)

	_display = TextureRect.new()
	_display.name = "WorldDisplay"
	_display.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_display.stretch_mode = TextureRect.STRETCH_SCALE



	_display.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_display)

	_viewport = SubViewport.new()
	_viewport.name = "WorldRender"
	_viewport.transparent_bg = false
	_viewport.handle_input_locally = false
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR




	_viewport.set_as_audio_listener_3d(true)
	_display.add_child(_viewport)
	_display.texture = _viewport.get_texture()
	_apply_brightness()

	_camera = Camera3D.new()
	_camera.name = "WorldCamera"
	_camera.current = true
	_viewport.add_child(_camera)


	if _source != null:
		_source.current = false

	_sync_render_quality()
	_sync_camera_settings()
	_sync_size()
	Settings.display_changed.connect(_on_display_changed)
	Settings.settings_changed.connect(_on_settings_changed)
	Settings.render_scale_changed.connect(_on_render_scale_changed)
	var window: = get_window()
	if window != null:
		window.size_changed.connect(_sync_size)




func set_paused(paused: bool) -> void :
	if _viewport == null or paused == _frozen:
		return
	_frozen = paused
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED\
	if paused else SubViewport.UPDATE_ALWAYS
	if not paused:
		_sync_camera()


func is_paused() -> bool:
	return _frozen


func _process(_delta: float) -> void :
	if _frozen:
		return
	_sync_camera()





func _sync_camera() -> void :
	if _source == null or _camera == null:
		return
	if _source.current:
		_source.current = false
	_camera.global_transform = _source.global_transform
	_camera.fov = _source.fov


func _sync_camera_settings() -> void :
	if _source == null or _camera == null:
		return
	_camera.keep_aspect = _source.keep_aspect
	_camera.near = _source.near
	_camera.far = _source.far
	_camera.cull_mask = _source.cull_mask
	_camera.h_offset = _source.h_offset
	_camera.v_offset = _source.v_offset
	_camera.attributes = _source.attributes





func _sync_size() -> void :
	if _viewport == null:
		return
	var window: = get_window()
	var content: = Vector2(window.content_scale_size) if window != null else Vector2.ZERO
	if content.x < 1.0 or content.y < 1.0:
		content = get_viewport().get_visible_rect().size
	var window_size: = Vector2(window.size) if window != null else Vector2.ZERO
	if window_size.x < 1.0 or window_size.y < 1.0:
		window_size = Vector2(DisplayServer.window_get_size())
	var scale: = 1.0
	if Settings.screen_stretch <= 0.001 and window_size.x >= content.x:
		scale = maxf(1.0, minf(window_size.x / content.x, window_size.y / content.y))
	var target: = Vector2i((content * scale).round())
	if target.x < 1 or target.y < 1:
		return
	if _viewport.size != target:
		_viewport.size = target


func _on_display_changed() -> void :
	_sync_size()
	_sync_camera_settings()
	_sync_render_quality()
	_request_frame()


func _on_settings_changed() -> void :
	_apply_brightness()
	_sync_camera_settings()
	_sync_render_quality()
	_request_frame()





func _apply_brightness() -> void :
	if _display == null:
		return
	var value: = clampf(Settings.brightness, 0.1, 2.0)
	_display.self_modulate = Color(value, value, value, 1.0)


func _on_render_scale_changed(value: float) -> void :
	if _viewport != null:
		_viewport.scaling_3d_scale = value
	_request_frame()



func _request_frame() -> void :
	if _viewport != null and _frozen:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE





func _sync_quality() -> void :
	var root: = get_viewport()
	if root == null or _viewport == null:
		return
	if not is_equal_approx(_viewport.scaling_3d_scale, root.scaling_3d_scale):
		_viewport.scaling_3d_scale = root.scaling_3d_scale


func _sync_render_quality() -> void :
	var root: = get_viewport()
	if root == null or _viewport == null:
		return
	if _viewport.msaa_3d != root.msaa_3d:
		_viewport.msaa_3d = root.msaa_3d
	if _viewport.screen_space_aa != root.screen_space_aa:
		_viewport.screen_space_aa = root.screen_space_aa
	if _viewport.use_taa != root.use_taa:
		_viewport.use_taa = root.use_taa
	if _viewport.use_debanding != root.use_debanding:
		_viewport.use_debanding = root.use_debanding
	if _viewport.scaling_3d_mode != root.scaling_3d_mode:
		_viewport.scaling_3d_mode = root.scaling_3d_mode
	_sync_quality()
