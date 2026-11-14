extends Node





const OUT: = "res://.tmpshots"
const DURATION: = 3.9



const STEPS: = [
	0.0, 0.06, 0.12, 0.18, 0.24, 0.3, 0.36, 0.42, 0.48, 
	0.54, 0.6, 0.66, 0.72, 0.78, 0.84, 0.9, 0.96
]

var _vm: Node3D
var _frames: Array = []


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	Settings.apply_display()



	var skin: = "forest"
	var left: = false

	var variant: = 0
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--skin="):
			skin = arg.substr(7)
		elif arg == "--left":
			left = true
		elif arg.begins_with("--variant="):
			variant = int(arg.substr(10))


	Settings.left_hand = left
	var game: Node = load("res://game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	var player: Node = game.get_node("Player")


	player._melee_skin = skin
	_vm = player.viewmodel
	await get_tree().create_timer(1.0).timeout
	player._switch_slot(player.SLOT_MELEE)
	await get_tree().create_timer(1.6).timeout
	Engine.time_scale = 0.0
	await get_tree().process_frame

	_vm._nomad_inspect_variant = variant
	_vm._select_inspect_curves()
	print("kind ", _vm._knife_kind, " viewport ", 
		get_viewport().get_visible_rect().size)

	for step in STEPS:
		await _shot("i%03d" % int(round(float(step) * 100.0)), 
			float(step))
	await _shot_closed()
	await _fold_strip()
	await _draw_strip()
	_save()
	get_tree().quit()



func _shot_closed() -> void :
	_vm._inspect_time = 0.0
	_vm._inspect_duration = 0.0
	_vm._fold_from = 0.0
	_vm._fold_to = 0.0
	_vm._fold_time = _vm._fold_duration
	_vm._fold_delay = 0.0
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + "/closed.png"))




func _fold_strip() -> void :
	await _strip("fold_close", 0.34, 0.02, 12)
	await _strip("fold_open", 0.56, 0.02, 12)


func _strip(name: String, from: float, step: float, count: int) -> void :
	var cell: = Vector2i(550, 430)
	var frames: Array = []
	for i in count:
		_inspect(from + step * float(i))
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		frames.append(_crop(get_viewport().get_texture().get_image(), cell))
	_sheet(name, frames, cell)





func _draw_strip() -> void :
	var cell: = Vector2i(550, 430)
	var frames: Array = []
	for i in 10:
		var k: = float(i) / 9.0
		_vm._inspect_time = 0.0
		_vm._inspect_duration = 0.0
		_vm._draw_time = 0.0
		_vm._draw_duration = 0.0
		_vm._fold_from = 0.0
		_vm._fold_to = 1.0
		_vm._fold_duration = 0.34
		_vm._fold_delay = 0.0
		_vm._fold_time = 0.34 * k
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		frames.append(_crop(get_viewport().get_texture().get_image(), cell))
	_sheet("draw_open", frames, cell)


func _crop(img: Image, cell: Vector2i) -> Image:


	var w: = img.get_width()
	var h: = img.get_height()
	var region: = Rect2i(int(w * 0.4), int(h * 0.16), 
		int(w * 0.58), int(h * 0.8))
	var part: Image = img.get_region(region)
	part.resize(cell.x, cell.y, Image.INTERPOLATE_BILINEAR)
	return part


func _sheet(name: String, frames: Array, cell: Vector2i) -> void :
	var cols: = 4
	var rows: = int(ceil(float(frames.size()) / float(cols)))
	var sheet: = Image.create(cell.x * cols, cell.y * rows, false, 
		Image.FORMAT_RGBA8)
	sheet.fill(Color(0.0, 0.0, 0.0, 1.0))
	for i in frames.size():
		sheet.blit_rect(frames[i], Rect2i(Vector2i.ZERO, cell), 
			Vector2i((i % cols) * cell.x, (i / cols) * cell.y))
	sheet.save_png(ProjectSettings.globalize_path("%s/%s.png" % [OUT, name]))
	print("saved ", name, ", frames=", frames.size())


func _inspect(t: float) -> void :
	_vm._draw_time = 0.0
	_vm._draw_duration = 0.0
	_vm._inspect_duration = DURATION
	_vm._inspect_time = clampf(t, 0.001, 0.999) * DURATION
	_vm._fold_time = _vm._fold_duration
	_vm._fold_from = 1.0
	_vm._fold_to = 1.0
	_vm._fold_delay = 0.0


func _shot(tag: String, t: float) -> void :
	_inspect(t)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("%s/%s.png" % [OUT, tag]))
	_frames.append(img)


func _save() -> void :
	var cols: = 3
	var rows: = int(ceil(float(_frames.size()) / float(cols)))
	var src: Vector2i = (_frames[0] as Image).get_size()
	var cell: = Vector2i(640, int(round(640.0 * float(src.y) / float(src.x))))
	var sheet: = Image.create(cell.x * cols, cell.y * rows, false, 
		Image.FORMAT_RGBA8)
	sheet.fill(Color(0.0, 0.0, 0.0, 1.0))
	for i in _frames.size():
		var small: Image = (_frames[i] as Image).duplicate()
		small.resize(cell.x, cell.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(small, Rect2i(Vector2i.ZERO, cell), 
			Vector2i((i % cols) * cell.x, (i / cols) * cell.y))
	sheet.save_png(ProjectSettings.globalize_path(OUT + "/inspect_sheet.png"))
	print("saved inspect sheet, frames=", _frames.size())
