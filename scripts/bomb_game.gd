extends Node3D

# Режим «Закладка бомбы» на de_dust2.
# Игрок — T с бомбой, 3 CT-бота защищают сайты A и B.

const MENU_SCENE: = "res://main_menu.tscn"
const BOT_SCRIPT = preload("res://scripts/duel_bot.gd")
const WeaponData = preload("res://scripts/weapon_data.gd")
const PlayerSkinData = preload("res://scripts/player_skin_data.gd")

enum Phase{INTRO, LIVE, PLANTED, ENDED}

const BOT_COUNT: = 3
const ROUNDS_TO_WIN: = 3
const ROUND_TIME: = 115.0
const PLANT_TIME: = 3.0
const BOMB_TIME: = 40.0
const DEFUSE_TIME: = 10.0
const DEFUSE_RANGE: = 2.6
const BOT_WEAPON: = "ak47"
const PLAYER_MAX_HEALTH: = 100.0
const TINT_GOLD: = Color(0.94, 0.78, 0.36)
const TINT_WARN: = Color(1.0, 0.45, 0.3)

@onready var player = $Player
@onready var hud = $HUD
@onready var map: Node = $Map
@onready var bots_root: Node3D = $Bots

var phase: = Phase.INTRO
var player_score: = 0
var ct_score: = 0

var _round_time: = ROUND_TIME
var _bomb_time: = BOMB_TIME
var _plant_progress: = 0.0
var _defuse_progress: = 0.0
var _defuser: Node3D = null
var _bomb_pos: = Vector3.ZERO
var _bomb_marker: MeshInstance3D = null
var _bots: Array[Node3D] = []
var _ct_spawns: Array[Vector3] = []
var _ammo_clock: = 0.0
var _last_weapon: = "ak47"
var _last_zone: = "body"
var _player_alive: = true
var _shown_plant: = -1
var _shown_bomb: = ""


func _ready() -> void :
	randomize()
	_ensure_plant_action()
	await map.map_ready
	_ct_spawns = map.call("get_ct_spawns")
	_place_player()
	_connect_player()
	_spawn_bots()
	_setup_hud()


func _ensure_plant_action() -> void :
	if InputMap.has_action("plant_bomb"):
		return
	InputMap.add_action("plant_bomb")
	var event: = InputEventKey.new()
	event.physical_keycode = KEY_E
	InputMap.action_add_event("plant_bomb", event)


func _place_player() -> void :
	var spawn: Vector3 = map.call("get_t_spawn")
	var yaw: float = map.call("get_t_spawn_yaw")
	player.set_spawn(spawn, yaw)
	player.global_position = spawn


func _connect_player() -> void :
	player.health_changed.connect(_on_player_health)
	player.died.connect(_on_player_died)
	player.shot_fired.connect(_on_player_shot)
	player.melee_hit.connect(_on_player_melee)


func _setup_hud() -> void :
	hud.show_health_panel(true)
	hud.set_health(PLAYER_MAX_HEALTH, PLAYER_MAX_HEALTH)
	hud.set_duel_score(player_score, ct_score, ROUNDS_TO_WIN)
	hud.set_ammo(player.get_ammo_state())
	hud.set_session_timer_visible(true)
	hud.set_session_time(ROUND_TIME)
	hud.toast("ЗАЛОЖИ БОМБУ НА САЙТЕ A ИЛИ B — ДЕРЖИ E 3 СЕК")
	await get_tree().create_timer(0.6).timeout
	hud.show_duel_banner("ЗАКЛАДКА БОМБЫ", TINT_GOLD)
	await get_tree().create_timer(1.8).timeout
	_start_round()


func _spawn_bots() -> void :
	var skins: Array = BOT_SCRIPT.SKINS
	for index in BOT_COUNT:
		var spawn: Vector3 = _ct_spawns[index % _ct_spawns.size()]
		var bot: Node3D = BOT_SCRIPT.new()
		bot.name = "CT_%d" % index
		var skin: = str(skins[index % skins.size()])
		bot.set_weapon(BOT_WEAPON, "classic")
		bot.configure(player, 980.0, skin)
		bot.configure_arena(map)
		bot.position = spawn
		bots_root.add_child(bot)
		bot.active = false
		bot.died.connect(_on_bot_died)
		_bots.append(bot)


func _start_round() -> void :
	phase = Phase.LIVE
	_round_time = ROUND_TIME
	_bomb_time = BOMB_TIME
	_plant_progress = 0.0
	_defuse_progress = 0.0
	_defuser = null
	_clear_bomb_marker()
	_player_alive = true
	_shown_plant = -1
	_shown_bomb = ""
	_place_player()
	if player.has_method("respawn"):
		player.call("respawn")
	hud.set_health(PLAYER_MAX_HEALTH, PLAYER_MAX_HEALTH)
	hud.set_session_time(ROUND_TIME)
	hud.set_countdown("")
	for index in _bots.size():
		var bot: Node3D = _bots[index]
		var ct_spawn: Vector3 = _ct_spawns[index % _ct_spawns.size()]
		bot.call("reset_round", ct_spawn)
		bot.global_position = ct_spawn
		bot.active = false
	hud.toast("РАУНД %d — НАЙДИ САЙТ И ЗАЛОЖИ БОМБУ" % (player_score + ct_score + 1))
	await get_tree().create_timer(1.4).timeout
	if phase != Phase.LIVE:
		return
	for bot in _bots:
		if is_instance_valid(bot) and bool(bot.alive):
			bot.active = true


func _process(delta: float) -> void :
	_tick_ammo(delta)
	match phase:
		Phase.LIVE:
			_tick_live(delta)
		Phase.PLANTED:
			_tick_planted(delta)


func _tick_ammo(delta: float) -> void :
	_ammo_clock += delta
	if _ammo_clock < 0.25:
		return
	_ammo_clock = 0.0
	hud.set_ammo(player.get_ammo_state())


func _tick_live(delta: float) -> void :
	_round_time = maxf(0.0, _round_time - delta)
	hud.set_session_time(_round_time)
	if _round_time <= 0.0:
		_finish_round(false, "ВРЕМЯ ВЫШЛО")
		return

	var site: int = map.call("site_at", player.global_position)
	var holding: bool = Input.is_action_pressed("plant_bomb")
	player.fire_locked = _plant_progress > 0.01
	if site >= 0 and holding and _player_alive:
		_plant_progress = minf(PLANT_TIME, _plant_progress + delta)
	else:
		_plant_progress = maxf(0.0, _plant_progress - delta * 1.6)
	if _plant_progress > 0.01:
		var percent: = int(round(_plant_progress / PLANT_TIME * 100.0))
		if percent != _shown_plant:
			_shown_plant = percent
			hud.set_countdown("ЗАКЛАДКА %d%%" % percent)
	elif _plant_progress <= 0.0:
		if _shown_plant != -1:
			_shown_plant = -1
			hud.set_countdown("")
	if _plant_progress >= PLANT_TIME:
		_plant_bomb()


func _tick_planted(delta: float) -> void :
	_bomb_time = maxf(0.0, _bomb_time - delta)
	hud.set_session_time(_bomb_time)
	if _bomb_time <= 0.0:
		_explode()
		return

	var candidate: Node3D = _find_defuser()
	if candidate != null and candidate != _defuser:
		if _defuser != null and is_instance_valid(_defuser):
			_defuser.active = true
		_defuser = candidate
		_defuse_progress = 0.0
		if _defuser != null:
			_defuser.active = false
	if _defuser == null or not is_instance_valid(_defuser) or not bool(_defuser.alive):
		_defuser = null
		_defuse_progress = maxf(0.0, _defuse_progress - delta * 0.8)
	else:
		_defuse_progress = minf(DEFUSE_TIME, _defuse_progress + delta)
		if _defuse_progress >= DEFUSE_TIME:
			_finish_round(false, "БОМБА РАЗМИНИРОВАНА")
			return
	_update_bomb_text()


func _update_bomb_text() -> void :
	var text: = "БОМБА %02d" % int(ceil(_bomb_time))
	if _defuse_progress > 0.0:
		text += " · РАЗМИН %d%%" % int(_defuse_progress / DEFUSE_TIME * 100.0)
	if text == _shown_bomb:
		return
	_shown_bomb = text
	hud.set_countdown(text)


func _find_defuser() -> Node3D:
	var best: Node3D = null
	var best_distance: = DEFUSE_RANGE + 4.0
	for bot in _bots:
		if not is_instance_valid(bot) or not bool(bot.alive):
			continue
		var distance: = bot.global_position.distance_to(_bomb_pos)
		if distance < best_distance:
			best_distance = distance
			best = bot
	if best == null or best_distance > DEFUSE_RANGE:
		return null
	return best


func _plant_bomb() -> void :
	phase = Phase.PLANTED
	_bomb_time = BOMB_TIME
	_bomb_pos = player.global_position
	_bomb_pos.y = maxf(_bomb_pos.y - 0.9, -50.0)
	_plant_progress = 0.0
	_spawn_bomb_marker()
	hud.set_session_time(BOMB_TIME)
	player.fire_locked = false
	_shown_bomb = ""
	_update_bomb_text()
	hud.show_duel_banner("БОМБА ЗАЛОЖЕНА", TINT_WARN)
	hud.toast("УДЕРЖИ САЙТ 40 СЕКУНД — БОТЫ ИДУТ РАЗМИНИРОВАТЬ")
	var hunt: Array[Vector3] = [_bomb_pos]
	map.set("bot_hunt_points", hunt)
	for bot in _bots:
		if is_instance_valid(bot) and bool(bot.alive):
			bot.set("_hunt_point", _bomb_pos)
			bot.call("_set_state", 5)


func _explode() -> void :
	_spawn_boom()
	_finish_round(true, "БОМБА ВЗОРВАЛАСЬ")


func _finish_round(player_won: bool, reason: String) -> void :
	if phase == Phase.ENDED:
		return
	phase = Phase.ENDED
	player.fire_locked = false
	if _defuser != null and is_instance_valid(_defuser):
		_defuser.active = true
	_defuser = null
	if player_won:
		player_score += 1
	else:
		ct_score += 1
	hud.set_duel_score(player_score, ct_score, ROUNDS_TO_WIN)
	hud.set_countdown("")
	hud.show_duel_banner(reason, TINT_GOLD if player_won else TINT_WARN)
	if player_score >= ROUNDS_TO_WIN or ct_score >= ROUNDS_TO_WIN:
		var victory: = player_score >= ROUNDS_TO_WIN
		await get_tree().create_timer(1.0).timeout
		hud.show_duel_banner("ПОБЕДА" if victory else "ПОРАЖЕНИЕ", 
			TINT_GOLD if victory else TINT_WARN)
		await get_tree().create_timer(3.2).timeout
		_return_to_menu()
		return
	await get_tree().create_timer(3.4).timeout
	_start_round()


func _return_to_menu() -> void :
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_player_shot(hit: Dictionary) -> void :
	if phase != Phase.LIVE and phase != Phase.PLANTED:
		return
	if not bool(hit.get("mannequin", false)):
		hud.kick_crosshair(1.6)
		return
	var zone: = str(hit.get("zone", "body"))
	var weapon: = str(hit.get("weapon", "ak47"))
	_last_zone = zone
	_last_weapon = weapon
	var info: Dictionary = WeaponData.get_weapon(weapon)
	var damage: = float(info.get("damage_body", 33.0))
	if zone == "head":
		damage = float(info.get("damage_head", 120.0))
	elif zone == "legs":
		damage = float(info.get("damage_legs", 24.0))
	var target: Node = _hit_target(hit)
	if target != null and target.has_method("take_hit"):
		target.call("take_hit", zone, player.global_position, damage)
	hud.flash_hit(zone == "head")
	hud.kick_crosshair(6.5 if zone == "head" else 3.0)


func _on_player_melee(hit: Dictionary) -> void :
	if phase != Phase.LIVE and phase != Phase.PLANTED:
		return
	if not bool(hit.get("mannequin", false)):
		hud.kick_crosshair(1.4)
		return
	var zone: = str(hit.get("zone", "body"))
	_last_zone = zone
	_last_weapon = "knife"
	var target: Node = _hit_target(hit)
	if target != null and target.has_method("take_hit"):
		target.call("take_hit", zone, player.global_position, 60.0)
	hud.flash_hit(false)


func _hit_target(hit: Dictionary) -> Node:
	var collider: Object = hit.get("collider")
	if collider == null:
		return null
	var target: Variant = collider.get("mannequin")
	return target as Node


func _on_player_health(health: float, max_health: float) -> void :
	hud.set_health(health, max_health)


func _on_player_died() -> void :
	_player_alive = false
	if phase == Phase.ENDED:
		return
	hud.toast("ТЫ ПОГИБ — БОМБА НЕ ЗАЛОЖЕНА" if phase == Phase.LIVE else "ТЫ ПОГИБ")
	_finish_round(false, "ТЫ ПОГИБ")


func _on_bot_died(dead_bot: Node3D) -> void :
	if phase == Phase.ENDED:
		return
	if dead_bot == _defuser:
		_defuser = null
		_defuse_progress = 0.0
	if dead_bot != null and is_instance_valid(dead_bot):
		if dead_bot.has_method("hide_for_ragdoll"):
			dead_bot.call("hide_for_ragdoll")
	var alive_count: = 0
	for bot in _bots:
		if is_instance_valid(bot) and bool(bot.alive):
			alive_count += 1
	if alive_count == 0 and (phase == Phase.LIVE or phase == Phase.PLANTED):
		_finish_round(true, "ВСЕ CT УСТРАНЕНЫ")


func _spawn_bomb_marker() -> void :
	_clear_bomb_marker()
	var marker: = MeshInstance3D.new()
	var mesh: = BoxMesh.new()
	mesh.size = Vector3(0.38, 0.24, 0.26)
	marker.mesh = mesh
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.14, 0.13)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.35, 0.12)
	mat.emission_energy_multiplier = 1.8
	marker.material_override = mat
	add_child(marker)
	marker.global_position = _bomb_pos + Vector3(0.0, 0.14, 0.0)
	_bomb_marker = marker


func _clear_bomb_marker() -> void :
	if _bomb_marker != null and is_instance_valid(_bomb_marker):
		_bomb_marker.queue_free()
	_bomb_marker = null


func _spawn_boom() -> void :
	var flash: = MeshInstance3D.new()
	var mesh: = SphereMesh.new()
	mesh.radius = 3.2
	mesh.height = 6.4
	flash.mesh = mesh
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.55, 0.2, 0.85)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.5, 0.15)
	mat.emission_energy_multiplier = 3.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash.material_override = mat
	add_child(flash)
	flash.global_position = _bomb_pos + Vector3(0.0, 1.0, 0.0)
	var tween: = create_tween()
	tween.tween_property(flash, "scale", Vector3.ONE * 2.4, 0.6)
	tween.tween_callback(flash.queue_free)
