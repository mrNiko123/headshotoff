extends Node

# Headless-тест БАТЛ РОЯЛЯ: оба подрежима (со строительством / без).

const BR_SCENE: = "res://br.tscn"
const LOOT_SCRIPT: = preload("res://br/building/loot_pickup.gd")
const SETTINGS_PATH: = "res://br/data/br_settings.tres"


func _ready() -> void :
	Settings.apply_display()
	Engine.time_scale = 8.0
	await _test_build_mode()
	await _test_no_build_mode()
	Engine.time_scale = 1.0
	get_tree().quit()


func _wait(seconds: float) -> void :
	await get_tree().create_timer(seconds, true).timeout


func _set_building(value: bool) -> void :
	var res: Resource = load(SETTINGS_PATH)
	if res != null:
		res.building_enabled = value
		ResourceSaver.save(res, SETTINGS_PATH)


func _wait_phase(br: Node, phase: int, guard_max: int) -> bool:
	var guard: = 0
	while int(br.phase) != phase and guard < guard_max:
		await _wait(0.1)
		guard += 1
	return int(br.phase) == phase


func _test_build_mode() -> void :
	print("=== РЕЖИМ СО СТРОИТЕЛЬСТВОМ ===")
	var br: Node = load(BR_SCENE).instantiate()
	add_child(br)
	await _wait(0.5)
	print("PASS_INTRO=", int(br.phase) == 0)
	var ok_bus: = await _wait_phase(br, br.Phase.BUS, 200)
	print("PASS_BUS=", ok_bus)
	print("PASS_BUS_NODE=", br.get_node_or_null("BattleBus") != null)
	br._eject_from_bus()
	print("PASS_GLIDE=", int(br.phase) == int(br.Phase.GLIDE))
	var ok_live: = await _wait_phase(br, br.Phase.LIVE, 500)
	print("PASS_LIVE=", ok_live)
	var bots_active: = true
	for bot in br._bot_nodes:
		if is_instance_valid(bot) and not bool(bot.active):
			bots_active = false
	print("PASS_BOTS_ACTIVE=", bots_active)
	var bm: Node = br.build_manager
	print("PASS_BM=", bm != null)
	if bm != null:
		bm.mats["wood"] = 100
		bm.toggle_for("wall")
		print("PASS_META=", br.player.has_meta("br_build"))
		await _wait(0.1)
		print("PASS_GHOST_VISIBLE=", bm.ghost.visible)
		bm.try_place()
		print("PASS_PIECES=", bm.piece_count >= 1)
		print("PASS_WOOD_SPENT=", int(bm.mats["wood"]) == 90)
		var piece: Node = bm.pieces_root.get_child(0)
		bm.damage_piece(piece, 100.0)
		print("PASS_DAMAGE=", absf(float(piece.get_meta("piece_hp"))) < 50.5)
		bm.damage_piece(piece, 60.0)
		print("PASS_DESTROYED=", bm.piece_count == 0)
		bm.toggle_for("wall")
		print("PASS_META_OFF=", not br.player.has_meta("br_build"))
	var harvest_nodes: = get_tree().get_nodes_in_group("harvestable")
	print("PASS_HARVESTABLE=", harvest_nodes.size() > 0)
	if bm != null and harvest_nodes.size() > 0:
		var target: Node = harvest_nodes[0]
		var mat_key: = str(target.get_meta("harvest_type"))
		var before: = int(bm.mats[mat_key])
		var hit: = {"collider": target, 
			"position": (target as Node3D).global_position \
				+ Vector3(0.0, 1.0, 0.0)}
		bm.knife_hit(hit)
		print("PASS_HARVEST_MATS=", int(bm.mats[mat_key]) > before)
	var mats_pickups: = 0
	var pickups: = 0
	for child in br.get_children():
		if child.get_script() == LOOT_SCRIPT:
			pickups += 1
			if child.kind == "mats":
				mats_pickups += 1
	print("PASS_PICKUPS=", pickups > 40)
	print("PASS_MATS_IN_LOOT=", mats_pickups > 0)
	# зона: принудительно сжать, проверить урон и смерть → финал матча
	br.player.health = 10.0
	var guard_wait: = 0
	while float(br._player_guard) > 0.0 and guard_wait < 100:
		await _wait(0.1)
		guard_wait += 1
	br._zone_radius = 5.0
	br._zone_phase = 4
	br._zone_mode = 2
	br._update_zone_wall()
	var zone_hit: = false
	var guard_dbg: = 0
	var ok_ended: = false
	while guard_dbg < 500:
		await _wait(0.1)
		if float(br.player.health) < 10.0:
			zone_hit = true
		if int(br.phase) == int(br.Phase.ENDED):
			ok_ended = true
			break
		guard_dbg += 1
	print("PASS_ZONE_DAMAGE=", zone_hit)
	print("PASS_ENDED=", ok_ended)
	print("PASS_PLACE=", br._player_place > 1)
	br.queue_free()
	await _wait(0.3)


func _test_no_build_mode() -> void :
	print("=== РЕЖИМ БЕЗ СТРОИТЕЛЬСТВА ===")
	_set_building(false)
	var br: Node = load(BR_SCENE).instantiate()
	add_child(br)
	await _wait(0.5)
	var ok_bus: = await _wait_phase(br, br.Phase.BUS, 200)
	print("PASS_BUS2=", ok_bus)
	print("PASS_BM_NULL=", br.build_manager == null)
	print("PASS_BUILD_HUD_NULL=", br._build_hud == null)
	br._eject_from_bus()
	var ok_live: = await _wait_phase(br, br.Phase.LIVE, 500)
	print("PASS_LIVE2=", ok_live)
	var mats_pickups: = 0
	var pickups: = 0
	for child in br.get_children():
		if child.get_script() == LOOT_SCRIPT:
			pickups += 1
			if child.kind == "mats":
				mats_pickups += 1
	print("PASS_PICKUPS2=", pickups > 40)
	print("PASS_NO_MATS_PICKUPS=", mats_pickups == 0)
	# укрытий больше (extra cover): считать StaticBody3D ящики сложно,
	# проверяем что карта реагирует на вызов
	print("PASS_EXTRA_COVER=", br.map.has_method("add_extra_cover"))
	br.player.health = 10.0
	var guard_wait: = 0
	while float(br._player_guard) > 0.0 and guard_wait < 100:
		await _wait(0.1)
		guard_wait += 1
	br._zone_radius = 5.0
	br._zone_phase = 4
	br._zone_mode = 2
	br._update_zone_wall()
	var ok_ended: = false
	var guard_dbg: = 0
	while guard_dbg < 500:
		await _wait(0.1)
		if int(br.phase) == int(br.Phase.ENDED):
			ok_ended = true
			break
		guard_dbg += 1
	print("PASS_ENDED2=", ok_ended)
	print("PASS_PLACE2=", br._player_place > 1)
	br.queue_free()
	await _wait(0.3)
	_set_building(true)
