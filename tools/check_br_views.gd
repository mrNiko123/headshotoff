extends Node

# Рендер БАТЛ РОЯЛЯ: автобус, приземление, призрак и постройки.

var _br: Node


func _ready() -> void :
	Settings.apply_display()
	_set_building(true)
	Engine.time_scale = 6.0
	_br = load("res://br.tscn").instantiate()
	add_child(_br)
	while int(_br.phase) != int(_br.Phase.BUS):
		await get_tree().process_frame
	Engine.time_scale = 1.0
	await get_tree().create_timer(0.4).timeout
	await _shot("br_bus")
	_br._eject_from_bus()
	Engine.time_scale = 10.0
	while int(_br.phase) != int(_br.Phase.LIVE):
		await get_tree().process_frame
	Engine.time_scale = 1.0
	await get_tree().create_timer(0.5).timeout
	await _shot("br_landing")
	var bm: Node = _br.build_manager
	if bm != null:
		bm.mats["wood"] = 120
		bm.toggle_for("wall")
		await get_tree().create_timer(0.3).timeout
		await _shot("br_ghost")
		bm.try_place()
		var before_count: int = bm.pieces_root.get_child_count()
		if before_count > 0:
			var last_piece: Node = bm.pieces_root.get_child(
				before_count - 1)
			last_piece.set_meta("mine", true)
		bm.toggle_for("wall")
		for bot in _br._bot_nodes:
			if is_instance_valid(bot):
				bot.active = false
		# отойти назад, чтобы стена попала в кадр
		var back: Vector3 = (_br.player as Node3D).global_basis.z
		back.y = 0.0
		(_br.player as Node3D).global_position += back.normalized() * 6.0
		print("PIECES=", bm.piece_count)
		print("PLAYER_POS=", (_br.player as Node3D).global_position, 
			" FWD=", - (_br.player as Node3D).global_basis.z)
		for piece in bm.pieces_root.get_children():
			if piece.has_meta("mine"):
				print("MINE=", (piece as Node3D).global_position)
		await get_tree().create_timer(0.4).timeout
		await _shot("br_pieces")
	get_tree().quit()


func _shot(shot_name: String) -> void :
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	image.save_png("res://tools/view_%s.png" % shot_name)
	print("SHOT_SAVED ", shot_name)


func _set_building(value: bool) -> void :
	var path: = "res://br/data/br_settings.tres"
	var res: Resource = load(path)
	if res != null:
		res.building_enabled = value
		ResourceSaver.save(res, path)
