extends Node




const OUT: = "res://.tmpshots"

var _vm: Node3D
var _player: Node
var _cam: Camera3D
var _frames: Array = []


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	Settings.apply_display()
	var game: Node = load("res://game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	_player = game.get_node("Player")
	_cam = game.get_node("Player/Head/Camera3D")


	_vm = _player.viewmodel
	await get_tree().create_timer(1.2).timeout
	Engine.time_scale = 0.0
	await get_tree().process_frame
	print("viewport rect ", get_viewport().get_visible_rect().size, 
		" window ", DisplayServer.window_get_size(), 
		" scale_mode ", get_window().content_scale_mode, 
		" content ", get_window().content_scale_size, 
		" aspect ", get_window().content_scale_aspect)
	print("stretch ", Settings.screen_stretch, " fov ", Settings.fov)
	var muzzle: Vector3 = _vm._weapon.get_node("Muzzle").global_transform.origin
	print("muzzle screen ", _cam.unproject_position(muzzle))

	await _shot("idle", func() -> void : pass)
	await _shot("fire", func() -> void :
		_player._try_fire())
	await _shot("reload040", func() -> void : _reload(0.4))
	await _shot("reload070", func() -> void : _reload(0.7))
	await _shot("inspect035", func() -> void : _inspect(0.35))
	await _shot("inspect050", func() -> void : _inspect(0.5))
	await _shot("draw040", func() -> void : _draw(0.4))
	await _shot("arctic", func() -> void :
		_vm.build_for("awp", "arctic")
		_reset())

	_save()
	get_tree().quit()


func _reset() -> void :
	_vm._reload_time = 0.0
	_vm._reload_duration = 0.0
	_vm._inspect_time = 0.0
	_vm._inspect_duration = 0.0
	_vm._draw_time = 0.0
	_vm._draw_duration = 0.0


func _reload(t: float) -> void :
	_reset()
	_vm._reload_duration = 2.55
	_vm._reload_time = clampf(t, 0.001, 0.999) * 2.55


func _inspect(t: float) -> void :
	_reset()
	_vm._inspect_duration = 2.0
	_vm._inspect_time = clampf(t, 0.001, 0.999) * 2.0


func _draw(t: float) -> void :
	_reset()
	_vm._draw_duration = 0.62
	_vm._draw_time = clampf(t, 0.001, 0.999) * 0.62


func _shot(tag: String, state: Callable) -> void :
	state.call()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("%s/%02d_%s.png" % [OUT, 
		_frames.size(), tag]))
	_frames.append(img)
	print("shot ", tag, " ", img.get_size())


func _save() -> void :
	var cols: = 2
	var rows: = int(ceil(float(_frames.size()) / 2.0))
	var cell: = Vector2i(640, 360)
	var sheet: = Image.create(cell.x * cols, cell.y * rows, false, 
		Image.FORMAT_RGBA8)
	sheet.fill(Color(0.0, 0.0, 0.0, 1.0))
	for i in _frames.size():
		var small: Image = (_frames[i] as Image).duplicate()
		small.resize(cell.x, cell.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(small, Rect2i(Vector2i.ZERO, cell), 
			Vector2i((i % cols) * cell.x, (i / cols) * cell.y))
	sheet.save_png(ProjectSettings.globalize_path(OUT + "/sheet.png"))
	print("saved sheet, frames=", _frames.size())
