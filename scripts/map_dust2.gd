extends Node3D






const MeshKit = preload("res://scripts/mesh_kit.gd")
const GRID_SHADER = preload("res://shaders/grid_surface.gdshader")

const HALF: = 56.0
const SEGMENT: = 6.4
const WALL_HEIGHT: = 13.0
const WALL_DEPTH: = 4.0

var spawn_points: Array[Vector3] = []
var player_start: = Vector3(0.0, 0.05, 48.0)

var _sand_mat: ShaderMaterial
var _sand_wall: ShaderMaterial
var _sand_wall_alt: ShaderMaterial
var _brick_dark: ShaderMaterial
var _accent: StandardMaterial3D
var _crate_mat: StandardMaterial3D
var _pad_mat: StandardMaterial3D
var _batches: Dictionary = {}


func _ready() -> void :
	_build_materials()
	_build_floor()
	_build_perimeter()
	_build_mid_doors()
	_build_site_a()
	_build_site_b()
	_build_long()
	_build_tunnels()
	_build_short()
	_build_cover()
	_build_pads()
	_build_spawn_points()
	_flush_visuals()


func _build_materials() -> void :
	_sand_mat = _grid_material(
		Color(0.54, 0.47, 0.32), Color(0.36, 0.3, 0.2), 
		Color(0.24, 0.2, 0.13), 3.4, 0.94, 0.0)
	_sand_wall = _grid_material(
		Color(0.5, 0.43, 0.3), Color(0.33, 0.28, 0.18), 
		Color(0.22, 0.185, 0.12), 2.6, 0.9, 0.012)
	_sand_wall_alt = _grid_material(
		Color(0.56, 0.49, 0.35), Color(0.38, 0.32, 0.21), 
		Color(0.26, 0.22, 0.14), 2.6, 0.88, 0.0)
	_brick_dark = _grid_material(
		Color(0.36, 0.27, 0.19), Color(0.24, 0.18, 0.124), 
		Color(0.15, 0.11, 0.075), 2.2, 0.93, 0.0)

	_accent = MeshKit.material(Color(0.85, 0.42, 0.16, 1.0), 0.62, 0.0, 
		Color(1.0, 0.5, 0.18, 1.0), 0.4)
	_crate_mat = MeshKit.material(Color(0.44, 0.32, 0.18, 1.0), 0.86, 0.04, 
		Color(0.5, 0.38, 0.2, 1.0), 0.0)
	_pad_mat = MeshKit.material(Color(0.9, 0.55, 0.2, 1.0), 0.45, 0.0, 
		Color(1.0, 0.62, 0.22, 1.0), 1.6)


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
		_sand_mat)










func _build_perimeter() -> void :
	var heights: = [11.5, 9.8, 12.6, 10.6, 11.8, 10.2, 12.2, 9.4]
	for side in [-1.0, 1.0]:
		for i in 18:
			var along: = - HALF + SEGMENT * (float(i) + 0.5)
			var h: float = heights[(i + (0 if side < 0.0 else 4)) % heights.size()]
			var mat: = _sand_wall if i % 3 != 1 else _sand_wall_alt
			if i % 7 == 3:
				mat = _brick_dark
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
			_solid(Vector3(9.0, WALL_HEIGHT, 9.0), 
				Vector3(sx * (HALF - 4.5), WALL_HEIGHT * 0.5, 
					sz * (HALF - 4.5)), _sand_wall_alt)










func _build_mid_doors() -> void :

	_solid(Vector3(3.2, 7.5, 22.0), Vector3(-13.0, 3.75, 2.0), _sand_wall)
	_solid(Vector3(3.2, 7.5, 18.0), Vector3(13.0, 3.75, 4.0), _sand_wall_alt)


	_solid(Vector3(10.0, 1.1, 4.0), Vector3(0.0, 1.0, -6.0), _brick_dark)
	_solid(Vector3(4.2, 7.0, 2.4), Vector3(-6.6, 3.5, -6.0), _sand_wall)
	_solid(Vector3(4.2, 7.0, 2.4), Vector3(6.6, 3.5, -6.0), _sand_wall)
	_solid(Vector3(16.0, 1.2, 2.8), Vector3(0.0, 7.4, -6.0), _brick_dark)

	_decor(Vector3(18.4, 0.26, 0.3), Vector3(0.0, 3.15, -4.6), _accent)


	_solid(Vector3(7.0, 6.5, 5.0), Vector3(-22.0, 3.25, -18.0), _sand_wall_alt)
	_solid(Vector3(4.0, 6.5, 22.0), Vector3(-26.0, 3.25, -8.0), _brick_dark)
	_solid(Vector3(4.0, 9.0, 14.0), Vector3(-30.0, 4.5, 22.0), _sand_wall)
	_solid(Vector3(4.0, 9.0, 10.0), Vector3(30.0, 4.5, 18.0), _sand_wall_alt)







func _build_site_a() -> void :

	_solid(Vector3(20.0, 1.6, 16.0), Vector3(34.0, 3.0, -34.0), _sand_wall_alt)
	_solid(Vector3(0.5, 1.0, 16.0), Vector3(23.8, 3.8, -34.0), _sand_wall)
	_solid(Vector3(20.0, 1.0, 0.5), Vector3(34.0, 3.75, -41.8), _sand_wall)

	_solid(Vector3(8.0, 6.0, 3.4), Vector3(24.5, 4.3, -45.0), _brick_dark)

	_solid(Vector3(9.0, 0.5, 20.0), Vector3(34.0, 0.3, -14.0), _sand_wall_alt, 
		Vector3(15.5, 0.0, 0.0))
	_cube_stack(Vector3(38.0, 0.0, -22.0), 3.0, 2, _crate_mat)
	_cube_stack(Vector3(31.0, 0.0, -38.0), 2.4, 1, _crate_mat)
	_cube_stack(Vector3(46.0, 0.0, -30.0), 2.2, 1, _crate_mat)







func _build_site_b() -> void :

	_solid(Vector3(18.0, 1.4, 14.0), Vector3(-34.0, 2.5, -36.0), _sand_wall_alt)
	_solid(Vector3(0.5, 0.9, 14.0), Vector3(-24.2, 3.25, -36.0), _sand_wall)
	_cube_stack(Vector3(-38.0, 0.0, -28.0), 2.6, 2, _crate_mat)
	_cube_stack(Vector3(-46.0, 0.0, -44.0), 3.2, 1, _crate_mat)

	_solid(Vector3(10.0, 7.0, 3.2), Vector3(-30.0, 3.5, -20.0), _brick_dark)
	_solid(Vector3(3.4, 1.0, 10.0), Vector3(-40.0, 0.7, -8.0), _sand_wall, 
		Vector3(0.0, 0.0, 12.0))











func _build_long() -> void :
	_solid(Vector3(3.6, 6.0, 26.0), Vector3(22.0, 3.0, 16.0), _sand_wall)
	_solid(Vector3(3.6, 6.0, 14.0), Vector3(22.0, 3.0, 40.0), _sand_wall_alt)
	_solid(Vector3(3.6, 1.0, 4.8), Vector3(22.0, 6.6, 30.0), _brick_dark)
	_cube_stack(Vector3(40.0, 0.0, 6.0), 3.4, 2, _crate_mat)
	_cube_stack(Vector3(46.0, 0.0, 20.0), 2.8, 1, _crate_mat)
	_cube_stack(Vector3(38.0, 0.0, 30.0), 4.2, 1, _crate_mat)
	_cube_stack(Vector3(48.0, 0.0, 38.0), 3.6, 2, _crate_mat)





func _build_tunnels() -> void :
	_solid(Vector3(4.0, 5.2, 30.0), Vector3(-22.0, 2.6, 24.0), _brick_dark)
	_solid(Vector3(4.0, 5.2, 30.0), Vector3(-22.0, 2.6, -8.0), _brick_dark)
	_solid(Vector3(12.0, 5.2, 4.0), Vector3(-28.0, 2.6, 40.0), _brick_dark)
	_solid(Vector3(14.0, 5.4, 3.4), Vector3(-14.0, 2.7, -2.0), _brick_dark)
	_cube_stack(Vector3(-16.0, 0.0, 14.0), 2.4, 1, _crate_mat)
	_cube_stack(Vector3(-46.0, 0.0, -6.0), 3.0, 1, _crate_mat)











func _build_short() -> void :
	_solid(Vector3(4.2, 6.8, 12.0), Vector3(8.0, 3.4, 34.0), _sand_wall_alt)
	_solid(Vector3(12.0, 6.8, 3.6), Vector3(18.0, 3.4, 28.0), _sand_wall_alt)
	_cube_stack(Vector3(4.0, 0.0, 26.0), 2.2, 1, _crate_mat)
	_solid(Vector3(6.0, 0.4, 10.0), Vector3(-4.0, 0.4, 32.0), _sand_wall_alt)
	_decor(Vector3(0.35, 0.4, 10.4), Vector3(-3.4, 0.9, 32.0), _accent)











func _build_cover() -> void :
	var stacks: = [
		[Vector3(-48.0, 0.0, 34.0), 4.2, 2, _crate_mat], 
		[Vector3(48.0, 0.0, -6.0), 3.2, 1, _crate_mat], 
		[Vector3(-10.0, 0.0, -30.0), 3.0, 1, _crate_mat], 
		[Vector3(10.0, 0.0, -32.0), 2.4, 2, _crate_mat], 
		[Vector3(-38.0, 0.0, 10.0), 3.6, 2, _crate_mat], 
		[Vector3(44.0, 0.0, 44.0), 3.4, 1, _crate_mat], 
		[Vector3(0.0, 0.0, 16.0), 2.8, 1, _crate_mat], 
		[Vector3(-52.0, 0.0, -20.0), 3.2, 2, _crate_mat], 
	]
	for spec in stacks:
		var base: Vector3 = spec[0]
		var size: float = spec[1]
		var levels: int = spec[2]
		var mat: Material = spec[3]
		_cube_stack(base, size, levels, mat)

	for spec in [
		[Vector3(-14.0, 0.7, -24.0), Vector3(9.0, 1.4, 1.3)], 
		[Vector3(14.0, 0.7, -26.0), Vector3(9.0, 1.4, 1.3)], 
		[Vector3(-34.0, 0.7, 26.0), Vector3(1.3, 1.4, 8.0)], 
		[Vector3(30.0, 0.7, 44.0), Vector3(8.0, 1.4, 1.3)], 
	]:
		var pos: Vector3 = spec[0]
		var size: Vector3 = spec[1]
		_solid(size, pos, _brick_dark)
		_decor(Vector3(size.x + 0.08, 0.1, size.z + 0.08), 
			pos + Vector3(0.0, size.y * 0.5, 0.0), _sand_wall_alt)


func _cube_stack(base: Vector3, size: float, levels: int, 
		mat: Material) -> void :
	for i in levels:
		var m: = mat if i % 2 == 0 else _brick_dark
		var pos: = base + Vector3(0.0, size * (float(i) + 0.5), 0.0)
		_solid(Vector3(size, size, size), pos, m)
		_decor(Vector3(size + 0.1, 0.1, size + 0.1), 
			pos + Vector3(0.0, size * 0.5 + 0.05, 0.0), _sand_wall)


func _cap(size: Vector3, pos: Vector3) -> void :
	_decor(size, pos, _sand_wall_alt)


func _build_pads() -> void :
	_bounce_pad(Vector3(12.0, 0.0, 44.0))
	_bounce_pad(Vector3(-12.0, 0.0, 44.0))
	_bounce_pad(Vector3(36.0, 0.0, 4.0))
	_bounce_pad(Vector3(-36.0, 0.0, 4.0))


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
			body.call("bounce", 15.0))

	_decor(Vector3(2.6, 0.16, 2.6), pos + Vector3(0.0, 0.08, 0.0), _pad_mat)
	_decor(Vector3(2.0, 0.1, 2.0), pos + Vector3(0.0, 0.2, 0.0), _pad_mat)







func _build_spawn_points() -> void :
	spawn_points = [
		Vector3(0.0, 0.05, 48.0), 
		Vector3(-16.0, 0.05, 44.0), 
		Vector3(16.0, 0.05, 44.0), 
		Vector3(-32.0, 0.05, 38.0), 
		Vector3(32.0, 0.05, 38.0), 
		Vector3(-48.0, 0.05, 28.0), 
		Vector3(48.0, 0.05, 28.0), 

		Vector3(-48.0, 0.05, 6.0), 
		Vector3(48.0, 0.05, 6.0), 
		Vector3(-32.0, 0.05, 10.0), 
		Vector3(32.0, 0.05, 12.0), 
		Vector3(-24.0, 0.05, 24.0), 
		Vector3(24.0, 0.05, 26.0), 
		Vector3(0.0, 1.65, 24.0), 

		Vector3(0.0, 0.05, -14.0), 
		Vector3(-22.0, 0.05, -6.0), 
		Vector3(22.0, 0.05, -6.0), 
		Vector3(-40.0, 0.05, -18.0), 
		Vector3(40.0, 0.05, -18.0), 
		Vector3(-48.0, 0.05, -32.0), 
		Vector3(48.0, 0.05, -32.0), 

		Vector3(-8.0, 1.45, -40.0), 
		Vector3(8.0, 1.45, -40.0), 
		Vector3(0.0, 1.45, -38.0), 

		Vector3(26.0, 3.85, -32.0), 
		Vector3(38.0, 3.85, -36.0), 
		Vector3(33.0, 3.85, -40.0), 
		Vector3(-30.0, 3.2, -34.0), 
		Vector3(-42.0, 3.2, -38.0), 
		Vector3(-35.0, 3.2, -42.0), 

		Vector3(0.0, 12.65, -18.0), 
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