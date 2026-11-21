extends Node3D

# Карта de_dust2 в палитре HEADSHOT OFF.
# Меш собран tools/build_dust2.gd (vertex colors, без CS-текстур).
# Скрипт строит коллизию, спавны, сайты A/B и навигационную сетку для ботов.

signal map_ready

const MESH_PATH: = "res://assets/maps/dust2/dust2_mesh.res"

const T_SPAWN: = Vector3(-8.0, 0.0, 11.5)
const CT_SPAWNS: Array[Vector3] = [
	Vector3(1.0, 0.0, -1.0), 
	Vector3(5.0, 0.0, -2.5), 
	Vector3(-1.5, 0.0, 2.0), 
]
const SITE_A: = Vector3(3.5, 0.0, 6.0)
const SITE_B: = Vector3(-7.0, 0.0, -11.0)
const SITE_RADIUS: = 5.0

const NO_FLOOR: = Vector3(0.0, -9999.0, 0.0)

const NAV_STEP: = 1.4
const NAV_LINK_DIST: = 2.6
const NAV_LINK_RISE: = 0.8

var bot_nav_points: Array[Vector3] = []
var bot_nav_links: Array[Vector2i] = []
var bot_hold_points: Array[Vector3] = []
var bot_peek_points: Array[Vector3] = []
var bot_hunt_points: Array[Vector3] = []

var _aabb: = AABB()
var _t_spawn: = T_SPAWN
var _t_spawn_yaw: = 0.0
var _ct_spawns: Array[Vector3] = []
var _site_a: = SITE_A
var _site_b: = SITE_B
var _space: PhysicsDirectSpaceState3D
var _body: StaticBody3D


func _ready() -> void :
	_build_visual()
	_build_body()
	_build_environment()
	call_deferred("_build_world")


func get_t_spawn() -> Vector3:
	return _t_spawn


func get_t_spawn_yaw() -> float:
	return _t_spawn_yaw


func get_ct_spawns() -> Array[Vector3]:
	return _ct_spawns


func get_site_center(index: int) -> Vector3:
	return _site_a if index == 0 else _site_b


func get_site_radius() -> float:
	return SITE_RADIUS


func site_at(point: Vector3) -> int:
	var flat: = Vector2(point.x, point.z)
	if flat.distance_to(Vector2(_site_a.x, _site_a.z)) <= SITE_RADIUS:
		return 0
	if flat.distance_to(Vector2(_site_b.x, _site_b.z)) <= SITE_RADIUS:
		return 1
	return -1


func _build_visual() -> void :
	var mesh: Mesh = load(MESH_PATH) as Mesh
	if mesh == null:
		push_error("dust2 mesh missing")
		return
	_aabb = mesh.get_aabb()
	var instance: = MeshInstance3D.new()
	instance.name = "Dust2Mesh"
	instance.mesh = mesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)


func _build_body() -> void :
	if _aabb.size == Vector3.ZERO:
		return
	var mesh: Mesh = (get_node("Dust2Mesh") as MeshInstance3D).mesh
	var body: = StaticBody3D.new()
	body.name = "Dust2Body"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape: = CollisionShape3D.new()
	var trimesh: = mesh.create_trimesh_shape() as ConcavePolygonShape3D
	if trimesh != null:
		trimesh.backface_collision = true
	shape.shape = trimesh
	body.add_child(shape)
	add_child(body)
	_body = body


func _build_environment() -> void :
	var env: = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky: = Sky.new()
	var sky_mat: = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.3, 0.41, 0.55)
	sky_mat.sky_horizon_color = Color(0.88, 0.8, 0.65)
	sky_mat.ground_bottom_color = Color(0.32, 0.28, 0.22)
	sky_mat.ground_horizon_color = Color(0.88, 0.8, 0.65)
	sky_mat.sun_angle_max = 26.0
	sky_mat.sun_curve = 0.14
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.0
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.8, 0.73, 0.6)
	env.fog_density = 0.004
	env.fog_sky_affect = 0.25
	var world_env: = WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	world_env.environment = env
	add_child(world_env)

	var sun: = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-48.0, -42.0, 0.0)
	sun.light_color = Color(1.0, 0.95, 0.85)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)


func _build_world() -> void :
	if _aabb.size == Vector3.ZERO:
		map_ready.emit()
		return
	await get_tree().physics_frame
	await get_tree().physics_frame
	_space = get_world_3d().direct_space_state
	_build_nav_points()
	_resolve_spawns()
	_build_nav_links()
	_make_bot_points()
	map_ready.emit()


func _ground_at(point: Vector3) -> Vector3:
	if _space == null:
		return point
	var bottom: = _aabb.position.y - 3.0
	var y: = _aabb.end.y + 3.0
	var best: = NO_FLOOR
	var guard: = 0
	while guard < 24:
		guard += 1
		var query: = PhysicsRayQueryParameters3D.create(
			Vector3(point.x, y, point.z), Vector3(point.x, bottom, point.z), 1)
		var hit: Dictionary = _space.intersect_ray(query)
		if hit.is_empty():
			break
		var position: Vector3 = hit["position"]
		var normal: Vector3 = hit["normal"]
		if hit.get("collider") != _body:
			y = position.y - 0.04
			continue
		var candidate: = Vector3(point.x, position.y + 0.02, point.z)
		if absf(normal.y) > 0.4 and _is_free(candidate):
			best = candidate
		y = position.y - 0.04
	return best


func _is_free(point: Vector3) -> bool:
	if _space == null:
		return true
	var feet: = point + Vector3(0.0, 0.2, 0.0)
	if _ray_hits_map(feet, point + Vector3(0.0, 1.95, 0.0)):
		return false
	var chest: = point + Vector3(0.0, 1.05, 0.0)
	for direction in [Vector3(1, 0, 0), Vector3(-1, 0, 0), 
			Vector3(0, 0, 1), Vector3(0, 0, -1)]:
		if _ray_hits_map(chest, chest + direction * 0.45):
			return false
	return true


func _ray_hits_map(from: Vector3, to: Vector3) -> bool:
	var query: = PhysicsRayQueryParameters3D.create(from, to, 1)
	var hit: Dictionary = _space.intersect_ray(query)
	if hit.is_empty():
		return false
	return hit.get("collider") == _body


func _resolve_spawns() -> void :
	_ct_spawns.clear()
	if bot_nav_points.is_empty():
		_t_spawn = _safe_point(T_SPAWN)
		if _t_spawn == NO_FLOOR:
			_t_spawn = Vector3(0.0, 0.5, 0.0)
		_site_a = _safe_point(SITE_A)
		_site_b = _safe_point(SITE_B)
		if _site_a == NO_FLOOR:
			_site_a = _t_spawn + Vector3(6.0, 0.0, 0.0)
		if _site_b == NO_FLOOR:
			_site_b = _t_spawn - Vector3(6.0, 0.0, 0.0)
		_ct_spawns.append(_t_spawn + Vector3(4.0, 0.0, 4.0))
		return

	var center: Vector3 = _aabb.get_center()
	var site_a_index: = 0
	var site_a_distance: = -1.0
	for i in bot_nav_points.size():
		var point: Vector3 = bot_nav_points[i]
		var distance: = _flat_distance(point, center)
		if distance > site_a_distance:
			site_a_distance = distance
			site_a_index = i
	_site_a = bot_nav_points[site_a_index]

	_site_b = _farthest_from(bot_nav_points, _site_a)
	_t_spawn = _pick_t_spawn(bot_nav_points, center)
	_t_spawn_yaw = _yaw_toward(_t_spawn, center)

	# CT-спавны — ближе к середине между сайтами.
	var middle: = (_site_a + _site_b) * 0.5
	var guard: = 0
	while _ct_spawns.size() < 3 and guard < 64:
		guard += 1
		var best_index: = -1
		var best_distance: = INF
		for i in bot_nav_points.size():
			var point: Vector3 = bot_nav_points[i]
			if _flat_distance(point, _site_a) < 6.0:
				continue
			if _flat_distance(point, _site_b) < 6.0:
				continue
			if _flat_distance(point, _t_spawn) < 9.0:
				continue
			var crowded: = false
			for used in _ct_spawns:
				if _flat_distance(point, used) < 3.0:
					crowded = true
					break
			if crowded:
				continue
			var distance: = _flat_distance(point, middle)
			if distance < best_distance:
				best_distance = distance
				best_index = i
		if best_index < 0:
			break
		_ct_spawns.append(bot_nav_points[best_index])
	if _ct_spawns.is_empty():
		_ct_spawns.append(_site_a + Vector3(2.0, 0.0, 2.0))


func _pick_t_spawn(dense: Array[Vector3], center: Vector3) -> Vector3:
	var fallback: = dense[0]
	var fallback_score: = -1.0
	for point in dense:
		var score: = minf(_flat_distance(point, _site_a), _flat_distance(point, _site_b))
		if score > fallback_score:
			fallback_score = score
			fallback = point
		if score < 9.0:
			continue
		if not _blocked_between(point, _site_a) and not _blocked_between(point, _site_b):
			return point
	return fallback


func _blocked_between(a: Vector3, b: Vector3) -> bool:
	var query: = PhysicsRayQueryParameters3D.create(
		a + Vector3(0.0, 1.5, 0.0), b + Vector3(0.0, 1.5, 0.0), 1)
	var hit: Dictionary = _space.intersect_ray(query)
	return not hit.is_empty() and hit.get("collider") == _body


func _yaw_toward(from: Vector3, to: Vector3) -> float:
	var direction: = Vector3(to.x - from.x, 0.0, to.z - from.z).normalized()
	return atan2(-direction.x, -direction.z)


func _farthest_from(points: Array[Vector3], origin: Vector3) -> Vector3:
	var best: = origin
	var best_distance: = -1.0
	for point in points:
		var distance: = _flat_distance(point, origin)
		if distance > best_distance:
			best_distance = distance
			best = point
	return best


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _farthest_point(origin: Vector3, avoid: Array) -> Vector3:
	var best: = origin
	var best_distance: = -1.0
	for point in bot_nav_points:
		var distance: = _flat_distance(point, origin)
		for other in avoid:
			distance = minf(distance, _flat_distance(point, other))
		if distance > best_distance:
			best_distance = distance
			best = point
	return best


func _safe_point(point: Vector3) -> Vector3:
	var landed: = _ground_at(point)
	if landed != NO_FLOOR:
		return landed
	var radius: = 1.8
	while radius <= 9.0:
		for step in 8:
			var angle: = TAU * float(step) / 8.0
			var probe: = point + Vector3(cos(angle), 0.0, sin(angle)) * radius
			var found: = _ground_at(probe)
			if found != NO_FLOOR:
				return found
		radius += 1.8
	return NO_FLOOR


func _build_nav_points() -> void :
	bot_nav_points.clear()
	bot_nav_links.clear()
	var step: = NAV_STEP
	var x: = _aabb.position.x + 1.0
	while x <= _aabb.end.x - 1.0:
		var z: = _aabb.position.z + 1.0
		while z <= _aabb.end.z - 1.0:
			var point: = _ground_at(Vector3(x, 0.0, z))
			if point != NO_FLOOR:
				bot_nav_points.append(point)
			z += step
		x += step


func _build_nav_links() -> void :
	bot_nav_links.clear()
	var cell: = NAV_LINK_DIST
	var buckets: Dictionary = {}
	for i in bot_nav_points.size():
		var point: Vector3 = bot_nav_points[i]
		var key: = "%d_%d" % [int(floor(point.x / cell)), int(floor(point.z / cell))]
		var bucket: Array = buckets.get(key, [])
		bucket.append(i)
		buckets[key] = bucket

	for i in bot_nav_points.size():
		var a: Vector3 = bot_nav_points[i]
		var cx: = int(floor(a.x / cell))
		var cz: = int(floor(a.z / cell))
		for ox in range(-1, 2):
			for oz in range(-1, 2):
				var key: = "%d_%d" % [cx + ox, cz + oz]
				var bucket: Array = buckets.get(key, [])
				for entry in bucket:
					var j: int = int(entry)
					if j <= i:
						continue
					var b: Vector3 = bot_nav_points[j]
					if absf(a.y - b.y) > NAV_LINK_RISE:
						continue
					if Vector2(a.x - b.x, a.z - b.z).length() > NAV_LINK_DIST:
						continue
					if _segment_blocked(a, b):
						continue
					bot_nav_links.append(Vector2i(i, j))

	_make_bot_points()


func _segment_blocked(a: Vector3, b: Vector3) -> bool:
	var query: = PhysicsRayQueryParameters3D.create(
		a + Vector3(0.0, 0.9, 0.0), b + Vector3(0.0, 0.9, 0.0), 1)
	var hit: Dictionary = _space.intersect_ray(query)
	if hit.is_empty():
		return false
	return hit.get("collider") == _body


func _make_bot_points() -> void :
	bot_hold_points.clear()
	bot_peek_points.clear()
	bot_hunt_points.clear()
	for site_index in 2:
		var center: = get_site_center(site_index)
		bot_hold_points.append(center)
		for ring in 4:
			var angle: = TAU * float(ring) / 4.0
			var offset: = Vector3(cos(angle), 0.0, sin(angle)) * 3.0
			var ring_point: = _safe_point(center + offset)
			if ring_point != NO_FLOOR:
				bot_hold_points.append(ring_point)
		var toward: = (Vector3.ZERO - center).normalized()
		for ring in 3:
			var offset: = toward * (2.5 + float(ring) * 2.0)
			var peek_point: = _safe_point(center + offset)
			if peek_point != NO_FLOOR:
				bot_peek_points.append(peek_point)
	var stride: = maxi(1, bot_nav_points.size() / 24)
	var index: = 0
	while index < bot_nav_points.size():
		bot_hunt_points.append(bot_nav_points[index])
		index += stride
