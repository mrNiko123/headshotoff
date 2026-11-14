extends Node3D











const BOT_SCRIPT = preload("res://scripts/dm_bot.gd")
const BotNames = preload("res://scripts/bot_names.gd")
const MENU_SCENE: = "res://main_menu.tscn"
const GameSettingsScript = preload("res://scripts/game_settings.gd")
const WorldViewScript = preload("res://scripts/world_view.gd")
const WorldTint = preload("res://scripts/world_tint.gd")
const WorldTintShader = preload("res://shaders/world_tint.gdshader")
const RagdollScript = preload("res://scripts/ragdoll.gd")
const WeaponData = preload("res://scripts/weapon_data.gd")

enum Phase{INTRO, LIVE, PAUSED, ENDED}

const MATCH_TIME: = 300.0
const BOT_COUNT: = 4
const TDM_BOT_COUNT: = 5
const TDM_ALPHA_BOTS: = 2
const TEAM_ALPHA: = "alpha"
const TEAM_BRAVO: = "bravo"
const BOT_RESPAWN: = 2.6
const PLAYER_RESPAWN: = 3.0


const SPAWN_PROTECTION: = 2.4
const BOT_WEAPONS: = ["ak47", "m4a1", "awp", "deagle"]
const KILL_POINTS: = 100
const HEADSHOT_BONUS: = 50
const ASSIST_POINTS: = 25
const FIRST_BLOOD_BONUS: = 25
const ASSIST_WINDOW: = 8.0
const ASSIST_MIN_DAMAGE: = 20.0
const INTRO_STEP: = 0.72
const PLAYER_MAX_HEALTH: = 100.0
const KNIFE_DAMAGE_BODY: = 55.0
const KNIFE_DAMAGE_HEAD: = 80.0
const KNIFE_DAMAGE_LEGS: = 45.0



const MAX_RAGDOLLS: = 4
const PLAYER_ID: = "player"



const ACCENT: = Color(1.0, 0.55, 0.16, 1.0)
const ACCENT_BRIGHT: = Color(1.0, 0.8, 0.4, 1.0)
const MUTED: = Color(0.62, 0.665, 0.725, 1.0)
const GREEN: = Color(0.36, 1.0, 0.55, 1.0)
const RED: = Color(1.0, 0.31, 0.27, 1.0)
const CYAN: = Color(0.32, 0.86, 1.0, 1.0)



const DM_SKY_TOP: = Color(0.115, 0.105, 0.245, 1.0)
const DM_SKY_HORIZON: = Color(0.985, 0.56, 0.285, 1.0)
const DM_FOG_COLOR: = Color(0.9, 0.61, 0.43, 1.0)

var phase: = Phase.INTRO
var map: Node3D
var world_environment: WorldEnvironment
var world_view
var _settings

var _time_left: = MATCH_TIME
var _first_blood: = false
var _transitioning: = false
var _intro_running: = false
var _phase_before_pause: = Phase.LIVE
var _leaderboard_clock: = 0.0
var _player_respawn_timer: = 0.0
var _player_guard: = 0.0



var _fighters: Array[Node3D] = []
var _bot_nodes: Array[Node3D] = []
var _stats: Dictionary = {}
var _last_hit_by: Dictionary = {}
var _damage_log: Dictionary = {}
var _bot_respawns: Array[Dictionary] = []
var _ragdolls: Array[Node3D] = []

var _tdm: = false
var _buy_menu: CanvasLayer

var _match_stats: = {
	"shots": 0, 
	"hits": 0, 
	"damage": 0.0, 
	"damage_taken": 0.0, 
}

var _player_name: = "ИГРОК"
var _player_weapon: = "ak47"
var _bot_names: Array[String] = []

var _death_camera: = false
var _death_look: = Vector3.ZERO
var _death_cam_tween: Tween
var _sun: DirectionalLight3D
var _sun_default_shadow: = false
var _applied_effects_quality: = -1
var _world_tint_mat: ShaderMaterial

@onready var player = $Player
@onready var hud = $HUD
@onready var dm_hud = $DMHUD
@onready var arena: Node3D = $Arena
@onready var bots_root: Node3D = $Bots


func _ready() -> void :
	randomize()
	_player_name = _resolve_player_name()
	_player_weapon = _resolve_player_weapon()
	map = arena.get_node_or_null("Map") as Node3D
	world_environment = arena.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_sun = arena.get_node_or_null("Sun") as DirectionalLight3D
	_sun_default_shadow = _sun != null and _sun.shadow_enabled
	_setup_world_view()
	_apply_world_tint()
	_place_player_initial()
	_connect_player()
	_connect_hud()
	_spawn_bots()
	_refresh_bot_targets()
	_setup_buy_menu()
	_apply_environment()
	_apply_quality_lighting()




	hud.show_health_panel(true)
	hud.set_duel_panel_visible(false)
	hud.set_rating_widget_visible(false)
	hud.set_session_timer_visible(false)
	hud.set_scoreboard_enabled(false)
	hud.set_health(PLAYER_MAX_HEALTH, PLAYER_MAX_HEALTH)
	hud.set_ammo(player.get_ammo_state())
	hud.set_scope(false)
	dm_hud.setup(_player_name)
	dm_hud.set_timer(MATCH_TIME)
	dm_hud.set_leaderboard(_sorted_rows())

	Settings.settings_changed.connect(_apply_environment)
	Settings.settings_changed.connect(_apply_quality_lighting)
	Settings.settings_changed.connect(_apply_world_tint)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Sfx.play_start()
	call_deferred("_begin_intro")




func _setup_buy_menu() -> void :
	var menu: = preload("res://scripts/buy_menu.gd").new()
	add_child(menu)
	menu.weapon_picked.connect(_on_buy_menu_pick)
	_buy_menu = menu


func _on_buy_menu_pick(weapon_id: String, skin_id: String) -> void :
	if player != null:
		player.set_duel_weapon(weapon_id, skin_id)
		_player_weapon = weapon_id


func _resolve_player_name() -> String:
	var nickname: = Settings.nickname.strip_edges().to_upper()
	return nickname if not nickname.is_empty() else "ИГРОК"


func _resolve_player_weapon() -> String:
	var id: = str(Settings.weapon_id)
	if not WeaponData.WEAPONS.has(id) or WeaponData.is_melee(id):
		return "ak47"
	return id


func _setup_world_view() -> void :
	world_view = WorldViewScript.new()
	world_view.name = "WorldView"
	add_child(world_view)
	world_view.setup(player.camera)


func _place_player_initial() -> void :
	var start: = Vector3(-68.0, 0.06, -12.0)
	if map != null:
		var value: Variant = map.get("player_start")
		if value is Vector3:
			start = value
	player.set_spawn(start, _yaw_to_center(start))
	player.reset_round_state()
	player.active = false
	_add_player_stats()


func _add_player_stats() -> void :
	player.set_meta("dm_id", PLAYER_ID)
	player.set_meta("dm_team", TEAM_ALPHA)
	_fighters.append(player)
	_stats[PLAYER_ID] = {
		"id": PLAYER_ID, 
		"name": _player_name, 
		"is_player": true, 
		"node": player, 
		"team": TEAM_ALPHA, 
		"points": 0, 
		"kills": 0, 
		"deaths": 0, 
		"assists": 0, 
		"headshots": 0, 
		"damage": 0.0, 
		"damage_taken": 0.0, 
	}


func _spawn_bots() -> void :
	if map == null:
		return
	_tdm = Settings.game_mode == "tdm"
	var names: = BotNames.new()
	var used: Dictionary = {_player_name: true}
	var count: int = TDM_BOT_COUNT if _tdm else BOT_COUNT
	for i in count:
		var nick: = _unique_nick(names, used)
		var spawn: = _choose_spawn(_fighters, null)
		var weapon: = str(BOT_WEAPONS[randi() % BOT_WEAPONS.size()])
		var skin_id: = _first_skin(weapon)
		var bot = BOT_SCRIPT.new()
		bot.name = "DMBot%d" % i
		bot.set_weapon(weapon, skin_id)
		var bot_skin: = str(BOT_SCRIPT.SKINS[randi() % BOT_SCRIPT.SKINS.size()])
		bot.configure(player, randf_range(950.0, 1850.0), bot_skin)
		bot.configure_arena(map)
		bot.position = spawn
		bots_root.add_child(bot)
		bot.set_dm_name(nick)
		bot.reset_round(spawn)
		bot.active = false
		bot.died.connect(_on_bot_died)
		bot.dm_hit.connect(_on_bot_hit)
		var id: = "bot_%d" % i
		bot.set_meta("dm_id", id)
		bot.set_meta("dm_name", nick)
		var team: = TEAM_ALPHA if _tdm and i < TDM_ALPHA_BOTS else TEAM_BRAVO
		if _tdm:
			bot.set_meta("dm_team", team)
		_fighters.append(bot)
		_bot_nodes.append(bot)
		_stats[id] = {
			"id": id, 
			"name": nick, 
			"is_player": false, 
			"node": bot, 
			"team": team, 
			"points": 0, 
			"kills": 0, 
			"deaths": 0, 
			"assists": 0, 
			"headshots": 0, 
			"damage": 0.0, 
			"damage_taken": 0.0, 
		}


func _unique_nick(names, used: Dictionary) -> String:
	var nick: String = str(names.random_nick())
	var guard: = 0
	while used.has(nick.to_upper()) and guard < 30:
		nick = str(names.random_nick())
		guard += 1
	used[nick.to_upper()] = true
	return nick.to_upper()


func _first_skin(weapon: String) -> String:
	var skins: Dictionary = WeaponData.get_weapon(weapon).get("skins", {})
	return str(skins.keys()[0]) if not skins.is_empty() else "default"


func _refresh_bot_targets() -> void :
	var all: Array = []
	for fighter in _fighters:
		if is_instance_valid(fighter):
			all.append(fighter)
	for bot in _bot_nodes:
		if is_instance_valid(bot):
			if _tdm:
				var my_team: = TEAM_BRAVO
				if bot.has_meta("dm_team"):
					my_team = str(bot.get_meta("dm_team"))
				var enemies: Array = []
				for fighter in all:
					if _team_of(fighter) != my_team:
						enemies.append(fighter)
				bot.set_dm_targets(enemies)
			else:
				bot.set_dm_targets(all)


func _team_of(node: Node) -> String:
	if node == null:
		return ""
	if node == player:
		return TEAM_ALPHA
	if node.has_meta("dm_team"):
		return str(node.get_meta("dm_team"))
	return ""


func _team_sum(team: String) -> int:
	var total: = 0
	for id in _stats:
		var entry: Dictionary = _stats[id]
		if str(entry.get("team", "")) == team:
			total += int(entry.get("points", 0))
	return total




func _connect_player() -> void :
	player.health_changed.connect(_on_player_health)
	player.damaged.connect(_on_player_damaged)
	player.died.connect(_on_player_died)
	player.shot_fired.connect(_on_player_shot)
	player.melee_hit.connect(_on_player_melee)
	player.weapon_changed.connect(_on_weapon_changed)
	player.ammo_changed.connect(_on_ammo_changed)
	player.scope_changed.connect(hud.set_scope)


func _connect_hud() -> void :
	hud.resume_requested.connect(_resume)
	hud.restart_requested.connect(_restart_match)
	hud.menu_requested.connect(_return_to_menu)
	hud.settings_requested.connect(_open_settings)
	hud.duel_menu_requested.connect(_return_to_menu)
	dm_hud.rematch_requested.connect(_restart_match)
	dm_hud.menu_requested.connect(_return_to_menu)


func _on_player_health(health: float, max_health: float) -> void :
	hud.set_health(health, max_health)


func _on_player_damaged(amount: float, _from_position: Vector3) -> void :


	hud.flash_damage()
	hud.kick_crosshair(4.5)


func _on_ammo_changed(ammo: int, magazine: int, reloading: bool) -> void :
	hud.set_ammo({"ammo": ammo, "magazine": magazine, "reloading": reloading})


func _on_weapon_changed(ammo: Dictionary) -> void :
	hud.set_ammo(ammo)
	hud.kick_crosshair(2.0)


func _on_player_shot(hit: Dictionary) -> void :


	_end_player_guard()
	if phase != Phase.LIVE:
		return
	_match_stats["shots"] = int(_match_stats.get("shots", 0)) + 1
	var zone: = str(hit.get("zone", "body"))
	var headshot: = bool(hit.get("headshot", false))
	if not bool(hit.get("mannequin", false)):
		hud.kick_crosshair(1.6)
		return
	var target: = _hit_target(hit)
	if target == null:
		return
	if _tdm and _team_of(target) == TEAM_ALPHA:
		dm_hud.popup("НЕ СТРЕЛЯЙ ПО СВОИМ", MUTED)
		return
	_match_stats["hits"] = int(_match_stats.get("hits", 0)) + 1
	var weapon: = str(hit.get("weapon", _player_weapon))
	var info: = WeaponData.get_weapon(weapon)
	var damage: = float(info.get("damage_body", 36.0))
	if zone == "head":
		damage = float(info.get("damage_head", damage))
	elif zone == "legs":
		damage = float(info.get("damage_legs", damage))
	_register_hit(target, player, damage, zone, weapon)
	if target.has_method("take_hit"):
		target.call("take_hit", zone, player.global_position, damage)
	elif target.has_method("take_damage"):
		target.call("take_damage", damage, player.global_position)
	hud.flash_hit(headshot)
	hud.kick_crosshair(6.5 if headshot else 3.0)
	if headshot:
		Sfx.play_headshot()
	else:
		Sfx.play_hit()


func _on_player_melee(hit: Dictionary) -> void :
	_end_player_guard()
	if phase != Phase.LIVE:
		return
	if not bool(hit.get("mannequin", false)):
		hud.kick_crosshair(1.4)
		return
	var zone: = str(hit.get("zone", "body"))
	var target: = _hit_target(hit)
	if target == null:
		return
	if _tdm and _team_of(target) == TEAM_ALPHA:
		dm_hud.popup("НЕ СТРЕЛЯЙ ПО СВОИМ", MUTED)
		return
	var damage: = KNIFE_DAMAGE_BODY
	if zone == "head":
		damage = KNIFE_DAMAGE_HEAD
	elif zone == "legs":
		damage = KNIFE_DAMAGE_LEGS
	_register_hit(target, player, damage, zone, "knife")
	if target.has_method("take_damage"):
		target.call("take_damage", damage, player.global_position)
	hud.flash_hit(zone == "head")
	hud.kick_crosshair(6.0 if zone == "head" else 3.0)
	if zone == "head":
		Sfx.play_headshot()
	else:
		Sfx.play_hit()


func _hit_target(hit: Dictionary) -> Node:
	var collider: Object = hit.get("collider")
	if collider == null:
		return null
	var value: Variant = collider.get("mannequin")
	return value as Node


func _on_player_died() -> void :
	if phase != Phase.LIVE:
		return
	_end_player_guard()
	player.set_combat_visible(false)
	player.collision_layer = 0
	hud.flash_damage(1.0)
	hud.show_death_fx()
	_spawn_player_ragdoll()
	_detach_death_camera()
	_player_respawn_timer = PLAYER_RESPAWN
	dm_hud.show_respawn(PLAYER_RESPAWN)
	_handle_death(player)




func _on_bot_hit(attacker: Node3D, victim: Node3D, amount: float, zone: String, 
		_lethal: bool, weapon: String) -> void :
	if phase != Phase.LIVE:
		return
	_register_hit(victim, attacker, amount, zone, weapon)


func _on_bot_died(dead_bot: Node3D) -> void :
	if phase != Phase.LIVE:
		return
	_spawn_bot_ragdoll(dead_bot)
	_handle_death(dead_bot)
	_bot_respawns.append({"bot": dead_bot, "time": BOT_RESPAWN})


func _spawn_bot_ragdoll(dead_bot: Node3D) -> void :
	if dead_bot == null or not is_instance_valid(dead_bot):
		return
	var colors: Dictionary = {}
	if dead_bot.has_method("ragdoll_palette"):
		var value: Variant = dead_bot.call("ragdoll_palette")
		if value is Dictionary:
			colors = value as Dictionary
	var from: Vector3 = player.global_position
	var info: Dictionary = _last_hit_by.get(_id_for(dead_bot), {})
	if not str(info.get("id", "")).is_empty():
		var killer: = _fighter_by_id(str(info.get("id", "")))
		if killer != null:
			from = killer.global_position
	if dead_bot.has_method("hide_for_ragdoll"):
		dead_bot.call("hide_for_ragdoll")
	_spawn_ragdoll("FallenBot", dead_bot.global_transform, colors, from, null)


func _spawn_player_ragdoll() -> void :
	var colors: = {
		"torso": Color(0.62, 0.085, 0.075, 1.0), 
		"shirt": Color(1.0, 0.16, 0.09, 1.0), 
		"pants": Color(0.235, 0.035, 0.03, 1.0), 
		"pants_dark": Color(0.175, 0.03, 0.026, 1.0), 
		"boots": Color(0.115, 0.08, 0.075, 1.0), 
		"skin": Color(0.76, 0.555, 0.41, 1.0), 
		"glove": Color(0.23, 0.035, 0.03, 1.0), 
		"helmet": Color(0.42, 0.05, 0.045, 1.0), 
		"accent": Color(1.0, 0.12, 0.08, 1.0), 
		"eye": Color(1.0, 0.3, 0.18, 1.0), 
		"sole": Color(0.06, 0.045, 0.045, 1.0), 
	}
	var info: Dictionary = _last_hit_by.get(PLAYER_ID, {})
	var from: Vector3 = player.global_position - Vector3(0.0, 0.0, 1.0)
	var killer: = _fighter_by_id(str(info.get("id", "")))
	if killer != null:
		from = killer.global_position
	_spawn_ragdoll("FallenPlayer", player.global_transform, colors, from, 
		player as PhysicsBody3D)


func _spawn_ragdoll(tag: String, at: Transform3D, colors: Dictionary, 
		from: Vector3, ignore: PhysicsBody3D) -> void :
	var body: = RagdollScript.new()
	body.name = tag
	body.palette = colors
	body.impulse_from = from
	body.exclude = ignore
	add_child(body)
	body.global_transform = at
	_ragdolls.append(body)
	while _ragdolls.size() > MAX_RAGDOLLS:
		var oldest: = _ragdolls[0]
		_ragdolls.remove_at(0)
		if is_instance_valid(oldest):
			oldest.queue_free()




func _id_for(node: Node) -> String:
	if node == null:
		return ""
	if node == player:
		return PLAYER_ID
	if node.has_meta("dm_id"):
		return str(node.get_meta("dm_id"))
	return ""


func _fighter_by_id(id: String) -> Node3D:
	var entry: Variant = _stats.get(id)
	if not (entry is Dictionary):
		return null
	var node: Variant = (entry as Dictionary).get("node")
	if node is Node3D and is_instance_valid(node):
		return node as Node3D
	return null


func _register_hit(victim: Node, attacker: Node, amount: float, zone: String, 
		weapon: String) -> void :
	if victim == null or attacker == null:
		return
	var victim_id: = _id_for(victim)
	var attacker_id: = _id_for(attacker)
	if victim_id.is_empty() or attacker_id.is_empty() or victim_id == attacker_id:
		return
	var now: = Time.get_ticks_msec() / 1000.0
	var log: Dictionary = _damage_log.get(victim_id, {})
	var entry: Dictionary = log.get(attacker_id, 
		{"damage": 0.0, "time": now})
	entry["damage"] = float(entry.get("damage", 0.0)) + amount
	entry["time"] = now
	log[attacker_id] = entry
	_damage_log[victim_id] = log
	_last_hit_by[victim_id] = {
		"id": attacker_id, 
		"zone": zone, 
		"weapon": weapon, 
		"time": now, 
	}
	if attacker_id == PLAYER_ID:
		_match_stats["damage"] = float(_match_stats.get("damage", 0.0)) + amount
	if victim_id == PLAYER_ID:
		_match_stats["damage_taken"] = \
		float(_match_stats.get("damage_taken", 0.0)) + amount
	var victim_stats: Dictionary = _stats.get(victim_id, {})
	if not victim_stats.is_empty():
		victim_stats["damage_taken"] = float(victim_stats.get("damage_taken", 0.0)) + amount
		_stats[victim_id] = victim_stats
	var attacker_stats: Dictionary = _stats.get(attacker_id, {})
	if not attacker_stats.is_empty():
		attacker_stats["damage"] = float(attacker_stats.get("damage", 0.0)) + amount
		_stats[attacker_id] = attacker_stats


func _handle_death(victim: Node) -> void :
	var victim_id: = _id_for(victim)
	if victim_id.is_empty():
		return
	var victim_stats: Dictionary = _stats.get(victim_id, {})
	if victim_stats.is_empty():
		return
	victim_stats["deaths"] = int(victim_stats.get("deaths", 0)) + 1
	_stats[victim_id] = victim_stats

	var info: Dictionary = _last_hit_by.get(victim_id, {})
	var killer_id: = str(info.get("id", ""))
	var zone: = str(info.get("zone", "body"))
	var weapon: = str(info.get("weapon", "ak47"))
	var headshot: = zone == "head"
	var victim_name: = str(victim_stats.get("name", "—"))

	if killer_id.is_empty() or killer_id == victim_id:
		hud.add_dm_killfeed("—", victim_name, weapon, headshot, MUTED)
	else:
		var killer_stats: Dictionary = _stats.get(killer_id, {})
		if killer_stats.is_empty():
			hud.add_dm_killfeed("—", victim_name, weapon, headshot, MUTED)
		else:
			var killer_name: = str(killer_stats.get("name", "—"))
			var points: = KILL_POINTS
			if headshot:
				points += HEADSHOT_BONUS
			var first: = not _first_blood
			if first:
				first = true
				_first_blood = true
				points += FIRST_BLOOD_BONUS
			killer_stats["kills"] = int(killer_stats.get("kills", 0)) + 1
			if headshot:
				killer_stats["headshots"] = int(killer_stats.get("headshots", 0)) + 1
			killer_stats["points"] = int(killer_stats.get("points", 0)) + points
			_stats[killer_id] = killer_stats

			var assists: = _assists_for(victim_id, killer_id)
			for assist_id in assists:
				var assist_stats: Dictionary = _stats.get(assist_id, {})
				if assist_stats.is_empty():
					continue
				assist_stats["assists"] = int(assist_stats.get("assists", 0)) + 1
				assist_stats["points"] = int(assist_stats.get("points", 0)) + ASSIST_POINTS
				_stats[assist_id] = assist_stats
				if assist_id == PLAYER_ID:
					dm_hud.popup("+%d · ПОМОЩЬ" % ASSIST_POINTS, CYAN)

			var accent: = ACCENT
			if killer_id == PLAYER_ID:
				accent = GREEN
			elif victim_id == PLAYER_ID:
				accent = RED
			hud.add_dm_killfeed(killer_name, victim_name, weapon, headshot, accent)

			if killer_id == PLAYER_ID:


				hud.register_kill(int(killer_stats.get("kills", 0)), headshot)
				var text: = "+%d" % points
				if headshot:
					text += " · ХЕДШОТ"
				if first:
					text += " · ПЕРВАЯ КРОВЬ"
				dm_hud.popup(text, GREEN)
			elif victim_id == PLAYER_ID:
				dm_hud.show_killed_by(killer_name, weapon)
			if first:
				dm_hud.announce("ПЕРВАЯ КРОВЬ · " + killer_name, ACCENT_BRIGHT)

	_last_hit_by.erase(victim_id)
	_damage_log.erase(victim_id)
	_leaderboard_clock = 0.0


func _assists_for(victim_id: String, killer_id: String) -> Array[String]:
	var result: Array[String] = []
	var log: Dictionary = _damage_log.get(victim_id, {})
	var now: = Time.get_ticks_msec() / 1000.0
	for raw_id in log:
		var assist_id: = str(raw_id)
		if assist_id == killer_id:
			continue
		var entry: Dictionary = log[raw_id]
		if now - float(entry.get("time", 0.0)) > ASSIST_WINDOW:
			continue
		if float(entry.get("damage", 0.0)) < ASSIST_MIN_DAMAGE:
			continue
		result.append(assist_id)
	return result




func _sorted_rows() -> Array:
	var rows: Array = []
	for id in _stats:
		var entry: Dictionary = _stats[id]
		rows.append(entry.duplicate())
	rows.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		var ap: = int(a.get("points", 0))
		var bp: = int(b.get("points", 0))
		if ap == bp:
			return int(a.get("kills", 0)) > int(b.get("kills", 0))
		return ap > bp)
	for i in rows.size():
		rows[i]["rank"] = i + 1
	return rows


func _player_row(rows: Array) -> Dictionary:
	for row in rows:
		if bool(row.get("is_player", false)):
			return row
	return {}




func _begin_intro() -> void :
	if _intro_running:
		return
	_intro_running = true
	phase = Phase.INTRO
	player.active = false
	for bot in _bot_nodes:
		if is_instance_valid(bot):
			bot.active = false
	dm_hud.show_intro()
	dm_hud.set_timer(MATCH_TIME)

	await _wait(0.55)
	for step in ["3", "2", "1"]:
		if not is_inside_tree() or phase != Phase.INTRO:
			_intro_running = false
			return
		dm_hud.set_intro_countdown(step)
		Sfx.play_tick()
		await _wait(INTRO_STEP)
	if not is_inside_tree() or phase != Phase.INTRO:
		_intro_running = false
		return
	dm_hud.set_intro_countdown("БОЙ")
	Sfx.play_start()
	await _wait(0.4)
	if not is_inside_tree() or phase != Phase.INTRO:
		_intro_running = false
		return
	await dm_hud.hide_intro()
	if not is_inside_tree() or phase != Phase.INTRO:
		_intro_running = false
		return
	player.active = true
	for bot in _bot_nodes:
		if is_instance_valid(bot):
			bot.active = true
	phase = Phase.LIVE
	_intro_running = false
	_start_player_guard()
	_refresh_bot_targets()


func _process(delta: float) -> void :
	if player != null and hud != null:
		hud.set_reload_progress(player.get_reload_progress(), 
			player.get_reload_remaining())
	if phase == Phase.LIVE:
		_time_left = maxf(0.0, _time_left - delta)
		dm_hud.set_timer(_time_left)
		_tick_bot_respawns(delta)
		_tick_player_respawn(delta)
		_tick_player_guard(delta)
		if _time_left <= 0.0:
			_finish_match()
	_leaderboard_clock -= delta
	if _leaderboard_clock <= 0.0:
		_leaderboard_clock = 0.16
		dm_hud.set_leaderboard(_sorted_rows())
		if _tdm:
			dm_hud.set_team_score(_team_sum(TEAM_ALPHA), _team_sum(TEAM_BRAVO))
	if _death_camera:
		var offset: Vector3 = player.camera.global_position - _death_look
		if Vector2(offset.x, offset.z).length_squared() > 0.0625:
			player.camera.look_at(_death_look, Vector3.UP)


func _tick_bot_respawns(delta: float) -> void :
	for i in range(_bot_respawns.size() - 1, -1, -1):
		var entry: Dictionary = _bot_respawns[i]
		entry["time"] = float(entry.get("time", 0.0)) - delta
		if float(entry["time"]) > 0.0:
			_bot_respawns[i] = entry
			continue
		_bot_respawns.remove_at(i)
		var bot: Variant = entry.get("bot")
		if bot is Node3D and is_instance_valid(bot):
			_respawn_bot(bot as Node3D)


func _tick_player_respawn(delta: float) -> void :
	if _player_respawn_timer <= 0.0:
		return
	_player_respawn_timer = maxf(0.0, _player_respawn_timer - delta)
	dm_hud.update_respawn(_player_respawn_timer)
	if _player_respawn_timer <= 0.0:
		_respawn_player()


func _respawn_bot(bot: Node3D) -> void :
	if phase != Phase.LIVE or not is_instance_valid(bot):
		return
	var occupants: = _alive_occupants(bot)
	var spawn: = _choose_spawn(occupants, bot)
	var yaw: = _yaw_to_nearest(spawn, occupants)
	bot.reset_round(spawn)
	bot.rotation.y = yaw
	bot.active = true
	var id: = _id_for(bot)
	_last_hit_by.erase(id)
	_damage_log.erase(id)
	_refresh_bot_targets()


func _respawn_player() -> void :
	if phase != Phase.LIVE:
		return
	var occupants: = _alive_occupants(player)
	var spawn: = _choose_spawn(occupants, player)
	var yaw: = _yaw_to_nearest(spawn, occupants)
	_restore_death_camera()
	player.set_spawn(spawn, yaw)
	player.reset_round_state()
	player.collision_layer = 1
	player.set_combat_visible(true)
	player.active = true
	hud.clear_death_fx()
	hud.set_health(PLAYER_MAX_HEALTH, PLAYER_MAX_HEALTH)
	hud.set_ammo(player.get_ammo_state())
	hud.set_scope(false)
	dm_hud.hide_respawn()
	dm_hud.hide_killed_by()
	_start_player_guard()
	_last_hit_by.erase(PLAYER_ID)
	_damage_log.erase(PLAYER_ID)
	_refresh_bot_targets()







func _start_player_guard() -> void :
	_player_guard = SPAWN_PROTECTION
	player.set_meta("dm_guard", true)
	dm_hud.show_guard(_player_guard)


func _end_player_guard() -> void :
	if _player_guard <= 0.0:
		return
	_player_guard = 0.0
	if player != null and is_instance_valid(player):
		player.remove_meta("dm_guard")
	dm_hud.hide_guard()


func _tick_player_guard(delta: float) -> void :
	if _player_guard <= 0.0:
		return
	_player_guard = maxf(0.0, _player_guard - delta)
	dm_hud.update_guard(_player_guard)
	if _player_guard <= 0.0:
		player.remove_meta("dm_guard")
		dm_hud.hide_guard()


func _alive_occupants(except: Node3D) -> Array:
	var result: Array = []
	for fighter in _fighters:
		if fighter == except or not is_instance_valid(fighter):
			continue
		if fighter.has_method("is_alive") and bool(fighter.call("is_alive")):
			result.append(fighter)
	return result


func _choose_spawn(occupants: Array, _from: Node3D) -> Vector3:
	var fallback: = Vector3(-68.0, 0.06, -12.0)
	if map == null:
		return fallback
	var value: Variant = map.get("spawn_points")
	if not (value is Array):
		return fallback
	var points: Array = value
	if points.is_empty():
		return fallback



	var safe_radius: = 18.0
	var safe_sq: = safe_radius * safe_radius
	var best: = fallback
	var best_score: = - INF
	for raw in points:
		if not (raw is Vector3):
			continue
		var point: Vector3 = raw
		var nearest: = 1000000000.0
		var penalty: = 0.0
		for fighter in occupants:
			if not is_instance_valid(fighter):
				continue
			var distance: = point.distance_squared_to(fighter.global_position)
			nearest = minf(nearest, distance)
			if distance < safe_sq:
				penalty += (safe_sq - distance) * 90.0
		if _spawn_exposed(point, occupants):
			penalty += 26000.0
		var score: = nearest - penalty + randf() * 12.0
		if score > best_score:
			best_score = score
			best = point
	return best




func _spawn_exposed(point: Vector3, occupants: Array) -> bool:
	var space: = get_world_3d().direct_space_state
	for fighter in occupants:
		if not is_instance_valid(fighter):
			continue
		var query: = PhysicsRayQueryParameters3D.create(
			point + Vector3.UP * 1.1, 
			fighter.global_position + Vector3.UP * 1.35)
		query.collision_mask = 1 | 8
		query.collide_with_areas = false
		query.collide_with_bodies = true
		var hit: = space.intersect_ray(query)
		if hit.is_empty():
			return true
		if hit.get("collider") == fighter:
			return true
	return false


func _yaw_to_center(from: Vector3) -> float:
	var direction: = Vector3(0.0, from.y, 0.0) - from
	direction.y = 0.0
	if direction.length_squared() < 0.01:
		return 0.0
	return atan2( - direction.x, - direction.z)


func _yaw_to_nearest(from: Vector3, occupants: Array) -> float:
	var best: Node3D = null
	var best_distance: = INF
	for fighter in occupants:
		if not is_instance_valid(fighter):
			continue
		var distance: = from.distance_squared_to(fighter.global_position)
		if distance < best_distance:
			best_distance = distance
			best = fighter
	if best == null:
		return _yaw_to_center(from)
	var direction: = best.global_position - from
	direction.y = 0.0
	if direction.length_squared() < 0.01:
		return 0.0
	return atan2( - direction.x, - direction.z)


func _finish_match() -> void :
	if phase == Phase.ENDED:
		return
	phase = Phase.ENDED
	Engine.time_scale = 1.0
	_player_respawn_timer = 0.0
	_end_player_guard()
	player.active = false
	for bot in _bot_nodes:
		if is_instance_valid(bot):
			bot.active = false
	player.exit_scope()
	_restore_death_camera()


	hud.clear_death_fx()
	dm_hud.set_match_hud_visible(false)
	dm_hud.hide_respawn()
	dm_hud.hide_killed_by()
	dm_hud.hide_scoreboard()
	var rows: = _sorted_rows()
	var own: = _player_row(rows)
	dm_hud.set_leaderboard(rows)
	dm_hud.show_result(rows, own, _match_stats)
	if _tdm:
		var alpha: = _team_sum(TEAM_ALPHA)
		var bravo: = _team_sum(TEAM_BRAVO)
		dm_hud.override_result_title(
			"ПОБЕДА АЛЬЯНСА!" if alpha >= bravo else "ПОБЕДА ВРАГА!")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if int(own.get("rank", 99)) == 1 \
			or (_tdm and _team_sum(TEAM_ALPHA) >= _team_sum(TEAM_BRAVO)):
		Sfx.play_victory()
	else:
		Sfx.play_finish()


func _wait(seconds: float) -> void :
	if seconds <= 0.0:
		return
	await get_tree().create_timer(seconds, false).timeout




func _detach_death_camera() -> void :
	var cam: Camera3D = player.camera
	var start: = cam.global_transform
	cam.top_level = true
	cam.global_transform = start
	_death_look = player.global_position + Vector3.UP * 1.1
	_death_camera = true
	var target: = start.origin + start.basis.z * 5.8 + start.basis.x * 2.4\
	+ Vector3.UP * 3.6
	_death_cam_tween = create_tween()
	_death_cam_tween.set_parallel(true)
	_death_cam_tween.tween_property(cam, "global_position", target, 2.5)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_death_cam_tween.tween_property(cam, "fov", 72.0, 2.5)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _restore_death_camera() -> void :
	if _death_cam_tween != null and _death_cam_tween.is_valid():
		_death_cam_tween.kill()
	if not _death_camera:
		return
	_death_camera = false
	var cam: Camera3D = player.camera
	cam.top_level = false
	cam.transform = Transform3D.IDENTITY
	cam.fov = Settings.fov
	_death_look = Vector3.ZERO




func _apply_environment() -> void :
	if world_environment == null or world_environment.environment == null:
		return
	var environment: = world_environment.environment
	Settings.apply_environment(environment)


	var sky: = environment.sky
	if sky != null and sky.sky_material is ProceduralSkyMaterial:
		var material: = sky.sky_material as ProceduralSkyMaterial
		material.sky_top_color = DM_SKY_TOP
		material.sky_horizon_color = DM_SKY_HORIZON
		material.ground_horizon_color = DM_SKY_HORIZON.darkened(0.16)
		material.ground_bottom_color = DM_SKY_TOP.darkened(0.38)
	environment.fog_light_color = DM_FOG_COLOR


func _apply_world_tint() -> void :
	if map == null:
		return
	if not Settings.world_tint_enabled:
		WorldTint.clear(map)
		return
	if _world_tint_mat == null:
		_world_tint_mat = ShaderMaterial.new()
		_world_tint_mat.shader = WorldTintShader
	_world_tint_mat.set_shader_parameter("tint", Settings.world_tint_color)
	WorldTint.apply(map, _world_tint_mat)


func _apply_quality_lighting() -> void :
	if _applied_effects_quality == Settings.effects_quality:
		return
	_applied_effects_quality = Settings.effects_quality
	if _sun != null:
		_sun.shadow_enabled = _sun_default_shadow and Settings.effects_quality >= 2
	var show_decor: = Settings.effects_quality >= 2
	for node in get_tree().get_nodes_in_group("arena_decor_lights"):
		var light: = node as Light3D
		if light != null:
			light.visible = show_decor




func _input(event: InputEvent) -> void :
	# B (магазин) обрабатываем в _input, чтобы событие не терялось в оверлеях.
	if _buy_menu != null and _buy_menu.handle_key(event):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause"):
		if phase == Phase.LIVE:
			_pause()
			get_viewport().set_input_as_handled()
		elif phase == Phase.PAUSED:
			_resume()
			get_viewport().set_input_as_handled()


func _pause() -> void :
	_phase_before_pause = phase
	phase = Phase.PAUSED
	player.active = false
	for bot in _bot_nodes:
		if is_instance_valid(bot):
			bot.active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dm_hud.hide_scoreboard()
	dm_hud.set_match_hud_visible(false)
	var own: Dictionary = _stats.get(PLAYER_ID, {})
	hud.set_pause_stats("DEATHMATCH   ·   ОЧКИ %d   ·   БЕЗ РЕЙТИНГА"\
	%int(own.get("points", 0)))
	hud.show_pause()
	if world_view != null:
		world_view.set_paused(true)
	Settings.save_settings()
	get_tree().paused = true


func _open_settings() -> void :
	if phase != Phase.PAUSED:
		return
	if _settings == null or not is_instance_valid(_settings):
		_settings = GameSettingsScript.new()
		_settings.closed.connect(_on_settings_closed)
		add_child(_settings)
	_settings.open()


func _on_settings_closed() -> void :
	hud.show_pause()


func _resume() -> void :
	if phase != Phase.PAUSED:
		return
	if _settings != null and is_instance_valid(_settings) and _settings.visible:
		_settings.close()
		return
	get_tree().paused = false
	phase = _phase_before_pause
	player.active = phase == Phase.LIVE and player.is_alive()
	for bot in _bot_nodes:
		if is_instance_valid(bot):
			bot.active = phase == Phase.LIVE
	if world_view != null:
		world_view.set_paused(false)
	hud.hide_pause()
	dm_hud.set_match_hud_visible(true)
	if _player_respawn_timer > 0.0:
		dm_hud.show_respawn(_player_respawn_timer)
	if _player_guard > 0.0:
		dm_hud.show_guard(_player_guard)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED




func _restart_match() -> void :
	if _transitioning:
		return
	_transitioning = true
	if _settings != null and is_instance_valid(_settings):
		_settings.close()
	get_tree().paused = false
	Engine.time_scale = 1.0
	Settings.save_settings()
	await hud.fade_out(0.22)
	get_tree().reload_current_scene()


func _return_to_menu() -> void :
	if _transitioning:
		return
	_transitioning = true
	if _settings != null and is_instance_valid(_settings):
		_settings.visible = false
	get_tree().paused = false
	Engine.time_scale = 1.0
	Settings.save_settings()
	player.active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if world_view != null:
		world_view.set_paused(false)
	await hud.fade_out(0.25)
	get_tree().change_scene_to_file(MENU_SCENE)
