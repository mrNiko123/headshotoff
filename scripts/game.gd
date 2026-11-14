extends Node3D



const MANNEQUIN_SCENE = preload("res://scenes/mannequin.tscn")
const MENU_SCENE: = "res://main_menu.tscn"
const GameSettingsScript = preload("res://scripts/game_settings.gd")
const WorldViewScript = preload("res://scripts/world_view.gd")
const WorldTint = preload("res://scripts/world_tint.gd")
const WorldTintShader = preload("res://shaders/world_tint.gdshader")
const MapData = preload("res://scripts/map_data.gd")

enum State{RUNNING, PAUSED}

var state: = State.RUNNING
var score: = 0
var shots: = 0
var hits: = 0
var kills: = 0
var headshots: = 0
var _settings

var _transitioning: = false
var _mannequins: Array[Node3D] = []
var _last_bounce_toast: = 0
var _session_time: = 0.0
var _buy_menu: CanvasLayer




const HIT_LIGHT_POOL: = 5


const HIT_LIGHT_FADE: = 0.14
var _hit_lights: Array[OmniLight3D] = []
var _hit_light_index: = 0
var _hit_light_time: PackedFloat32Array = PackedFloat32Array()
var _hit_light_peak: PackedFloat32Array = PackedFloat32Array()

@onready var player = $Player
@onready var hud = $HUD


var map: Node3D
var world_environment: WorldEnvironment


var _sun: DirectionalLight3D
var _sun_default_shadow: = false
var _applied_effects_quality: = -1


var world_view
@onready var mannequins_root: Node3D = $Mannequins

var _world_tint_mat: ShaderMaterial


func _ready() -> void :
	randomize()
	_load_selected_arena()
	_setup_world_view()
	_apply_world_tint()
	_setup_buy_menu()
	player.shot_fired.connect(_on_player_shot)
	player.melee_hit.connect(_on_player_melee)
	player.weapon_changed.connect(_on_weapon_changed)
	player.wall_jumped.connect(_on_wall_jumped)
	player.bounced.connect(_on_bounced)
	player.slide_boosted.connect(_on_slide_boosted)
	player.spawned_mannequin_requested.connect(_on_spawn_mannequin)
	player.landed.connect(_on_player_landed)
	player.ammo_changed.connect(_on_ammo_changed)
	player.scope_changed.connect(hud.set_scope)
	hud.resume_requested.connect(_resume)
	hud.restart_requested.connect(_reset_session)
	hud.menu_requested.connect(_return_to_menu)
	hud.settings_requested.connect(_open_settings)
	Settings.settings_changed.connect(_apply_environment)
	Settings.settings_changed.connect(_apply_quality_lighting)
	Settings.settings_changed.connect(_apply_world_tint)

	for i in Settings.mannequin_count:
		_spawn_mannequin(_pick_spawn_point(player.global_position))

	_build_hit_light_pool()
	_apply_environment()
	_apply_quality_lighting()
	_update_stats_hud()
	hud.set_ammo(player.get_ammo_state())
	hud.set_scope(false)
	hud.set_movement(0.0, 0, true)
	hud.set_session_time(_session_time)
	hud.update_scoreboard(_mannequins.size())

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Sfx.play_start()




func _load_selected_arena() -> void :
	var path: = MapData.arena_path(Settings.map_id)
	var current: = get_node_or_null("Arena") as Node3D
	if current != null and current.scene_file_path != path:
		var scene: = load(path) as PackedScene
		if scene != null:
			var replacement: = scene.instantiate() as Node3D
			if replacement != null:
				replacement.name = "Arena"
				remove_child(current)
				current.queue_free()
				add_child(replacement)
				move_child(replacement, 0)
				current = replacement
	if current == null:
		return
	map = current.get_node_or_null("Map") as Node3D
	world_environment = current.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_sun = current.get_node_or_null("Sun") as DirectionalLight3D
	_sun_default_shadow = _sun != null and _sun.shadow_enabled
	_applied_effects_quality = -1
	if map != null:
		_place_player(map.get("player_start"))


func _place_player(start: Variant) -> void :
	if start is Vector3:
		player.global_position = start
		player.velocity = Vector3.ZERO




func _setup_world_view() -> void :
	world_view = WorldViewScript.new()
	world_view.name = "WorldView"
	add_child(world_view)
	world_view.setup(player.camera)


func _process(delta: float) -> void :
	if state != State.RUNNING:
		return
	_animate_hit_lights(delta)
	_session_time += delta
	var speed: float = player.get_speed()
	hud.set_session_time(_session_time)
	hud.set_movement(speed, player.get_bhop_chain(), player.is_on_floor())
	hud.set_spread(player.get_spread_scale())
	hud.set_reload_progress(player.get_reload_progress(), 
		player.get_reload_remaining())
	hud.update_scoreboard(_mannequins.size())


	if speed > Settings.best_speed:
		Settings.record_speed(speed)


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


func _input(event: InputEvent) -> void :
	# B (магазин) обрабатываем в _input: _unhandled_input может не получить
	# событие, если его перехватил другой Control/оверлей.
	if _buy_menu != null and _buy_menu.handle_key(event):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause"):
		if state == State.RUNNING:
			_pause()
			get_viewport().set_input_as_handled()
		elif state == State.PAUSED:
			_resume()
			get_viewport().set_input_as_handled()


func _setup_buy_menu() -> void :
	var menu: = preload("res://scripts/buy_menu.gd").new()
	add_child(menu)
	menu.weapon_picked.connect(_on_buy_menu_pick)
	_buy_menu = menu


func _on_buy_menu_pick(weapon_id: String, skin_id: String) -> void :
	if player != null:
		player.set_duel_weapon(weapon_id, skin_id)


func _on_player_shot(hit: Dictionary) -> void :
	if state != State.RUNNING:
		return

	shots += 1
	var is_mannequin: = bool(hit.get("mannequin", false))
	var headshot: = bool(hit.get("headshot", false))
	var killed: = false
	var zone: = str(hit.get("zone", "body"))
	var position: Vector3 = hit.get("position", Vector3.ZERO)

	if is_mannequin:
		hits += 1
		var collider: Object = hit.get("collider")
		if collider != null:
			var mannequin: Node = collider.get("mannequin")
			if mannequin != null and mannequin.has_method("take_hit"):
				killed = bool(mannequin.call("take_hit", zone, 
					float(hit.get("damage", 999.0))))
		score += 3 if headshot else 1
		if killed:
			kills += 1
			hud.register_kill(kills, headshot)
		if headshot:
			headshots += 1
		hud.flash_hit(headshot)
		hud.kick_crosshair(6.5 if headshot else 3.0)


		if Settings.effects_quality >= 2:
			_spawn_hit_light(position, headshot)
		if headshot:
			Sfx.play_headshot()
		else:
			Sfx.play_hit()


		if killed:
			hud.add_killfeed(hit, true)
	else:
		hud.kick_crosshair(1.6)

	Settings.record_shot(is_mannequin, headshot and is_mannequin, killed)
	_update_stats_hud()


func _on_player_melee(hit: Dictionary) -> void :
	if state != State.RUNNING:
		return
	if not bool(hit.get("mannequin", false)):
		hud.kick_crosshair(1.4)
		return

	var zone: = str(hit.get("zone", "body"))
	var headshot: = zone == "head"
	var killed: = false
	var collider: Object = hit.get("collider")
	if collider != null:
		var mannequin: Node = collider.get("mannequin")
		if mannequin != null and mannequin.has_method("take_hit"):
			killed = bool(mannequin.call("take_hit", zone, 
				float(hit.get("damage", 999.0))))

	score += 3 if headshot else 1
	if killed:
		kills += 1
		hud.register_kill(kills, headshot)
	if headshot:
		headshots += 1
	hud.flash_hit(headshot)
	hud.kick_crosshair(6.0 if headshot else 3.0)
	var position: Vector3 = hit.get("position", Vector3.ZERO)
	if Settings.effects_quality >= 2:
		_spawn_hit_light(position, headshot)
	if headshot:
		Sfx.play_headshot()
	else:
		Sfx.play_hit()
	if killed:
		hud.add_killfeed(hit, true)
	Settings.record_melee(killed, headshot)
	_update_stats_hud()


func _on_weapon_changed(ammo: Dictionary) -> void :
	hud.set_ammo(ammo)
	hud.kick_crosshair(2.0)


func _on_wall_jumped() -> void :
	if _toast_ready():
		hud.toast("ОТСКОК ОТ СТЕНЫ  ·  WALL JUMP")


func _on_bounced(_strength: float) -> void :
	if _toast_ready():
		hud.toast("ОТТОЛКНУЛСЯ ОТ ПЛОЩАДКИ")


func _on_slide_boosted(strength: float) -> void :
	if _toast_ready():
		hud.toast("SLIDE BOOST  +%.0f" % strength)


func _toast_ready() -> bool:
	var now: = Time.get_ticks_msec()
	if now - _last_bounce_toast < 900:
		return false
	_last_bounce_toast = now
	return true


func _update_stats_hud() -> void :
	var accuracy: = 0.0
	if shots > 0:
		accuracy = float(hits) / float(shots) * 100.0
	hud.set_score(score)
	hud.set_accuracy(accuracy)
	hud.set_counters(kills, headshots, shots, hits)


func _on_ammo_changed(ammo: int, magazine: int, reloading: bool) -> void :
	hud.set_ammo({"ammo": ammo, "magazine": magazine, "reloading": reloading})


func _on_player_landed(_impact_speed: float) -> void :
	pass


func _on_spawn_mannequin() -> void :
	if state != State.RUNNING:
		return
	if _mannequins.size() >= 24:
		hud.toast("Лимит манекенов: 24")
		return
	var point: = _find_front_spawn()
	_spawn_mannequin(point)
	hud.toast("Манекен заспавнен" if Settings.is_mobile()
		else "Манекен заспавнен  ·  M")


func _spawn_mannequin(point: Vector3) -> void :
	if not is_instance_valid(map):
		return
	var mannequin: = MANNEQUIN_SCENE.instantiate()
	mannequins_root.add_child(mannequin)
	mannequin.connect("died", _on_mannequin_died)
	mannequin.call("respawn_at", point, player.global_position)
	_mannequins.append(mannequin)


func _on_mannequin_died(mannequin: Node3D, _zone: String, _world_position: Vector3) -> void :


	_respawn_later(mannequin)


func _respawn_later(mannequin: Node3D) -> void :
	await get_tree().create_timer(1.15).timeout
	if not is_instance_valid(mannequin) or state != State.RUNNING:
		return
	mannequin.call("respawn_at", _pick_spawn_point(player.global_position), player.global_position)


func _pick_spawn_point(avoid: Vector3) -> Vector3:
	var points: Array = map.get("spawn_points")
	if points == null or points.is_empty():
		return avoid + Vector3(0.0, 0.1, -8.0)

	var candidates: Array[Vector3] = []
	for p in points:
		var point: Vector3 = p
		if point.distance_to(avoid) < 7.0:
			continue
		var too_close: = false
		for m in _mannequins:
			if is_instance_valid(m) and m.global_position.distance_to(point) < 2.2:
				too_close = true
				break
		if not too_close:
			candidates.append(point)
	if candidates.is_empty():
		for p in points:
			candidates.append(p)
	return candidates[randi() % candidates.size()]


func _find_front_spawn() -> Vector3:
	var forward: Vector3 = - player.camera.global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() < 0.01:
		forward = Vector3.FORWARD
	forward = forward.normalized()
	var base: Vector3 = player.global_position + forward * 7.5
	var space: = get_world_3d().direct_space_state
	var query: = PhysicsRayQueryParameters3D.create(base + Vector3.UP * 5.0, 
		base + Vector3.DOWN * 6.0, 1)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [player.get_rid()]
	var result: = space.intersect_ray(query)
	if not result.is_empty():
		var pos: Vector3 = result.get("position", base)
		return pos + Vector3(0.0, 0.03, 0.0)
	return _pick_spawn_point(player.global_position)


func _spawn_hit_light(world_position: Vector3, headshot: bool) -> void :
	if _hit_lights.is_empty():
		return
	var index: = _hit_light_index
	var light: = _hit_lights[index]
	_hit_light_index = (index + 1) % _hit_lights.size()
	light.global_position = world_position
	light.light_color = Color(1.0, 0.58, 0.2, 1.0) if headshot else Color(1.0, 0.72, 0.42, 1.0)
	var energy: = 3.6 if headshot else 2.2
	light.light_energy = energy
	light.visible = true
	_hit_light_time[index] = 0.0
	_hit_light_peak[index] = energy




func _animate_hit_lights(delta: float) -> void :
	for i in _hit_lights.size():
		var light: = _hit_lights[i]
		if not light.visible:
			continue
		_hit_light_time[i] += delta
		var k: = _hit_light_time[i] / HIT_LIGHT_FADE
		if k >= 1.0:
			light.light_energy = 0.0
			light.visible = false
		else:
			light.light_energy = _hit_light_peak[i] * (1.0 - k)


func _clear_hit_lights() -> void :
	for i in _hit_lights.size():
		_hit_lights[i].light_energy = 0.0
		_hit_lights[i].visible = false
		_hit_light_time[i] = 0.0
		_hit_light_peak[i] = 0.0


func _build_hit_light_pool() -> void :
	_hit_light_time.resize(HIT_LIGHT_POOL)
	_hit_light_peak.resize(HIT_LIGHT_POOL)
	for i in HIT_LIGHT_POOL:
		var light: = OmniLight3D.new()
		light.name = "HitLightPool%d" % i
		light.omni_range = 2.6
		light.light_energy = 0.0
		light.shadow_enabled = false

		light.visible = false
		add_child(light)
		_hit_lights.append(light)


func _pause() -> void :
	state = State.PAUSED
	player.active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_pause()

	if world_view != null:
		world_view.set_paused(true)
	Settings.save_settings()
	get_tree().paused = true


func _open_settings() -> void :
	if state != State.PAUSED:
		return
	if _settings == null or not is_instance_valid(_settings):
		_settings = GameSettingsScript.new()
		_settings.closed.connect(_on_settings_closed)
		add_child(_settings)
	_settings.open()


func _on_settings_closed() -> void :
	hud.show_pause()


func _resume() -> void :
	if state != State.PAUSED:
		return

	if _settings != null and is_instance_valid(_settings) and _settings.visible:
		_settings.close()
		return
	get_tree().paused = false
	state = State.RUNNING
	player.active = true
	if world_view != null:
		world_view.set_paused(false)
	hud.hide_pause()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _reset_session() -> void :
	if _settings != null and is_instance_valid(_settings):
		_settings.close()
	get_tree().paused = false
	state = State.RUNNING
	player.active = true
	if world_view != null:
		world_view.set_paused(false)
	score = 0
	shots = 0
	hits = 0
	kills = 0
	headshots = 0
	_session_time = 0.0
	_clear_hit_lights()
	_update_stats_hud()
	hud.set_session_time(0.0)
	hud.hide_pause()
	hud.toast("Сессия сброшена")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for m in _mannequins:
		if is_instance_valid(m):
			m.call("respawn_at", _pick_spawn_point(player.global_position), player.global_position)


func _return_to_menu() -> void :
	if _transitioning:
		return
	_transitioning = true
	if _settings != null and is_instance_valid(_settings):
		_settings.visible = false
	Settings.save_settings()
	player.active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	if world_view != null:
		world_view.set_paused(false)
	await hud.fade_out()
	get_tree().change_scene_to_file(MENU_SCENE)


func _exit_tree() -> void :
	Settings.save_settings()
