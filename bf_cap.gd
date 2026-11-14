extends Node





const OUT: = "res://.tmpshots"
const OPENS: = [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0]

const YAWS: = [0.0, 55.0, 90.0]
const CELL: = 620

var _vm: Node3D
var _camera: Camera3D
var _parts: Array = []


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	RenderingServer.set_default_clear_color(Color(0.44, 0.47, 0.52))
	Settings.apply_display()
	var game: Node = load("res://game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	var player: Node = game.get_node("Player")


	var skin: = "forest"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--skin="):
			skin = arg.substr(7)
	player._melee_skin = skin
	_vm = player.viewmodel
	await get_tree().create_timer(1.0).timeout
	player._switch_slot(player.SLOT_MELEE)
	await get_tree().create_timer(1.6).timeout
	Engine.time_scale = 0.0
	await get_tree().process_frame


	player.set_process(false)
	player.set_physics_process(false)
	_vm.set_process(false)
	_camera = player._vm_camera
	if player._vm_environment != null:
		player._vm_environment.ambient_light_energy = 1.5
	var viewport: = player._vm_viewport as SubViewport
	viewport.transparent_bg = false
	_parts = [_vm._bf_blade, _vm._bf_lever1, _vm._bf_lever2]

	var base: Transform3D = _vm._weapon.transform
	for yaw in YAWS:
		var frames: Array = []
		for open in OPENS:
			pose(float(open))


			_vm._weapon.transform = base
			_vm._weapon.rotate_object_local(Vector3.UP, deg_to_rad(float(yaw)))
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var raw: = get_viewport().get_texture().get_image()
			frames.append(_crop(raw))
		_save("fold_view_%03d" % int(yaw), frames)
	get_tree().quit()


func pose(open: float) -> void :

	_vm._inspect_time = 0.0
	_vm._inspect_duration = 0.0
	_vm._draw_time = 0.0
	_vm._draw_duration = 0.0
	_vm._swing_time = _vm._swing_duration
	_vm._fold_delay = 0.0
	_vm._fold_duration = 0.0
	_vm._fold_from = open
	_vm._fold_to = open
	_vm._fold = open
	_vm._apply_fold(open)




func _crop(img: Image) -> Image:
	var mn: = Vector2(INF, INF)
	var mx: = - mn
	for arm in _parts:
		if arm == null:
			continue
		var mesh: = _first_mesh(arm)
		if mesh == null:
			continue
		var mi: = mesh as MeshInstance3D
		var box: = mi.get_aabb()
		for i in 8:
			var p: Vector3 = mi.global_transform * box.get_endpoint(i)
			var s: = _camera.unproject_position(p)
			mn = mn.min(s)
			mx = mx.max(s)
	var content: = get_viewport().get_visible_rect().size
	var scale: = Vector2(img.get_width() / content.x, img.get_height() / content.y)
	mn *= scale
	mx *= scale
	var pad: = 34.0 * scale.x
	mn -= Vector2(pad, pad)
	mx += Vector2(pad, pad)

	if not (mn.is_finite() and mx.is_finite()) or mx.x <= mn.x or mx.y <= mn.y:
		return _cell(img.get_region(Rect2i(Vector2i.ZERO, img.get_size())))
	var region: = Rect2i(Vector2i(mn), Vector2i(mx - mn))
	region = region.intersection(Rect2i(Vector2i.ZERO, img.get_size()))


	if region.size.x < 2 or region.size.y < 2:
		region = Rect2i(Vector2i.ZERO, img.get_size())
	return _cell(img.get_region(region))



func _cell(part: Image) -> Image:
	if part == null or part.get_width() < 1 or part.get_height() < 1:
		part = Image.create(CELL, CELL, false, Image.FORMAT_RGBA8)
		part.fill(Color(0.44, 0.47, 0.52))
	var side: = maxi(part.get_width(), part.get_height())
	var square: = Image.create(side, side, false, Image.FORMAT_RGBA8)
	square.fill(Color(0.44, 0.47, 0.52))
	square.blit_rect(part, Rect2i(Vector2i.ZERO, part.get_size()), 
		Vector2i((side - part.get_width()) / 2, (side - part.get_height()) / 2))
	square.resize(CELL, CELL, Image.INTERPOLATE_BILINEAR)
	return square


func _first_mesh(node: Node) -> Node:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found: = _first_mesh(child)
		if found != null:
			return found
	return null


func _save(name: String, frames: Array) -> void :
	var cols: = 4
	var rows: = int(ceil(float(frames.size()) / float(cols)))
	var sheet: = Image.create(CELL * cols, CELL * rows, false, 
		Image.FORMAT_RGBA8)
	sheet.fill(Color(0.0, 0.0, 0.0, 1.0))
	for i in frames.size():
		sheet.blit_rect(frames[i], Rect2i(Vector2i.ZERO, Vector2i(CELL, CELL)), 
			Vector2i((i % cols) * CELL, (i / cols) * CELL))
	sheet.save_png(ProjectSettings.globalize_path("%s/%s.png" % [OUT, name]))
	print("saved ", name)
