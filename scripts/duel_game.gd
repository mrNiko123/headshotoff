extends Node3D







const BOT_SCRIPT = preload("res://scripts/duel_bot.gd")
const MENU_SCENE: = "res://main_menu.tscn"
const GameSettingsScript = preload("res://scripts/game_settings.gd")
const WorldViewScript = preload("res://scripts/world_view.gd")
const WorldTint = preload("res://scripts/world_tint.gd")
const WorldTintShader = preload("res://shaders/world_tint.gdshader")
const RagdollScript = preload("res://scripts/ragdoll.gd")
const WeaponData = preload("res://scripts/weapon_data.gd")
const MapData = preload("res://scripts/map_data.gd")

enum Phase{INTRO, LIVE, ROUND_END, ENDED, PAUSED}

const PLAYER_MAX_HEALTH: = 100.0
const PLAYER_SPAWN_YAW: = - PI * 0.5
const INTRO_STEP: = 0.72
const ROUNDS_TO_WIN: = 5
const ROUND_DELAY_WIN: = 1.45
const ROUND_DELAY_LOSS: = 2.15
const AWP_DAMAGE_BODY: = 100.0
const AWP_DAMAGE_HEAD: = 150.0
const AWP_DAMAGE_LEGS: = 70.0
const KNIFE_DAMAGE_BODY: = 55.0
const KNIFE_DAMAGE_HEAD: = 80.0
const KNIFE_DAMAGE_LEGS: = 45.0


const DUEL_WEAPONS: = ["awp", "ak47", "m4a1"]

var phase: = Phase.INTRO
var bot
var map: Node3D
var world_environment: WorldEnvironment
var world_view
var player_score: = 0
var bot_score: = 0

var _world_tint_mat: ShaderMaterial
var _settings
var _transitioning: = false
var _result_applied: = false
var _result_data: Dictionary = {}
var _intro_running: = false
var _phase_before_pause: = Phase.LIVE
var _death_camera: = false
var _death_look: = Vector3.ZERO
var _death_cam_tween: Tween
var _sun: DirectionalLight3D
var _sun_default_shadow: = false
var _applied_effects_quality: = -1
var _round_token: = 0

var duel_weapon_id: = "ak47"
var duel_weapon_skin: = "classic"
var _weapon_intro_shown: = false

var _bot_skin: = ""

var _bot_avatar_path: = ""

var _abandon_checked: = false



var shots_fired: = 0
var shots_hit: = 0
var headshot_count: = 0
var damage_dealt: = 0.0
var damage_taken: = 0.0

var _last_player_zone: = "body"
var _last_player_weapon: = "awp"
var _bot_last_zone: = "body"

@onready var player = $Player
@onready var hud = $HUD
@onready var arena: Node3D = $Arena
@onready var bots_root: Node3D = $Bots


func _ready() -> void :
	randomize()
	_choose_duel_weapon()
	_load_random_arena()

	player.set_duel_weapon(duel_weapon_id, duel_weapon_skin)
	map = arena.get_node_or_null("Map") as Node3D
	world_environment = arena.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_sun = arena.get_node_or_null("Sun") as DirectionalLight3D
	_sun_default_shadow = _sun != null and _sun.shadow_enabled
	_setup_world_view()
	_apply_world_tint()
	_place_player()
	_connect_player()
	_connect_hud()
	_spawn_bot()
	_apply_environment()
	_apply_quality_lighting()

	hud.show_health_panel(true)
	hud.set_health(PLAYER_MAX_HEALTH, PLAYER_MAX_HEALTH)
	hud.set_rating(Settings.rating_elo, Settings.rating_level(), 
		Settings.rating_level_name())
	_update_header()
	hud.set_duel_score(player_score, bot_score, ROUNDS_TO_WIN)
	_setup_duel_roster()
	hud.set_ammo(player.get_ammo_state())
	hud.set_scope(false)

	Settings.settings_changed.connect(_apply_environment)
	Settings.settings_changed.connect(_apply_quality_lighting)
	Settings.settings_changed.connect(_apply_world_tint)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Sfx.play_start()
	call_deferred("_begin_intro")




func _load_random_arena() -> void :
	var scene: PackedScene = load(MapData.random_ranked_scene()) as PackedScene
	if scene == null:
		return
	var replacement: Node3D = scene.instantiate() as Node3D
	if replacement == null:
		return
	var old: Node3D = arena
	remove_child(old)
	old.queue_free()
	replacement.name = "Arena"
	add_child(replacement)
	move_child(replacement, 0)
	arena = replacement


func _choose_duel_weapon() -> void :
	duel_weapon_id = str(DUEL_WEAPONS[randi() % DUEL_WEAPONS.size()])
	var skins: Dictionary = WeaponData.get_weapon(duel_weapon_id).get("skins", {})
	duel_weapon_skin = str(skins.keys()[0]) if not skins.is_empty() else "default"
	_last_player_weapon = duel_weapon_id



func _setup_world_view() -> void :
	world_view = WorldViewScript.new()
	world_view.name = "WorldView"
	add_child(world_view)
	world_view.setup(player.camera)


func _place_player() -> void :
	player.reset_health()
	if map == null:
		return
	var start: Variant = map.get("player_start")
	if start is Vector3:
		player.set_spawn(start, PLAYER_SPAWN_YAW)


func _spawn_bot() -> void :
	if map == null:
		return
	var start: Variant = map.get("bot_start")
	var spawn: Vector3 = start if start is Vector3 else Vector3(8.5, 0.06, 0.0)



	if bot != null and is_instance_valid(bot):
		bot.set_weapon(duel_weapon_id, duel_weapon_skin)
		bot.set_match_score(player_score, bot_score)
		bot.reset_round(spawn)
		return
	if _bot_skin.is_empty():
		var skins: Array = BOT_SCRIPT.SKINS
		_bot_skin = str(skins[randi() % skins.size()])
	bot = BOT_SCRIPT.new()
	bot.name = "DuelBot"
	bot.set_weapon(duel_weapon_id, duel_weapon_skin)
	bot.configure(player, float(Settings.duel_rival_rating()), _bot_skin)
	bot.configure_arena(map)
	bot.set_match_score(player_score, bot_score)
	bot.position = spawn
	bots_root.add_child(bot)
	bot.active = false
	bot.died.connect(_on_bot_died)
	bot.damaged.connect(_on_bot_damaged)
	bot.player_hit.connect(_on_bot_player_hit)


func _update_header() -> void :


	hud.set_duel_header("РЕЙТИНГОВАЯ ДУЭЛЬ 1×1")




func _setup_duel_roster() -> void :
	var pool: Array = Settings.AVATARS
	if _bot_avatar_path.is_empty() and not pool.is_empty():
		var index: = randi() % pool.size()
		if index == Settings.avatar_index and pool.size() > 1:
			index = (index + 1) % pool.size()
		_bot_avatar_path = str(pool[index])
	var player_name: = Settings.nickname.strip_edges().to_upper()
	if player_name.is_empty():
		player_name = "ИГРОК"
	var bot_avatar: Texture2D = null
	if not _bot_avatar_path.is_empty():
		bot_avatar = load(_bot_avatar_path) as Texture2D
	hud.set_duel_roster(player_name, Settings.get_avatar_texture(), 
		_bot_display_name(), bot_avatar)
	hud.set_duel_bot_level(_bot_level(), Settings.duel_rival_rating())


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
	hud.restart_requested.connect(_restart_duel)
	hud.menu_requested.connect(_return_to_menu)
	hud.settings_requested.connect(_open_settings)
	hud.duel_menu_requested.connect(_return_to_menu)




func _begin_intro() -> void :
	if _intro_running:
		return
	_intro_running = true
	phase = Phase.INTRO
	player.active = false
	if is_instance_valid(bot):
		bot.active = false



	if not _weapon_intro_shown:
		_weapon_intro_shown = true
		await hud.show_duel_weapon_roll(duel_weapon_id)
		if not is_inside_tree() or phase != Phase.INTRO:
			_intro_running = false
			return

	for step in ["3", "2", "1"]:
		if not is_inside_tree() or phase != Phase.INTRO:
			_intro_running = false
			return
		hud.set_countdown(step)
		Sfx.play_tick()
		await get_tree().create_timer(INTRO_STEP, false).timeout

	if not is_inside_tree() or phase != Phase.INTRO:
		_intro_running = false
		return
	hud.set_countdown("БОЙ")
	Sfx.play_start()
	await get_tree().create_timer(0.42, false).timeout

	if not is_inside_tree() or phase != Phase.INTRO:
		_intro_running = false
		return
	hud.hide_duel_intro()
	player.active = true
	if is_instance_valid(bot):
		bot.active = true
	phase = Phase.LIVE
	_intro_running = false




func _on_player_shot(hit: Dictionary) -> void :
	if phase != Phase.LIVE:
		return
	shots_fired += 1
	var zone: = str(hit.get("zone", "body"))
	var headshot: = bool(hit.get("headshot", false))
	if not bool(hit.get("mannequin", false)):
		hud.kick_crosshair(1.6)
		return

	shots_hit += 1
	_last_player_zone = zone
	var weapon: = str(hit.get("weapon", "awp"))
	_last_player_weapon = weapon


	var info: = WeaponData.get_weapon(weapon)
	var damage: = float(info.get("damage_body", AWP_DAMAGE_BODY))
	if zone == "head":
		damage = float(info.get("damage_head", AWP_DAMAGE_HEAD))
		headshot_count += 1
	elif zone == "legs":
		damage = float(info.get("damage_legs", AWP_DAMAGE_LEGS))
	damage_dealt += damage

	var target: = _hit_target(hit)
	if target != null and target.has_method("take_hit"):
		target.call("take_hit", zone, player.global_position, damage)
	hud.flash_hit(headshot)
	hud.kick_crosshair(6.5 if headshot else 3.0)
	if headshot:
		Sfx.play_headshot()
	else:
		Sfx.play_hit()


func _on_player_melee(hit: Dictionary) -> void :
	if phase != Phase.LIVE:
		return
	if not bool(hit.get("mannequin", false)):
		hud.kick_crosshair(1.4)
		return
	var zone: = str(hit.get("zone", "body"))
	_last_player_zone = zone
	_last_player_weapon = "knife"
	var target: = _hit_target(hit)
	if target != null and target.has_method("take_damage"):
		var damage: = KNIFE_DAMAGE_BODY
		if zone == "head":
			damage = KNIFE_DAMAGE_HEAD
		elif zone == "legs":
			damage = KNIFE_DAMAGE_LEGS
		damage_dealt += damage
		target.call("take_damage", damage, zone)
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
	var target: Variant = collider.get("mannequin")
	return target as Node


func _on_player_health(health: float, max_health: float) -> void :
	hud.set_health(health, max_health)


func _on_player_damaged(amount: float, _from_position: Vector3) -> void :
	damage_taken += amount
	hud.flash_damage()
	hud.kick_crosshair(4.5)


func _on_ammo_changed(ammo: int, magazine: int, reloading: bool) -> void :
	hud.set_ammo({"ammo": ammo, "magazine": magazine, "reloading": reloading})


func _on_weapon_changed(ammo: Dictionary) -> void :
	hud.set_ammo(ammo)
	hud.kick_crosshair(2.0)




func _on_bot_damaged(_amount: float, _health: float) -> void :


	pass


func _on_bot_player_hit(zone: String, _lethal: bool) -> void :
	_bot_last_zone = zone


func _on_bot_died(dead_bot: Node3D) -> void :
	if phase != Phase.LIVE:
		return


	if dead_bot != null and is_instance_valid(dead_bot):
		var colors: Dictionary = {}
		if dead_bot.has_method("ragdoll_palette"):
			var value: Variant = dead_bot.call("ragdoll_palette")
			if value is Dictionary:
				colors = value as Dictionary
		if dead_bot.has_method("hide_for_ragdoll"):
			dead_bot.call("hide_for_ragdoll")
		_spawn_ragdoll("FallenBot", dead_bot.global_transform, colors, 
			player.global_position, null)
	hud.add_duel_killfeed(true, _player_display_name(), _bot_display_name(), 
		_last_player_weapon, _last_player_zone == "head")
	player_score += 1
	_finish_round(true)


func _on_player_died() -> void :
	if phase != Phase.LIVE:
		return
	hud.add_duel_killfeed(false, _player_display_name(), _bot_display_name(), 
		duel_weapon_id, _bot_last_zone == "head")
	bot_score += 1
	_finish_round(false)


func _player_display_name() -> String:
	var nickname: = Settings.nickname.strip_edges().to_upper()
	return nickname if not nickname.is_empty() else "ИГРОК"


func _bot_level() -> int:
	return Settings.duel_rival_level()




func _bot_display_name() -> String:
	return Settings.duel_rival_display_name()


func _finish_round(player_won: bool) -> void :
	phase = Phase.ROUND_END
	player.active = false
	if is_instance_valid(bot):
		bot.active = false
	player.exit_scope()
	hud.set_duel_score(player_score, bot_score, ROUNDS_TO_WIN)
	var match_over: = player_score >= ROUNDS_TO_WIN or bot_score >= ROUNDS_TO_WIN

	if player_won:
		if match_over:
			hud.show_duel_banner("ПОБЕДА", Color(0.42, 1.0, 0.56, 1.0))
			Sfx.play_victory()
			_slowmo(0.45, 0.85)
		else:
			hud.show_duel_banner("РАУНД ЗА ВАМИ", 
				Color(0.42, 1.0, 0.56, 1.0))
			Sfx.play_finish()
			_slowmo(0.52, 0.55)
		await _wait(ROUND_DELAY_WIN)
	else:
		player.set_combat_visible(false)
		hud.flash_damage(1.0)
		hud.show_death_fx()
		_spawn_death_body()
		_detach_death_camera()
		_slowmo(0.32, 0.85)
		await _wait(0.68)
		if match_over:
			hud.show_duel_banner("ПОРАЖЕНИЕ", Color(1.0, 0.28, 0.24, 1.0))
			Sfx.play_defeat()
		else:


			var rival_name: = _bot_display_name()
			var loss_text: = "РАУНД ЗА СОПЕРНИКОМ"
			if not rival_name.is_empty() and rival_name != "БОТ":
				loss_text = "РАУНД ЗА %s" % rival_name
			hud.show_duel_banner(loss_text, 
				Color(1.0, 0.28, 0.24, 1.0))
		await _wait(ROUND_DELAY_LOSS - 0.68)

	if not is_inside_tree():
		return
	if match_over:
		_finish_match(player_won)
	else:
		_next_round()


func _finish_match(won: bool) -> void :
	phase = Phase.ENDED
	Engine.time_scale = 1.0
	hud.set_duel_match_over(player_score, bot_score)
	_apply_result(won)
	await _wait(0.35)
	if not is_inside_tree():
		return
	_open_result()



func _next_round() -> void :
	_round_token += 1
	var token: = _round_token
	await hud.fade_out(0.18)
	if token != _round_token or not is_inside_tree():
		return
	_reset_round()
	await hud.fade_in(0.18)
	if token != _round_token or not is_inside_tree():
		return
	_begin_intro()


func _reset_round() -> void :
	Engine.time_scale = 1.0
	_restore_death_camera()
	_clear_death_body()
	hud.clear_duel_fx()
	player.reset_round_state()
	player.active = false
	_spawn_bot()
	_update_header()
	hud.show_health_panel(true)
	hud.set_health(PLAYER_MAX_HEALTH, PLAYER_MAX_HEALTH)
	hud.set_rating(Settings.rating_elo, Settings.rating_level(), 
		Settings.rating_level_name())
	hud.set_duel_score(player_score, bot_score, ROUNDS_TO_WIN)
	hud.set_ammo(player.get_ammo_state())
	hud.set_scope(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _wait(seconds: float) -> void :
	if seconds <= 0.0:
		return
	await get_tree().create_timer(seconds, false).timeout




func _apply_result(won: bool) -> void :
	if _result_applied:
		return
	_result_applied = true
	var opponent: = int(bot.skill_elo) if is_instance_valid(bot) else 0
	var stats: = {
		"shots": shots_fired, 
		"hits": shots_hit, 
		"headshots": headshot_count, 
		"damage": damage_dealt, 
		"damage_taken": damage_taken, 
		"rounds_won": player_score, 
		"rounds_lost": bot_score, 
	}
	_result_data = Settings.apply_duel_result(won, opponent, stats)
	_result_data["rounds_won"] = player_score
	_result_data["rounds_lost"] = bot_score
	hud.set_rating(Settings.rating_elo, Settings.rating_level(), 
		Settings.rating_level_name())


func _open_result() -> void :
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_duel_result(_result_data)


func _slowmo(scale: float, duration: float) -> void :
	Engine.time_scale = scale
	await get_tree().create_timer(duration, true, false, true).timeout
	if is_inside_tree():
		Engine.time_scale = 1.0







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


func _clear_death_body() -> void :
	for child in get_children():
		if child.name.begins_with("Fallen"):
			child.queue_free()




func _spawn_ragdoll(tag: String, at: Transform3D, colors: Dictionary, 
		from: Vector3, ignore: PhysicsBody3D) -> void :
	var body: = RagdollScript.new()
	body.name = tag
	body.palette = colors
	body.impulse_from = from
	body.exclude = ignore
	add_child(body)
	body.global_transform = at


func _process(_delta: float) -> void :
	if player != null and hud != null:
		hud.set_reload_progress(player.get_reload_progress(), 
			player.get_reload_remaining())
	if _death_camera:



		var offset: Vector3 = player.camera.global_position - _death_look
		if Vector2(offset.x, offset.z).length_squared() > 0.0625:
			player.camera.look_at(_death_look, Vector3.UP)





func _spawn_death_body() -> void :
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
	var from: Vector3 = player.global_position - Vector3(0.0, 0.0, 1.0)
	if is_instance_valid(bot):
		from = bot.global_position
	_spawn_ragdoll("FallenPlayer", player.global_transform, colors, from, 
		player as PhysicsBody3D)




func _apply_environment() -> void :
	if world_environment != null and world_environment.environment != null:
		Settings.apply_environment(world_environment.environment)




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




func _unhandled_input(event: InputEvent) -> void :
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
	if is_instance_valid(bot):
		bot.active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
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
	player.active = phase == Phase.LIVE
	if is_instance_valid(bot):
		bot.active = phase == Phase.LIVE
	if world_view != null:
		world_view.set_paused(false)
	hud.hide_pause()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED




func _restart_duel() -> void :
	if _transitioning:
		return
	_transitioning = true
	_register_abandon()
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
	_register_abandon()
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





func _register_abandon(notify: = true) -> void :
	if _abandon_checked or _result_applied:
		return
	if phase == Phase.ENDED:
		return
	_abandon_checked = true

	if DisplayServer.get_name() == "headless":
		return
	Settings.apply_duel_abandon(notify)


func _notification(what: int) -> void :
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_register_abandon(false)
		Settings.save_settings()


func _exit_tree() -> void :
	Engine.time_scale = 1.0


	_register_abandon(false)
	Settings.save_settings()
