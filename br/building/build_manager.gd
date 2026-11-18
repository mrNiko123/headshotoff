extends Node
## МЕНЕДЖЕР СТРОИТЕЛЬСТВА БАТЛ РОЯЛЯ (подрежим "со строительством").
## Материалы: дерево/камень/металл (999 макс). Добыча ножом по
## добываемым объектам (группа "harvestable"). Элементы: стена (Q),
## пол (Z), лестница (X), крыша (C). Сетка 4x3x4. Прочность по материалу,
## 3 стадии трещин. Редактор: G — проём в стене. Боты строят стены.

signal mats_changed(wood: int, stone: int, metal: int, selected: int)
signal mode_changed(active: bool, kind: String)

const MeshKit = preload("res://scripts/mesh_kit.gd")

const CELL: = 4.0
const CELL_HEIGHT: = 3.0
const KINDS: = ["wall", "floor", "stairs", "roof"]
const KIND_KEYS: = {
	"wall": KEY_Q, "floor": KEY_Z, "stairs": KEY_X, "roof": KEY_C, }
const MAT_NAMES: = ["ДЕРЕВО", "КАМЕНЬ", "МЕТАЛЛ"]
const MAT_COLORS: = [
	Color(0.76, 0.6, 0.38, 1.0), 
	Color(0.55, 0.55, 0.52, 1.0), 
	Color(0.6, 0.64, 0.7, 1.0), 
]
const MAT_KEYS: = ["wood", "stone", "metal"]

var settings: Resource = preload("res://br/data/building_settings.tres")
var active: = false
var kind: = "wall"
var mat_index: = 0
var mats: = {"wood": 0, "stone": 0, "metal": 0}

var player: Node3D
var game: Node
var pieces_root: Node3D
var ghost: MeshInstance3D
var ghost_valid: = false
var piece_count: = 0

var _piece_materials: Array = []
var _ghost_materials: Array = []
var _harvest_registry: Dictionary = {}
var _bot_last_build: Dictionary = {}
var _ghost_query_shape: BoxShape3D


func setup(game_node: Node, player_node: Node3D) -> void :
	game = game_node
	player = player_node
	pieces_root = Node3D.new()
	pieces_root.name = "BuildPieces"
	game.add_child(pieces_root)
	_make_materials()
	_make_ghost()


func _make_materials() -> void :
	for base_color: Color in MAT_COLORS:
		var stages: = []
		for stage in 3:
			var mat: = StandardMaterial3D.new()
			var factor: = 1.0 - float(stage) * 0.22
			mat.albedo_color = Color(base_color.r * factor, 
				base_color.g * factor, base_color.b * factor, 1.0)
			mat.roughness = 0.85
			stages.append(mat)
		_piece_materials.append(stages)
	for color: Color in [Color(0.36, 1.0, 0.55, 0.4), 
		Color(1.0, 0.31, 0.27, 0.4)]:
		var mat: = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = color
		_ghost_materials.append(mat)


func _make_ghost() -> void :
	ghost = MeshInstance3D.new()
	ghost.name = "BuildGhost"
	ghost.mesh = MeshKit.box_mesh(Vector3(CELL, CELL_HEIGHT, 0.4))
	ghost.material_override = _ghost_materials[0]
	ghost.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ghost.visible = false
	game.add_child(ghost)
	_ghost_query_shape = BoxShape3D.new()
	_ghost_query_shape.size = Vector3(CELL, CELL_HEIGHT, CELL) * 0.92


# ---------- режим ----------

func toggle_for(kind_id: String) -> void :
	if not active:
		active = true
		kind = kind_id
	elif kind == kind_id:
		active = false
	else:
		kind = kind_id
	if active:
		player.set_meta("br_build", true)
	else:
		player.remove_meta("br_build")
	mode_changed.emit(active, kind)


func set_mat(index: int) -> void :
	mat_index = clampi(index, 0, 2)
	mats_changed.emit(mats["wood"], mats["stone"], mats["metal"], mat_index)


func add_mats(mat_key: String, amount: int) -> void :
	var cap: = int(settings.material_cap)
	mats[mat_key] = clampi(int(mats[mat_key]) + amount, 0, cap)
	mats_changed.emit(mats["wood"], mats["stone"], mats["metal"], mat_index)


func selected_mat_key() -> String:
	return MAT_KEYS[mat_index]


func selected_mats() -> int:
	return int(mats[MAT_KEYS[mat_index]])


func ghost_transform() -> Transform3D:
	var camera: Camera3D = player.camera
	var origin: = camera.global_position
	var forward: = - camera.global_basis.z
	var flat: = Vector3(forward.x, 0.0, forward.z)
	if flat.length_squared() < 0.01:
		flat = Vector3.FORWARD
	flat = flat.normalized()
	var pos: = origin + flat * (CELL * 0.9)
	# башня: смотрим вниз — пол ставится под ногами
	if kind == "floor" and forward.y < - 0.55:
		pos = origin + flat * 0.5
	var oc: = Vector2(floorf(origin.x / CELL), floorf(origin.z / CELL))
	var fc: = Vector2(floorf(pos.x / CELL), floorf(pos.z / CELL))
	var ox: = (oc.x + 0.5) * CELL
	var oz: = (oc.y + 0.5) * CELL
	var fx: = (fc.x + 0.5) * CELL
	var fz: = (fc.y + 0.5) * CELL
	var level: = floorf((origin.y - 0.1) / CELL_HEIGHT) * CELL_HEIGHT
	var yaw: = roundf(rad_to_deg(atan2(flat.x, flat.z)) / 90.0) * 90.0
	if kind == "wall":
		var basis: = Basis.from_euler(Vector3(0.0, deg_to_rad(yaw), 0.0))
		# стена стоит на границе клетки игрока и клетки перед ним
		var along_x: bool = absf(flat.x) > absf(flat.z)
		var wx: = (ox + fx) * 0.5 if along_x else ox
		var wz: = oz if along_x else (oz + fz) * 0.5
		return Transform3D(basis, Vector3(wx, level + CELL_HEIGHT * 0.5, wz))
	if kind == "floor":
		# башня: смотрим вниз — пол ставится под ноги на текущей высоте
		if forward.y < - 0.55:
			var feet: = player.global_position.y
			return Transform3D(Basis.IDENTITY, 
				Vector3(ox, feet + 0.03, oz))
		return Transform3D(Basis.IDENTITY, 
			Vector3(fx, level + 0.15, fz))
	if kind == "roof":
		return Transform3D(Basis.IDENTITY, 
			Vector3(fx, level + CELL_HEIGHT + 0.15, fz))
	# лестница: рампа в клетке перед игроком, подъём от игрока
	var basis_ramp: = Basis.from_euler(Vector3(
		-deg_to_rad(33.7), deg_to_rad(yaw), 0.0))
	return Transform3D(basis_ramp, Vector3(fx, level + CELL_HEIGHT * 0.45, 
		fz) - flat * (CELL * 0.2))


func _ghost_mesh_for(kind_id: String) -> Mesh:
	if kind_id == "wall":
		return MeshKit.box_mesh(Vector3(CELL, CELL_HEIGHT, 0.4))
	if kind_id == "stairs":
		return MeshKit.box_mesh(Vector3(CELL, 0.3, CELL * 1.15))
	return MeshKit.box_mesh(Vector3(CELL, 0.3, CELL))


func update_ghost() -> void :
	var show: bool = active and player.is_alive() \
		and bool(player.get("active"))
	ghost.visible = show
	if not show:
		return
	ghost.mesh = _ghost_mesh_for(kind)
	ghost.transform = ghost_transform()
	ghost_valid = true
	var params: = PhysicsShapeQueryParameters3D.new()
	params.shape = _ghost_query_shape
	params.transform = Transform3D(Basis.IDENTITY, ghost.transform.origin)
	params.collision_mask = 1
	params.exclude = [player.get_rid()]
	var hit: Array = game.get_world_3d().direct_space_state.intersect_shape(
		params, 1)
	var can_afford: bool = selected_mats() >= int(settings.piece_cost)
	if not hit.is_empty() or not can_afford:
		ghost_valid = false
	ghost.material_override = _ghost_materials[0] if ghost_valid \
		else _ghost_materials[1]


func try_place() -> void :
	if not active or not ghost_valid:
		return
	var cost: = int(settings.piece_cost)
	var mat_key: = selected_mat_key()
	if int(mats[mat_key]) < cost:
		return
	mats[mat_key] = int(mats[mat_key]) - cost
	_spawn_piece(kind, ghost_transform(), mat_key)
	mats_changed.emit(mats["wood"], mats["stone"], mats["metal"], mat_index)


func _spawn_piece(kind_id: String, transform: Transform3D, mat_key: String, 
		door: = false) -> StaticBody3D:
	# лимит построек: старые удаляются
	var max_pieces: = int(settings.max_pieces)
	while piece_count >= max_pieces and pieces_root.get_child_count() > 0:
		var oldest: = pieces_root.get_child(0)
		pieces_root.remove_child(oldest)
		oldest.queue_free()
		piece_count -= 1
	var body: = StaticBody3D.new()
	body.transform = transform
	body.add_to_group("build_piece")
	body.set_meta("piece_kind", kind_id)
	body.set_meta("piece_mat", mat_key)
	body.set_meta("has_door", door)
	var hp: float = float(settings.wood_hp)
	if mat_key == "stone":
		hp = float(settings.stone_hp)
	elif mat_key == "metal":
		hp = float(settings.metal_hp)
	body.set_meta("piece_hp", hp)
	body.set_meta("piece_max_hp", hp)
	var mat_index_piece: = MAT_KEYS.find(mat_key)
	_apply_piece_geometry(body, kind_id, mat_index_piece, hp, door)
	pieces_root.add_child(body)
	piece_count += 1
	return body


func _apply_piece_geometry(body: StaticBody3D, kind_id: String, 
		mat_i: int, hp: float, door: bool) -> void :
	for child in body.get_children():
		child.queue_free()
	var stage: = _stage_for(hp, float(body.get_meta("piece_max_hp", hp)))
	var mat: Material = _piece_materials[mat_i][stage]
	if kind_id == "wall" and door:
		# проём 1.6 x 2.0 по центру стены
		var parts: = [
			[Vector3(1.2, CELL_HEIGHT, 0.4), Vector3(-1.4, 0.0, 0.0)], 
			[Vector3(1.2, CELL_HEIGHT, 0.4), Vector3(1.4, 0.0, 0.0)], 
			[Vector3(1.6, 1.0, 0.4), Vector3(0.0, 1.0, 0.0)], 
		]
		for part: Array in parts:
			_add_box(body, part[0], part[1], mat)
	elif kind_id == "wall":
		_add_box(body, Vector3(CELL, CELL_HEIGHT, 0.4), 
			Vector3.ZERO, mat)
	elif kind_id == "stairs":
		_add_box(body, Vector3(CELL, 0.3, CELL * 1.15), Vector3.ZERO, mat)
	else:
		_add_box(body, Vector3(CELL, 0.3, CELL), Vector3.ZERO, mat)


func _add_box(body: StaticBody3D, size: Vector3, offset: Vector3, 
		mat: Material) -> void :
	var col: = CollisionShape3D.new()
	var shape: = BoxShape3D.new()
	shape.size = size
	col.shape = shape
	col.position = offset
	body.add_child(col)
	var mesh: = MeshInstance3D.new()
	mesh.mesh = MeshKit.box_mesh(size)
	mesh.material_override = mat
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	mesh.position = offset
	body.add_child(mesh)


func _stage_for(hp: float, max_hp: float) -> int:
	var ratio: = hp / maxf(1.0, max_hp)
	if ratio > 0.66:
		return 0
	if ratio > 0.33:
		return 1
	return 2


# ---------- урон / разрушение ----------

func damage_piece(piece: Node, amount: float) -> void :
	if not piece.is_in_group("build_piece"):
		return
	var hp: = float(piece.get_meta("piece_hp", 0.0)) - amount
	piece.set_meta("piece_hp", hp)
	if hp <= 0.0:
		_destroy_piece(piece)
		return
	_apply_piece_geometry(piece, str(piece.get_meta("piece_kind")), 
		MAT_KEYS.find(str(piece.get_meta("piece_mat"))), hp, 
		bool(piece.get_meta("has_door", false)))


func _destroy_piece(piece: Node) -> void :
	if not is_instance_valid(piece):
		return
	piece.remove_from_group("build_piece")
	piece.collision_layer = 0
	for child in piece.get_children():
		if child is MeshInstance3D:
			(child as MeshInstance3D).visible = false
		elif child is CollisionShape3D:
			(child as CollisionShape3D).disabled = true
	_spawn_debris(piece.global_position, 
		MAT_COLORS[MAT_KEYS.find(str(piece.get_meta("piece_mat", "wood")))])
	Sfx.play_hit()
	piece_count = maxi(0, piece_count - 1)


func _spawn_debris(pos: Vector3, color: Color) -> void :
	var particles: = CPUParticles3D.new()
	particles.one_shot = true
	particles.emitting = true
	particles.amount = 14
	particles.lifetime = 0.7
	particles.explosiveness = 0.9
	particles.direction = Vector3.UP
	particles.spread = 70.0
	particles.initial_velocity_min = 3.0
	particles.initial_velocity_max = 6.5
	particles.gravity = Vector3(0.0, - 12.0, 0.0)
	particles.mesh = MeshKit.box_mesh(Vector3(0.22, 0.22, 0.22))
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = color
	particles.material_override = mat
	game.add_child(particles)
	particles.global_position = pos
	var timer: = game.get_tree().create_timer(1.1)
	timer.timeout.connect( func() -> void :
		if is_instance_valid(particles):
			particles.queue_free())


# ---------- редактор проёма ----------

func toggle_doorway() -> void :
	if not active:
		return
	# ищем свою стену перед игроком
	var camera: Camera3D = player.camera
	var from: = camera.global_position
	var to: = from - camera.global_basis.z * 4.5
	var query: = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	var hit: Dictionary = game.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var body: Object = hit.get("collider")
	if body == null or not (body as Node).is_in_group("build_piece"):
		return
	if str((body as Node).get_meta("piece_kind")) != "wall":
		return
	var door: = not bool((body as Node).get_meta("has_door", false))
	(body as Node).set_meta("has_door", door)
	_apply_piece_geometry(body as StaticBody3D, "wall", 
		MAT_KEYS.find(str((body as Node).get_meta("piece_mat"))), 
		float((body as Node).get_meta("piece_hp")), door)


# ---------- добыча материалов ----------

func knife_hit(hit: Dictionary) -> void :
	var collider: Object = hit.get("collider")
	if collider == null:
		return
	var body: = collider as Node
	if body == null or not body.is_in_group("harvestable"):
		return
	var harvest_type: = str(body.get_meta("harvest_type", ""))
	if not MAT_KEYS.has(harvest_type):
		return
	var info: Dictionary = _harvest_registry.get(body, {})
	if info.is_empty():
		info = _register_harvestable(body)
		if info.is_empty():
			return
	# слабая точка
	var amount: = randi_range(int(settings.harvest_min), 
		int(settings.harvest_max))
	var weak_pos: Vector3 = info["weak_pos"]
	var hit_pos: Vector3 = hit.get("position", Vector3.ZERO)
	if hit_pos.distance_to(weak_pos) <= 0.9:
		amount = int(float(amount) * float(settings.weak_point_bonus))
	var hp: = float(info.get("hp", 100.0)) - 60.0
	info["hp"] = hp
	_harvest_registry[body] = info
	add_mats(harvest_type, amount)
	var mesh_node: Variant = body.get_meta("mesh_node", null)
	if mesh_node is MeshInstance3D:
		var ratio: = hp / float(info.get("max_hp", 100.0))
		var base: = body.get_meta("base_mat") as StandardMaterial3D
		if base != null:
			var dark: = base.albedo_color.darkened(1.0 - ratio)
			var per_object: Variant = mesh_node.material_override
			if per_object == base:
				per_object = base.duplicate()
				mesh_node.material_override = per_object
				body.set_meta("base_mat", base)
				body.set_meta("live_mat", per_object)
			if per_object is StandardMaterial3D:
				(per_object as StandardMaterial3D).albedo_color = dark
	if hp <= 0.0:
		_destroy_harvestable(body)


func _register_harvestable(body: Node) -> Dictionary:
	var mesh_node: Variant = body.get_meta("mesh_node", null)
	if not (mesh_node is MeshInstance3D):
		return {}
	var aabb: = (mesh_node as MeshInstance3D).mesh.get_aabb()
	var weak_pos: Vector3 = body.global_position + Vector3(
		randf_range(- aabb.size.x * 0.4, aabb.size.x * 0.4), 
		aabb.size.y * randf_range(0.3, 0.8), 
		randf_range(- aabb.size.z * 0.4, aabb.size.z * 0.4))
	# маркер слабой точки
	var marker: = MeshInstance3D.new()
	marker.mesh = MeshKit.box_mesh(Vector3(0.34, 0.34, 0.34))
	var marker_mat: = StandardMaterial3D.new()
	marker_mat.albedo_color = Color(1.0, 0.85, 0.2, 1.0)
	marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marker_mat.emission_enabled = true
	marker_mat.emission = Color(1.0, 0.75, 0.1, 1.0)
	marker_mat.emission_energy_multiplier = 1.4
	marker.material_override = marker_mat
	marker.position = weak_pos - body.global_position
	body.add_child(marker)
	var info: = {
		"hp": 120.0, 
		"max_hp": 120.0, 
		"weak_pos": weak_pos, 
	}
	_harvest_registry[body] = info
	body.set_meta("base_mat", (mesh_node as MeshInstance3D).material_override)
	return info


func _destroy_harvestable(body: Node) -> void :
	_harvest_registry.erase(body)
	body.remove_from_group("harvestable")
	body.collision_layer = 0
	for child in body.get_children():
		if child is MeshInstance3D:
			(child as MeshInstance3D).visible = false
		elif child is CollisionShape3D:
			(child as CollisionShape3D).disabled = true
	_spawn_debris(body.global_position + Vector3(0.0, 1.0, 0.0), 
		MAT_COLORS[MAT_KEYS.find(str(body.get_meta("harvest_type", "wood")))])
	Sfx.play_hit()


# ---------- боты ----------

func bot_react(bot: Node3D, enemy: Node3D) -> void :
	# Стена между ботом и врагом под огнём (если есть материалы).
	if not is_instance_valid(bot) or not is_instance_valid(enemy):
		return
	var now: = Time.get_ticks_msec() / 1000.0
	var last: = float(_bot_last_build.get(bot, 0.0))
	if now - last < 2.5:
		return
	if not bot.has_meta("br_mats"):
		# стартовый запас дерева бота (имитация добычи)
		bot.set_meta("br_mats", 80)
	var bot_mats: Variant = bot.get_meta("br_mats", 0)
	var wood: = int(bot_mats)
	var cost: = int(settings.piece_cost)
	if wood < cost:
		return
	var direction: = enemy.global_position - bot.global_position
	if absf(direction.y) > 3.0 and direction.y > 0.0:
		# враг сверху — лестница в его сторону
		var yaw_s: = rad_to_deg(atan2(direction.x, direction.z))
		var transform: = Transform3D(
			Basis.from_euler(Vector3(-deg_to_rad(33.7), 
			deg_to_rad(roundf(yaw_s / 90.0) * 90.0), 0.0)), 
			bot.global_position + Vector3(0.0, 0.5, 0.0))
		_spawn_piece("stairs", transform, "wood")
		bot.set_meta("br_mats", wood - cost)
		_bot_last_build[bot] = now
		return
	if absf(direction.y) > 2.0:
		return
	direction.y = 0.0
	if direction.length_squared() < 0.01:
		return
	direction = direction.normalized()
	var wall_pos: = bot.global_position + direction * (CELL * 0.5) \
		+ Vector3(0.0, CELL_HEIGHT * 0.5, 0.0)
	var yaw: = rad_to_deg(atan2(direction.x, direction.z))
	var wall_transform: = Transform3D(
		Basis.from_euler(Vector3(0.0, deg_to_rad(
		roundf(yaw / 90.0) * 90.0), 0.0)), 
		Vector3(floorf(wall_pos.x / CELL) * CELL + CELL * 0.5, 
		wall_pos.y, wall_pos.z))
	_spawn_piece("wall", wall_transform, "wood")
	bot.set_meta("br_mats", wood - cost)
	_bot_last_build[bot] = now


func clear_all() -> void :
	if pieces_root != null:
		for child in pieces_root.get_children():
			child.queue_free()
	piece_count = 0
