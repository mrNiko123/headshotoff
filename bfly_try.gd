extends Node



const OUT: = "res://.tmpshots"

var _vm: Node3D
var _frames: Array = []


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	Settings.apply_display()
	var skin_before: = Settings.knife_skin
	Settings.knife_skin = "ember"
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
	_vm._select_inspect_curves()
	player.set_process(false)


	var ts: Array = []
	var t: = 0.34
	while t < 0.575:
		ts.append(t)
		t += 0.015
	for value in ts:
		var phase: float = value
		await _shot("fan%03d" % int(round(phase * 100.0)), 
			func() -> void : _inspect(phase), false)
	_save("fold")


	_frames.clear()
	for i in 19:
		var phase: = 0.05 + 0.9 * float(i) / 18.0
		await _shot("inspect%03d" % int(round(phase * 100.0)), 
			func() -> void : _inspect(phase), true)
	_save("sheet")

	Settings.knife_skin = skin_before
	get_tree().quit()


func _inspect(t: float) -> void :
	_vm._swing_time = 0.0
	_vm._swing_duration = 0.0
	_vm._inspect_duration = 2.0
	_vm._inspect_time = clampf(t, 0.001, 0.999) * 2.0
	_vm._draw_time = 0.0
	_vm._draw_duration = 0.0
	_vm._fold_time = 1.0
	_vm._fold_duration = 1.0
	_vm._fold_delay = 0.0
	_vm._fold_from = 1.0
	_vm._fold_to = 1.0


func _shot(tag: String, state: Callable, keep: bool) -> void :
	state.call()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("%s/bf_%s.png" % [OUT, tag]))
	if keep:
		_frames.append(img)


func _save(tag: String) -> void :
	var cols: = 6
	var cell: = Vector2i(480, 270)
	var rows: = int(ceil(float(_frames.size()) / float(cols)))
	if _frames.is_empty():
		return
	var sheet: = Image.create(cell.x * cols, cell.y * rows, false, 
		Image.FORMAT_RGBA8)
	sheet.fill(Color(0.0, 0.0, 0.0, 1.0))
	for i in _frames.size():
		var small: Image = (_frames[i] as Image).duplicate()
		small.resize(cell.x, cell.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(small, Rect2i(Vector2i.ZERO, cell), 
			Vector2i((i % cols) * cell.x, (i / cols) * cell.y))
	sheet.save_png(ProjectSettings.globalize_path("%s/bf_%s_sheet.png" % [OUT, tag]))
	print("saved ", tag, " sheet, frames=", _frames.size())
