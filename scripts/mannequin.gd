extends Node3D




signal died(mannequin: Node3D, zone: String, world_position: Vector3)

const MeshKit = preload("res://scripts/mesh_kit.gd")
const HitboxScript = preload("res://scripts/mannequin_hitbox.gd")



const SHARD_COUNT: = 12
const SHARD_COUNT_MOBILE: = 7


const SHARD_COUNT_MIN: = 4



const DEATH_FALL_TIME: = 0.42
const DEATH_HOLD_TIME: = 0.18
const DEATH_SHRINK_TIME: = 0.16
const FLASH_UP_TIME: = 0.04
const FLASH_DOWN_TIME: = 0.24
const FLASH_PEAK: = 3.2


const MAX_HEALTH: = 100.0

var alive: = true
var health: = MAX_HEALTH

var _visual: Node3D
var _hitboxes: Array[Area3D] = []

var _death_time: = -1.0
var _death_fall_angle: = 0.0
var _flash_time: = -1.0



static var _shared_mesh: ArrayMesh


var _mat: StandardMaterial3D

var _rainbow_phase: = 0.0
var _rainbow_clock: = 0.0


var _flash: = 0.0





static var _shard_meshes: Array[BoxMesh] = []
var _shard_pool: Array[MeshInstance3D] = []
var _shard_from: PackedVector3Array = PackedVector3Array()
var _shard_to: PackedVector3Array = PackedVector3Array()
var _shard_spin: PackedVector3Array = PackedVector3Array()
var _shard_elapsed: PackedFloat32Array = PackedFloat32Array()
var _shard_life: PackedFloat32Array = PackedFloat32Array()
var _shard_active: = 0


func _ready() -> void :
	add_to_group("mannequins")
	_rainbow_phase = randf()
	_rainbow_clock = randf() * 12.0
	_build_materials()
	_build_visual()
	_build_shards()
	_build_hitboxes()
	if not Settings.settings_changed.is_connected(_on_settings_changed):
		Settings.settings_changed.connect(_on_settings_changed)
	_apply_mannequin_color()


	_sync_processing()


func _process(delta: float) -> void :
	if Settings.mannequin_rainbow:
		_rainbow_clock += delta
		_apply_mannequin_color()
	if _death_time >= 0.0:
		_animate_death(delta)
	if _flash_time >= 0.0:
		_animate_flash(delta)
	if _shard_active > 0:
		_animate_shards(delta)




func _sync_processing() -> void :
	set_process(Settings.mannequin_rainbow or _shard_active > 0
		or _death_time >= 0.0 or _flash_time >= 0.0)


func _on_settings_changed() -> void :
	_apply_mannequin_color()
	_sync_processing()





func take_hit(zone: String, amount: = -1.0) -> bool:
	if not alive:
		return false
	var damage: = amount if amount > 0.0 else MAX_HEALTH * 2.0
	health = maxf(0.0, health - damage)
	if health > 0.0:
		_flash_hit()
		return false
	alive = false
	for box in _hitboxes:
		box.collision_layer = 0


	_flash_hit()
	_spawn_shards(zone)
	died.emit(self, zone, global_position + Vector3.UP * 1.3)
	_play_death(zone)
	return true


func respawn_at(point: Vector3, look_target: Vector3) -> void :
	_death_time = -1.0
	_flash_time = -1.0
	visible = true
	position = point
	var flat_target: = Vector3(look_target.x, point.y, look_target.z)
	if flat_target.distance_squared_to(point) > 0.04:
		look_at(flat_target, Vector3.UP)
	if _visual != null:
		_visual.scale = Vector3.ONE
		_visual.position = Vector3.ZERO
		_visual.rotation = Vector3(0.0, 0.0, 0.0)
		_visual.visible = true
	for box in _hitboxes:
		box.collision_layer = 2
	alive = true
	health = MAX_HEALTH


	_flash = 0.0
	_hide_shards()
	_apply_mannequin_color()



func _build_materials() -> void :



	var base: = MeshKit.material(Settings.mannequin_color, 0.85, 0.0)
	_mat = base.duplicate() as StandardMaterial3D



	_mat.disable_ambient_light = true


	_mat.disable_fog = true
	_mat.emission_enabled = true
	_mat.emission = Settings.mannequin_color
	_mat.emission_energy_multiplier = 0.2




func _apply_mannequin_color() -> void :
	if _mat == null:
		return
	var color: = Settings.mannequin_color
	var energy: = 0.2
	if Settings.mannequin_rainbow:
		var hue: = fposmod(_rainbow_clock * 0.16 + _rainbow_phase, 1.0)
		var value: = 0.94 + sin(_rainbow_clock * 2.4 + _rainbow_phase * TAU) * 0.06
		color = Color.from_hsv(hue, 0.8, value, 1.0)
		energy = 0.42
	_mat.albedo_color = color


	var heat: = clampf(_flash / 2.8, 0.0, 1.0)
	_mat.emission = color.lerp(Color(1.0, 1.0, 1.0, 1.0), heat * 0.82)
	_mat.emission_energy_multiplier = energy + _flash


func _build_visual() -> void :
	_visual = Node3D.new()
	_visual.name = "Visual"
	add_child(_visual)

	if _shared_mesh == null:
		_shared_mesh = _make_body_mesh()
	var body: = MeshInstance3D.new()
	body.name = "Body"
	body.mesh = _shared_mesh
	body.material_override = _mat
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_visual.add_child(body)




func _make_body_mesh() -> ArrayMesh:
	var parts: Array = []

	_add_part(parts, Vector3(0.3, 0.3, 0.3), Vector3(0.0, 1.74, 0.0))
	_add_part(parts, Vector3(0.14, 0.1, 0.14), Vector3(0.0, 1.57, 0.0))
	_add_part(parts, Vector3(0.54, 0.62, 0.28), Vector3(0.0, 1.25, 0.0))
	_add_part(parts, Vector3(0.44, 0.16, 0.28), Vector3(0.0, 0.95, 0.0))


	for side in [-1.0, 1.0]:
		var from: = Vector3(side * 0.24, 1.5, 0.0)
		var to: = Vector3(side * 0.94, 1.5, 0.0)
		parts.append([
			MeshKit.box_mesh(Vector3(0.16, from.distance_to(to), 0.16 * 0.72)), 
			MeshKit.limb_transform(from, to), 
		])
		_add_part(parts, Vector3(0.14, 0.18, 0.16), Vector3(side * 0.98, 1.5, 0.0))

		_add_part(parts, Vector3(0.19, 0.72, 0.24), Vector3(side * 0.14, 0.5, 0.0))
		_add_part(parts, Vector3(0.21, 0.1, 0.34), Vector3(side * 0.14, 0.09, -0.04))

	return MeshKit.merged_boxes(parts)


func _add_part(parts: Array, size: Vector3, pos: Vector3) -> void :
	parts.append([MeshKit.box_mesh(size), Transform3D(Basis(), pos)])


func _build_hitboxes() -> void :
	_add_hitbox("head", Vector3(0.0, 1.74, 0.0), _sphere_shape(0.21))
	_add_hitbox("body", Vector3(0.0, 1.24, 0.0), _box_shape(Vector3(0.58, 0.82, 0.32)))

	for side in [-1.0, 1.0]:
		_add_hitbox("body", Vector3(side * 0.61, 1.5, 0.0), 
			_box_shape(Vector3(0.72, 0.2, 0.22)))
	_add_hitbox("legs", Vector3(0.0, 0.5, 0.0), _box_shape(Vector3(0.5, 0.92, 0.32)))


func _add_hitbox(zone: String, pos: Vector3, shape: Shape3D) -> void :
	var area: = Area3D.new()
	area.set_script(HitboxScript)
	area.name = "Hitbox_" + zone
	area.set("zone", zone)
	area.set("mannequin", self)
	area.position = pos
	var col: = CollisionShape3D.new()
	col.shape = shape
	area.add_child(col)
	add_child(area)
	_hitboxes.append(area)


func _sphere_shape(radius: float) -> SphereShape3D:
	var shape: = SphereShape3D.new()
	shape.radius = radius
	return shape


func _box_shape(size: Vector3) -> BoxShape3D:
	var shape: = BoxShape3D.new()
	shape.size = size
	return shape


func _play_death(zone: String) -> void :
	var direction: = 1.0 if randf() > 0.5 else -1.0
	if zone == "head":
		direction = - direction
	_death_fall_angle = (1.55 if zone == "head" else 1.35) * direction
	_death_time = 0.0
	_sync_processing()




func _animate_death(delta: float) -> void :
	_death_time += delta
	if _visual == null:
		_death_time = -1.0
		_sync_processing()
		return
	if _death_time < DEATH_FALL_TIME:
		var k: = _death_time / DEATH_FALL_TIME
		var eased: = k * k
		_visual.rotation.z = _death_fall_angle * eased
		_visual.position.y = -0.22 * eased
		_visual.rotation.x = deg_to_rad(18.0) * eased
		return
	if _death_time < DEATH_FALL_TIME + DEATH_HOLD_TIME:
		return
	var shrink: = clampf(
		(_death_time - DEATH_FALL_TIME - DEATH_HOLD_TIME) / DEATH_SHRINK_TIME, 
		0.0, 1.0)
	_visual.scale = Vector3.ONE.lerp(Vector3(0.04, 0.04, 0.04), shrink)
	if shrink >= 1.0:
		visible = false
		_death_time = -1.0
		_sync_processing()




func _flash_hit() -> void :
	if _mat == null:
		return
	_flash_time = 0.0
	_flash = 0.0
	_apply_mannequin_color()
	_sync_processing()


func _animate_flash(delta: float) -> void :
	_flash_time += delta
	if _flash_time < FLASH_UP_TIME:
		_set_flash(FLASH_PEAK * (_flash_time / FLASH_UP_TIME))
	elif _flash_time < FLASH_UP_TIME + FLASH_DOWN_TIME:
		var k: = (_flash_time - FLASH_UP_TIME) / FLASH_DOWN_TIME
		_set_flash(FLASH_PEAK * (1.0 - k))
	else:
		_flash_time = -1.0
		_set_flash(0.0)
		_sync_processing()


func _set_flash(value: float) -> void :
	_flash = value
	_apply_mannequin_color()





func _build_shards() -> void :
	if _shard_meshes.is_empty():
		for i in SHARD_COUNT:
			var box: = BoxMesh.new()
			box.size = Vector3(randf_range(0.05, 0.15), randf_range(0.05, 0.15), 
				randf_range(0.05, 0.15))
			_shard_meshes.append(box)
	var total: = SHARD_COUNT_MOBILE if Settings.is_mobile() else SHARD_COUNT
	_shard_pool.resize(total)
	_shard_from.resize(total)
	_shard_to.resize(total)
	_shard_spin.resize(total)
	_shard_elapsed.resize(total)
	_shard_life.resize(total)
	for i in total:
		var shard: = MeshInstance3D.new()
		shard.name = "Shard%d" % i
		shard.mesh = _shard_meshes[i]
		shard.material_override = _mat
		shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shard.gi_mode = GeometryInstance3D.GI_MODE_DISABLED


		shard.top_level = true
		shard.visible = false
		add_child(shard)
		_shard_pool[i] = shard





func _spawn_shards(zone: String) -> void :
	if _shard_pool.is_empty() or _mat == null:
		return
	var count: = _shard_budget()
	var height: = 1.72 if zone == "head" else (0.62 if zone == "legs" else 1.22)
	for i in _shard_pool.size():
		var shard: = _shard_pool[i]
		if i >= count:
			shard.visible = false
			continue
		var from: = global_position + Vector3(
			randf_range(-0.42, 0.42), 
			height + randf_range(-0.32, 0.32), 
			randf_range(-0.22, 0.22))
		var direction: = Vector3(randf_range(-1.0, 1.0), randf_range(0.15, 1.05), 
			randf_range(-1.0, 1.0)).normalized()

		if shard.material_override != _mat:
			shard.material_override = _mat
		_shard_from[i] = from
		_shard_to[i] = from + direction * randf_range(0.65, 1.55)\
		+ Vector3.DOWN * 0.55
		_shard_spin[i] = Vector3(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0), 
			randf_range(-6.0, 6.0))
		_shard_elapsed[i] = 0.0
		_shard_life[i] = randf_range(0.42, 0.62)
		shard.global_position = from
		shard.rotation = Vector3.ZERO
		shard.scale = Vector3.ONE
		shard.visible = true
	_shard_active = count
	_sync_processing()



func _shard_budget() -> int:
	var budget: = SHARD_COUNT_MOBILE if Settings.is_mobile() else SHARD_COUNT
	match Settings.effects_quality:
		0:
			budget = SHARD_COUNT_MIN
		1:
			budget = 6 if Settings.is_mobile() else 8
	return mini(budget, _shard_pool.size())





func _animate_shards(delta: float) -> void :
	var alive: = 0
	for i in _shard_pool.size():
		var shard: = _shard_pool[i]
		if not shard.visible:
			continue
		_shard_elapsed[i] += delta
		var life: = maxf(_shard_life[i], 0.001)
		var t: = clampf(_shard_elapsed[i] / life, 0.0, 1.0)
		var eased: = 1.0 - (1.0 - t) * (1.0 - t)
		shard.global_position = _shard_from[i].lerp(_shard_to[i], eased)
		shard.rotation = _shard_spin[i] * t
		var shrink: = clampf((_shard_elapsed[i] - 0.22) / 0.28, 0.0, 1.0)
		shard.scale = Vector3.ONE * (1.0 - shrink * shrink)
		if t < 1.0:
			alive += 1
		else:
			shard.visible = false
	_shard_active = alive
	if alive == 0:
		_sync_processing()


func _hide_shards() -> void :
	for shard in _shard_pool:
		shard.visible = false
	_shard_active = 0
	_sync_processing()
