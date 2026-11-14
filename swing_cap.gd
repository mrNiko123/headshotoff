extends Node





const OUT: = "res://.tmpshots"
const SWING_DURATION: = 0.62
const STEPS: = [0.06, 0.14, 0.22, 0.3, 0.36, 0.42, 0.5, 0.62, 0.78]

var _vm: Node3D


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	Settings.apply_display()
	var skin: = "forest"
	var left: = false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--skin="):
			skin = arg.substr(7)
		elif arg == "--left":
			left = true

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
	print("kind ", _vm._knife_kind, " viewport ", 
		get_viewport().get_visible_rect().size)

	for kind in (4 if _vm._dual else 3):
		await _strip(kind)
	get_tree().quit()


func _set_swing(kind: int, t: float) -> void :
	_vm._swing_left = _vm._dual and kind == 3
	_vm._swing_kind = kind
	_vm._swing_duration = SWING_DURATION
	_vm._swing_time = clampf(t, 0.001, 0.999) * SWING_DURATION
	_vm._inspect_time = 0.0
	_vm._inspect_duration = 0.0
	_vm._draw_time = 0.0
	_vm._draw_duration = 0.0
	_vm._fold_time = _vm._fold_duration
	_vm._fold_from = 1.0
	_vm._fold_to = 1.0
	_vm._fold_delay = 0.0


func _strip(kind: int) -> void :
	var frames: Array = []
	for step in STEPS:
		_set_swing(kind, float(step))
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: = get_viewport().get_texture().get_image()
		var tag: = "s%d_%03d" % [kind, int(round(float(step) * 100.0))]
		img.save_png(ProjectSettings.globalize_path("%s/%s.png" % [OUT, tag]))
		frames.append(img)
	_save("swing_%s_sheet.png" % "abcd"[kind], frames)


func _save(name: String, frames: Array) -> void :
	var cols: = 3
	var rows: = int(ceil(float(frames.size()) / float(cols)))
	var cell: = Vector2i(640, 360)
	var sheet: = Image.create(cell.x * cols, cell.y * rows, false, 
		Image.FORMAT_RGBA8)
	sheet.fill(Color(0.0, 0.0, 0.0, 1.0))
	for i in frames.size():
		var small: Image = (frames[i] as Image).duplicate()
		small.resize(cell.x, cell.y, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(small, Rect2i(Vector2i.ZERO, cell), 
			Vector2i((i % cols) * cell.x, (i / cols) * cell.y))
	sheet.save_png(ProjectSettings.globalize_path("%s/%s" % [OUT, name]))
	print("saved ", name, " frames=", frames.size())
