extends Node3D
## БАТЛ РОЯЛЬ: огромная карта (340 x 340 м) в духе Fortnite.
## Город в центре, четыре POI по квадрантам, холмы, деревья, скалы.
## Даёт боту/игроку: spawn_points, player_start, bot_start,
## bot_hold_points, bot_hunt_points, bot_nav_points.

const MeshKit = preload("res://scripts/mesh_kit.gd")
const FLOOR_SHADER = preload("res://shaders/arena_floor.gdshader")

const HALF: = 170.0
const WALL_HEIGHT: = 14.0

var spawn_points: Array[Vector3] = []
var player_start: = Vector3(0.0, 0.05, 40.0)
var bot_start: = Vector3(0.0, 0.05, -40.0)
var bot_hold_points: Array[Vector3] = []
var bot_hunt_points: Array[Vector3] = []
var bot_nav_points: Array[Vector3] = []
var loot_points: Array[Vector3] = []

var _grass: StandardMaterial3D
var _road: StandardMaterial3D
var _wall: StandardMaterial3D
var _brick: StandardMaterial3D
var _roof: StandardMaterial3D
var _wood: StandardMaterial3D
var _metal: StandardMaterial3D
var _rock: StandardMaterial3D
var _trunk: StandardMaterial3D
var _leaf: StandardMaterial3D
var _accent: StandardMaterial3D

var _batches: Dictionary = {}


func _ready() -> void :
	_build_materials()
	_build_terrain()
	_build_town()
	_build_pois()
	_build_nature()
	_build_environment_walls()
	_build_lights()
	_build_spawn_points()
	_flush_visuals()


func _build_materials() -> void :
	_grass = MeshKit.material(Color(0.38, 0.62, 0.3, 1.0), 0.95, 0.0)
	_road = MeshKit.material(Color(0.45, 0.43, 0.4, 1.0), 0.9, 0.0)
	_wall = MeshKit.material(Color(0.9, 0.88, 0.84, 1.0), 0.9, 0.0)
	_brick = MeshKit.material(Color(0.72, 0.45, 0.32, 1.0), 0.9, 0.0)
	_roof = MeshKit.material(Color(0.55, 0.3, 0.24, 1.0), 0.9, 0.0)
	_wood = MeshKit.material(Color(0.66, 0.52, 0.34, 1.0), 0.9, 0.0)
	_metal = MeshKit.material(Color(0.55, 0.58, 0.62, 1.0), 0.6, 0.35)
	_rock = MeshKit.material(Color(0.5, 0.48, 0.45, 1.0), 0.95, 0.0)
	_trunk = MeshKit.material(Color(0.42, 0.31, 0.2, 1.0), 0.95, 0.0)
	_leaf = MeshKit.material(Color(0.24, 0.52, 0.22, 1.0), 0.95, 0.0)
	_accent = MeshKit.material(Color(0.98, 0.66, 0.12, 1.0), 0.6, 0.0, 
		Color(1.0, 0.7, 0.2, 1.0), 0.3)


# ---------- примитивы ----------

func _solid(size: Vector3, pos: Vector3, mat: Material, 
		rot: = Vector3.ZERO) -> void :
	_collision(size, pos, rot)
	_batch(size, pos, mat, rot)


func _collision(size: Vector3, pos: Vector3, rot: Vector3) -> void :
	var body: = StaticBody3D.new()
	body.position = pos
	body.rotation_degrees = rot
	add_child(body)
	var shape: = BoxShape3D.new()
	shape.size = size
	var col: = CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)


func _batch(size: Vector3, pos: Vector3, mat: Material, rot: Vector3) -> void :
	if not _batches.has(mat):
		_batches[mat] = []
	var basis: = Basis.from_euler(rot * (PI / 180.0))
	_batches[mat].append([MeshKit.box_mesh(size), Transform3D(basis, pos)])


func _flush_visuals() -> void :
	for mat in _batches:
		var parts: Array = _batches[mat]
		if parts.is_empty():
			continue
		var inst: = MeshInstance3D.new()
		inst.mesh = MeshKit.merged_boxes(parts)
		inst.material_override = mat
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		inst.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		add_child(inst)
	_batches.clear()


# ---------- рельеф ----------

func _build_terrain() -> void :
	# основной пол
	var body: = StaticBody3D.new()
	body.name = "Floor"
	add_child(body)
	var shape: = BoxShape3D.new()
	shape.size = Vector3(HALF * 2.0 + 4.0, 0.6, HALF * 2.0 + 4.0)
	var col: = CollisionShape3D.new()
	col.shape = shape
	col.position = Vector3(0.0, -0.3, 0.0)
	body.add_child(col)
	var mesh: = MeshInstance3D.new()
	mesh.mesh = MeshKit.box_mesh(shape.size)
	var floor_mat: = ShaderMaterial.new()
	floor_mat.shader = FLOOR_SHADER
	floor_mat.set_shader_parameter("base_color", Color(0.36, 0.58, 0.29, 1.0))
	floor_mat.set_shader_parameter("seam_color", Color(0.25, 0.42, 0.22, 1.0))
	floor_mat.set_shader_parameter("tile_size", 4.0)
	mesh.material_override = floor_mat
	mesh.position = Vector3(0.0, -0.3, 0.0)
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_child(mesh)

	# дороги: крест через всю карту (декор без коллизии)
	_batch(Vector3(HALF * 2.0, 0.08, 9.0), Vector3(0.0, 0.04, 0.0), _road, 
		Vector3.ZERO)
	_batch(Vector3(9.0, 0.08, HALF * 2.0), Vector3(0.0, 0.04, 0.0), _road, 
		Vector3.ZERO)

	# холмы: платформы с рампами
	var hills: = [
		[Vector3(-95.0, 0.0, -95.0), 10.0], 
		[Vector3(105.0, 0.0, -85.0), 8.0], 
		[Vector3(-105.0, 0.0, 100.0), 7.0], 
		[Vector3(90.0, 0.0, 105.0), 9.0], 
	]
	for h in hills:
		var spec: Array = h
		var center: Vector3 = spec[0]
		var height: float = spec[1]
		_solid(Vector3(52.0, height, 52.0), 
			center + Vector3(0.0, height * 0.5, 0.0), _grass)
		_solid(Vector3(14.0, 0.5, height * 2.6), 
			center + Vector3(0.0, height * 0.5 + 0.25, 
			26.0 + height * 1.1), _road, 
			Vector3(rad_to_deg(asin(1.0 / 2.6)), 0.0, 0.0))
		_batch(Vector3(54.0, 0.5, 54.0), 
			center + Vector3(0.0, height + 0.2, 0.0), _grass, Vector3.ZERO)


# ---------- дом (кирпичный, с дверью и окнами) ----------

func _house(center: Vector3, width: = 12.0, depth: = 10.0, height: = 6.0, 
		mat: = _brick) -> void :
	var t: = 0.5
	# четыре стены с дверным проёмом на +z стороне
	_solid(Vector3(width, height, t), center + Vector3(0.0, height * 0.5, 
		- depth * 0.5), mat)
	_solid(Vector3(t, height, depth), center + Vector3(- width * 0.5, 
		height * 0.5, 0.0), mat)
	_solid(Vector3(t, height, depth), center + Vector3(width * 0.5, 
		height * 0.5, 0.0), mat)
	# фасад: два сегмента + перемычка над дверью
	_solid(Vector3(width * 0.38, height, t), 
		center + Vector3(- width * 0.31, height * 0.5, depth * 0.5), mat)
	_solid(Vector3(width * 0.38, height, t), 
		center + Vector3(width * 0.31, height * 0.5, depth * 0.5), mat)
	_solid(Vector3(width * 0.24, 1.4, t), 
		center + Vector3(0.0, height - 0.7, depth * 0.5), mat)
	# второй этаж-плита и крыша
	_solid(Vector3(width + 0.8, 0.4, depth + 0.8), 
		center + Vector3(0.0, height + 0.2, 0.0), _wood)
	_solid(Vector3(width + 1.6, 0.4, depth + 1.6), 
		center + Vector3(0.0, height + 2.6, 0.0), _roof)
	_batch(Vector3(width + 1.2, 1.8, depth + 1.2), 
		center + Vector3(0.0, height + 1.7, 0.0), _roof, Vector3.ZERO)


func _warehouse(center: Vector3) -> void :
	# ангар: три стены + плоская крыша на колоннах
	_solid(Vector3(22.0, 8.0, 0.6), center + Vector3(0.0, 4.0, -9.0), _metal)
	_solid(Vector3(0.6, 8.0, 18.0), center + Vector3(-11.0, 4.0, 0.0), _metal)
	_solid(Vector3(0.6, 8.0, 18.0), center + Vector3(11.0, 4.0, 0.0), _metal)
	_solid(Vector3(23.0, 0.6, 19.0), center + Vector3(0.0, 8.3, 0.0), _metal)
	_solid(Vector3(6.0, 2.4, 6.0), center + Vector3(-6.0, 1.2, 2.0), _metal)
	_solid(Vector3(6.0, 2.4, 6.0), center + Vector3(6.0, 1.2, -2.0), _metal)
	_solid(Vector3(10.0, 1.0, 12.0), center + Vector3(0.0, 0.5, 2.0), _wood)


func _tower(center: Vector3, height: = 14.0) -> void :
	# дозорная башня: платформа на 4 опорах + рампа
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			_solid(Vector3(1.2, height, 1.2), 
				center + Vector3(sx * 4.0, height * 0.5, sz * 4.0), _wood)
	_solid(Vector3(11.0, 0.6, 11.0), 
		center + Vector3(0.0, height + 0.3, 0.0), _wood)
	for sx in [-1.0, 1.0]:
		_solid(Vector3(0.4, 1.4, 11.0), 
			center + Vector3(sx * 5.4, height + 1.3, 0.0), _wood)
	for sz in [-1.0, 1.0]:
		_solid(Vector3(11.0, 1.4, 0.4), 
			center + Vector3(0.0, height + 1.3, sz * 5.4), _wood)
	var ramp_len: = height * 2.4
	_solid(Vector3(5.0, 0.4, ramp_len), 
		center + Vector3(0.0, height * 0.5, 5.5 + ramp_len * 0.44), _wood, 
		Vector3(rad_to_deg(asin(1.0 / 2.4)), 0.0, 0.0))


# ---------- город в центре ----------

func _build_town() -> void :
	# центральная площадь
	_solid(Vector3(40.0, 0.3, 40.0), Vector3(0.0, 0.15, 0.0), _road)
	_house(Vector3(-24.0, 0.0, -22.0))
	_house(Vector3(24.0, 0.0, -22.0), 14.0, 11.0, 7.0)
	_house(Vector3(-26.0, 0.0, 22.0), 13.0, 10.0, 6.0)
	_house(Vector3(26.0, 0.0, 24.0))
	_warehouse(Vector3(0.0, 0.0, -44.0))
	_tower(Vector3(0.0, 0.0, 40.0), 13.0)
	# фонтан-укрытие в центре
	_solid(Vector3(6.0, 1.4, 6.0), Vector3(0.0, 0.7, 0.0), _rock)
	_batch(Vector3(3.0, 1.6, 3.0), Vector3(0.0, 1.9, 0.0), _accent, 
		Vector3.ZERO)


# ---------- POI по квадрантам ----------

func _build_pois() -> void :
	# СЗ: ферма
	_house(Vector3(-95.0, 0.0, -30.0), 16.0, 12.0, 7.0, _wood)
	_house(Vector3(-70.0, 0.0, -55.0), 10.0, 9.0, 5.0, _wood)
	_solid(Vector3(20.0, 1.2, 1.0), Vector3(-95.0, 0.6, -12.0), _wood)
	# СВ: ангар + ящики
	_warehouse(Vector3(95.0, 0.0, -110.0))
	# ЮЗ: дозорная башня + руины
	_tower(Vector3(-110.0, 0.0, 105.0), 15.0)
	_solid(Vector3(10.0, 4.0, 0.7), Vector3(-80.0, 2.0, 78.0), _brick)
	_solid(Vector3(0.7, 3.0, 10.0), Vector3(-86.0, 1.5, 84.0), _brick)
	# ЮВ: двухэтажный дом + сарай
	_house(Vector3(90.0, 0.0, 90.0), 16.0, 14.0, 10.0, _brick)
	_house(Vector3(115.0, 0.0, 60.0), 10.0, 9.0, 5.0, _wood)
	_solid(Vector3(9.0, 3.0, 0.7), Vector3(70.0, 1.5, 55.0), _wood)


# ---------- природа ----------

func _tree(pos: Vector3, scale: = 1.0) -> void :
	var h: = 4.5 * scale
	# ствол — добываемый (дерево), листва — обычный декор с коллизией
	_harvest_solid(Vector3(0.8 * scale, h, 0.8 * scale), 
		pos + Vector3(0.0, h * 0.5, 0.0), _trunk, "wood")
	_solid(Vector3(3.6 * scale, 2.4 * scale, 3.6 * scale), 
		pos + Vector3(0.0, h + 1.0 * scale, 0.0), _leaf)


func _harvest_solid(size: Vector3, pos: Vector3, mat: Material, 
		harvest_type: String) -> void :
	# Добываемый объект: коллизия + собственный меш (трещины/разрушение).
	var body: = StaticBody3D.new()
	body.position = pos
	add_child(body)
	var shape: = BoxShape3D.new()
	shape.size = size
	var col: = CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)
	var mesh: = MeshInstance3D.new()
	mesh.mesh = MeshKit.box_mesh(size)
	mesh.material_override = mat
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_child(mesh)
	body.add_to_group("harvestable")
	body.set_meta("harvest_type", harvest_type)
	body.set_meta("mesh_node", mesh)


func _car(pos: Vector3, yaw: = 0.0) -> void :
	# машина-укрытие: добываемый металл
	var body: = StaticBody3D.new()
	body.position = pos
	body.rotation_degrees = Vector3(0.0, yaw, 0.0)
	add_child(body)
	var shape: = BoxShape3D.new()
	shape.size = Vector3(2.2, 1.5, 4.8)
	var col: = CollisionShape3D.new()
	col.shape = shape
	col.position = Vector3(0.0, 0.75, 0.0)
	body.add_child(col)
	var mesh: = MeshInstance3D.new()
	mesh.mesh = MeshKit.box_mesh(Vector3(2.2, 1.5, 4.8))
	mesh.material_override = _metal
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.position = Vector3(0.0, 0.75, 0.0)
	body.add_child(mesh)
	var cabin: = MeshInstance3D.new()
	cabin.mesh = MeshKit.box_mesh(Vector3(2.0, 1.1, 2.4))
	cabin.material_override = _metal
	cabin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cabin.position = Vector3(0.0, 2.0, -0.2)
	body.add_child(cabin)
	body.add_to_group("harvestable")
	body.set_meta("harvest_type", "metal")
	body.set_meta("mesh_node", mesh)


func _build_nature() -> void :
	var spots: = [
		Vector3(-45.0, 0.0, 60.0), Vector3(-60.0, 0.0, 30.0), 
		Vector3(45.0, 0.0, -60.0), Vector3(60.0, 0.0, -30.0), 
		Vector3(-40.0, 0.0, -70.0), Vector3(40.0, 0.0, 70.0), 
		Vector3(-130.0, 0.0, -60.0), Vector3(130.0, 0.0, 60.0), 
		Vector3(-130.0, 0.0, 40.0), Vector3(130.0, 0.0, -40.0), 
		Vector3(-60.0, 0.0, 120.0), Vector3(60.0, 0.0, -120.0), 
		Vector3(-20.0, 0.0, 110.0), Vector3(20.0, 0.0, -110.0), 
		Vector3(110.0, 0.0, 20.0), Vector3(-110.0, 0.0, -20.0), 
		Vector3(140.0, 0.0, 120.0), Vector3(-140.0, 0.0, -120.0), 
		Vector3(140.0, 0.0, -120.0), Vector3(-140.0, 0.0, 120.0), 
	]
	for i in spots.size():
		_tree(spots[i], 1.0 + (float(i % 4)) * 0.22)
	# скалы-укрытия
	var rocks: = [
		[Vector3(-15.0, 0.0, 70.0), Vector3(4.0, 3.0, 3.0)], 
		[Vector3(15.0, 0.0, -70.0), Vector3(4.0, 3.0, 3.0)], 
		[Vector3(70.0, 0.0, 15.0), Vector3(3.0, 4.0, 4.0)], 
		[Vector3(-70.0, 0.0, -15.0), Vector3(3.0, 4.0, 4.0)], 
		[Vector3(50.0, 0.0, 50.0), Vector3(5.0, 2.6, 3.0)], 
		[Vector3(-50.0, 0.0, -50.0), Vector3(5.0, 2.6, 3.0)], 
		[Vector3(-50.0, 0.0, 50.0), Vector3(3.0, 3.4, 3.6)], 
		[Vector3(50.0, 0.0, -50.0), Vector3(3.0, 3.4, 3.6)], 
		[Vector3(0.0, 0.0, 90.0), Vector3(6.0, 2.2, 3.0)], 
		[Vector3(0.0, 0.0, -90.0), Vector3(6.0, 2.2, 3.0)], 
		[Vector3(90.0, 0.0, 0.0), Vector3(3.0, 2.2, 6.0)], 
		[Vector3(-90.0, 0.0, 0.0), Vector3(3.0, 2.2, 6.0)], 
	]
	for r in rocks:
		var spec: Array = r
		_harvest_solid(spec[1], 
			spec[0] + Vector3(0.0, spec[1].y * 0.5, 0.0), _rock, "stone")
	# машины вдоль дорог
	for car_spec in [
		[Vector3(9.0, 0.0, 60.0), 90.0], [Vector3(-9.0, 0.0, -80.0), 90.0], 
		[Vector3(60.0, 0.0, -9.0), 0.0], [Vector3(-80.0, 0.0, 9.0), 0.0], 
		[Vector3(9.0, 0.0, 130.0), 90.0], [Vector3(-9.0, 0.0, -130.0), 90.0], 
		[Vector3(130.0, 0.0, 9.0), 0.0], [Vector3(-130.0, 0.0, -9.0), 0.0], 
	]:
		var cspec: Array = car_spec
		_car(cspec[0], float(cspec[1]))


func _build_environment_walls() -> void :
	_solid(Vector3(HALF * 2.0, WALL_HEIGHT, 1.0), 
		Vector3(0.0, WALL_HEIGHT * 0.5, - HALF - 1.0), _rock)
	_solid(Vector3(HALF * 2.0, WALL_HEIGHT, 1.0), 
		Vector3(0.0, WALL_HEIGHT * 0.5, HALF + 1.0), _rock)
	_solid(Vector3(1.0, WALL_HEIGHT, HALF * 2.0), 
		Vector3(- HALF - 1.0, WALL_HEIGHT * 0.5, 0.0), _rock)
	_solid(Vector3(1.0, WALL_HEIGHT, HALF * 2.0), 
		Vector3(HALF + 1.0, WALL_HEIGHT * 0.5, 0.0), _rock)


func _build_lights() -> void :
	for spec in [
		[Vector3(0.0, 12.0, 0.0), 1.4, 60.0], 
		[Vector3(-100.0, 12.0, -100.0), 1.2, 60.0], 
		[Vector3(100.0, 12.0, -100.0), 1.2, 60.0], 
		[Vector3(-100.0, 12.0, 100.0), 1.2, 60.0], 
		[Vector3(100.0, 12.0, 100.0), 1.2, 60.0], 
	]:
		var light: = OmniLight3D.new()
		light.position = spec[0]
		light.light_color = Color(1.0, 0.9, 0.76, 1.0)
		light.light_energy = spec[1]
		light.omni_range = spec[2]
		light.shadow_enabled = false
		light.add_to_group("arena_decor_lights")
		add_child(light)


func _build_spawn_points() -> void :
	# 20 точек по кольцу карты (игрок + боты)
	spawn_points = [
		Vector3(0.0, 0.05, 145.0), Vector3(30.0, 0.05, 140.0), 
		Vector3(-30.0, 0.05, 140.0), Vector3(60.0, 0.05, 120.0), 
		Vector3(-60.0, 0.05, 120.0), Vector3(95.0, 0.05, 100.0), 
		Vector3(-95.0, 0.05, 100.0), Vector3(130.0, 0.05, 60.0), 
		Vector3(-130.0, 0.05, 60.0), Vector3(145.0, 0.05, 0.0), 
		Vector3(-145.0, 0.05, 0.0), Vector3(130.0, 0.05, -60.0), 
		Vector3(-130.0, 0.05, -60.0), Vector3(95.0, 0.05, -100.0), 
		Vector3(-95.0, 0.05, -100.0), Vector3(60.0, 0.05, -120.0), 
		Vector3(-60.0, 0.05, -120.0), Vector3(30.0, 0.05, -140.0), 
		Vector3(-30.0, 0.05, -140.0), Vector3(0.0, 0.05, -145.0), 
	]
	player_start = Vector3(0.0, 0.05, 145.0)
	bot_start = Vector3(0.0, 0.05, -145.0)

	# навигация ботов: сетка по карте
	bot_nav_points = []
	var x: = -140.0
	while x <= 140.0:
		var z: = -140.0
		while z <= 140.0:
			bot_nav_points.append(Vector3(x, 0.05, z))
			z += 70.0
		x += 70.0
	# ключевые точки интереса для удержания/охоты
	bot_hold_points = [
		Vector3(0.0, 0.05, 0.0), Vector3(-24.0, 0.05, -22.0), 
		Vector3(24.0, 0.05, -22.0), Vector3(-26.0, 0.05, 22.0), 
		Vector3(26.0, 0.05, 24.0), Vector3(0.0, 0.05, -44.0), 
		Vector3(0.0, 0.05, 40.0), Vector3(-95.0, 0.05, -30.0), 
		Vector3(95.0, 0.05, -110.0), Vector3(-110.0, 0.05, 105.0), 
		Vector3(90.0, 0.05, 90.0), Vector3(0.0, 8.0, 105.0), 
		Vector3(-95.0, 10.5, -95.0), Vector3(105.0, 8.5, -85.0), 
		Vector3(90.0, 9.5, 105.0), Vector3(-105.0, 7.5, 100.0), 
	]
	bot_hunt_points = bot_hold_points.duplicate()

	# точки для лута: POI + сетка + крыши
	loot_points = []
	for p in bot_hold_points:
		loot_points.append(Vector3(p.x, p.y + 0.5, p.z))
	for p in bot_nav_points:
		loot_points.append(Vector3(p.x + randf_range(-8.0, 8.0), 0.5, 
			p.z + randf_range(-8.0, 8.0)))
	loot_points.append(Vector3(-26.0, 8.2, 22.0))
	loot_points.append(Vector3(24.0, 9.2, -22.0))
	loot_points.append(Vector3(0.0, 9.0, 40.0))
	loot_points.append(Vector3(90.0, 12.2, 90.0))


func add_extra_cover() -> void :
	# Больше укрытий для режима БЕЗ строительства:
	# ящики, бетонные стены, камни.
	var crates: = [
		Vector3(-12.0, 0.0, 12.0), Vector3(12.0, 0.0, -12.0), 
		Vector3(-20.0, 0.0, 5.0), Vector3(20.0, 0.0, -5.0), 
		Vector3(8.0, 0.0, 30.0), Vector3(-8.0, 0.0, -30.0), 
		Vector3(30.0, 0.0, 8.0), Vector3(-30.0, 0.0, -8.0), 
		Vector3(-15.0, 0.0, 45.0), Vector3(15.0, 0.0, -45.0), 
		Vector3(45.0, 0.0, -15.0), Vector3(-45.0, 0.0, 15.0), 
		Vector3(-8.0, 0.0, 95.0), Vector3(8.0, 0.0, -95.0), 
	]
	for i in crates.size():
		var size: = 1.8 if i % 2 == 0 else 1.4
		_solid(Vector3(size, size, size), crates[i] + Vector3(0.0, 
			size * 0.5, 0.0), _wood)
	var walls: = [
		[Vector3(25.0, 0.0, 12.0), 90.0], [Vector3(-25.0, 0.0, -12.0), 90.0], 
		[Vector3(12.0, 0.0, -25.0), 0.0], [Vector3(-12.0, 0.0, 25.0), 0.0], 
		[Vector3(60.0, 0.0, 30.0), 0.0], [Vector3(-60.0, 0.0, -30.0), 0.0], 
	]
	for w in walls:
		var wspec: Array = w
		var yaw: float = wspec[1]
		var wsize: = Vector3(6.0, 2.6, 0.6) if yaw == 0.0 \
			else Vector3(0.6, 2.6, 6.0)
		_solid(wsize, wspec[0] + Vector3(0.0, 1.3, 0.0), _brick)
	var rocks: = [
		Vector3(35.0, 0.0, 35.0), Vector3(-35.0, 0.0, -35.0), 
		Vector3(-35.0, 0.0, 35.0), Vector3(35.0, 0.0, -35.0), 
		Vector3(80.0, 0.0, -20.0), Vector3(-80.0, 0.0, 20.0), 
		Vector3(-20.0, 0.0, -80.0), Vector3(20.0, 0.0, 80.0), 
	]
	for r in rocks:
		_harvest_solid(Vector3(3.4, 2.6, 3.0), r + Vector3(0.0, 1.3, 0.0), 
			_rock, "stone")
