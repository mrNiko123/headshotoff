extends Node3D
## БАТЛ РОЯЛЬ HEADSHOT: 20 бойцов, сужающаяся зона, два подрежима
## (со строительством / без — Settings.br_build). Победа — последний выживший.

const BOT_SCRIPT = preload("res://scripts/br_bot.gd")
const BotNames = preload("res://scripts/bot_names.gd")
const MENU_SCENE: = "res://main_menu.tscn"
const GameSettingsScript = preload("res://scripts/game_settings.gd")
const WorldViewScript = preload("res://scripts/world_view.gd")
const WorldTint = preload("res://scripts/world_tint.gd")
const WorldTintShader = preload("res://shaders/world_tint.gdshader")
const RagdollScript = preload("res://scripts/ragdoll.gd")
const WeaponData = preload("res://scripts/weapon_data.gd")
const MeshKit = preload("res://scripts/mesh_kit.gd")
const BuildManagerScript = preload("res://br/building/build_manager.gd")
const BRBuildHudScript = preload("res://br/building/br_build_hud.gd")
const LootPickupScript = preload("res://br/building/loot_pickup.gd")

enum Phase{INTRO, BUS, GLIDE, LIVE, PAUSED, ENDED}

const FIGHTER_COUNT: = 20
const SAFEGUARD_TIME: = 600.0
const SPAWN_PROTECTION: = 2.4
const BOT_WEAPONS: = ["ak47", "m4a1", "awp", "deagle"]
const ASSIST_WINDOW: = 8.0
const ASSIST_MIN_DAMAGE: = 20.0
const INTRO_STEP: = 0.72
const PLAYER_MAX_HEALTH: = 100.0
const KNIFE_DAMAGE_BODY: = 55.0
const KNIFE_DAMAGE_HEAD: = 80.0
const KNIFE_DAMAGE_LEGS: = 45.0
const MAX_RAGDOLLS: = 4
const PLAYER_ID: = "player"

# зона
const ZONE_START_RADIUS: = 245.0
const ZONE_HEIGHT: = 90.0
const ZONE_TICK: = 0.5
# фазы: [пауза, сжатие, целевой радиус, урон/сек]
const ZONE_PHASES: = [
	[40.0, 35.0, 150.0, 1.0], 
	[30.0, 30.0, 95.0, 2.0], 
	[25.0, 25.0, 55.0, 4.0], 
	[20.0, 20.0, 26.0, 6.0], 
	[15.0, 15.0, 8.0, 10.0], 
]

# строительство (система res://br/building/, только подрежим "со строительством")
const MAT_KEYS: = ["wood", "stone", "metal"]
const LOOT_COUNT: = 70
# автобус
const BUS_HEIGHT: = 105.0
const BUS_SPEED: = 22.0
const GLIDE_FALL_MAX: = - 11.0

const ACCENT: = Color(1.0, 0.55, 0.16, 1.0)
const ACCENT_BRIGHT: = Color(1.0, 0.8, 0.4, 1.0)
const MUTED: = Color(0.62, 0.665, 0.725, 1.0)
const GREEN: = Color(0.36, 1.0, 0.55, 1.0)
const RED: = Color(1.0, 0.31, 0.27, 1.0)
const CYAN: = Color(0.32, 0.86, 1.0, 1.0)
const VIOLET: = Color(0.78, 0.55, 1.0, 1.0)

const DM_SKY_TOP: = Color(0.115, 0.105, 0.245, 1.0)
const DM_SKY_HORIZON: = Color(0.985, 0.56, 0.285, 1.0)
const DM_FOG_COLOR: = Color(0.9, 0.61, 0.43, 1.0)

var phase: = Phase.INTRO
var map: Node3D
var world_environment: WorldEnvironment
var world_view
var _settings

var _safeguard: = SAFEGUARD_TIME
var _first_blood: = false
var _transitioning: = false
var _intro_running: = false
var _phase_before_pause: = Phase.LIVE
var _leaderboard_clock: = 0.0
var _player_guard: = 0.0

var _fighters: Array[Node3D] = []
var _bot_nodes: Array[Node3D] = []
var _stats: Dictionary = {}
var _last_hit_by: Dictionary = {}
var _damage_log: Dictionary = {}
var _ragdolls: Array[Node3D] = []

var _buy_menu: CanvasLayer = null

var _match_stats: = {
	"shots": 0, 
	"hits": 0, 
	"damage": 0.0, 
	"damage_taken": 0.0, 
}

var _player_name: = "ИГРОК"
var _player_weapon: = "ak47"
var _player_place: = 1

var _death_camera: = false
var _death_look: = Vector3.ZERO
var _death_cam_tween: Tween
var _sun: DirectionalLight3D
var _sun_default_shadow: = false
var _applied_effects_quality: = -1
var _world_tint_mat: ShaderMaterial

# зона — состояние
var _zone_center: = Vector3.ZERO
var _zone_radius: = ZONE_START_RADIUS
var _zone_phase: = -1
var _zone_mode: = 0
var _zone_timer: = 0.0
var _zone_radius_from: = ZONE_START_RADIUS
var _zone_damage_clock: = 0.0
var _zone_wall: MeshInstance3D
var _zone_material: StandardMaterial3D
var _zone_points_clock: = 0.0
var _zone_warned: = false

# строительство — система (подрежим "со строительством")
var _build_enabled: = false
var build_manager: Node
var _build_hud: CanvasLayer

# автобус и лут
var _bus: Node3D
var _bus_from: = Vector3.ZERO
var _bus_to: = Vector3.ZERO
var _bus_progress: = 0.0

@onready var player = $Player
@onready var hud = $HUD
@onready var dm_hud = $DMHUD
@onready var arena: Node3D = $Arena
@onready var bots_root: Node3D = $Bots


func _ready() -> void :
	randomize()
	_player_name = _resolve_player_name()
	_player_weapon = _resolve_player_weapon()
	_build_enabled = _resolve_build_enabled()
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
	_setup_zone()
	_setup_build_system()
	_spawn_loot()
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
	dm_hud.set_timer_visible(false)
	dm_hud.set_br_panel_visible(true)
	dm_hud.set_leaderboard(_sorted_rows())
	dm_hud.set_br_status(_alive_count(), FIGHTER_COUNT, "РАЗВЁРТКА", "—")

	Settings.settings_changed.connect(_apply_environment)
	Settings.settings_changed.connect(_apply_quality_lighting)
	Settings.settings_changed.connect(_apply_world_tint)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Sfx.play_start()
	call_deferred("_begin_intro")


func _resolve_player_name() -> String:
	var nickname: = Settings.nickname.strip_edges().to_upper()
	return nickname if not nickname.is_empty() else "ИГРОК"


func _resolve_player_weapon() -> String:
	var id: = str(Settings.weapon_id)
	if not WeaponData.WEAPONS.has(id) or WeaponData.is_melee(id):
		return "ak47"
	return id


func _resolve_build_enabled() -> bool:
	# выбор подрежима хранится в res://br/data/br_settings.tres
	var settings_resource: Resource = load("res://br/data/br_settings.tres")
	if settings_resource != null:
		var value: Variant = settings_resource.get("building_enabled")
		if value != null:
			return bool(value)
	return bool(Settings.br_build)


func _setup_world_view() -> void :
	world_view = WorldViewScript.new()
	world_view.name = "WorldView"
	add_child(world_view)
	world_view.setup(player.camera)


func _place_player_initial() -> void :
	var start: = Vector3(0.0, 0.06, 145.0)
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
	_fighters.append(player)
	_stats[PLAYER_ID] = {
		"id": PLAYER_ID, 
		"name": _player_name, 
		"is_player": true, 
		"node": player, 
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
	var names: = BotNames.new()
	var used: Dictionary = {_player_name: true}
	var spawns: Array = []
	var raw: Variant = map.get("spawn_points")
	if raw is Array:
		spawns = (raw as Array).duplicate()
		# убрать точку игрока из списка ботов
		var player_start: Vector3 = Vector3(0.0, 0.06, 145.0)
		if map != null:
			var value: Variant = map.get("player_start")
			if value is Vector3:
				player_start = value
		var filtered: Array = []
		for point in spawns:
			if point is Vector3 \
					and (point as Vector3).distance_to(player_start) < 10.0:
				continue
			filtered.append(point)
		spawns = filtered
	spawns.shuffle()
	var count: = FIGHTER_COUNT - 1
	for i in count:
		var nick: = _unique_nick(names, used)
		var spawn: Vector3 = Vector3(0.0, 0.06, -145.0)
		if spawns.size() > 0:
			spawn = spawns[i % spawns.size()]
		var weapon: = str(BOT_WEAPONS[randi() % BOT_WEAPONS.size()])
		var skin_id: = _first_skin(weapon)
		var bot = BOT_SCRIPT.new()
		bot.name = "BrBot%d" % i
		bot.set_weapon(weapon, skin_id)
		var bot_skin: = str(BOT_SCRIPT.SKINS[randi() % BOT_SCRIPT.SKINS.size()])
		bot.configure(player, randf_range(950.0, 1750.0), bot_skin)
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
		_fighters.append(bot)
		_bot_nodes.append(bot)
		_stats[id] = {
			"id": id, 
			"name": nick, 
			"is_player": false, 
			"node": bot, 
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
			bot.set_dm_targets(all)


# ---------- зона ----------

func _setup_zone() -> void :
	_zone_center = Vector3(randf_range(-40.0, 40.0), 0.0, 
		randf_range(-40.0, 40.0))
	_zone_radius = ZONE_START_RADIUS
	_zone_phase = -1
	_zone_mode = 0
	_zone_timer = ZONE_PHASES[0][0]
	_zone_wall = MeshInstance3D.new()
	_zone_wall.name = "ZoneWall"
	var cyl: = CylinderMesh.new()
	cyl.top_radius = 1.0
	cyl.bottom_radius = 1.0
	cyl.height = ZONE_HEIGHT
	cyl.radial_segments = 96
	cyl.rings = 1
	_zone_wall.mesh = cyl
	_zone_material = StandardMaterial3D.new()
	_zone_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_zone_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_zone_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_zone_material.albedo_color = Color(0.6, 0.32, 1.0, 0.14)
	_zone_material.no_fog = true
	_zone_wall.material_override = _zone_material
	_zone_wall.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_zone_wall.position = Vector3(_zone_center.x, ZONE_HEIGHT * 0.5 - 4.0, 
		_zone_center.z)
	_zone_wall.visible = false
	add_child(_zone_wall)
	_update_zone_wall()


func _update_zone_wall() -> void :
	if _zone_wall == null:
		return
	_zone_wall.scale = Vector3(_zone_radius, 1.0, _zone_radius)
	_zone_wall.position = Vector3(_zone_center.x, 
		ZONE_HEIGHT * 0.5 - 4.0, _zone_center.z)


func _tick_zone(delta: float) -> void :
	_zone_timer = maxf(0.0, _zone_timer - delta)
	if _zone_mode == 0:
		if _zone_timer <= 0.0:
			_zone_phase += 1
			if _zone_phase >= ZONE_PHASES.size():
				_zone_mode = 2
			else:
				_zone_mode = 1
				var spec: Array = ZONE_PHASES[_zone_phase]
				_zone_timer = float(spec[1])
				_zone_radius_from = _zone_radius
				_zone_warned = false
				dm_hud.announce("ЗОНА СЖИМАЕТСЯ!", VIOLET)
				Sfx.play_tick()
	elif _zone_mode == 1:
		var spec: Array = ZONE_PHASES[_zone_phase]
		var span: = maxf(0.01, float(spec[1]))
		var target: = float(spec[2])
		var t: = 1.0 - _zone_timer / span
		_zone_radius = lerpf(_zone_radius_from, target, t)
		_update_zone_wall()
		if _zone_timer <= 0.0:
			_zone_radius = target
			_zone_mode = 0
			_zone_timer = float(ZONE_PHASES[_zone_phase + 1][0]) \
				if _zone_phase + 1 < ZONE_PHASES.size() else 0.0
			_update_zone_wall()
	# урон вне зоны
	_zone_damage_clock -= delta
	if _zone_damage_clock <= 0.0:
		_zone_damage_clock = ZONE_TICK
		_apply_zone_damage()
	# точки для ботов
	_zone_points_clock -= delta
	if _zone_points_clock <= 0.0:
		_zone_points_clock = 2.5
		_push_zone_points()


func _zone_damage_per_second() -> float:
	if _zone_phase < 0:
		return 0.5
	if _zone_phase >= ZONE_PHASES.size():
		return 10.0
	return float(ZONE_PHASES[_zone_phase][3])


func _apply_zone_damage() -> void :
	var dps: = _zone_damage_per_second()
	var amount: = dps * ZONE_TICK
	for fighter in _fighters:
		if not is_instance_valid(fighter) or fighter == null:
			continue
		var alive: = true
		if fighter.has_method("is_alive"):
			alive = bool(fighter.call("is_alive"))
		elif fighter == player:
			alive = player.is_alive()
		if not alive:
			continue
		var pos: Vector3 = (fighter as Node3D).global_position
		if Vector2(pos.x - _zone_center.x, pos.z - _zone_center.z).length() \
				> _zone_radius:
			if fighter == player:
				if _player_guard <= 0.0:
					player.take_damage(amount, Vector3.ZERO)
					if not _zone_warned:
						_zone_warned = true
						dm_hud.popup("ТЫ ВНЕ ЗОНЫ!", RED)
			elif fighter.has_method("take_damage"):
				fighter.call("take_damage", amount, Vector3.ZERO)


func _push_zone_points() -> void :
	var pool: Array = []
	var raw_hold: Variant = map.get("bot_hold_points") if map != null else null
	if raw_hold is Array:
		pool = raw_hold
	var raw_nav: Variant = map.get("bot_nav_points") if map != null else null
	if raw_nav is Array:
		for p in raw_nav:
			pool.append(p)
	var limit: = _zone_radius * 0.72
	var inside: Array = []
	for p in pool:
		if p is Vector3:
			var point: Vector3 = p
			if Vector2(point.x - _zone_center.x, point.z - _zone_center.z)\
					.length() <= limit:
				inside.append(point)
	if inside.is_empty():
		inside.append(_zone_center)
	for bot in _bot_nodes:
		if not is_instance_valid(bot) or not bool(bot.call("is_alive")):
			continue
		var nearest: Array = _nearest_points(inside, 
			(bot as Node3D).global_position, 14)
		bot.call("set_zone_points", nearest)


func _nearest_points(points: Array, from: Vector3, count: int) -> Array:
	var scored: = []
	for p in points:
		scored.append([from.distance_squared_to(p), p])
	scored.sort_custom( func(a: Array, b: Array) -> bool:
		return a[0] < b[0])
	var result: = []
	for i in mini(count, scored.size()):
		result.append(scored[i][1])
	return result


func _zone_status_text() -> String:
	if _zone_mode == 2:
		return "ФИНАЛ · ДЕРЖИСЬ В ЗОНЕ"
	if _zone_mode == 1:
		return "ЗОНА СЖИМАЕТСЯ"
	if _zone_phase + 1 < ZONE_PHASES.size():
		return "ЗОНА ЧЕРЕЗ:"
	return "ФИНАЛЬНАЯ ЗОНА"


# ---------- строительство (build_manager) ----------

func _setup_build_system() -> void :
	if _build_enabled:
		build_manager = BuildManagerScript.new()
		build_manager.name = "BuildManager"
		add_child(build_manager)
		build_manager.setup(self, player)
		_build_hud = BRBuildHudScript.new()
		_build_hud.name = "BRBuildHud"
		add_child(_build_hud)
		build_manager.mats_changed.connect(_build_hud.update_mats)
		build_manager.mode_changed.connect(_build_hud.update_mode)
		_build_hud.update_mats(0, 0, 0, 0)
	elif map != null and map.has_method("add_extra_cover"):
		# подрежим БЕЗ строительства: больше укрытий, ничего от стройки
		map.add_extra_cover()


func _tick_build(delta: float) -> void :
	if not _build_enabled or build_manager == null:
		return
	if phase != Phase.LIVE or not player.is_alive():
		build_manager.ghost.visible = false
		return
	build_manager.update_ghost()
	if player.has_meta("br_build") \
			and Input.is_action_just_pressed("shoot"):
		build_manager.try_place()


# ---------- автобус ----------

func _setup_bus() -> void :
	var angle: = randf() * TAU
	var direction: = Vector3(cos(angle), 0.0, sin(angle))
	_bus_from = - direction * 300.0 + Vector3(0.0, BUS_HEIGHT, 0.0)
	_bus_to = direction * 300.0 + Vector3(0.0, BUS_HEIGHT, 0.0)
	_bus_progress = 0.0
	_bus = Node3D.new()
	_bus.name = "BattleBus"
	_bus.position = _bus_from
	var body: = MeshInstance3D.new()
	body.mesh = MeshKit.box_mesh(Vector3(2.6, 2.5, 10.0))
	body.material_override = MeshKit.material(Color(0.95, 0.55, 0.1, 1.0), 
		0.6, 0.1)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.position = Vector3(0.0, 1.25, 0.0)
	_bus.add_child(body)
	var cabin: = MeshInstance3D.new()
	cabin.mesh = MeshKit.box_mesh(Vector3(2.4, 0.8, 2.0))
	cabin.material_override = MeshKit.material(Color(0.15, 0.2, 0.25, 1.0), 
		0.3, 0.2)
	cabin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cabin.position = Vector3(0.0, 2.9, 3.6)
	_bus.add_child(cabin)
	for side in [- 1.0, 1.0]:
		var window: = MeshInstance3D.new()
		window.mesh = MeshKit.box_mesh(Vector3(0.1, 0.9, 7.0))
		window.material_override = MeshKit.material(
			Color(0.4, 0.7, 0.9, 1.0), 0.2, 0.4)
		window.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		window.position = Vector3(side * 1.32, 1.7, 0.0)
		_bus.add_child(window)
	add_child(_bus)
	var yaw: = atan2( - direction.x, - direction.z)
	_bus.rotation.y = yaw
	player.global_position = _bus_from + Vector3(0.0, 11.0, 0.0)
	player.rotation.y = yaw
	player.set("_pitch", - 0.62)
	player.head.rotation.x = - 0.62
	player.active = false


func _tick_bus(delta: float) -> void :
	_bus_progress += delta * BUS_SPEED / 600.0
	if _bus_progress >= 1.0:
		_eject_from_bus()
		return
	var pos: = _bus_from.lerp(_bus_to, _bus_progress)
	_bus.position = pos
	player.global_position = pos + Vector3(0.0, 11.0, 0.0)


func _eject_from_bus() -> void :
	if phase != Phase.BUS:
		return
	phase = Phase.GLIDE
	var pos: = _bus_from.lerp(_bus_to, minf(_bus_progress, 1.0))
	player.global_position = pos + Vector3(0.0, 11.0, 0.0)
	player.rotation.y = _bus.rotation.y
	player.active = true
	player.velocity = Vector3( - _bus_from.direction_to(_bus_to).x * 8.0, 
		- 2.0, - _bus_from.direction_to(_bus_to).z * 8.0)
	if _bus != null and is_instance_valid(_bus):
		var bus_node: = _bus
		var timer: = get_tree().create_timer(6.0)
		timer.timeout.connect( func() -> void :
			if is_instance_valid(bus_node):
				bus_node.queue_free())
		_bus = null
	dm_hud.announce("ГЛАЙДЕР · ИЩИ МЕСТО ПОСАДКИ", CYAN)


func _tick_glide(delta: float) -> void :
	# планер: падение замедлено до посадки
	if not player.is_on_floor():
		if player.velocity.y < GLIDE_FALL_MAX:
			player.velocity.y = GLIDE_FALL_MAX
		return
	_start_live()


func _start_live() -> void :
	phase = Phase.LIVE
	player.active = true
	if _zone_wall != null:
		_zone_wall.visible = true
	for bot in _bot_nodes:
		if is_instance_valid(bot):
			bot.active = true
	_start_player_guard()
	_refresh_bot_targets()
	_push_zone_points()
	if _build_enabled:
		dm_hud.popup("Q СТЕНА · Z ПОЛ · X ЛЕСТНИЦА · C КРЫША", CYAN)
	else:
		dm_hud.popup("ЛУТАЙ ОРУЖИЕ И ДЕРЖИСЬ В ЗОНЕ", CYAN)


# ---------- лут ----------

func _spawn_loot() -> void :
	if map == null:
		return
	var raw: Variant = map.get("loot_points")
	if not (raw is Array):
		return
	var points: Array = (raw as Array).duplicate()
	points.shuffle()
	var count: = mini(points.size(), LOOT_COUNT)
	for i in count:
		if not (points[i] is Vector3):
			continue
		var point: Vector3 = points[i]
		var kind: = _roll_loot_kind()
		var payload = null
		if kind == "weapon":
			payload = BOT_WEAPONS[randi() % BOT_WEAPONS.size()]
		elif kind == "mats":
			payload = MAT_KEYS[randi() % MAT_KEYS.size()]
		var pickup := LootPickupScript.new()
		pickup.setup(kind, payload, point)
		pickup.target = player
		pickup.collected.connect(_on_loot_collected)
		add_child(pickup)


func _roll_loot_kind() -> String:
	var roll: = randf()
	if _build_enabled:
		# 25% аптечка / 30% патроны / 15% оружие / 30% материалы
		if roll < 0.25:
			return "health"
		if roll < 0.55:
			return "ammo"
		if roll < 0.7:
			return "weapon"
		return "mats"
	# без строительства материалы не выпадают
	if roll < 0.35:
		return "health"
	if roll < 0.7:
		return "ammo"
	return "weapon"


func _on_loot_collected(kind: String, payload) -> void :
	if phase != Phase.LIVE or not player.is_alive():
		return
	if kind == "health":
		player.reset_health()
		dm_hud.popup("АПТЕЧКА · ПОЛНОЕ ЛЕЧЕНИЕ", GREEN)
	elif kind == "ammo":
		var state: Dictionary = player.get_ammo_state()
		var magazine: = int(state.get("magazine", 0))
		if magazine > 0:
			var current: = int(player.get("_primary_ammo"))
			player.set("_primary_ammo", clampi(current + magazine * 2, 0, 
				magazine * 4))
			dm_hud.popup("+2 МАГАЗИНА", Color(1.0, 0.8, 0.25, 1.0))
	elif kind == "weapon":
		var weapon_id: = str(payload)
		player.set_duel_weapon(weapon_id, _first_skin(weapon_id))
		dm_hud.popup("ОРУЖИЕ · %s" % weapon_id.to_upper(), CYAN)
	elif kind == "mats" and _build_enabled and build_manager != null:
		build_manager.add_mats(str(payload), randi_range(30, 50))
		dm_hud.popup("МАТЕРИАЛЫ +30-50", Color(0.76, 0.6, 0.38, 1.0))


# ---------- подключение ----------

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


func _on_player_damaged(_amount: float, _from_position: Vector3) -> void :
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
	var collider_shot: Object = hit.get("collider")
	if _build_enabled and build_manager != null and collider_shot is Node \
			and (collider_shot as Node).is_in_group("build_piece"):
		var weapon_info: = WeaponData.get_weapon(
			str(hit.get("weapon", _player_weapon)))
		build_manager.damage_piece(collider_shot as Node, 
			float(weapon_info.get("damage_body", 36.0)))
		hud.kick_crosshair(1.2)
		return
	var zone: = str(hit.get("zone", "body"))
	var headshot: = bool(hit.get("headshot", false))
	if not bool(hit.get("mannequin", false)):
		hud.kick_crosshair(1.6)
		return
	var target: = _hit_target(hit)
	if target == null:
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
	var collider_melee: Object = hit.get("collider")
	if _build_enabled and build_manager != null and collider_melee is Node \
			and (collider_melee as Node).is_in_group("harvestable"):
		build_manager.knife_hit(hit)
		hud.kick_crosshair(1.4)
		return
	if not bool(hit.get("mannequin", false)):
		hud.kick_crosshair(1.4)
		return
	var zone: = str(hit.get("zone", "body"))
	var target: = _hit_target(hit)
	if target == null:
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
	var alive: = _alive_count()
	_player_place = alive + 1
	_handle_death(player)
	_finish_match()


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
	var alive: = _alive_count()
	if alive <= 1 and player.is_alive():
		_player_place = 1
		_finish_match()
	_refresh_br_status()


func _alive_count() -> int:
	var total: = 0
	for fighter in _fighters:
		if not is_instance_valid(fighter):
			continue
		var alive: = false
		if fighter.has_method("is_alive"):
			alive = bool(fighter.call("is_alive"))
		elif fighter == player:
			alive = player.is_alive()
		if alive:
			total += 1
	return total


func _refresh_br_status() -> void :
	var seconds: = _zone_timer
	if _zone_mode == 1:
		seconds = _zone_timer
	dm_hud.set_br_status(_alive_count(), FIGHTER_COUNT, _zone_status_text(), 
		"%d с" % int(ceil(seconds)))


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
	# боты BR: стена между собой и врагом / лестница
	if _build_enabled and build_manager != null \
			and victim_id.begins_with("bot_") and is_instance_valid(victim) \
			and is_instance_valid(attacker) and victim is Node3D \
			and attacker is Node3D:
		build_manager.bot_react(victim as Node3D, attacker as Node3D)


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
		hud.add_dm_killfeed("ЗОНА", victim_name, "storm", false, VIOLET)
	else:
		var killer_stats: Dictionary = _stats.get(killer_id, {})
		if killer_stats.is_empty():
			hud.add_dm_killfeed("—", victim_name, weapon, headshot, MUTED)
		else:
			var killer_name: = str(killer_stats.get("name", "—"))
			var points: = 100
			if headshot:
				points += 50
			var first: = not _first_blood
			if first:
				first = true
				_first_blood = true
				points += 25
			killer_stats["kills"] = int(killer_stats.get("kills", 0)) + 1
			if headshot:
				killer_stats["headshots"] = int(killer_stats.get("headshots", 0)) + 1
			killer_stats["points"] = int(killer_stats.get("points", 0)) + points
			_stats[killer_id] = killer_stats

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
				dm_hud.popup(text, GREEN)
			elif victim_id == PLAYER_ID:
				dm_hud.show_killed_by(killer_name, weapon)
			if first:
				dm_hud.announce("ПЕРВАЯ КРОВЬ · " + killer_name, ACCENT_BRIGHT)

	_last_hit_by.erase(victim_id)
	_damage_log.erase(victim_id)
	_leaderboard_clock = 0.0


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
	var mode_text: = "СО СТРОИТЕЛЬСТВОМ" if _build_enabled \
		else "БЕЗ СТРОИТЕЛЬСТВА"
	dm_hud.configure_intro(
		"ЛЮБИТЕЛЬСКИЙ РЕЖИМ  ·  РЕЙТИНГ НЕ ВЛИЯЕТ", 
		"БАТЛ РОЯЛЬ", 
		"КВАРТАЛ «СЕРЫЙ»  ·  %d БОЙЦОВ  ·  %s" % [FIGHTER_COUNT, mode_text], 
		"ПРЫГАЙ С АВТОБУСА  ·  ЛУТАЙ ОРУЖИЕ  ·  ДЕРЖИСЬ ВНУТРИ ЗОНЫ", 
		"ПРОБЕЛ — ПРЫЖОК С АВТОБУСА. ПОБЕДА — ПОСЛЕДНИЙ ВЫЖИВШИЙ "
			+ "ИЗ %d БОЙЦОВ." % FIGHTER_COUNT)
	dm_hud.show_intro()
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
	dm_hud.set_intro_countdown("ВЗЛЁТ")
	Sfx.play_start()
	await _wait(0.4)
	if not is_inside_tree() or phase != Phase.INTRO:
		_intro_running = false
		return
	await dm_hud.hide_intro()
	if not is_inside_tree() or phase != Phase.INTRO:
		_intro_running = false
		return
	# автобус: игрок на крыше, ПРОБЕЛ — прыжок
	_setup_bus()
	phase = Phase.BUS
	_intro_running = false
	dm_hud.popup("ПРОБЕЛ — ПРЫЖОК С АВТОБУСА", CYAN)


func _process(delta: float) -> void :
	if player != null and hud != null:
		hud.set_reload_progress(player.get_reload_progress(), 
			player.get_reload_remaining())
	if phase == Phase.LIVE:
		_safeguard = maxf(0.0, _safeguard - delta)
		_tick_zone(delta)
		_tick_build(delta)
		_tick_player_guard(delta)
		_refresh_br_status()
		if _safeguard <= 0.0:
			_player_place = _alive_count() if player.is_alive() \
				else _alive_count() + 1
			_finish_match()
	elif phase == Phase.BUS and _bus != null:
		_tick_bus(delta)
	elif phase == Phase.GLIDE:
		_tick_glide(delta)
	_leaderboard_clock -= delta
	if _leaderboard_clock <= 0.0:
		_leaderboard_clock = 0.16
		dm_hud.set_leaderboard(_sorted_rows())
	if _death_camera:
		var offset: Vector3 = player.camera.global_position - _death_look
		if Vector2(offset.x, offset.z).length_squared() > 0.0625:
			player.camera.look_at(_death_look, Vector3.UP)


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


func _finish_match() -> void :
	if phase == Phase.ENDED:
		return
	phase = Phase.ENDED
	Engine.time_scale = 1.0
	_end_player_guard()
	player.remove_meta("br_build")
	player.active = false
	for bot in _bot_nodes:
		if is_instance_valid(bot):
			bot.active = false
	player.exit_scope()
	_restore_death_camera()
	hud.clear_death_fx()
	dm_hud.set_match_hud_visible(false)
	dm_hud.hide_guard()
	dm_hud.hide_killed_by()
	dm_hud.hide_scoreboard()
	if build_manager != null and build_manager.ghost != null:
		build_manager.ghost.visible = false
	var rows: = _sorted_rows()
	var own: = _player_row(rows)
	dm_hud.set_leaderboard(rows)
	dm_hud.show_result(rows, own, _match_stats)
	if _player_place == 1:
		dm_hud.override_result_title("ПОБЕДА! ТОП-1 ИЗ %d" % FIGHTER_COUNT)
		Sfx.play_victory()
	else:
		dm_hud.override_result_title("МЕСТО #%d ИЗ %d" % [_player_place, 
			FIGHTER_COUNT])
		Sfx.play_finish()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _wait(seconds: float) -> void :
	if seconds <= 0.0:
		return
	await get_tree().create_timer(seconds, false).timeout


func _yaw_to_center(from: Vector3) -> float:
	var direction: = Vector3(0.0, from.y, 0.0) - from
	direction.y = 0.0
	if direction.length_squared() < 0.01:
		return 0.0
	return atan2( - direction.x, - direction.z)


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
	# лёгкий туман: с высоты автобуса должна быть видна вся карта
	if environment.fog_enabled:
		environment.fog_density = 0.0045
		environment.fog_sky_affect = 0.35
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


func _unhandled_input(event: InputEvent) -> void :
	if event is InputEventKey and event.pressed and not event.echo:
		var key: = event as InputEventKey
		if _handle_build_key(key):
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("jump") and phase == Phase.BUS:
		_eject_from_bus()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed \
			and phase == Phase.LIVE and _build_enabled \
			and build_manager != null and player.has_meta("br_build"):
		var button: = event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_WHEEL_UP:
			build_manager.set_mat(
				(build_manager.mat_index + 2) % 3)
			get_viewport().set_input_as_handled()
			return
		if button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			build_manager.set_mat(
				(build_manager.mat_index + 1) % 3)
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("pause"):
		if phase == Phase.LIVE:
			_pause()
			get_viewport().set_input_as_handled()
		elif phase == Phase.PAUSED:
			_resume()
			get_viewport().set_input_as_handled()


func _handle_build_key(key: InputEventKey) -> bool:
	# Q/Z/X/C — элементы стройки, G — проём, 1-3 — материал в режиме стройки.
	if not _build_enabled or build_manager == null:
		return false
	if phase != Phase.LIVE:
		return false
	match key.physical_keycode:
		KEY_Q:
			build_manager.toggle_for("wall")
			return true
		KEY_Z:
			build_manager.toggle_for("floor")
			return true
		KEY_X:
			build_manager.toggle_for("stairs")
			return true
		KEY_C:
			build_manager.toggle_for("roof")
			return true
		KEY_G:
			build_manager.toggle_doorway()
			return true
		KEY_1, KEY_KP_1:
			if player.has_meta("br_build"):
				build_manager.set_mat(0)
				return true
		KEY_2, KEY_KP_2:
			if player.has_meta("br_build"):
				build_manager.set_mat(1)
				return true
		KEY_3, KEY_KP_3:
			if player.has_meta("br_build"):
				build_manager.set_mat(2)
				return true
	return false


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
	if build_manager != null and build_manager.ghost != null:
		build_manager.ghost.visible = false
	var own: Dictionary = _stats.get(PLAYER_ID, {})
	var mode_text: = "СО СТРОИТЕЛЬСТВОМ" if _build_enabled else "БЕЗ СТРОИТЕЛЬСТВА"
	hud.set_pause_stats("БАТЛ РОЯЛЬ · %s · БЕЗ РЕЙТИНГА" % mode_text)
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
