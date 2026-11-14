extends CharacterBody3D



























signal died(bot: Node3D)
signal damaged(amount: float, health: float)


signal player_hit(zone: String, lethal: bool)

const MeshKit = preload("res://scripts/mesh_kit.gd")
const HitboxScript = preload("res://scripts/mannequin_hitbox.gd")
const WeaponBuilder = preload("res://scripts/weapon_builder.gd")



const WeaponData = preload("res://scripts/weapon_data.gd")

const MAX_HEALTH: = 100.0
const GRAVITY: = 23.5
const EYE_HEIGHT: = 1.62
const CROUCH_EYE_HEIGHT: = 1.05
const STAND_CAPSULE_HEIGHT: = 1.8
const CROUCH_CAPSULE_HEIGHT: = 1.24
const CROUCH_SPEED_SCALE: = 0.52
const CROUCH_RATE: = 8.0
const TRACER_POOL: = 4


const AWP_BOLT_DELAY: = 0.22
const VIEW_HALF_ANGLE: = 100.0






const PERCEPTION_INTERVAL: = 0.05
const LOOK_CLEAR_INTERVAL: = 0.1

const BOT_STEP_MIN_INTERVAL: = 0.28

const LOOK_PROBES: = [0.0, 20.0, -20.0, 40.0, -40.0, 65.0, -65.0, 
	95.0, -95.0, 140.0, -140.0]




const BODY_SAMPLES: = [1.22, 1.4, 0.98, 0.72, 0.42, 1.62]



const PERSONA_PATIENT: = 0
const PERSONA_BALANCED: = 1
const PERSONA_AGGRESSIVE: = 2





enum State{SEEK, HOLD, PEEK, ENGAGE, REPOSITION, HUNT, PARKOUR, DEAD}

var player: Node3D
var skill_elo: = 1000.0
var skin: = "forest"

var weapon_id: = "awp"
var weapon_skin: = "default"
var active: = true
var health: = MAX_HEALTH
var alive: = true

var _state: = State.SEEK
var _state_time: = 0.0



var _logic_accum: = 0.0
const LOGIC_INTERVAL: = 1.0 / 60.0


var _prev_xform: = Transform3D.IDENTITY
var _curr_xform: = Transform3D.IDENTITY
var _visible: = false
var _was_visible: = false
var _last_seen: = Vector3.ZERO
var _last_seen_time: = 99.0
var _reaction_timer: = 0.0
var _think_timer: = 0.0
var _scan_timer: = 0.0
var _hold_timer: = 1.0
var _peek_timer: = 1.2
var _reposition_timer: = 1.2
var _engage_limit: = 1.6
var _engage_time: = 0.0
var _reposition_lock: = 0.0
var _strafe_sign: = 1.0
var _strafe_timer: = 0.0
var _peek_side: = 1.0
var _stuck_time: = 0.0
var _last_position: = Vector3.ZERO




var _perception_timer: = 0.0
var _look_clear_timer: = 0.0
var _look_clear_point: = Vector3.ZERO
var _look_raw_last: = Vector3.ZERO
var _ray_query: PhysicsRayQueryParameters3D


var _visible_height: = 1.22


var _direct_check_timer: = 0.0
var _direct_clear: = false
var _direct_target: = Vector3.ZERO
var _direct_from: = Vector3.ZERO



var _route_check_timer: = 0.0
var _route_clear: = false
var _route_point: = Vector3.ZERO
var _route_from: = Vector3.ZERO




var _crouched: = false
var _crouch_blend: = 0.0
var _crouch_timer: = 0.0
var _crouch_decision: = 0.0
var _crouch_applied: = -1.0
var _eye_height: = EYE_HEIGHT
var _collision: CollisionShape3D
var _capsule: CapsuleShape3D
var _hitbox_base: Dictionary = {}
var _label_base_y: = 2.1

var _hold_side: = 1.0
var _hold_point: = Vector3.ZERO
var _peek_point: = Vector3.ZERO
var _hunt_point: = Vector3.ZERO


var arena_map: Node3D
var _hold_points: Array[Vector3] = []
var _peek_points: Array[Vector3] = []
var _hunt_points: Array[Vector3] = []
var _jump_pads: Array[Vector3] = []
var _parkour_landing: = Vector3.ZERO
var _nav_points: Array[Vector3] = []
var _nav_adj: Dictionary = {}
var _path: Array[Vector3] = []
var _path_index: = 0
var _path_goal: = Vector3.ZERO
var _parkour_point: = Vector3.ZERO
var _launch_lock: = 0.0
var _jump_cooldown: = 0.0
var _hop_timer: = 0.0
var _parkour_cooldown: = 0.0


var _high_ground_timer: = 0.0
var _aggression: = 0.5



var _base_aggression: = 0.5
var _score_behind: = false
var _skill_t: = 0.0


var _lead_time: = 0.05


var _retreat_timer: = 0.0
var _miss_streak: = 0



var _trade_window: = 0.0



var _near_miss_cooldown: = 0.0



var _heard_point: = Vector3.ZERO
var _heard_timer: = 99.0
var _heard_cooldown: = 0.0


var _noise_cooldown: = 0.0


var _scope_sound_on: = false


var _reaction_time: = 0.3
var _aim_speed: = 7.5
var _shot_spread: = 0.016
var _aim_error_distance: = 0.09
var _headshot_aim: = 0.28
var _move_speed: = 8.8
var _strafe_speed: = 5.4
var _jump_speed: = 7.4



var _fire_interval: = 1.32
var _reload_time: = 2.55
var _magazine: = 5
var _automatic: = false
var _bolt_delay: = AWP_BOLT_DELAY
var _settle_required: = 0.1
var _aim_settle: = 0.0

var _ammo: = 5
var _reloading: = false
var _reload_timer: = 0.0
var _bolt_timer: = 0.0
var _aim_offset: = Vector3.ZERO
var _aim_head: = false
var _aim_pitch: = 0.0
var _fall_dir: = 1.0
var _death_time: = -1.0


var _death_arm_left: = Vector3.ZERO
var _death_arm_right: = Vector3.ZERO
var _death_leg_left: = Vector3.ZERO
var _death_leg_right: = Vector3.ZERO
var _death_head: = Vector3.ZERO
var _death_weapon: = Vector3.ZERO
var _flash: = 0.0

var _visual: Node3D
var _hips: Node3D
var _torso: Node3D
var _upper: Node3D
var _head: Node3D
var _leg_left: Node3D
var _leg_right: Node3D
var _knee_left: Node3D
var _knee_right: Node3D
var _arm_left: Node3D
var _arm_right: Node3D
var _elbow_left: Node3D
var _elbow_right: Node3D
var _weapon_pivot: Node3D
var _weapon_visual: Node3D
var _weapon_root: Node3D
var _muzzle: Node3D



var _hand_grip_pos: = Vector3(0.02, -0.02, 0.03)
var _hand_support_pos: = Vector3(-0.04, 0.01, -0.19)
var _label: Label3D
var _materials: Array[StandardMaterial3D] = []



var _part_batches: Dictionary = {}


var _ragdoll_palette: Dictionary = {}
var _hitboxes: Array[Area3D] = []
var _tracers: Array[MeshInstance3D] = []
var _tracer_mats: Array[StandardMaterial3D] = []
var _tracer_time: PackedFloat32Array = PackedFloat32Array()
var _tracer_index: = 0
var _walk_phase: = 0.0
var _upper_base_y: = 0.5

var _idle_clock: = 0.0
var _target_yaw: = 0.0



var _target_pitch: = 0.0
var _recoil: = 0.0
var _reload_blend: = 0.0
var _weapon_base_pos: = Vector3(0.17, -0.12, -0.3)
var _weapon_base_rot: = Vector3(-3.0, 4.0, 2.0)


var _aim_weapon_pos: = Vector3(0.075, 0.075, -0.235)
var _aim_weapon_rot: = Vector3(-0.5, 1.0, 0.0)
var _aim_blend: = 0.0
var _lean: = 0.0
var _flinch: = 0.0
var _aim_line: MeshInstance3D
var _aim_line_mat: StandardMaterial3D
var _aim_point: = Vector3.ZERO
var _upper_aim_yaw: = 0.0
var _head_scan: = 0.0

var _personality: = PERSONA_BALANCED
var _aim_visual: = Vector3.ZERO


var _jiggle_peek: = 0.0
var _jiggle_total: = 0.34
var _jiggle_dir: = 1.0
var _jiggle_amp: = 0.5



var _spray_bloom: = 0.0
var _burst_left: = 0
var _burst_pause: = 0.0


var _burst_fresh: = false


var _aim_punch: = Vector3.ZERO


var _walking: = false

var _step_timer: = 0.0
var _was_on_floor: = true
var _tracer_active: = false
const ARM_L1: = 0.36
const ARM_L2: = 0.3
const ARM_RIGHT_POLE: = Vector3(0.55, -0.95, 0.3)
const ARM_LEFT_POLE: = Vector3(-0.55, -0.95, 0.22)




const SKINS: = ["forest", "desert", "trooper", "urban"]





func set_weapon(id: String, skin_id: = "") -> void :
	if not WeaponData.WEAPONS.has(id) or WeaponData.is_melee(id):
		return
	var skins: Dictionary = WeaponData.get_weapon(id).get("skins", {})
	var resolved: = skin_id
	if resolved.is_empty() or not skins.has(resolved):
		resolved = str(skins.keys()[0]) if not skins.is_empty() else "default"


	if weapon_id == id and weapon_skin == resolved and _weapon_pivot != null:
		return
	weapon_id = id
	weapon_skin = resolved
	_sync_weapon_data()
	_ammo = _magazine
	if _weapon_pivot != null:
		_rebuild_weapon()






func configure(target: Node3D, elo: float, look: = "", persona: = -1) -> void :
	player = target
	skill_elo = elo
	if look.is_empty() or not SKINS.has(look):
		skin = SKINS[randi() % SKINS.size()]
	else:
		skin = look
	if persona >= 0:
		_personality = clampi(persona, PERSONA_PATIENT, PERSONA_AGGRESSIVE)
	else:
		_personality = (SKINS.find(skin) + int(elo / 100.0)) % 3





func configure_arena(map_node: Node) -> void :
	arena_map = map_node as Node3D
	_hold_points = _read_points("bot_hold_points")
	_peek_points = _read_points("bot_peek_points")
	_hunt_points = _read_points("bot_hunt_points")
	_jump_pads = _read_points("bot_jump_pads")
	_nav_points = _read_points("bot_nav_points")
	var landing: Variant = map_node.get("bot_parkour_landing") if map_node != null else null
	if landing is Vector3:
		_parkour_landing = landing
	var links: Variant = map_node.get("bot_nav_links") if map_node != null else null
	_nav_adj.clear()
	for i in _nav_points.size():
		_nav_adj[i] = []
	if links is Array:
		for link in links:
			if link is Vector2i:
				var a: int = link.x
				var b: int = link.y
				if a >= 0 and b >= 0 and a < _nav_points.size() and b < _nav_points.size():
					var from_list: Array = _nav_adj[a]
					var to_list: Array = _nav_adj[b]
					from_list.append(b)
					to_list.append(a)
					_nav_adj[a] = from_list
					_nav_adj[b] = to_list
	_apply_difficulty()




func set_match_score(my_score: int, enemy_score: int) -> void :
	_score_behind = my_score < enemy_score
	var shift: = 0.0
	if my_score > enemy_score:
		shift = -0.08
	elif _score_behind:
		shift = 0.14


	_aggression = clampf(_base_aggression + shift, 0.26, 0.98)





func _on_player_shot(hit: Dictionary) -> void :
	if not alive or not active:
		return
	_react_to_near_miss(hit)
	_hear_shot(hit)
	if _retreat_timer > 0.0:
		return
	if _last_seen_time > 2.5:
		return
	if randf() < 0.3 + 0.45 * _skill_t:
		_trade_window = randf_range(0.35, 0.7)






func _react_to_near_miss(hit: Dictionary) -> void :
	if _near_miss_cooldown > 0.0:
		return
	if bool(hit.get("mannequin", false)):
		return
	var raw_from: Variant = hit.get("origin")
	var raw_to: Variant = hit.get("position")
	if not (raw_from is Vector3) or not (raw_to is Vector3):
		return
	var from: Vector3 = raw_from
	var to: Vector3 = raw_to
	var chest: = global_position + Vector3.UP * 1.1
	var closest: = Geometry3D.get_closest_point_to_segment(chest, from, to)
	if closest.distance_squared_to(chest) > 1.44:
		return
	_near_miss_cooldown = 0.5
	_aim_settle = 0.0


	_aim_punch += Vector3(
		randf_range(-0.08, 0.08), 
		randf_range(0.0, 0.05), 
		randf_range(-0.08, 0.08))
	_aim_visual += Vector3(
		randf_range(-0.07, 0.07), 
		randf_range(-0.02, 0.02), 
		randf_range(-0.07, 0.07))
	if randf() < 0.3 + 0.3 * _skill_t:
		_retreat_timer = maxf(_retreat_timer, randf_range(0.18, 0.42))
		_strafe_sign = - _strafe_sign






func _hear_shot(hit: Dictionary) -> void :
	if _heard_cooldown > 0.0:
		return
	var raw: Variant = hit.get("origin")
	if not (raw is Vector3):
		return
	var origin: Vector3 = raw
	if origin.distance_squared_to(global_position) > 3600.0:
		return
	var error: = lerpf(3.2, 0.9, _skill_t)
	_heard_point = origin + Vector3(
		randf_range( - error, error), 0.0, randf_range( - error, error))
	_heard_timer = 0.0
	_heard_cooldown = randf_range(1.6, 2.6)


	if _last_seen_time < 0.9 or _state == State.ENGAGE\
	or _state == State.PARKOUR or _state == State.DEAD:
		return
	if randf() < 0.32 + 0.46 * _skill_t:
		_set_state(State.HUNT)
		_hunt_point = _heard_point







func _on_player_noise(kind: String, origin: Vector3, loudness: float) -> void :
	if not alive or not active:
		return
	if _noise_cooldown > 0.0:
		return
	var distance: = origin.distance_to(global_position)
	var base_range: = 12.0
	match kind:
		"step":
			base_range = 13.0
		"jump":
			base_range = 15.0
		"wall_jump", "bounce", "slide":
			base_range = 18.0
		"land":
			base_range = 17.0
		"reload":
			base_range = 24.0
		"scope":
			base_range = 9.0
		"knife":
			base_range = 8.0


	var hearing: = base_range * lerpf(0.78, 1.18, _skill_t)\
	* clampf(0.45 + loudness, 0.45, 1.45)
	if distance > hearing:
		return
	var proximity: = 1.0 - clampf(distance / maxf(hearing, 0.01), 0.0, 1.0)
	var notice: = lerpf(0.24, 0.94, proximity)\
	* lerpf(0.72, 1.0, _skill_t)\
	* clampf(0.7 + loudness * 0.55, 0.7, 1.25)
	if randf() > notice:
		return
	_noise_cooldown = randf_range(0.16, 0.3) if kind == "step"\
	else randf_range(0.22, 0.42)
	var error: = lerpf(4.2, 1.1, _skill_t) * (1.0 - proximity * 0.55)
	error += randf_range(0.0, 1.2)
	_heard_point = origin + Vector3(
		randf_range( - error, error), 0.0, randf_range( - error, error))
	_heard_timer = 0.0



	if _last_seen_time < 0.8 or _state == State.ENGAGE\
	or _state == State.PARKOUR or _state == State.DEAD:
		if kind == "reload" and _last_seen_time < 2.5\
		and _retreat_timer <= 0.0\
		and randf() < 0.45 + 0.35 * _skill_t:
			_trade_window = maxf(_trade_window, randf_range(0.4, 0.8))
		return
	if _state == State.HOLD or _state == State.PEEK:


		_aim_visual += Vector3(
			randf_range(-0.04, 0.04), 0.0, randf_range(-0.04, 0.04))
	if _state == State.HUNT:


		_hunt_point = _heard_point
		return
	if kind == "reload":

		if randf() < 0.34 + 0.3 * _skill_t:
			_hunt_point = _heard_point
			_set_state(State.HUNT)
	elif randf() < 0.26 + 0.34 * _skill_t + _aggression * 0.12:
		_hunt_point = _heard_point
		_set_state(State.HUNT)


func _read_points(key: String) -> Array[Vector3]:
	var points: Array[Vector3] = []
	if arena_map == null:
		return points
	var raw: Variant = arena_map.get(key)
	if raw is Array:
		for value in raw:
			if value is Vector3:
				points.append(value)
	return points


func _ready() -> void :
	add_to_group("duel_bot")
	_sync_weapon_data()
	_ammo = _magazine
	if player != null and player.has_signal("shot_fired"):
		player.connect("shot_fired", _on_player_shot)
	if player != null and player.has_signal("noise_made"):
		player.connect("noise_made", _on_player_noise)
	_apply_difficulty()
	_build_collision()
	_build_visual()
	_build_hitboxes()
	_build_tracers()
	_build_label()
	_choose_hold(true)
	velocity = Vector3.ZERO
	_last_position = global_position
	if player != null:
		var flat: = player.global_position - global_position
		flat.y = 0.0
		if flat.length_squared() > 0.01:
			rotation.y = atan2( - flat.x, - flat.z)
	_set_state(State.HOLD)






func _sync_weapon_data() -> void :
	var info: = WeaponData.get_weapon(weapon_id)
	_fire_interval = maxf(float(info.get("fire_rate", 1.32)), 0.02)
	_reload_time = maxf(float(info.get("reload_time", 2.55)), 0.1)
	_magazine = maxi(int(info.get("magazine", 5)), 1)
	_automatic = bool(info.get("automatic", false))
	_bolt_delay = 0.0 if _automatic else AWP_BOLT_DELAY
	_ammo = clampi(_ammo, 0, _magazine)








func _apply_difficulty() -> void :

	var p: = 1.0 - exp( - maxf(skill_elo - 700.0, 0.0) / 1500.0)




	var elite: = 0.0
	if skill_elo > 3000.0:
		elite = 1.0 - exp( - (skill_elo - 3000.0) / 9000.0)
	_skill_t = clampf(p + 0.12 * elite, 0.0, 1.0)
	_reaction_time = lerpf(0.33, 0.1, p) - 0.015 * elite
	_aim_speed = lerpf(6.8, 17.0, p) + 3.0 * elite
	_shot_spread = lerpf(0.018, 0.0028, p) - 0.001 * elite
	_aim_error_distance = lerpf(0.1, 0.012, p) - 0.005 * elite
	_headshot_aim = lerpf(0.24, 0.96, p)



	if weapon_id == "awp":
		_headshot_aim = lerpf(0.1, 0.32, p) + 0.05 * elite
	_move_speed = lerpf(8.6, 9.6, p) + 0.25 * elite
	_strafe_speed = lerpf(5.0, 6.6, p) + 0.3 * elite
	_jump_speed = lerpf(7.0, 8.9, p) + 0.25 * elite


	_settle_required = lerpf(0.19, 0.035, p) - 0.012 * elite


	_lead_time = lerpf(0.012, 0.135, p) + 0.025 * elite
	_base_aggression = clampf(lerpf(0.34, 0.84, p) + 0.08 * elite, 0.0, 0.98)



	match _personality:
		PERSONA_PATIENT:
			_base_aggression = clampf(_base_aggression - 0.12, 0.0, 0.98)
			_reaction_time *= 0.97
			_settle_required *= 1.08
		PERSONA_AGGRESSIVE:
			_base_aggression = clampf(_base_aggression + 0.14, 0.0, 0.98)
			_move_speed *= 1.04
			_strafe_speed *= 1.03
			_settle_required *= 0.94
		_:
			pass
	_aggression = _base_aggression


func _build_collision() -> void :



	collision_layer = 8
	collision_mask = 1
	floor_snap_length = 0.35
	var shape: = CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = STAND_CAPSULE_HEIGHT
	_capsule = shape
	var col: = CollisionShape3D.new()
	col.name = "Collision"
	col.shape = shape
	col.position = Vector3(0.0, STAND_CAPSULE_HEIGHT * 0.5, 0.0)
	_collision = col
	add_child(col)




func _mat(color: Color, roughness: = 0.9) -> StandardMaterial3D:
	var material: = MeshKit.material(color, roughness, 0.0).duplicate() as StandardMaterial3D

	material.disable_ambient_light = false
	_materials.append(material)
	return material




func _set_ragdoll_palette(torso: Material, shirt: Material, pants: Material, 
		pants_dark: Material, boots: Material, skin: Material, 
		glove: Material, helmet: Material, accent: Material) -> void :
	_ragdoll_palette = {
		"torso": _albedo(torso), 
		"shirt": _albedo(shirt), 
		"pants": _albedo(pants), 
		"pants_dark": _albedo(pants_dark), 
		"boots": _albedo(boots), 
		"skin": _albedo(skin), 
		"glove": _albedo(glove), 
		"helmet": _albedo(helmet), 
		"accent": _albedo(accent), 
	}


func _albedo(material: Material) -> Color:
	if material is StandardMaterial3D:
		return (material as StandardMaterial3D).albedo_color
	return Color(0.4, 0.4, 0.4, 1.0)


func ragdoll_palette() -> Dictionary:
	return _ragdoll_palette




func hide_for_ragdoll() -> void :
	_death_time = -1.0
	if _visual != null:
		_visual.visible = false
	if _label != null:
		_label.visible = false
	if _aim_line != null:
		_aim_line.visible = false






func reset_round(spawn: Vector3) -> void :
	alive = true
	active = false
	health = MAX_HEALTH
	velocity = Vector3.ZERO
	_death_time = -1.0
	_flash = 0.0
	_flinch = 0.0
	_recoil = 0.0
	_reload_blend = 0.0
	_aim_blend = 0.0
	_crouched = false
	_crouch_blend = 0.0
	_crouch_timer = 0.0
	_crouch_decision = 0.0
	_crouch_applied = -1.0
	_eye_height = EYE_HEIGHT
	_ammo = _magazine
	_reloading = false
	_reload_timer = 0.0
	_bolt_timer = 0.0
	Sfx.stop_bot_weapon_sounds()
	_aim_settle = 0.0
	_aim_visual = Vector3.ZERO
	_aim_pitch = 0.0
	_jiggle_peek = 0.0
	_jiggle_total = 0.34
	_jiggle_dir = 1.0
	_jiggle_amp = 0.5
	_spray_bloom = 0.0
	_burst_left = 0
	_burst_pause = 0.0
	_burst_fresh = false
	_aim_punch = Vector3.ZERO
	_walking = false
	_near_miss_cooldown = 0.0
	_trade_window = 0.0
	_retreat_timer = 0.0
	_miss_streak = 0
	_visible_height = 1.22
	_heard_point = Vector3.ZERO
	_heard_timer = 99.0
	_heard_cooldown = 0.0
	_noise_cooldown = 0.0
	_scope_sound_on = false
	_stuck_time = 0.0
	_launch_lock = 0.0
	_jump_cooldown = 0.0
	_hop_timer = 0.0
	_parkour_cooldown = 0.0
	_high_ground_timer = 0.0
	_step_timer = 0.0
	_was_on_floor = true
	_perception_timer = 0.0
	_look_clear_timer = 0.0
	_look_raw_last = Vector3.ZERO
	_look_clear_point = Vector3.ZERO
	_direct_check_timer = 0.0
	_direct_clear = false
	_direct_target = Vector3.ZERO
	_direct_from = Vector3.ZERO
	_route_check_timer = 0.0
	_route_clear = false
	_route_point = Vector3.ZERO
	_route_from = Vector3.ZERO
	_logic_accum = 0.0
	_visible = false
	_was_visible = false
	_last_seen = Vector3.ZERO
	_last_seen_time = 99.0
	_reaction_timer = 0.0
	_think_timer = 0.0
	_scan_timer = 0.0
	_path.clear()
	_path_index = 0
	_path_goal = Vector3.ZERO
	_walk_phase = 0.0
	_idle_clock = 0.0
	_head_scan = 0.0
	_lean = 0.0
	_upper_aim_yaw = 0.0

	global_position = spawn
	if player != null and is_instance_valid(player):
		var flat: = player.global_position - global_position
		flat.y = 0.0
		rotation.y = atan2( - flat.x, - flat.z) if flat.length_squared() > 0.01 else 0.0
	else:
		rotation.y = 0.0
	_target_yaw = rotation.y
	_target_pitch = 0.0
	_aim_pitch = 0.0
	_last_position = global_position
	_prev_xform = global_transform
	_curr_xform = global_transform

	if _visual != null:
		_visual.visible = true
		_visual.position = Vector3.ZERO
		_visual.rotation = Vector3.ZERO
	if _label != null:
		_label.visible = true
	if _muzzle != null:
		_muzzle.visible = true
	if _aim_line != null:
		_aim_line.visible = false

	collision_layer = 8
	collision_mask = 1
	for box in _hitboxes:
		box.collision_layer = 2
	for material in _materials:
		material.emission_enabled = false
		material.emission_energy_multiplier = 0.0
	for i in _tracer_time.size():
		_tracer_time[i] = 0.0
		if i < _tracers.size():
			(_tracers[i].mesh as ImmediateMesh).clear_surfaces()
			_tracer_mats[i].albedo_color.a = 0.0
	_tracer_active = false
	_apply_crouch_geometry()

	_choose_hold(true)
	_set_state(State.HOLD)


	_animate_pose(0.0)


func _build_visual() -> void :
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)



	_hips = _pivot(_visual, Vector3(0.0, 0.92, 0.0), "Hips")
	_torso = _pivot(_hips, Vector3.ZERO, "Torso")
	_upper = _pivot(_torso, Vector3(0.0, _upper_base_y, 0.0), "Upper")

	if skin == "trooper":
		_build_trooper()
	elif skin == "urban":
		_build_trooper(1)
	elif skin == "desert":
		_build_forest(1)
	else:
		_build_forest()

	_build_legs()
	_build_weapon()
	_build_aim_line()
	_flush_parts()


func _part(parent: Node3D, size: Vector3, pos: Vector3, material: Material, 
		rot: = Vector3.ZERO) -> MeshInstance3D:



	var key: = "%d|%d" % [parent.get_instance_id(), material.get_instance_id()]
	var entry: Dictionary
	if _part_batches.has(key):
		entry = _part_batches[key]
	else:
		entry = {"parent": parent, "material": material, "parts": []}
		_part_batches[key] = entry
	var basis: = Basis.from_euler(rot * (PI / 180.0))
	(entry["parts"] as Array).append(
		[MeshKit.box_mesh(size), Transform3D(basis, pos)])
	return null





func _flush_parts() -> void :
	for key in _part_batches:
		var entry: Dictionary = _part_batches[key]
		var parts: Array = entry["parts"]
		if parts.is_empty():
			continue
		var inst: = MeshInstance3D.new()
		inst.mesh = MeshKit.merged_boxes(parts)
		inst.material_override = entry["material"]
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		inst.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		(entry["parent"] as Node3D).add_child(inst)
	_part_batches.clear()


func _pivot(parent: Node3D, pos: Vector3, node_name: String) -> Node3D:
	var node: = Node3D.new()
	node.name = node_name
	node.position = pos
	parent.add_child(node)
	return node


func _build_head(skin_tone: Material, hood: Material, eye: Material, 
		accent: Material) -> void :
	_head = _pivot(_upper, Vector3(0.0, 0.13, 0.0), "Head")

	_part(_upper, Vector3(0.145, 0.14, 0.145), Vector3(0.0, 0.075, 0.0), 
		skin_tone)
	_part(_upper, Vector3(0.085, 0.05, 0.075), Vector3(0.0, 0.105, -0.055), 
		skin_tone)

	_part(_head, Vector3(0.235, 0.24, 0.245), Vector3(0.0, 0.15, 0.0), 
		skin_tone)
	_part(_head, Vector3(0.205, 0.075, 0.225), Vector3(0.0, 0.045, -0.012), 
		skin_tone)
	_part(_head, Vector3(0.15, 0.05, 0.09), Vector3(0.0, 0.015, -0.075), 
		skin_tone)

	_part(_head, Vector3(0.255, 0.085, 0.26), Vector3(0.0, 0.265, 0.004), 
		hood)
	_part(_head, Vector3(0.235, 0.13, 0.065), Vector3(0.0, 0.185, 0.108), 
		hood)

	_part(_head, Vector3(0.2, 0.026, 0.03), Vector3(0.0, 0.212, -0.122), 
		hood)
	_part(_head, Vector3(0.05, 0.028, 0.02), Vector3(-0.058, 0.188, -0.125), 
		eye)
	_part(_head, Vector3(0.05, 0.028, 0.02), Vector3(0.058, 0.188, -0.125), 
		eye)
	_part(_head, Vector3(0.042, 0.058, 0.048), Vector3(0.0, 0.15, -0.133), 
		skin_tone)
	_part(_head, Vector3(0.03, 0.072, 0.055), Vector3(-0.126, 0.165, 0.0), 
		skin_tone)
	_part(_head, Vector3(0.03, 0.072, 0.055), Vector3(0.126, 0.165, 0.0), 
		skin_tone)

	_part(_head, Vector3(0.045, 0.05, 0.04), Vector3(0.105, 0.235, -0.1), 
		accent)


func _build_forest(variant: = 0) -> void :
	var desert: = variant == 1
	var green_dark: = _mat(Color(0.3, 0.255, 0.155) if desert
		else Color(0.105, 0.235, 0.115))
	var green: = _mat(Color(0.48, 0.415, 0.255) if desert
		else Color(0.235, 0.36, 0.15))
	var green_light: = _mat(Color(0.635, 0.55, 0.345) if desert
		else Color(0.33, 0.45, 0.2))
	var pink: = _mat(Color(0.82, 0.385, 0.17) if desert
		else Color(0.86, 0.5, 0.59))
	var skin_tone: = _mat(Color(0.74, 0.525, 0.345) if desert
		else Color(0.78, 0.57, 0.39))
	var glove: = _mat(Color(0.335, 0.3, 0.235) if desert
		else Color(0.3, 0.315, 0.33), 0.72)
	var boot: = _mat(Color(0.15, 0.13, 0.105) if desert
		else Color(0.115, 0.12, 0.125), 0.82)
	var strap: = _mat(Color(0.38, 0.33, 0.215) if desert
		else Color(0.18, 0.2, 0.17))
	var dark_green: = _mat(Color(0.22, 0.18, 0.105) if desert
		else Color(0.08, 0.15, 0.085))



	_part(_torso, Vector3(0.42, 0.22, 0.26), Vector3(0.0, 0.08, 0.0), 
		green_dark)
	_part(_torso, Vector3(0.52, 0.3, 0.3), Vector3(0.0, 0.3, 0.0), 
		green_dark)
	_part(_torso, Vector3(0.59, 0.16, 0.32), Vector3(0.0, 0.5, 0.0), 
		green_dark)
	_part(_torso, Vector3(0.24, 0.3, 0.035), Vector3(0.0, 0.31, -0.157), 
		pink)
	_part(_torso, Vector3(0.3, 0.14, 0.035), Vector3(0.0, 0.5, -0.163), 
		pink)
	_part(_torso, Vector3(0.5, 0.1, 0.315), Vector3(0.0, 0.0, 0.0), strap)
	_part(_torso, Vector3(0.4, 0.12, 0.28), Vector3(0.0, -0.07, 0.0), 
		green_dark)
	_part(_torso, Vector3(0.16, 0.15, 0.045), Vector3(-0.14, 0.29, -0.166), 
		green)
	_part(_torso, Vector3(0.16, 0.15, 0.045), Vector3(0.14, 0.29, -0.166), 
		green)
	_part(_torso, Vector3(0.11, 0.08, 0.05), Vector3(0.0, 0.43, -0.168), 
		green_light)
	_part(_torso, Vector3(0.09, 0.16, 0.04), Vector3(-0.205, 0.33, -0.164), 
		dark_green)
	_part(_torso, Vector3(0.09, 0.16, 0.04), Vector3(0.205, 0.33, -0.164), 
		dark_green)

	_build_head(skin_tone, green_dark, dark_green, green_light)
	_build_arms(pink, skin_tone, glove)
	_arms_hold_pose()


	_part(_torso, Vector3(0.035, 0.28, 0.07), Vector3(-0.29, 0.05, 0.13), 
		_mat(Color(0.56, 0.59, 0.62), 0.45), Vector3(0.0, 0.0, 18.0))
	_part(_torso, Vector3(0.045, 0.13, 0.08), Vector3(-0.25, 0.19, 0.13), 
		_mat(Color(0.12, 0.125, 0.13)), Vector3(0.0, 0.0, 18.0))

	_leg_materials = [green, green, boot, green_light, dark_green]
	_glove_material = glove
	_set_ragdoll_palette(green_dark, pink, green, dark_green, boot, 
		skin_tone, glove, green_dark, green_light)


func _build_trooper(variant: = 0) -> void :
	var urban: = variant == 1
	var navy: = _mat(Color(0.155, 0.165, 0.185) if urban
		else Color(0.105, 0.165, 0.285))
	var navy_light: = _mat(Color(0.29, 0.305, 0.335) if urban
		else Color(0.18, 0.27, 0.43))
	var armor: = _mat(Color(0.3, 0.315, 0.34) if urban
		else Color(0.385, 0.41, 0.425), 0.78)
	var armor_dark: = _mat(Color(0.155, 0.165, 0.185) if urban
		else Color(0.25, 0.27, 0.285), 0.8)
	var olive: = _mat(Color(0.35, 0.115, 0.115) if urban
		else Color(0.29, 0.345, 0.235))
	var olive_dark: = _mat(Color(0.235, 0.07, 0.07) if urban
		else Color(0.205, 0.25, 0.17))
	var skin_tone: = _mat(Color(0.7, 0.5, 0.34) if urban
		else Color(0.72, 0.51, 0.34))
	var boot: = _mat(Color(0.09, 0.095, 0.105) if urban
		else Color(0.105, 0.11, 0.115), 0.82)
	var blue_glow: = _mat(Color(1.0, 0.235, 0.17) if urban
		else Color(0.16, 0.56, 1.0), 0.4)

	_part(_torso, Vector3(0.46, 0.24, 0.29), Vector3(0.0, 0.08, 0.0), 
		armor_dark)
	_part(_torso, Vector3(0.56, 0.3, 0.33), Vector3(0.0, 0.3, 0.0), 
		armor)
	_part(_torso, Vector3(0.62, 0.16, 0.35), Vector3(0.0, 0.5, 0.0), 
		armor)
	_part(_torso, Vector3(0.34, 0.16, 0.37), Vector3(0.0, 0.46, -0.02), 
		navy)
	for x in [-0.17, 0.0, 0.17]:
		_part(_torso, Vector3(0.13, 0.17, 0.05), Vector3(x, 0.18, -0.178), 
			armor_dark)
	_part(_torso, Vector3(0.5, 0.09, 0.335), Vector3(0.0, 0.0, 0.0), 
		navy)
	_part(_torso, Vector3(0.1, 0.15, 0.05), Vector3(0.235, 0.36, -0.18), 
		navy_light)
	_part(_torso, Vector3(0.3, 0.12, 0.28), Vector3(0.0, -0.07, 0.0), 
		navy)

	_part(_upper, Vector3(0.15, 0.13, 0.15), Vector3(0.0, 0.075, 0.0), 
		skin_tone)


	_head = _pivot(_upper, Vector3(0.0, 0.13, 0.0), "Head")
	_part(_head, Vector3(0.23, 0.235, 0.24), Vector3(0.0, 0.15, 0.0), 
		skin_tone)
	_part(_head, Vector3(0.205, 0.07, 0.22), Vector3(0.0, 0.045, -0.01), 
		skin_tone)
	_part(_head, Vector3(0.26, 0.105, 0.27), Vector3(0.0, 0.275, 0.0), 
		navy)
	_part(_head, Vector3(0.29, 0.05, 0.3), Vector3(0.0, 0.225, -0.005), 
		navy_light)
	_part(_head, Vector3(0.3, 0.045, 0.27), Vector3(0.0, 0.245, -0.065), 
		navy)
	_part(_head, Vector3(0.22, 0.09, 0.045), Vector3(0.0, 0.16, -0.122), 
		_mat(Color(0.035, 0.045, 0.06), 0.36))
	_part(_head, Vector3(0.045, 0.05, 0.025), Vector3(0.145, 0.19, -0.115), 
		blue_glow)
	_part(_head, Vector3(0.03, 0.07, 0.055), Vector3(-0.126, 0.15, 0.0), 
		skin_tone)
	_part(_head, Vector3(0.03, 0.07, 0.055), Vector3(0.126, 0.15, 0.0), 
		skin_tone)

	_build_arms(navy, armor, armor_dark)
	_arms_hold_pose()
	_leg_materials = [olive, olive, boot, olive_dark, navy]
	_glove_material = armor_dark
	_set_ragdoll_palette(armor, navy, olive, olive_dark, boot, skin_tone, 
		armor_dark, navy, blue_glow)


func _build_arms(sleeve: Material, flesh: Material, glove: Material) -> void :
	_arm_right = _pivot(_upper, Vector3(0.325, 0.04, 0.0), "ArmRight")
	_arm_left = _pivot(_upper, Vector3(-0.325, 0.04, 0.0), "ArmLeft")
	for arm in [_arm_right, _arm_left]:


		_part(arm, Vector3(0.175, 0.17, 0.2), Vector3(0.0, -0.02, 0.0), sleeve)
		_part(arm, Vector3(0.145, 0.22, 0.16), Vector3(0.0, -0.2, 0.0), sleeve)
		_part(arm, Vector3(0.125, 0.075, 0.14), Vector3(0.0, -0.33, 0.0), flesh)
	_elbow_right = _pivot(_arm_right, Vector3(0.0, -0.36, 0.0), "ElbowRight")
	_elbow_left = _pivot(_arm_left, Vector3(0.0, -0.36, 0.0), "ElbowLeft")
	for elbow in [_elbow_right, _elbow_left]:
		_part(elbow, Vector3(0.14, 0.24, 0.155), Vector3(0.0, -0.12, 0.0), 
			sleeve)
		_part(elbow, Vector3(0.125, 0.075, 0.14), Vector3(0.0, -0.255, 0.0), 
			flesh)
		_part(elbow, Vector3(0.145, 0.14, 0.16), Vector3(0.0, -0.345, -0.01), 
			glove)




func _arms_hold_pose() -> void :
	if _arm_right != null:
		_arm_right.rotation = Vector3(1.02, 0.1, -0.22)
	if _elbow_right != null:
		_elbow_right.rotation = Vector3(0.66, 0.0, -0.1)
	if _arm_left != null:
		_arm_left.rotation = Vector3(1.18, -0.18, 0.42)
	if _elbow_left != null:
		_elbow_left.rotation = Vector3(0.7, 0.0, 0.16)


var _leg_materials: Array = []
var _glove_material: Material


func _build_legs() -> void :
	var pants: Material = _leg_materials[0]
	var pants_dark: Material = _leg_materials[1]
	var boot: Material = _leg_materials[2]
	var camo_light: Material = _leg_materials[3]
	var camo_dark: Material = _leg_materials[4]

	_leg_right = _pivot(_hips, Vector3(0.155, 0.0, 0.0), "LegRight")
	_leg_left = _pivot(_hips, Vector3(-0.155, 0.0, 0.0), "LegLeft")
	for leg in [_leg_right, _leg_left]:


		_part(leg, Vector3(0.225, 0.24, 0.25), Vector3(0.0, -0.12, 0.0), pants)
		_part(leg, Vector3(0.2, 0.24, 0.23), Vector3(0.0, -0.35, 0.0), pants)
		_part(leg, Vector3(0.095, 0.11, 0.02), Vector3(0.05, -0.15, -0.128), 
			camo_light)
		_part(leg, Vector3(0.115, 0.13, 0.02), Vector3(0.055, -0.33, -0.118), 
			camo_light)
	_knee_right = _pivot(_leg_right, Vector3(0.0, -0.46, 0.0), "KneeRight")
	_knee_left = _pivot(_leg_left, Vector3(0.0, -0.46, 0.0), "KneeLeft")
	for knee in [_knee_right, _knee_left]:
		_part(knee, Vector3(0.185, 0.2, 0.21), Vector3(0.0, -0.1, 0.0), 
			pants_dark)
		_part(knee, Vector3(0.165, 0.18, 0.19), Vector3(0.0, -0.29, 0.0), 
			pants_dark)

		_part(knee, Vector3(0.19, 0.1, 0.215), Vector3(0.0, -0.015, -0.005), 
			camo_dark)
		_part(knee, Vector3(0.2, 0.16, 0.24), Vector3(0.0, -0.365, -0.02), 
			boot)
		_part(knee, Vector3(0.215, 0.09, 0.33), Vector3(0.0, -0.415, -0.075), 
			boot)





func _build_weapon() -> void :
	_apply_weapon_pose()
	_weapon_pivot = _pivot(_upper, _weapon_base_pos, "WeaponPivot")
	_weapon_pivot.rotation_degrees = _weapon_base_rot
	_build_weapon_model()




func _apply_weapon_pose() -> void :
	if weapon_id == "awp":
		_weapon_base_pos = Vector3(0.17, -0.12, -0.3)
		_aim_weapon_pos = Vector3(0.075, 0.075, -0.235)
	else:
		_weapon_base_pos = Vector3(0.15, -0.14, -0.46)
		_aim_weapon_pos = Vector3(0.05, 0.015, -0.4)



func _rebuild_weapon() -> void :
	if _weapon_visual != null and is_instance_valid(_weapon_visual):
		_weapon_pivot.remove_child(_weapon_visual)
		_weapon_visual.queue_free()
	_weapon_visual = null
	_muzzle = null
	_apply_weapon_pose()
	_weapon_pivot.position = _weapon_base_pos
	_build_weapon_model()


func _build_weapon_model() -> void :
	_weapon_visual = Node3D.new()
	_weapon_visual.name = "WeaponVisual"
	_weapon_pivot.add_child(_weapon_visual)
	_weapon_root = WeaponBuilder.build(_weapon_visual, weapon_id, weapon_skin, 
		false)
	var weapon_scale: = 0.96
	_weapon_root.scale = Vector3.ONE * weapon_scale
	_muzzle = _weapon_root.get_node_or_null("Muzzle") as Node3D




	_hand_grip_pos = Vector3(0.02, -0.02, 0.03)
	_hand_support_pos = Vector3(-0.04, 0.01, -0.19)
	if _weapon_root.has_meta("view_hand_right"):
		var right: Vector3 = _weapon_root.get_meta("view_hand_right", 
			Vector3.ZERO) * weapon_scale
		var left: Vector3 = _weapon_root.get_meta("view_hand_left", 
			Vector3.ZERO) * weapon_scale
		_hand_grip_pos = right + Vector3(0.0, -0.022, 0.0)
		_hand_support_pos = left + Vector3(0.0, -0.012, 0.0)
	if _glove_material != null:
		_part(_weapon_visual, Vector3(0.15, 0.13, 0.18), 
			_hand_grip_pos, _glove_material)
		_part(_weapon_visual, Vector3(0.14, 0.12, 0.17), 
			_hand_support_pos, _glove_material)
	_flush_parts()





func _build_aim_line() -> void :
	_aim_line_mat = MeshKit.additive(Color(1.0, 0.3, 0.22, 0.0))
	_aim_line = MeshInstance3D.new()
	_aim_line.name = "BotAimLine"
	_aim_line.mesh = ImmediateMesh.new()
	_aim_line.material_override = _aim_line_mat
	_aim_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_aim_line.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	_aim_line.top_level = true
	_aim_line.visible = false
	_visual.add_child(_aim_line)


func _build_label() -> void :
	_label = Label3D.new()
	_label.name = "BotTag"
	_label.text = "BOT · LVL %d" % _level_from_elo()
	_label.position = Vector3(0.0, _label_base_y, 0.0)
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = false
	_label.fixed_size = false
	_label.pixel_size = 0.0032
	_label.font_size = 26
	_label.outline_size = 7
	_label.modulate = Color(1.0, 0.86, 0.62, 0.95)
	_label.outline_modulate = Color(0.03, 0.03, 0.04, 0.9)
	add_child(_label)


func _level_from_elo() -> int:
	return Settings.rating_level_for(int(skill_elo))




func _build_hitboxes() -> void :
	_add_hitbox("head", Vector3(0.0, 1.78, 0.0), _sphere(0.23))



	_add_hitbox("body", Vector3(0.0, 1.3, 0.0), _box(Vector3(0.82, 0.74, 0.56)))
	_add_hitbox("legs", Vector3(0.0, 0.49, 0.0), _box(Vector3(0.82, 1.02, 0.54)))


func _add_hitbox(zone: String, pos: Vector3, shape: Shape3D) -> void :
	var area: = Area3D.new()
	area.set_script(HitboxScript)
	area.name = "Hitbox_" + zone
	area.set("zone", zone)
	area.set("mannequin", self)
	area.position = pos
	_hitbox_base[zone] = pos
	var col: = CollisionShape3D.new()
	col.shape = shape
	area.add_child(col)
	add_child(area)
	_hitboxes.append(area)


func _sphere(radius: float) -> SphereShape3D:
	var shape: = SphereShape3D.new()
	shape.radius = radius
	return shape


func _box(size: Vector3) -> BoxShape3D:
	var shape: = BoxShape3D.new()
	shape.size = size
	return shape




func _physics_process(delta: float) -> void :
	if not active or not alive or player == null or not is_instance_valid(player):
		velocity = Vector3.ZERO
		_logic_accum = 0.0
		return

	_state_time += delta




	_logic_accum += delta
	if _logic_accum < LOGIC_INTERVAL - 0.0005:
		return

	var step: = _logic_accum
	_logic_accum = 0.0
	var before: = global_transform

	_update_crouch(step)
	_update_perception(step)
	_think(step)
	_update_aim(step)
	_smooth_aim(step)
	_update_weapon(step)
	_animate_pose(step)
	_update_movement(step)

	_prev_xform = before
	_curr_xform = global_transform





func _update_crouch(delta: float) -> void :
	_crouch_decision -= delta
	if not is_on_floor():
		_crouched = false
		_crouch_timer = 0.0
	elif _crouched:
		_crouch_timer -= delta
		var holding: = _state == State.HOLD or _state == State.PEEK
		if _crouch_timer <= 0.0 or not holding:
			_crouched = false
			_crouch_timer = randf_range(0.9, 2.0)
	else:
		_crouch_timer = maxf(0.0, _crouch_timer - delta)
		if _crouch_timer <= 0.0 and _crouch_decision <= 0.0:
			_crouch_decision = randf_range(0.35, 0.8)
			if _state == State.HOLD or _state == State.PEEK:
				var chance: = 0.35 + 0.42 * _skill_t
				if _reloading:
					chance += 0.2
				if _last_seen_time < 2.5:
					chance += 0.12
				if randf() < chance:
					_crouched = true
					_crouch_timer = randf_range(1.3, 3.2)
				else:
					_crouch_timer = randf_range(1.0, 2.2)
	_crouch_blend = move_toward(_crouch_blend, 
		1.0 if _crouched else 0.0, delta * CROUCH_RATE)
	_eye_height = lerpf(EYE_HEIGHT, CROUCH_EYE_HEIGHT, _crouch_blend)
	_apply_crouch_geometry()





func _apply_crouch_geometry() -> void :
	if is_equal_approx(_crouch_blend, _crouch_applied):
		return
	_crouch_applied = _crouch_blend
	if _capsule != null and _collision != null:
		var height: = lerpf(STAND_CAPSULE_HEIGHT, CROUCH_CAPSULE_HEIGHT, 
			_crouch_blend)
		_capsule.height = height
		_collision.position.y = height * 0.5
	for area in _hitboxes:
		if not is_instance_valid(area):
			continue
		var zone: = str(area.get("zone"))
		var stored: Variant = _hitbox_base.get(zone, area.position)
		var base: Vector3 = stored if stored is Vector3 else area.position
		var crouched_y: = base.y
		match zone:
			"head":
				crouched_y = 1.36
			"body":
				crouched_y = 0.9
			"legs":
				crouched_y = 0.42
		area.position = Vector3(base.x, 
			lerpf(base.y, crouched_y, _crouch_blend), base.z)
	if _label != null:
		_label.position.y = _label_base_y - _crouch_blend * 0.42





func _update_perception(delta: float) -> void :
	if not _visible:
		_last_seen_time += delta
	_reaction_timer = maxf(_reaction_timer - delta, 0.0)
	_perception_timer -= delta
	if _perception_timer > 0.0:
		return
	_perception_timer = PERCEPTION_INTERVAL
	_was_visible = _visible
	var spot: = _spot_player()
	_visible = bool(spot.get("visible", false))
	if _visible:
		_visible_height = float(spot.get("height", 1.22))
		if not _was_visible:


			_reaction_timer = _reaction_time * randf_range(0.88, 1.22)\
			+ randf_range(0.0, 0.05)


			_aim_visual = Vector3(
				randf_range(-0.1, 0.1), 
				randf_range(-0.035, 0.035), 
				randf_range(-0.1, 0.1))
		_last_seen = player.global_position
		_last_seen_time = 0.0
	else:
		_aim_settle = 0.0







func _spot_player() -> Dictionary:
	var base: = player.global_position
	var from: = global_position + Vector3.UP * _eye_height
	for offset in BODY_SAMPLES:
		var point: = base + Vector3.UP * float(offset)
		if not _in_view_cone(point):
			continue
		var result: = _ray(from, point)
		if not result.is_empty() and result.get("collider") == player:
			return {"visible": true, "height": float(offset)}
	return {"visible": false, "height": 1.22}





func _aim_height() -> float:
	var height: = _visible_height
	if _aim_head and height > 1.12:
		height = maxf(height, 1.58)
	return height


func _in_view_cone(target: Vector3) -> bool:
	var from: = global_position + Vector3.UP * _eye_height
	var to: = target - from
	if to.length_squared() < 1.44:
		return true
	var forward: = _forward_direction()
	return rad_to_deg(forward.angle_to(to.normalized())) <= VIEW_HALF_ANGLE


func _has_line_of_sight(target: Vector3, _allow_player: = false) -> bool:
	var from: = global_position + Vector3.UP * _eye_height
	var result: = _ray(from, target)
	if result.is_empty():
		return false
	return result.get("collider") == player





func _ray(from: Vector3, to: Vector3) -> Dictionary:
	if _ray_query == null:
		_ray_query = PhysicsRayQueryParameters3D.new()
		_ray_query.collision_mask = 1
		_ray_query.exclude = [get_rid()]
		_ray_query.collide_with_areas = false
		_ray_query.collide_with_bodies = true
	_ray_query.from = from
	_ray_query.to = to
	return get_world_3d().direct_space_state.intersect_ray(_ray_query)


func _segment_blocked(from: Vector3, to: Vector3) -> bool:
	var result: = _ray(from + Vector3.UP * 0.5, to + Vector3.UP * 0.5)
	if result.is_empty():
		return false
	return result.get("collider") != player




func _set_state(next_state: State) -> void :
	if _state == next_state:
		_state_time = 0.0
		return
	_state = next_state
	_state_time = 0.0
	_update_scope_sound(next_state)


	var tempo: = 1.0
	var peek_switch: = 0.35
	var engage_tempo: = 1.0
	match _personality:
		PERSONA_PATIENT:
			tempo = 1.16
			peek_switch = 0.22
			engage_tempo = 0.9
		PERSONA_AGGRESSIVE:
			tempo = 0.86
			peek_switch = 0.46
			engage_tempo = 1.15
	match next_state:
		State.HOLD:
			_hold_timer = randf_range(1.0, 2.4) * lerpf(1.0, 0.62, _aggression)\
			* tempo
		State.PEEK:
			_peek_timer = randf_range(1.1, 2.2) * lerpf(1.0, 0.72, _aggression)\
			* tempo
			if randf() < peek_switch:
				_peek_side = - _peek_side
		State.ENGAGE:
			_engage_time = 0.0
			_engage_limit = randf_range(1.0, 2.3)\
			* lerpf(0.8, 1.15, _aggression) * engage_tempo
			_reaction_timer = maxf(_reaction_timer, _reaction_time * 0.65)
			_strafe_timer = randf_range(0.35, 0.9)
		State.REPOSITION:
			_reposition_timer = randf_range(0.9, 1.7) * tempo
			_reposition_lock = randf_range(0.55, 0.95)
			_choose_reposition()
		State.HUNT:
			_scan_timer = randf_range(0.4, 0.9)
			_pick_hunt_point()
		State.PARKOUR:
			_parkour_cooldown = 2.5
			if _jump_pads.is_empty():
				_set_state(State.HUNT)
		_:
			pass





func _update_scope_sound(next_state: State) -> void :
	if _automatic:
		return
	if next_state == State.ENGAGE:
		if _scope_sound_on:
			return

		if _ammo <= 0 or _reloading:
			return
		_scope_sound_on = true
		Sfx.play_bot_scope(global_position + Vector3.UP * 1.45, true)
	elif _scope_sound_on:
		_scope_sound_on = false
		Sfx.play_bot_scope(global_position + Vector3.UP * 1.45, false)


func _think(delta: float) -> void :
	_think_timer -= delta
	_scan_timer -= delta
	_strafe_timer -= delta
	_reposition_lock = maxf(0.0, _reposition_lock - delta)
	_parkour_cooldown = maxf(0.0, _parkour_cooldown - delta)
	_high_ground_timer = maxf(0.0, _high_ground_timer - delta)
	_retreat_timer = maxf(0.0, _retreat_timer - delta)
	_trade_window = maxf(0.0, _trade_window - delta)
	_near_miss_cooldown = maxf(0.0, _near_miss_cooldown - delta)
	_heard_timer = minf(_heard_timer + delta, 99.0)
	_heard_cooldown = maxf(0.0, _heard_cooldown - delta)
	_noise_cooldown = maxf(0.0, _noise_cooldown - delta)
	if _strafe_timer <= 0.0:
		_strafe_timer = randf_range(0.5, 1.4)
		_strafe_sign = 1.0 if randf() > 0.5 else -1.0




	_jiggle_peek = maxf(0.0, _jiggle_peek - delta)
	if _jiggle_peek <= 0.0 and _last_seen_time < 6.0\
	and (_state == State.HOLD or _state == State.PEEK):
		var jiggle_chance: = 0.28
		match _personality:
			PERSONA_PATIENT:
				jiggle_chance = 0.18
			PERSONA_AGGRESSIVE:
				jiggle_chance = 0.42
		if randf() < jiggle_chance * delta:
			_jiggle_total = randf_range(0.22, 0.52)
			_jiggle_peek = _jiggle_total
			_jiggle_amp = randf_range(0.35, 0.85)
			_jiggle_dir = 1.0 if randf() > 0.5 else -1.0




	if not _reloading and _ammo > 0\
	and _ammo < _magazine and _last_seen_time > 2.2\
	and _state != State.ENGAGE and _state != State.PARKOUR:
		var reload_threshold: = int(ceil(_magazine * (
			0.45 if _personality == PERSONA_PATIENT else 0.3)))
		if _ammo <= reload_threshold and randf() < delta * 0.55:
			_start_reload()




	if _trade_window > 0.0 and not _visible and _retreat_timer <= 0.0\
	and (_state == State.HOLD or _state == State.REPOSITION):
		_trade_window = 0.0
		_pick_new_peek()
		_set_state(State.PEEK)




	if _retreat_timer > 0.0 and _bolt_timer <= 0.0\
	and _state != State.DEAD and _state != State.PARKOUR:
		_retreat_timer = 0.0
		_set_state(State.REPOSITION)

	if _visible:
		var retreating: = _state == State.REPOSITION and _reposition_lock > 0.0
		if _state != State.ENGAGE and _state != State.DEAD and not retreating:
			_set_state(State.ENGAGE)
	else:
		if _state == State.ENGAGE:
			if _last_seen_time > 0.45:
				_set_state(State.REPOSITION)
		elif _state == State.PEEK:
			if _state_time > _peek_timer:

				if randf() < 0.55:
					_set_state(State.HOLD)
					_hold_timer = randf_range(0.5, 1.0)
				else:
					_pick_new_peek()
					_state_time = 0.0
		elif _state == State.HOLD:
			if _state_time > _hold_timer:
				_set_state(State.PEEK)
			elif _state_time > _hold_timer + 3.2:
				_set_state(State.REPOSITION)
		elif _state == State.REPOSITION:
			if _state_time > _reposition_timer:
				_set_state(State.HOLD)
		elif _state == State.HUNT:
			if _state_time > 3.4 + 2.2 * (1.0 - _aggression):
				_set_state(State.HOLD)
		elif _state == State.PARKOUR:

			if is_on_floor() and global_position.y > 1.4:
				_hold_point = _parkour_landing
				_peek_point = _nearest_point(_peek_points, _parkour_landing, 7.0, true)
				_high_ground_timer = 5.0
				_set_state(State.HOLD)
				_hold_timer = 2.6
			elif _state_time > 4.2:
				_set_state(State.HOLD)

		var hunt_after: = lerpf(6.4, 4.2, _aggression)


		if _high_ground_timer <= 0.0 and _last_seen_time > hunt_after\
		and _state != State.HUNT and _state != State.PARKOUR:
			_set_state(State.HUNT)



	if _parkour_cooldown <= 0.0 and not _visible and _high_ground_timer <= 0.0\
	and _state != State.PARKOUR and _state != State.DEAD\
	and global_position.y < 1.2 and not _jump_pads.is_empty():
		_parkour_cooldown = randf_range(7.0, 12.0)
		var elevated: = _last_seen_time < 5.0\
		and _last_seen.y > global_position.y + 1.5


		if elevated or randf() < 0.06 + 0.16 * _aggression:
			_start_parkour()

	if _state == State.ENGAGE:
		_engage_time += delta
		if _visible and _engage_time > _engage_limit and _bolt_timer <= 0.0:

			_set_state(State.REPOSITION)
		if not _visible and _last_seen_time > 0.45:
			_set_state(State.REPOSITION)

	if _think_timer > 0.0:
		return
	_think_timer = randf_range(0.18, 0.42)
	var spread: = _aim_error_distance
	_aim_offset = Vector3(
		randf_range( - spread, spread), 
		randf_range( - spread * 0.55, spread * 0.55), 
		randf_range( - spread, spread))
	_aim_head = randf() < _headshot_aim




func _start_parkour() -> void :
	if _jump_pads.is_empty():
		return
	var best: = _jump_pads[0]
	var best_distance: = INF
	for point in _jump_pads:
		var distance: = global_position.distance_squared_to(point)
		if distance < best_distance:
			best_distance = distance
			best = point
	_parkour_point = best
	if _parkour_landing == Vector3.ZERO:
		_parkour_landing = Vector3(0.0, 2.86, 0.0)
	_set_state(State.PARKOUR)





func _choose_hold(initial: = false) -> void :
	var points: = _hold_points
	if points.is_empty():
		points = [Vector3(7.5, 0.06, 3.8), Vector3(7.5, 0.06, -3.8), 
			Vector3(10.5, 0.06, 8.5), Vector3(10.5, 0.06, -8.5)]
	var focus: = global_position
	if _last_seen_time < 10.0:
		focus = _last_seen
	elif not initial:
		focus = Vector3(0.0, 0.0, 0.0)
	_hold_point = _pick_point(points, focus, initial)




	if initial and not _peek_points.is_empty():
		var push_chance: = 0.16 + 0.34 * _aggression + 0.12 * _skill_t
		if _personality == PERSONA_AGGRESSIVE:
			push_chance += 0.16
		elif _personality == PERSONA_PATIENT:
			push_chance -= 0.1
		if randf() < push_chance:
			var forward: = _pick_point(_peek_points, Vector3.ZERO, false)
			if forward != Vector3.ZERO:
				_hold_point = forward
	_hold_side = 1.0 if _hold_point.z >= 0.0 else -1.0
	_peek_point = _nearest_point(_peek_points, _hold_point, 9.5, 
		_hold_point.y > 1.4)
	if _peek_point == Vector3.ZERO:
		_peek_point = _hold_point + Vector3(2.0, 0.0, 0.0)


func _pick_new_peek() -> void :
	var focus: = _hold_point if _hold_point != Vector3.ZERO else global_position
	if _last_seen_time < 3.0:
		focus = _last_seen


	var pool: = _peek_points
	if global_position.y > 1.4:
		var high: Array[Vector3] = []
		for point in _peek_points:
			if absf(point.y - global_position.y) <= 1.0:
				high.append(point)
		if not high.is_empty():
			pool = high
	_peek_point = _pick_point(pool, focus, false, _peek_point)
	if _peek_point != Vector3.ZERO:
		_hold_side = 1.0 if _peek_point.z >= 0.0 else -1.0
	else:
		_peek_point = global_position + Vector3(3.0, 0.0, _hold_side)


func _choose_reposition() -> void :


	var points: = _hold_points
	if points.is_empty():
		points = [Vector3(7.5, 0.06, 3.8), Vector3(7.5, 0.06, -3.8)]

	if global_position.y > 1.4 and _high_ground_timer > 0.0:
		var high: Array[Vector3] = []
		for point in points:
			if absf(point.y - global_position.y) <= 1.0:
				high.append(point)
		if not high.is_empty():
			points = high
	var focus: = _last_seen if _last_seen_time < 6.0 else Vector3(0.0, 0.0, 0.0)
	var next: = _pick_point(points, focus, false, _hold_point)
	if next == Vector3.ZERO or next.distance_to(_hold_point) < 2.0:
		next = _pick_point(points, focus, false, _hold_point)
	_hold_point = next
	_hold_side = 1.0 if _hold_point.z >= 0.0 else -1.0
	_peek_point = _nearest_point(_peek_points, _hold_point, 9.5, 
		_hold_point.y > 1.4)




func _pick_hunt_point() -> void :


	if _heard_timer < 2.5 and _heard_point != Vector3.ZERO:
		_hunt_point = _heard_point
		return
	if _last_seen_time < 6.0:
		_hunt_point = _last_seen
		return
	var points: = _hunt_points
	if points.is_empty():
		_hunt_point = Vector3(0.0, 0.06, 0.0)
		return


	var far: Array[Vector3] = []
	for point in points:
		if point.distance_to(global_position) > 10.0:
			far.append(point)
	_hunt_point = _pick_point(far if not far.is_empty() else points, 
		Vector3( - global_position.x, 0.0, - global_position.z), true)




func _pick_point(points: Array[Vector3], focus: Vector3, 
		prefer_far: = false, avoid: = Vector3.ZERO) -> Vector3:
	if points.is_empty():
		return Vector3.ZERO
	var candidates: Array[Vector3] = []
	for point in points:
		if avoid != Vector3.ZERO and point.distance_to(avoid) < 2.5:
			continue
		candidates.append(point)
	if candidates.is_empty():
		candidates = points.duplicate()
	if randf() < 0.22:
		return candidates[randi() % candidates.size()]
	var best: = candidates[0]
	var best_score: = INF
	for point in candidates:
		var distance: = point.distance_to(focus)
		var score: = distance if not prefer_far else - distance

		score += randf_range(-2.4, 2.4)
		if score < best_score:
			best_score = score
			best = point
	return best


func _nearest_point(points: Array[Vector3], origin: Vector3, 
		max_distance: = 12.0, same_level: = false) -> Vector3:
	var best: = Vector3.ZERO
	var best_distance: = max_distance
	for point in points:


		if same_level and absf(point.y - origin.y) > 1.0:
			continue
		var distance: = point.distance_to(origin)
		if distance < best_distance:
			best_distance = distance
			best = point
	return best


func _movement_target() -> Vector3:
	match _state:
		State.HOLD:
			return _route_to(_hold_point)
		State.PEEK:
			return _route_to(_peek_point)
		State.REPOSITION:
			return _route_to(_hold_point)
		State.HUNT:
			if _scan_timer <= 0.0:
				_scan_timer = randf_range(0.6, 1.2)
				_pick_hunt_point()
			return _route_to(_hunt_point)
		State.PARKOUR:

			if not is_on_floor() and global_position.y > 0.9:
				return _parkour_landing
			return _parkour_point
		State.ENGAGE:
			return global_position
		_:
			return _route_to(_peek_point)






func _direct_route_clear(target: Vector3) -> bool:
	if _direct_check_timer > 0.0\
	and _direct_target.distance_squared_to(target) < 0.36\
	and _direct_from.distance_squared_to(global_position) < 1.0:
		return _direct_clear
	_direct_check_timer = 0.14
	_direct_target = target
	_direct_from = global_position
	_direct_clear = not _segment_blocked(global_position, target)
	return _direct_clear





func _route_point_clear(point: Vector3) -> bool:
	if _route_check_timer > 0.0\
	and _route_point.distance_squared_to(point) < 0.25\
	and _route_from.distance_squared_to(global_position) < 0.36:
		return _route_clear
	_route_check_timer = 0.1
	_route_point = point
	_route_from = global_position
	_route_clear = not _segment_blocked(global_position, point)
	return _route_clear





func _route_to(target: Vector3) -> Vector3:
	if target == Vector3.ZERO:
		return global_position
	var same_level: = absf(target.y - global_position.y) < 1.3
	var direct: = false
	if _nav_points.is_empty():
		direct = true
	elif same_level:
		direct = _direct_route_clear(target)
	if direct:
		_path.clear()
		_path_index = 0
		_path_goal = target
		return target
	if _path.is_empty() or _path_goal.distance_to(target) > 1.5:
		_plan_path(target)
	var guard: = 0
	while _path_index < _path.size() and guard < 64:
		guard += 1
		var point: = _path[_path_index]
		var flat: = Vector2(point.x - global_position.x, point.z - global_position.z)
		if flat.length() <= 0.9:
			_path_index += 1
			continue



		if not _route_point_clear(point):
			_path_index += 1
			continue
		break
	if _path_index < _path.size():
		return _path[_path_index]
	return target


func _plan_path(goal: Vector3) -> void :
	_path.clear()
	_path_index = 0
	_path_goal = goal
	if _nav_points.is_empty():
		return
	var start: = _nearest_nav_index(global_position)
	var end: = _nearest_nav_index(goal)
	if start < 0 or end < 0:
		return
	if start == end:
		_path.append(goal)
		return




	var count: = _nav_points.size()
	var end_pos: = _nav_points[end]
	var cost: = PackedFloat32Array()
	cost.resize(count)
	cost.fill(INF)
	cost[start] = 0.0
	var came: = PackedInt32Array()
	came.resize(count)
	came.fill(-1)
	var closed: = PackedByteArray()
	closed.resize(count)
	closed.fill(0)

	var open_nodes: Array[int] = [start]
	var open_scores: Array[float] = [_nav_points[start].distance_to(end_pos)]

	while not open_nodes.is_empty():

		var current: = open_nodes[0]
		var last: = open_nodes.size() - 1
		if last == 0:
			open_nodes.clear()
			open_scores.clear()
		else:
			open_nodes[0] = open_nodes[last]
			open_scores[0] = open_scores[last]
			open_nodes.remove_at(last)
			open_scores.remove_at(last)
			var hole: = 0
			var size: = open_nodes.size()
			while true:
				var child: = hole * 2 + 1
				if child >= size:
					break
				var right: = child + 1
				if right < size and open_scores[right] < open_scores[child]:
					child = right
				if open_scores[hole] <= open_scores[child]:
					break
				var swap_node: = open_nodes[hole]
				open_nodes[hole] = open_nodes[child]
				open_nodes[child] = swap_node
				var swap_score: = open_scores[hole]
				open_scores[hole] = open_scores[child]
				open_scores[child] = swap_score
				hole = child
		if closed[current] == 1:
			continue
		if current == end:
			break
		closed[current] = 1
		var current_cost: = cost[current]
		var current_pos: = _nav_points[current]
		var neighbors: Array = _nav_adj.get(current, [])
		for neighbor_value in neighbors:
			var neighbor: = int(neighbor_value)
			if closed[neighbor] == 1:
				continue
			var tentative: = current_cost\
			+ current_pos.distance_to(_nav_points[neighbor])
			if tentative >= cost[neighbor]:
				continue
			cost[neighbor] = tentative
			came[neighbor] = current
			var score: = tentative\
			+ _nav_points[neighbor].distance_to(end_pos)

			open_nodes.append(neighbor)
			open_scores.append(score)
			var slot: = open_nodes.size() - 1
			while slot > 0:
				var parent: = (slot - 1) / 2
				if open_scores[parent] <= open_scores[slot]:
					break
				var up_node: = open_nodes[slot]
				open_nodes[slot] = open_nodes[parent]
				open_nodes[parent] = up_node
				var up_score: = open_scores[slot]
				open_scores[slot] = open_scores[parent]
				open_scores[parent] = up_score
				slot = parent

	if came[end] == -1:
		return
	var chain: Array[int] = []
	var node: = end
	var safety: = 0
	while node != start and safety < 64:
		safety += 1
		chain.push_front(node)
		var prev: = came[node]
		if prev == -1:
			break
		node = prev
	chain.push_front(start)
	for index in chain:
		_path.append(_nav_points[index])
	if _path.size() > 1\
	and _path[0].distance_to(global_position) < 1.2:
		_path.remove_at(0)
	_path.append(goal)


func _nearest_nav_index(point: Vector3) -> int:
	if _nav_points.is_empty():
		return -1
	var best: = -1
	var best_distance: = INF
	for i in _nav_points.size():
		var node: = _nav_points[i]
		var distance: = node.distance_to(point) + absf(node.y - point.y) * 1.5
		if distance < best_distance:
			best_distance = distance
			best = i
	return best


func _update_movement(delta: float) -> void :
	_jump_cooldown = maxf(0.0, _jump_cooldown - delta)
	_launch_lock = maxf(0.0, _launch_lock - delta)
	_hop_timer -= delta
	_direct_check_timer = maxf(0.0, _direct_check_timer - delta)
	_route_check_timer = maxf(0.0, _route_check_timer - delta)
	var target: = _movement_target()
	var flat: = Vector3(target.x - global_position.x, 0.0, 
		target.z - global_position.z)
	var speed: = _move_speed * lerpf(1.0, CROUCH_SPEED_SCALE, _crouch_blend)
	match _state:
		State.HOLD:
			speed *= 0.55
		State.PEEK:
			speed *= 0.48
		State.ENGAGE:

			speed = 0.0
		State.REPOSITION:
			speed *= 0.94
		State.HUNT:
			speed *= 0.8
		State.PARKOUR:
			speed *= 1.0



	_walking = false
	if _state == State.PEEK:

		_walking = true
	elif _state == State.HUNT or _state == State.REPOSITION:
		var close_to_target: = flat.length() < 3.2
		var near_player: = player != null and not _visible\
		and global_position.distance_to(player.global_position) < 11.0
		_walking = close_to_target or near_player
		if _walking:
			speed *= 0.62
	var desired: = Vector3.ZERO
	if flat.length() > 0.35 and speed > 0.05:
		desired = flat.normalized() * speed



	if (_state == State.PEEK or _state == State.HOLD) and player != null:
		var toward: = player.global_position - global_position
		toward.y = 0.0
		if toward.length_squared() > 0.04:
			var side: = toward.normalized().cross(Vector3.UP).normalized()
			var near: = 1.0 - clampf(flat.length() / 2.2, 0.0, 1.0)
			var jiggle: = sin(_idle_clock * 2.4 + _state_time * 1.6)\
			* _strafe_speed * 0.3 * near * _strafe_sign
			desired += side * jiggle



	if _state == State.ENGAGE and player != null\
	and (_bolt_timer > 0.0 or _reloading):
		var to_player: = player.global_position - global_position
		to_player.y = 0.0
		if to_player.length_squared() > 0.04:
			var side: = to_player.normalized().cross(Vector3.UP).normalized()
			desired = side * _strafe_sign * _strafe_speed * 0.42




	if _jiggle_peek > 0.0 and player != null:
		var peek_to: = player.global_position - global_position
		peek_to.y = 0.0
		if peek_to.length_squared() > 0.04:
			var peek_side: = peek_to.normalized().cross(Vector3.UP).normalized()
			var life: = 1.0 - _jiggle_peek / maxf(_jiggle_total, 0.05)
			desired += peek_side * _jiggle_dir * _strafe_speed * _jiggle_amp\
			* sin(clampf(life, 0.0, 1.0) * PI)



	var blend: = 1.0 - exp(-10.0 * delta)
	if _launch_lock > 0.0:
		blend *= 0.12
	velocity.x = lerpf(velocity.x, desired.x, blend)
	velocity.z = lerpf(velocity.z, desired.z, blend)



	if _launch_lock > 0.0:
		velocity.y -= GRAVITY * delta
	elif not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
		if _jump_cooldown <= 0.0 and _wants_jump():
			velocity.y = _jump_speed
			_jump_cooldown = 0.42
			_hop_timer = randf_range(2.2, 4.6)
	move_and_slide()
	_update_footsteps(delta)



	var moved: = global_position.distance_to(_last_position)
	_last_position = global_position
	if moved < 0.008 and speed > 0.5:
		_stuck_time += delta
		if _stuck_time > 0.55:
			_stuck_time = 0.0
			_strafe_sign = - _strafe_sign
			if is_on_floor():
				velocity.y = _jump_speed
				_jump_cooldown = 0.45


			if _path_index < _path.size():
				_path_index += 1
			elif _state == State.PARKOUR:
				_set_state(State.HUNT)
			else:
				_pick_new_peek()
				_set_state(State.PEEK)
	else:
		_stuck_time = maxf(0.0, _stuck_time - delta)





func _update_footsteps(delta: float) -> void :
	var on_floor: = is_on_floor()
	var speed: = Vector2(velocity.x, velocity.z).length()
	var intensity: = clampf(speed / maxf(_move_speed, 0.1), 0.08, 1.0)
	if _walking:

		intensity *= 0.55
	if on_floor and not _was_on_floor:
		Sfx.play_bot_land(global_position, intensity)
	elif not on_floor and _was_on_floor and velocity.y > 1.2:
		Sfx.play_bot_jump(global_position)
	if on_floor and speed > 1.4:
		_step_timer -= delta
		if _step_timer <= 0.0:
			var interval: = clampf(3.5 / maxf(speed, 1.0), 
				BOT_STEP_MIN_INTERVAL, 0.48)
			if _walking:
				interval *= 1.18
			_step_timer = interval
			Sfx.play_bot_step(global_position, intensity)
	else:
		_step_timer = 0.0
	_was_on_floor = on_floor




func _wants_jump() -> bool:
	if _crouch_blend > 0.15:
		return false
	if _state == State.ENGAGE or _state == State.PARKOUR:
		return false
	if _launch_lock > 0.0:
		return false
	if _hop_timer > 0.0:
		return false
	if _state == State.HUNT:
		return _aggression > 0.26
	if _state == State.REPOSITION:
		return _aggression > 0.46
	if _visible and player != null:

		return player.global_position.y > global_position.y + 1.5
	return false




func pad_launch(lift: float, push: Vector3) -> void :
	if not active or not alive:
		return
	velocity.y = maxf(velocity.y, lift)
	velocity.x = push.x
	velocity.z = push.z
	_launch_lock = 0.55
	_jump_cooldown = 0.5
	_hop_timer = 1.2




func _animate_pose(delta: float) -> void :
	_idle_clock += delta


	var aiming: = _visible and alive
	var aim_target: = 0.0
	if aiming:
		aim_target = 1.0
	elif _state == State.HOLD or _state == State.PEEK\
	or _state == State.HUNT or _state == State.REPOSITION:
		aim_target = 0.3
	if _reloading:
		aim_target = 0.0
	_aim_blend = move_toward(_aim_blend, aim_target, 
		delta * (7.5 if aiming else 3.0))
	_flinch = maxf(0.0, _flinch - delta * 2.6)

	var horizontal: = Vector2(velocity.x, velocity.z).length()
	var ratio: = clampf(horizontal / maxf(_move_speed, 0.1), 0.0, 1.0)

	var body_ratio: = ratio * (1.0 - 0.55 * _aim_blend)
	var amp: = body_ratio * 0.6
	_walk_phase += delta * (3.0 + horizontal * 1.35)
	var stride: = sin(_walk_phase)
	var breath: = sin(_idle_clock * 1.55)
	var sway: = sin(_idle_clock * 0.72)
	var lean_target: = 0.0
	if _state == State.PEEK or _state == State.HOLD:
		lean_target = - _strafe_sign * 0.055 * (1.0 - body_ratio)
	elif _state == State.ENGAGE:
		lean_target = - _strafe_sign * 0.022
	elif _state == State.REPOSITION or _state == State.HUNT:
		lean_target = - _strafe_sign * 0.03 * body_ratio
	_lean = lerpf(_lean, lean_target, 1.0 - exp(-6.0 * delta))



	var crouch: = _crouch_blend
	var walk_scale: = 1.0 - crouch * 0.82
	if _leg_left != null and _leg_right != null:
		_leg_left.rotation.x = stride * amp * walk_scale + 0.04 * body_ratio\
		+ crouch * 1.1
		_leg_right.rotation.x = - stride * amp * walk_scale + 0.04 * body_ratio\
		+ crouch * 1.1
	if _knee_left != null:
		_knee_left.rotation.x = - maxf(0.0, - stride) * amp * 1.7 * walk_scale\
		- crouch * 1.6
	if _knee_right != null:
		_knee_right.rotation.x = - maxf(0.0, stride) * amp * 1.7 * walk_scale\
		- crouch * 1.6




	if _hips != null:
		_hips.position.y = 0.92 + sin(_walk_phase * 2.0) * 0.016 * body_ratio\
		+ breath * 0.004 * (1.0 - body_ratio) - _aim_blend * 0.018\
		- crouch * 0.3
		_hips.position.x = sway * 0.014 * (1.0 - body_ratio)\
		+ sin(_walk_phase) * 0.01 * body_ratio
		_hips.rotation.z = - sway * 0.014 * (1.0 - body_ratio) + _lean * 0.35
		_hips.rotation.y = sin(_walk_phase) * 0.045 * body_ratio


	if _torso != null:
		_torso.rotation.x = -0.045 * body_ratio\
		+ breath * 0.006 * (1.0 - body_ratio) + _aim_blend * 0.012\
		- crouch * 0.2
		_torso.rotation.z = sway * 0.01 * (1.0 - body_ratio)\
		+ sin(_walk_phase) * 0.012 * body_ratio + _lean * 0.65
		_torso.rotation.y = - sin(_walk_phase) * 0.03 * body_ratio

	_recoil = maxf(0.0, _recoil - delta * 4.2)
	_reload_blend = move_toward(_reload_blend, 
		1.0 if _reloading else 0.0, delta * 5.0)



	var residual: = wrapf(_target_yaw - rotation.y, - PI, PI)
	_upper_aim_yaw = lerpf(_upper_aim_yaw, clampf(residual * 0.58, -0.55, 0.55), 
		1.0 - exp(-12.0 * delta))

	var scan_target: = 0.0
	if not _visible:
		scan_target = sin(_idle_clock * 0.62) * 0.26\
		+ sin(_idle_clock * 1.47) * 0.05
	_head_scan = lerpf(_head_scan, scan_target * (1.0 - _aim_blend), 
		1.0 - exp(-3.4 * delta))

	if _upper != null:
		_upper.position.y = _upper_base_y\
		+ sin(_walk_phase * 2.0) * 0.01 * body_ratio\
		+ breath * 0.004 - _aim_blend * 0.025
		_upper.rotation.x = _aim_pitch * 0.42 - 0.03 * body_ratio\
		- _recoil * 0.035 + breath * 0.006 + _aim_blend * 0.022
		_upper.rotation.y = _upper_aim_yaw
		_upper.rotation.z = sin(_walk_phase) * 0.014 * body_ratio\
		+ sway * 0.008 * (1.0 - body_ratio) + _lean
	if _head != null:
		_head.rotation.x = _aim_pitch * 0.42 - _upper.rotation.x * 0.55\
		+ breath * 0.012 + _aim_blend * 0.055
		_head.rotation.y = clampf(residual * 0.26, -0.38, 0.38) + _head_scan
		_head.rotation.z = - sway * 0.02 + _lean * 0.4


	if _flinch > 0.01:
		var shake: = sin(_idle_clock * 52.0) * _flinch
		if _upper != null:
			_upper.rotation.x += _flinch * 0.075
			_upper.rotation.z += shake * 0.045
		if _head != null:
			_head.rotation.x -= _flinch * 0.05
			_head.rotation.z += shake * 0.08
		if _hips != null:
			_hips.rotation.z += shake * 0.02

	_pose_weapon(delta, body_ratio, breath, sway)
	_pose_arms(delta)





func _pose_weapon(_delta: float, ratio: float, breath: float, 
		sway: float) -> void :
	if _weapon_pivot == null:
		return
	var bolt: = 0.0
	if _bolt_timer > 0.0 and not _reloading and not _automatic:



		var elapsed: = _fire_interval - _bolt_timer
		var cycle: = maxf(_fire_interval - _bolt_delay, 0.1)
		var progress: = clampf((elapsed - _bolt_delay) / cycle, 0.0, 1.0)
		bolt = sin(progress * PI)
	var reload: = _reload_blend * _reload_blend * (3.0 - 2.0 * _reload_blend)
	var base: = _weapon_base_pos.lerp(_aim_weapon_pos, _aim_blend)
	var base_rot: = _weapon_base_rot.lerp(_aim_weapon_rot, _aim_blend)

	var steadiness: = 1.0 - 0.72 * _aim_blend
	var pos: = Vector3(
		base.x + sway * 0.006 * (1.0 - ratio) * steadiness - reload * 0.02, 
		base.y + breath * 0.005 * steadiness - reload * 0.16
			- bolt * 0.012, 
		base.z + _recoil * 0.075 + bolt * 0.012)
	_weapon_pivot.position = pos
	var rot: = Vector3(
		deg_to_rad(base_rot.x + _aim_pitch * 32.0
			- _recoil * 7.0 + reload * 26.0), 
		deg_to_rad(base_rot.y + sway * 1.2 * (1.0 - ratio) * steadiness
			+ bolt * 4.0), 
		deg_to_rad(base_rot.z + sway * 0.8 * (1.0 - ratio) * steadiness
			+ bolt * 7.0 + reload * 18.0))
	_weapon_pivot.rotation = rot





func _pose_arms(_delta: float) -> void :
	if _weapon_pivot == null or _arm_right == null or _arm_left == null:
		return
	var weapon: = _weapon_pivot.transform
	var grip: = weapon * _hand_grip_pos
	var support: = weapon * _hand_support_pos
	_solve_arm(_arm_right, _elbow_right, Vector3(0.325, 0.04, 0.0), grip, 
		ARM_RIGHT_POLE)
	_solve_arm(_arm_left, _elbow_left, Vector3(-0.325, 0.04, 0.0), support, 
		ARM_LEFT_POLE)


func _solve_arm(arm: Node3D, elbow: Node3D, shoulder: Vector3, 
		target: Vector3, pole_hint: Vector3) -> void :
	if elbow == null:
		return
	var to_target: = target - shoulder
	var distance: = to_target.length()
	if distance < 0.001:
		return
	var reach: = clampf(distance, absf(ARM_L1 - ARM_L2) + 0.005, 
		ARM_L1 + ARM_L2 - 0.005)
	var dir: = to_target / distance
	var pole: = pole_hint - dir * pole_hint.dot(dir)
	if pole.length_squared() < 0.0001:
		pole = Vector3.RIGHT - dir * dir.x
	if pole.length_squared() < 0.0001:
		pole = Vector3.BACK - dir * dir.z
	pole = pole.normalized()

	var cos_a: = clampf((ARM_L1 * ARM_L1 + reach * reach
		- ARM_L2 * ARM_L2) / (2.0 * ARM_L1 * reach), -1.0, 1.0)
	var sin_a: = sqrt(maxf(1.0 - cos_a * cos_a, 0.0))
	var elbow_dir: = (dir * cos_a + pole * sin_a).normalized()
	var elbow_pos: = shoulder + elbow_dir * ARM_L1
	var forearm_dir: = (target - elbow_pos)
	if forearm_dir.length_squared() < 0.0001:
		forearm_dir = dir
	forearm_dir = forearm_dir.normalized()

	var upper_q: = Quaternion(Vector3.DOWN, elbow_dir)
	arm.quaternion = upper_q
	elbow.quaternion = upper_q.inverse() * Quaternion(Vector3.DOWN, forearm_dir)





func _player_velocity() -> Vector3:
	if player == null or not is_instance_valid(player):
		return Vector3.ZERO
	var raw: Variant = player.get("velocity")
	if raw is Vector3:
		return raw
	return Vector3.ZERO




func _smooth_aim(delta: float) -> void :
	var weight: = 1.0 - exp( - _aim_speed * delta)
	rotation.y = lerp_angle(rotation.y, _target_yaw, weight)
	_aim_pitch = lerpf(_aim_pitch, _target_pitch, weight)


func _update_aim(delta: float) -> void :
	if player == null:
		return

	_aim_visual = _aim_visual.lerp(Vector3.ZERO, 
		1.0 - exp(-8.0 * delta))


	_aim_punch = _aim_punch.lerp(Vector3.ZERO, 
		1.0 - exp(-7.0 * delta))
	_aim_punch = _aim_punch.limit_length(0.32)
	var point: Vector3
	if _visible:
		var aim_height: = _aim_height()
		point = player.global_position + Vector3.UP * aim_height + _aim_offset



		var target_velocity: = _player_velocity()
		if target_velocity.length_squared() > 0.09:
			var lead: = Vector3(target_velocity.x, 0.0, target_velocity.z) * _lead_time



			var distance: = global_position.distance_to(player.global_position)
			var max_lead: = maxf(0.06, tan(deg_to_rad(2.5)) * distance)
			point += lead.limit_length(minf(0.35, max_lead))
	elif _last_seen_time < 2.2:


		point = _last_seen + Vector3.UP * 1.16
	elif _heard_timer < 1.5:


		var heard_dir: = _heard_point - global_position
		heard_dir.y = 0.0
		if heard_dir.length_squared() > 0.25:
			point = global_position + heard_dir.normalized() * 6.0\
			+ Vector3.UP * 1.35
		else:
			point = _heard_point
	elif _state == State.HUNT:
		var move_dir: = Vector3(velocity.x, 0.0, velocity.z)
		if move_dir.length_squared() < 0.04:
			move_dir = _hunt_point - global_position
		move_dir.y = 0.0
		point = global_position + move_dir.normalized() * 5.0 + Vector3.UP * 1.25
	else:

		var watch: = _peek_point
		if _state == State.PARKOUR:
			watch = _parkour_point
		var watch_dir: = watch - global_position
		watch_dir.y = 0.0
		if watch_dir.length_squared() < 0.01:
			watch_dir = Vector3(0.0, 0.0, _hold_side)


		watch_dir = watch_dir.normalized().rotated(Vector3.UP, 
			sin(_idle_clock * 0.9 + _state_time) * 0.16)


		point = global_position + watch_dir * 7.0 + Vector3.UP * 1.5

	if not _visible:



		_look_clear_timer -= delta
		if _look_clear_timer <= 0.0\
		or _look_raw_last.distance_squared_to(point) > 0.36:
			_look_clear_point = _clear_look_point(point)
			_look_raw_last = point
			_look_clear_timer = LOOK_CLEAR_INTERVAL
		point = _look_clear_point
	else:
		_look_clear_timer = 0.0

	point += _aim_punch




	var sway_amp: = (0.022 - 0.012 * _skill_t) * (1.0 - 0.45 * _aim_blend)
	point += Vector3(
		sin(_idle_clock * 1.7 + 0.6), 
		sin(_idle_clock * 2.3) * 0.55, 
		cos(_idle_clock * 1.3)) * sway_amp
	point += _aim_visual
	_aim_point = point
	var from: = global_position + Vector3.UP * _eye_height
	var direction: = point - from
	if direction.length_squared() < 0.001:
		return
	direction = direction.normalized()
	var target_yaw: = atan2( - direction.x, - direction.z)
	var target_pitch: = asin(clampf(direction.y, -1.0, 1.0))
	_target_yaw = target_yaw
	_target_pitch = target_pitch





func _clear_look_point(raw: Vector3) -> Vector3:
	var from: = global_position + Vector3.UP * _eye_height
	var direction: = raw - from
	if direction.length_squared() < 0.01:
		direction = _forward_direction()
	direction = direction.normalized()
	for angle in LOOK_PROBES:
		var probe: = direction.rotated(Vector3.UP, deg_to_rad(float(angle)))
		var result: = _ray(from, from + probe * 8.0)
		var distance: = 8.0
		if not result.is_empty():
			distance = from.distance_to(result.get("position", from))
		if distance > 5.0:
			return from + probe * minf(distance - 0.4, 7.6)
	return from + _forward_direction() * 4.0






func _update_weapon(delta: float) -> void :
	_bolt_timer = maxf(0.0, _bolt_timer - delta)


	_spray_bloom = maxf(0.0, _spray_bloom - delta * lerpf(0.014, 0.035, _skill_t))
	if _automatic:
		_burst_pause = maxf(0.0, _burst_pause - delta)
	if _reloading:
		_reload_timer -= delta
		if _reload_timer <= 0.0:
			_reloading = false
			_ammo = _magazine
		return



	if _ammo <= 0:
		if _bolt_timer <= 0.0:
			_start_reload()
		return
	if _state != State.ENGAGE or not _visible or player == null:
		_aim_settle = 0.0
		_burst_left = 0
		_burst_pause = 0.0
		_burst_fresh = false
		return
	if not player.has_method("is_alive") or not bool(player.call("is_alive")):
		return
	if _reaction_timer > 0.0:
		return


	if _bolt_timer > 0.0:
		_aim_settle += delta
		return
	if Vector2(velocity.x, velocity.z).length() > 1.6:
		return



	if _automatic:
		if _burst_pause > 0.0:
			_aim_settle = 0.0
			return
		if _burst_left <= 0:
			_burst_left = _roll_burst_length()
			_burst_fresh = true

	var point: = player.global_position + Vector3.UP * _aim_height()\
	+ _aim_offset + _aim_punch + _aim_visual * 0.6
	var from: = global_position + Vector3.UP * _eye_height
	var aim: = (point - from).normalized()



	var tolerance: = lerpf(2.6, 1.0, _skill_t)
	if _forward_direction().angle_to(aim) > deg_to_rad(tolerance):
		_aim_settle = 0.0
		return



	_aim_settle += delta
	if ( not _automatic or _burst_fresh) and _aim_settle < _settle_required:
		return
	_shoot(aim)
	if not _automatic:
		_play_bolt_sound()
	_ammo -= 1
	_bolt_timer = _fire_interval
	if _automatic:
		_burst_left -= 1
		_burst_fresh = false
		_aim_settle = _settle_required
		if _burst_left <= 0:
			_burst_pause = randf_range(0.16, 0.34)\
			* lerpf(1.15, 0.72, _skill_t)
	else:
		_aim_settle = 0.0





func _roll_burst_length() -> int:
	var distance: = 30.0
	if player != null and is_instance_valid(player):
		distance = global_position.distance_to(player.global_position)
	var base: = 7.0
	if distance > 24.0:
		base = 3.0
	elif distance > 15.0:
		base = 4.0
	elif distance > 9.0:
		base = 5.0
	var length: = int(round(base + randf_range(-1.0, 1.0) + _skill_t * 1.5))
	return clampi(length, 2, 10)





func _play_bolt_sound() -> void :
	var point: = _muzzle.global_position if _muzzle != null else global_position
	Sfx.play_bot_bolt(point, AWP_BOLT_DELAY)


func _start_reload() -> void :
	if _reloading or _ammo >= _magazine or not alive:
		return
	_reloading = true
	_reload_timer = _reload_time
	_aim_settle = 0.0


	_burst_left = 0
	_burst_pause = 0.0
	_burst_fresh = false


	var point: = _muzzle.global_position if _muzzle != null else global_position
	Sfx.play_bot_reload(point)


func _forward_direction() -> Vector3:
	var yaw: = rotation.y
	var pitch: = _aim_pitch
	return Vector3( - sin(yaw) * cos(pitch), sin(pitch), 
		- cos(yaw) * cos(pitch)).normalized()


func _shoot(aim: Vector3) -> void :
	_recoil = 1.0
	var spread: = _shot_spread + _spray_bloom



	if _automatic:
		var bloom: = lerpf(0.0075, 0.0022, _skill_t)
		var bloom_max: = lerpf(0.022, 0.007, _skill_t)
		_spray_bloom = minf(_spray_bloom + bloom, bloom_max)
	var direction: = (aim + Vector3(
		randf_range( - spread, spread), 
		randf_range( - spread, spread), 
		randf_range( - spread, spread))).normalized()
	var from: = global_position + Vector3.UP * _eye_height
	var result: = _ray(from, from + direction * 90.0)
	var end: = from + direction * 90.0
	var hit_player: = false
	var hit_position: = end
	if not result.is_empty():
		end = result.get("position", end)
		hit_position = end
		hit_player = result.get("collider") == player
	_spawn_tracer(_muzzle.global_position if _muzzle != null else from, end)
	Sfx.play_bot_shot(_muzzle.global_position if _muzzle != null else from)

	if hit_player and player != null and player.has_method("take_damage"):
		_miss_streak = 0



		var relative: = hit_position.y - player.global_position.y
		var zone: = "body"
		if relative < 0.88:
			zone = "legs"
		elif relative > 1.46:
			zone = "head"
		var damage: = _damage_for_zone(zone)
		var lethal: bool = damage >= float(player.get("health"))
		player_hit.emit(zone, lethal)
		player.call("take_damage", damage, global_position)
	else:
		_miss_streak += 1



		var retreat_chance: = clampf(
			0.28 + 0.12 * float(_miss_streak) + 0.25 * _skill_t, 0.0, 0.92)
		if randf() < retreat_chance:
			_retreat_timer = maxf(_retreat_timer, randf_range(0.18, 0.45))




func _damage_for_zone(zone: String) -> float:
	var info: = WeaponData.get_weapon(weapon_id)
	var damage: = float(info.get("damage_body", 100.0))
	match zone:
		"head":
			damage = float(info.get("damage_head", damage))
		"legs":
			damage = float(info.get("damage_legs", damage))
	return damage





func _update_aim_line(_delta: float) -> void :
	if _aim_line == null:
		return
	_aim_line.visible = false


func _build_tracers() -> void :
	for i in TRACER_POOL:
		var material: = MeshKit.additive(Color(1.0, 0.72, 0.34, 0.0))
		var inst: = MeshInstance3D.new()
		inst.name = "BotTracer%d" % i
		inst.mesh = ImmediateMesh.new()
		inst.material_override = material
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		inst.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		inst.top_level = true
		_visual.add_child(inst)
		_tracers.append(inst)
		_tracer_mats.append(material)
	_tracer_time.resize(TRACER_POOL)


	_warm_tracers()



func _warm_tracers() -> void :
	if _tracers.is_empty():
		return

	var slot: = _tracers[_tracers.size() - 1]
	var immediate: = slot.mesh as ImmediateMesh
	if immediate == null:
		return
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate.surface_add_vertex(Vector3.ZERO)
	immediate.surface_add_vertex(Vector3.UP * 0.02)
	immediate.surface_end()
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	await tree.process_frame
	await tree.process_frame
	if is_instance_valid(immediate):
		immediate.clear_surfaces()


func _spawn_tracer(from: Vector3, to: Vector3) -> void :
	if _tracers.is_empty():
		return
	var index: = _tracer_index
	_tracer_index = (_tracer_index + 1) % _tracers.size()
	var inst: = _tracers[index]
	var mat: = _tracer_mats[index]
	var immediate: = inst.mesh as ImmediateMesh
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate.surface_add_vertex(from)
	immediate.surface_add_vertex(to)
	immediate.surface_end()
	mat.albedo_color.a = 0.9
	_tracer_time[index] = 0.06
	_tracer_active = true


func _process(delta: float) -> void :



	if not active and _death_time < 0.0 and _flash <= 0.0\
	and not _tracer_active:
		return



	if active and alive and _visual != null:
		var alpha: = Engine.get_physics_interpolation_fraction()
		_visual.global_transform = _prev_xform.interpolate_with(_curr_xform, alpha)
	_update_aim_line(delta)
	var tracer_live: = false
	for i in _tracers.size():
		if _tracer_time[i] <= 0.0:
			continue
		_tracer_time[i] -= delta
		var mat: = _tracer_mats[i]
		mat.albedo_color.a = maxf(_tracer_time[i] / 0.06, 0.0) * 0.9
		if _tracer_time[i] > 0.0:
			tracer_live = true
		else:
			mat.albedo_color.a = 0.0
			(_tracers[i].mesh as ImmediateMesh).clear_surfaces()
	_tracer_active = tracer_live

	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 6.0)
		for material in _materials:
			material.emission_enabled = _flash > 0.01
			material.emission = Color(1.0, 0.16, 0.1)
			material.emission_energy_multiplier = _flash * 1.8

	if _death_time >= 0.0:
		_animate_death(delta)




func take_damage(amount: float, source: Variant = null) -> void :
	if not alive or amount <= 0.0:
		return
	health = maxf(0.0, health - amount)
	_flash = 1.0
	_flinch = 1.0


	_aim_settle = 0.0
	if source is Vector3 and source != Vector3.ZERO:
		var src: Vector3 = source



		var offset: = src - global_position
		var distance: = offset.length()
		var error: = distance * lerpf(0.06, 0.015, _skill_t)
		var side: = offset.normalized().cross(Vector3.UP)
		if side.length_squared() > 0.001:
			offset += side.normalized() * randf_range( - error, error)
		offset += Vector3.UP * randf_range(-0.15, 0.35)
		_last_seen = global_position + offset
		_last_seen_time = 0.0


		var punch: = Vector3(
			randf_range(-1.0, 1.0), 
			randf_range(0.2, 0.8), 
			randf_range(-1.0, 1.0)).normalized()
		_aim_punch += punch * randf_range(0.07, 0.16)


	if randf() < 0.45 + 0.35 * _skill_t:
		_retreat_timer = maxf(_retreat_timer, randf_range(0.25, 0.6))
	damaged.emit(amount, health)
	if health <= 0.0:
		_die()






func take_hit(zone: String, from_position: = Vector3.ZERO, 
		amount: = -1.0) -> bool:
	if not alive:
		return false
	var damage: = amount
	if damage < 0.0:
		damage = _damage_for_zone(zone)
	take_damage(damage, from_position)
	return not alive


func is_alive() -> bool:
	return alive


func _die() -> void :
	if not alive:
		return
	alive = false
	active = false
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0
	for box in _hitboxes:
		box.collision_layer = 0
	if _label != null:
		_label.visible = false
	_death_time = 0.0
	_fall_dir = -1.0 if player != null and player.global_position.x < global_position.x else 1.0
	_death_arm_left = _arm_left.rotation if _arm_left != null else Vector3.ZERO
	_death_arm_right = _arm_right.rotation if _arm_right != null else Vector3.ZERO
	_death_leg_left = _leg_left.rotation if _leg_left != null else Vector3.ZERO
	_death_leg_right = _leg_right.rotation if _leg_right != null else Vector3.ZERO
	_death_head = _head.rotation if _head != null else Vector3.ZERO
	_death_weapon = _weapon_pivot.rotation if _weapon_pivot != null else Vector3.ZERO
	if _muzzle != null:
		_muzzle.visible = false
	died.emit(self)






func _animate_death(delta: float) -> void :
	_death_time += delta
	var fall: = clampf(_death_time / 0.62, 0.0, 1.0)
	var eased: = fall * fall
	var bounce: = 0.0
	var jolt: = 0.0
	if _death_time > 0.62:
		var after: = _death_time - 0.62
		bounce = sin(after * 15.0) * 0.045 * exp( - after * 6.5)
		jolt = sin(after * 10.0) * 0.03 * exp( - after * 4.5)
	if _visual != null:
		_visual.rotation.z = _fall_dir * (1.5 * eased + jolt)
		_visual.rotation.x = deg_to_rad(13.0) * eased
		_visual.position.y = -0.1 * eased + maxf(bounce, -0.02)
	if _hips != null:
		_hips.position.y = 0.92 - 0.11 * eased
		_hips.rotation.z = - _fall_dir * 0.14 * eased
	if _torso != null:
		_torso.rotation.x = 0.16 * eased
		_torso.rotation.y = 0.2 * _fall_dir * eased
	if _head != null:
		_head.rotation = _death_head.lerp(
			_death_head + Vector3(0.3, 0.2 * _fall_dir, -0.24 * _fall_dir), 
			eased)
	if _arm_left != null:
		_arm_left.rotation = _death_arm_left.lerp(
			_death_arm_left + Vector3(-0.42, 0.2 * _fall_dir, 0.55 * _fall_dir), 
			eased)
	if _arm_right != null:
		_arm_right.rotation = _death_arm_right.lerp(
			_death_arm_right + Vector3(-0.36, -0.18 * _fall_dir, -0.48 * _fall_dir), 
			eased)
	if _leg_left != null:
		_leg_left.rotation = _death_leg_left.lerp(
			_death_leg_left + Vector3(0.42, 0.0, 0.18 * _fall_dir), eased)
	if _leg_right != null:
		_leg_right.rotation = _death_leg_right.lerp(
			_death_leg_right + Vector3(0.3, 0.0, -0.14 * _fall_dir), eased)
	if _weapon_pivot != null:
		_weapon_pivot.rotation = _death_weapon.lerp(
			_death_weapon + Vector3(0.45, 0.0, 0.3 * _fall_dir), 
			eased * 0.55)
	if _death_time >= 2.4:
		_death_time = -1.0
