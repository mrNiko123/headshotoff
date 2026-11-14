extends Node



const OUT: = "res://.tmpshots"

var _vm: Node3D
var _frames: Array = []


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	Settings.apply_display()


	var skin_before: = Settings.knife_skin
	Settings.knife_skin = "karambit"
	var game: Node = load("res://game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	var player: Node = game.get_node("Player")
	_vm = player.viewmodel
	await get_tree().create_timer(1.0).timeout
	player._switch_slot(player.SLOT_MELEE)
	await get_tree().create_timer(1.6).timeout
	Engine.time_scale = 0.0
	await get_tree().process_frame
	print("knife kind: ", _vm._knife_kind)

	await _shot("idle", func() -> void : pass)
	await _shot("a030", func() -> void : _swing(0, 0.3))
	await _shot("a046", func() -> void : _swing(0, 0.46))
	await _shot("c040", func() -> void : _swing(2, 0.4))
	await _shot("inspect016", func() -> void : _inspect(0.16))
	await _shot("inspect040", func() -> void : _inspect(0.4))
	await _shot("inspect052", func() -> void : _inspect(0.52))
	await _shot("draw040", func() -> void : _draw(0.4))

	var arms: Node3D = _vm._rig.get_node("Arms")
	arms.visible = false
	await _shot("bare90", func() -> void : pass)
	arms.visible = true
	_save()
	Settings.knife_skin = skin_before
	get_tree().quit()


func _reset() -> void :
	_vm._swing_time = 0.0
	_vm._swing_duration = 0.0
	_vm._inspect_time = 0.0
	_vm._inspect_duration = 0.0
	_vm._draw_time = 0.0
	_vm._draw_duration = 0.0
	_vm._fold_time = _vm._fold_duration
	_vm._fold_to = 1.0
	_vm._fold_from = 1.0
	_vm._fold_delay = 0.0


func _swing(kind: int, t: float) -> void :
	_reset()
	_vm._swing_kind = kind
	_vm._swing_duration = 0.62
	_vm._swing_time = clampf(t, 0.001, 0.999) * 0.62


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
	img.save_png(ProjectSettings.globalize_path("%s/kar_%s.png" % [OUT, tag]))
	_frames.append(img)


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
	sheet.save_png(ProjectSettings.globalize_path(OUT + "/kar_sheet.png"))
	print("saved karambit sheet, frames=", _frames.size())
