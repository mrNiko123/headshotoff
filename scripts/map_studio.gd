extends Node3D










const MeshKit = preload("res://scripts/mesh_kit.gd")
const GRID_SHADER = preload("res://shaders/grid_surface.gdshader")

const HALF: = 60.0
const SEGMENT: = 6.0
const WALL_HEIGHT: = 14.0
const WALL_DEPTH: = 4.0

var spawn_points: Array[Vector3] = []
var player_start: = Vector3(0.0, 0.05, 50.0)

var _floor_mat: ShaderMaterial
var _white: ShaderMaterial
var _white_alt: ShaderMaterial
var _white_dark: ShaderMaterial
var _accent: StandardMaterial3D
var _pad_mat: StandardMaterial3D
var _batches: Dictionary = {}


func _ready() -> void :
	_build_materials()
	_build_floor()
	_build_perimeter()
	_build_arch()
	_build_side_halls()
	_build_midfield()
	_build_platforms()
	_build_back_stand()
	_build_cover()
	_build_ramps()
	_build_pads()
	_build_spawn_points()
	_flush_visuals()


func _build_materials() -> void :
	_floor_mat = _grid_material(
		Color(0.455, 0.465, 0.485), Color(0.29, 0.31, 0.345), 
		Color(0.17, 0.19, 0.225), 3.0, 0.86, 0.026)
	_white = _grid_material(
		Color(0.475, 0.49, 0.51), Color(0.29, 0.31, 0.345), 
		Color(0.175, 0.195, 0.23), 2.0, 0.91, 0.014)
	_white_alt = _grid_material(
		Color(0.53, 0.545, 0.565), Color(0.33, 0.35, 0.385), 
		Color(0.2, 0.22, 0.255), 2.0, 0.89, 0.0)
	_white_dark = _grid_material(
		Color(0.37, 0.39, 0.42), Color(0.24, 0.26, 0.295), 
		Color(0.145, 0.165, 0.2), 2.0, 0.93, 0.0)


	_accent = MeshKit.material(Color(0.98, 0.7, 0.26, 1.0), 0.55, 0.0, 
		Color(1.0, 0.64, 0.18, 1.0), 0.45)
	_pad_mat = MeshKit.material(Color(1.0, 0.71, 0.23, 1.0), 0.45, 0.0, 
		Color(1.0, 0.6, 0.12, 1.0), 1.8)


func _grid_material(base: Color, seam: Color, cross: Color, grid: float, 
		roughness: float, checker: float) -> ShaderMaterial:
	var mat: = ShaderMaterial.new()
	mat.shader = GRID_SHADER
	mat.set_shader_parameter("base_color", base)
	mat.set_shader_parameter("seam_color", seam)
	mat.set_shader_parameter("cross_color", cross)
	mat.set_shader_parameter("grid_size", grid)
	mat.set_shader_parameter("roughness_value", roughness)
	mat.set_shader_parameter("checker_amount", checker)
	return mat


func _build_floor() -> void :
	_solid(Vector3(HALF * 2.0, 0.6, HALF * 2.0), Vector3(0.0, -0.3, 0.0), 
		_floor_mat)






func _build_perimeter() -> void :
	var heights: = [12.5, 10.8, 13.6, 11.6, 12.8]
	for side in [-1.0, 1.0]:
		for i in 20:
			var along: = - HALF + SEGMENT * (float(i) + 0.5)
			var h: float = heights[(i + (0 if side < 0.0 else 2)) % heights.size()]
			var mat: = _white if i % 3 != 1 else _white_alt
			if i % 7 == 3:
				mat = _white_dark
			var z: float = side * (HALF - WALL_DEPTH * 0.5)
			_solid(Vector3(SEGMENT, h, WALL_DEPTH), Vector3(along, h * 0.5, z), mat)
			_cap(Vector3(SEGMENT + 0.1, 0.3, WALL_DEPTH + 0.24), 
				Vector3(along, h + 0.15, z))
			var x: float = side * (HALF - WALL_DEPTH * 0.5)
			_solid(Vector3(WALL_DEPTH, h, SEGMENT), Vector3(x, h * 0.5, along), mat)
			_cap(Vector3(WALL_DEPTH + 0.24, 0.3, SEGMENT + 0.1), 
				Vector3(x, h + 0.15, along))


	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			_solid(Vector3(8.0, WALL_HEIGHT, 8.0), 
				Vector3(sx * (HALF - 4.0), WALL_HEIGHT * 0.5, 
					sz * (HALF - 4.0)), _white_alt)


func _cap(size: Vector3, pos: Vector3) -> void :
	_decor(size, pos, _white_alt)




func _build_arch() -> void :

	for side in [-1.0, 1.0]:
		_solid(Vector3(5.0, 10.0, 6.0), 
			Vector3(side * 8.5, 5.0, -6.0), _white)

		_decor(Vector3(0.22, 9.2, 0.35), 
			Vector3(side * 6.0, 4.6, -3.05), _white_dark)
	_solid(Vector3(26.0, 2.4, 8.0), Vector3(0.0, 11.2, -6.0), _white_alt)
	_solid(Vector3(18.0, 1.2, 6.0), Vector3(0.0, 13.0, -6.0), _white)
	_decor(Vector3(22.0, 0.45, 6.6), Vector3(0.0, 9.85, -6.0), _white_dark)

	_decor(Vector3(18.0, 0.1, 0.1), Vector3(0.0, 13.62, -3.02), _accent)

	for side in [-1.0, 1.0]:
		_solid(Vector3(6.0, 8.0, 8.0), 
			Vector3(side * 17.0, 4.0, -6.0), _white_alt)

	for side in [-1.0, 1.0]:
		_solid(Vector3(12.0, 8.0, 4.0), 
			Vector3(side * 14.0, 4.0, -22.0), _white)
	_solid(Vector3(16.0, 1.2, 4.0), Vector3(0.0, 7.4, -22.0), _white_alt)






func _build_side_halls() -> void :
	for side in [-1.0, 1.0]:
		var sx: float = side

		_solid(Vector3(4.0, 11.0, 14.0), Vector3(sx * 31.0, 5.5, -15.0), _white_alt)
		_solid(Vector3(4.0, 11.0, 10.0), Vector3(sx * 31.0, 5.5, 0.0), _white)
		_solid(Vector3(4.0, 1.0, 4.6), Vector3(sx * 31.0, 6.5, -6.5), _white_alt)

		_solid(Vector3(6.0, 11.0, 4.0), Vector3(sx * 44.0, 5.5, 3.0), _white_alt)
		_solid(Vector3(6.0, 11.0, 4.0), Vector3(sx * 34.0, 5.5, 3.0), _white)
		_solid(Vector3(4.6, 1.0, 4.0), Vector3(sx * 39.0, 6.5, 3.0), _white_alt)

		_solid(Vector3(9.0, 0.9, 2.2), Vector3(sx * 39.0, 0.45, -14.0), _white)
		_cube_stack(Vector3(sx * 36.0, 0.0, -20.0), 2.6, 2, _white_alt)
		_cube_stack(Vector3(sx * 45.0, 0.0, -8.0), 1.8, 1, _white)






func _build_midfield() -> void :
	for side in [-1.0, 1.0]:
		var sx: float = side
		_solid(Vector3(4.0, 8.0, 10.0), Vector3(sx * 15.0, 4.0, 22.0), _white_alt)
		_solid(Vector3(4.0, 8.0, 6.0), Vector3(sx * 15.0, 4.0, 11.0), _white)
		_solid(Vector3(4.0, 1.0, 4.2), Vector3(sx * 15.0, 7.5, 15.5), _white_alt)
		_cube_stack(Vector3(sx * 24.0, 0.0, 30.0), 4.0, 2, _white_alt)


	_cube_stack(Vector3(0.0, 0.0, 4.0), 4.0, 1, _white)


	_solid(Vector3(44.0, 0.8, 4.0), Vector3(0.0, 3.0, -30.0), _white)
	for x in [-10.0, 0.0, 10.0]:
		_solid(Vector3(2.0, 2.6, 2.0), Vector3(x, 1.3, -30.0), _white_alt)


	_cube_stack(Vector3(-48.0, 0.0, 40.0), 5.0, 3, _white)
	_cube_stack(Vector3(48.0, 0.0, 38.0), 4.5, 2, _white_alt)
	_cube_stack(Vector3(-46.0, 0.0, -44.0), 5.0, 2, _white_alt)
	_cube_stack(Vector3(46.0, 0.0, -44.0), 4.2, 2, _white)




func _build_platforms() -> void :

	_solid(Vector3(24.0, 1.2, 18.0), Vector3(31.0, 3.0, -24.0), _white_alt)
	_solid(Vector3(0.4, 0.6, 18.0), Vector3(43.2, 3.9, -24.0), _white)
	_solid(Vector3(24.0, 0.6, 0.4), Vector3(31.0, 3.9, -33.2), _white)
	_cube_stack(Vector3(24.0, 3.6, -28.0), 2.2, 2, _white)
	_solid(Vector3(9.0, 0.6, 32.0), Vector3(31.0, 0.8, 2.0), _white_alt, 
		Vector3(9.0, 0.0, 0.0))


	_solid(Vector3(22.0, 1.2, 16.0), Vector3(-31.0, 2.2, -24.0), _white)
	_solid(Vector3(0.4, 0.6, 16.0), Vector3(-42.2, 3.1, -24.0), _white)
	_solid(Vector3(22.0, 0.6, 0.4), Vector3(-31.0, 3.1, -32.2), _white)
	_cube_stack(Vector3(-24.0, 2.8, -28.0), 1.9, 2, _white_alt)
	_solid(Vector3(9.0, 0.6, 32.0), Vector3(-31.0, 0.28, 0.0), _white, 
		Vector3(8.0, 0.0, 0.0))


	_solid(Vector3(18.0, 1.2, 12.0), Vector3(0.0, 1.0, 24.0), _white_alt)
	_solid(Vector3(10.0, 0.5, 18.0), Vector3(0.0, 0.45, 38.0), _white, 
		Vector3(7.0, 0.0, 0.0))




func _build_back_stand() -> void :
	_solid(Vector3(28.0, 1.4, 8.0), Vector3(0.0, 0.7, -42.0), _white)
	_solid(Vector3(28.0, 0.7, 2.0), Vector3(0.0, 0.35, -37.0), _white_alt)
	_solid(Vector3(28.0, 1.0, 0.5), Vector3(0.0, 1.9, -46.0), _white_alt)
	for side in [-1.0, 1.0]:
		_solid(Vector3(4.0, 12.0, 4.0), 
			Vector3(side * 22.0, 6.0, -44.0), _white_alt)
	_solid(Vector3(48.0, 1.2, 4.0), Vector3(0.0, 12.6, -44.0), _white)
	_decor(Vector3(48.0, 0.1, 0.12), Vector3(0.0, 13.22, -41.94), _accent)




func _build_cover() -> void :
	var stacks: = [
		[Vector3(-17.0, 0.0, 18.0), 3.0, 1, _white], 
		[Vector3(17.0, 0.0, 20.0), 2.4, 2, _white_alt], 
		[Vector3(-44.0, 0.0, 34.0), 4.0, 1, _white], 
		[Vector3(45.0, 0.0, 32.0), 3.4, 2, _white_alt], 
		[Vector3(-48.0, 0.0, -26.0), 3.6, 1, _white_alt], 
		[Vector3(48.0, 0.0, -24.0), 3.2, 1, _white], 
		[Vector3(-13.0, 0.0, 4.0), 2.2, 1, _white], 
		[Vector3(13.0, 0.0, 0.0), 1.8, 2, _white_alt], 
	]
	for spec in stacks:
		var base: Vector3 = spec[0]
		var size: float = spec[1]
		var levels: int = spec[2]
		var mat: Material = spec[3]
		_cube_stack(base, size, levels, mat)


	for spec in [
		[Vector3(-20.0, 0.8, 10.0), Vector3(10.0, 1.6, 1.4)], 
		[Vector3(20.0, 0.8, 12.0), Vector3(10.0, 1.6, 1.4)], 
		[Vector3(-10.0, 0.8, -16.0), Vector3(1.4, 1.6, 8.0)], 
		[Vector3(10.0, 0.8, -18.0), Vector3(1.4, 1.6, 8.0)], 
		[Vector3(0.0, 0.8, 10.0), Vector3(9.0, 1.6, 1.4)], 
	]:
		var pos: Vector3 = spec[0]
		var size: Vector3 = spec[1]
		_solid(size, pos, _white)
		_decor(Vector3(size.x + 0.08, 0.1, size.z + 0.08), 
			pos + Vector3(0.0, size.y * 0.5, 0.0), _white_alt)


func _cube_stack(base: Vector3, size: float, levels: int, 
		mat: Material) -> void :
	for i in levels:
		var m: = mat if i % 2 == 0 else _white_alt
		var pos: = base + Vector3(0.0, size * (float(i) + 0.5), 0.0)
		_solid(Vector3(size, size, size), pos, m)
		_decor(Vector3(size + 0.1, 0.1, size + 0.1), 
			pos + Vector3(0.0, size * 0.5 + 0.05, 0.0), _white_dark)




func _build_ramps() -> void :

	for side in [-1.0, 1.0]:
		_solid(Vector3(7.0, 0.42, 12.0), 
			Vector3(side * 12.0, 1.0, 16.0), _white, 
			Vector3(16.0, 0.0, 0.0))
		_decor(Vector3(7.0, 0.1, 0.18), 
			Vector3(side * 12.0, 2.72, 10.3), _accent, Vector3(16.0, 0.0, 0.0))




func _build_pads() -> void :
	_bounce_pad(Vector3(14.0, 0.0, 42.0))
	_bounce_pad(Vector3(-14.0, 0.0, 42.0))
	_bounce_pad(Vector3(38.0, 0.0, 8.0))
	_bounce_pad(Vector3(-38.0, 0.0, 8.0))


func _bounce_pad(pos: Vector3) -> void :
	var area: = Area3D.new()
	area.name = "BouncePad"
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitorable = false
	area.position = pos + Vector3(0.0, 0.35, 0.0)
	add_child(area)

	var shape: = BoxShape3D.new()
	shape.size = Vector3(2.4, 0.7, 2.4)
	var col: = CollisionShape3D.new()
	col.shape = shape
	area.add_child(col)
	area.body_entered.connect( func(body: Node) -> void :
		if body.has_method("bounce"):
			body.call("bounce", 16.0))

	_decor(Vector3(2.6, 0.16, 2.6), pos + Vector3(0.0, 0.08, 0.0), _pad_mat)
	_decor(Vector3(2.0, 0.1, 2.0), pos + Vector3(0.0, 0.2, 0.0), _pad_mat)




func _build_spawn_points() -> void :
	spawn_points = [

		Vector3(0.0, 0.05, 50.0), 
		Vector3(-16.0, 0.05, 46.0), 
		Vector3(16.0, 0.05, 46.0), 
		Vector3(-32.0, 0.05, 40.0), 
		Vector3(32.0, 0.05, 40.0), 
		Vector3(-48.0, 0.05, 30.0), 
		Vector3(48.0, 0.05, 30.0), 

		Vector3(-48.0, 0.05, 8.0), 
		Vector3(48.0, 0.05, 8.0), 
		Vector3(-32.0, 0.05, 12.0), 
		Vector3(32.0, 0.05, 14.0), 
		Vector3(-25.0, 0.05, 24.0), 
		Vector3(25.0, 0.05, 24.0), 
		Vector3(0.0, 1.65, 24.0), 

		Vector3(0.0, 0.05, -14.0), 
		Vector3(-24.0, 0.05, -8.0), 
		Vector3(24.0, 0.05, -8.0), 
		Vector3(-40.0, 0.05, -18.0), 
		Vector3(40.0, 0.05, -18.0), 
		Vector3(-48.0, 0.05, -34.0), 
		Vector3(48.0, 0.05, -34.0), 

		Vector3(-8.0, 1.45, -42.0), 
		Vector3(8.0, 1.45, -42.0), 
		Vector3(0.0, 1.45, -40.0), 

		Vector3(24.0, 3.65, -22.0), 
		Vector3(38.0, 3.65, -26.0), 
		Vector3(31.0, 3.65, -30.0), 
		Vector3(-24.0, 2.85, -22.0), 
		Vector3(-38.0, 2.85, -26.0), 
		Vector3(-31.0, 2.85, -30.0), 

		Vector3(0.0, 13.65, -6.0), 
	]




func _solid(size: Vector3, pos: Vector3, mat: Material, 
		rot: = Vector3.ZERO) -> void :
	var body: = StaticBody3D.new()
	body.position = pos
	body.rotation_degrees = rot
	add_child(body)
	var shape: = BoxShape3D.new()
	shape.size = size
	var col: = CollisionShape3D.new()
	col.shape = shape
	body.add_child(col)
	_batch(size, pos, mat, rot)


func _decor(size: Vector3, pos: Vector3, mat: Material, 
		rot: = Vector3.ZERO) -> void :
	_batch(size, pos, mat, rot)


func _batch(size: Vector3, pos: Vector3, mat: Material, 
		rot: Vector3) -> void :
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
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		inst.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		add_child(inst)
	_batches.clear()
