extends Node3D










const MeshKit = preload("res://scripts/mesh_kit.gd")
const FLOOR_SHADER = preload("res://shaders/arena_floor.gdshader")

const HALF: = 48.0
const WALL_HEIGHT: = 13.0
const TILE_W: = 2.2
const TILE_H: = 1.4


const HOUSE_HALF_X: = 17.0
const HOUSE_Z0: = -10.0
const HOUSE_Z1: = -30.0
const HOUSE_Y: = 5.4
const HOUSE_ROOF: = 10.0
const ROOF_TOP: = 10.45

var spawn_points: Array[Vector3] = []
var player_start: = Vector3(0.0, 0.05, 34.0)

var _floor_mat: ShaderMaterial
var _mortar: StandardMaterial3D
var _yellow: StandardMaterial3D
var _yellow_deep: StandardMaterial3D
var _taupe: StandardMaterial3D
var _taupe_light: StandardMaterial3D
var _print: StandardMaterial3D
var _accent: StandardMaterial3D
var _pad_mat: StandardMaterial3D



var _batches: Dictionary = {}


func _ready() -> void :
	_build_materials()
	_build_floor()
	_build_perimeter()
	_build_house()
	_build_second_floor()
	_build_roof_access()
	_build_balcony_ramps()
	_build_towers()
	_build_plaza()
	_build_ramps()
	_build_pads()
	_build_lights()
	_build_spawn_points()
	_flush_visuals()


func _build_materials() -> void :
	_floor_mat = ShaderMaterial.new()
	_floor_mat.shader = FLOOR_SHADER
	_floor_mat.set_shader_parameter("base_color", Color(0.185, 0.172, 0.158, 1.0))
	_floor_mat.set_shader_parameter("seam_color", Color(0.14, 0.13, 0.12, 1.0))
	_floor_mat.set_shader_parameter("tile_size", 4.0)


	_mortar = MeshKit.material(Color(0.115, 0.104, 0.096, 1.0), 0.95, 0.0)
	_yellow = MeshKit.material(Color(0.945, 0.62, 0.07, 1.0), 0.82, 0.0)
	_yellow_deep = MeshKit.material(Color(0.84, 0.5, 0.04, 1.0), 0.86, 0.0)
	_taupe = MeshKit.material(Color(0.3, 0.272, 0.252, 1.0), 0.9, 0.0)
	_taupe_light = MeshKit.material(Color(0.395, 0.36, 0.335, 1.0), 0.9, 0.0)

	_print = MeshKit.material(Color(0.905, 0.895, 0.86, 1.0), 0.65, 0.0)
	_accent = MeshKit.material(Color(1.0, 0.6, 0.12, 1.0), 0.55, 0.0, 
		Color(1.0, 0.58, 0.14, 1.0), 0.55)
	_pad_mat = MeshKit.material(Color(1.0, 0.64, 0.16, 1.0), 0.55, 0.0, 
		Color(1.0, 0.56, 0.1, 1.0), 1.6)


func _build_floor() -> void :
	var body: = StaticBody3D.new()
	body.name = "Floor"
	add_child(body)
	var shape: = BoxShape3D.new()
	shape.size = Vector3(HALF * 2.0, 0.6, HALF * 2.0)
	var col: = CollisionShape3D.new()
	col.shape = shape
	col.position = Vector3(0.0, -0.3, 0.0)
	body.add_child(col)
	var mesh: = MeshInstance3D.new()
	mesh.mesh = MeshKit.box_mesh(shape.size)
	mesh.material_override = _floor_mat
	mesh.position = Vector3(0.0, -0.3, 0.0)
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.add_child(mesh)




func _build_perimeter() -> void :
	var bands: = [
		[4.6, 0.0, _yellow], 
		[4.0, 4.6, _taupe], 
		[4.4, 8.6, _yellow_deep], 
	]
	for side in [-1.0, 1.0]:
		for band in bands:
			var height: float = band[0]
			var y: float = band[1]
			_solid(Vector3(HALF * 2.0, height, 1.2), 
				Vector3(0.0, y + height * 0.5, side * (HALF - 0.6)), band[2])
			_solid(Vector3(1.2, height, HALF * 2.0), 
				Vector3(side * (HALF - 0.6), y + height * 0.5, 0.0), band[2])

	for side in [-1.0, 1.0]:
		_decor(Vector3(HALF * 2.0, 0.45, 1.5), 
			Vector3(0.0, WALL_HEIGHT + 0.2, side * (HALF - 0.6)), _mortar)
		_decor(Vector3(1.5, 0.45, HALF * 2.0), 
			Vector3(side * (HALF - 0.6), WALL_HEIGHT + 0.2, 0.0), _mortar)
		_decor(Vector3(HALF * 2.0 - 8.0, 0.12, 0.06), 
			Vector3(0.0, 5.2, side * (HALF - 1.22)), _accent)
		_decor(Vector3(0.06, 0.12, HALF * 2.0 - 8.0), 
			Vector3(side * (HALF - 1.22), 5.2, 0.0), _accent)




func _build_house() -> void :


	_clad_wall(Vector3(8.0, HOUSE_Y, 1.2), Vector3(-13.0, HOUSE_Y * 0.5, HOUSE_Z0))
	_clad_wall(Vector3(8.0, HOUSE_Y, 1.2), Vector3(13.0, HOUSE_Y * 0.5, HOUSE_Z0))
	_clad_wall(Vector3(4.6, HOUSE_Y, 1.2), Vector3(-6.7, HOUSE_Y * 0.5, HOUSE_Z0))
	_clad_wall(Vector3(4.6, HOUSE_Y, 1.2), Vector3(6.7, HOUSE_Y * 0.5, HOUSE_Z0))
	_clad_wall(Vector3(8.8, 0.9, 1.2), Vector3(0.0, 4.95, HOUSE_Z0))

	_clad_wall(Vector3(34.0, HOUSE_Y, 1.2), Vector3(0.0, HOUSE_Y * 0.5, HOUSE_Z1))
	_clad_wall(Vector3(20.0, HOUSE_Y, 1.2), Vector3( - HOUSE_HALF_X, HOUSE_Y * 0.5, 
		(HOUSE_Z0 + HOUSE_Z1) * 0.5), Vector3(0.0, 90.0, 0.0))
	_clad_wall(Vector3(20.0, HOUSE_Y, 1.2), Vector3(HOUSE_HALF_X, HOUSE_Y * 0.5, 
		(HOUSE_Z0 + HOUSE_Z1) * 0.5), Vector3(0.0, 90.0, 0.0))


	_brick_pillar(Vector3(-7.0, 0.0, -20.0), HOUSE_Y, 2.2)
	_brick_pillar(Vector3(7.0, 0.0, -20.0), HOUSE_Y, 2.2)


	for side in [-1.0, 1.0]:
		for offset in [-5.0, 5.0]:
			_decor(Vector3(0.1, 2.2, 4.2), 
				Vector3(side * (HOUSE_HALF_X - 0.66), 2.9, -20.0 + offset), 
				_mortar)



	for x in [-16.0, -6.0, 6.0, 16.0]:
		_brick_pillar(Vector3(x, HOUSE_Y, HOUSE_Z0 + 1.0), HOUSE_ROOF - HOUSE_Y, 2.2)
		_brick_pillar(Vector3(x, HOUSE_Y, HOUSE_Z1 - 1.0), HOUSE_ROOF - HOUSE_Y, 2.2)
	for z in [-16.0, -24.0]:
		_brick_pillar(Vector3( - HOUSE_HALF_X + 1.0, HOUSE_Y, z), 
			HOUSE_ROOF - HOUSE_Y, 2.2)
		_brick_pillar(Vector3(HOUSE_HALF_X - 1.0, HOUSE_Y, z), 
			HOUSE_ROOF - HOUSE_Y, 2.2)


	var frame_h: = 1.0
	var parapet_y: = HOUSE_Y + frame_h * 0.5
	var beam_y: = HOUSE_ROOF - frame_h * 0.5


	for side in [-1.0, 1.0]:
		_clad_wall(Vector3(11.0, frame_h, 1.0), 
			Vector3(side * 9.5, parapet_y, HOUSE_Z0))
	_clad_wall(Vector3(30.0, frame_h, 1.0), Vector3(0.0, parapet_y, HOUSE_Z1))
	for z in [HOUSE_Z0, HOUSE_Z1]:
		_clad_wall(Vector3(30.0, frame_h, 1.0), Vector3(0.0, beam_y, z))
	for x in [ - HOUSE_HALF_X, HOUSE_HALF_X]:
		_clad_wall(Vector3(18.0, frame_h, 1.0), Vector3(x, parapet_y, 
			(HOUSE_Z0 + HOUSE_Z1) * 0.5), Vector3(0.0, 90.0, 0.0))
		_clad_wall(Vector3(18.0, frame_h, 1.0), Vector3(x, beam_y, 
			(HOUSE_Z0 + HOUSE_Z1) * 0.5), Vector3(0.0, 90.0, 0.0))


	_solid(Vector3(34.0, 0.6, 20.0), Vector3(0.0, HOUSE_ROOF + 0.3, -20.0), 
		_taupe_light)

	_roof_tiles()


	_solid(Vector3(34.0, 0.85, 0.5), Vector3(0.0, ROOF_TOP + 0.42, HOUSE_Z1 + 0.15), 
		_taupe)
	_solid(Vector3(34.0, 0.85, 0.5), Vector3(0.0, ROOF_TOP + 0.42, HOUSE_Z0 - 0.15), 
		_taupe)
	_solid(Vector3(0.5, 0.85, 20.0), Vector3( - HOUSE_HALF_X + 0.15, ROOF_TOP + 0.42, 
		-20.0), _taupe)


	_solid(Vector3(20.0, 1.1, 10.0), Vector3(0.0, ROOF_TOP + 0.55, -20.0), _yellow)
	_solid(Vector3(14.0, 1.1, 9.0), Vector3(0.0, ROOF_TOP + 1.65, -20.0), _taupe)
	_solid(Vector3(8.0, 1.1, 8.0), Vector3(0.0, ROOF_TOP + 2.75, -20.0), _yellow_deep)
	for i in 3:
		var w: = 4.0 - i
		_decor(Vector3(w, 0.22, 0.9), 
			Vector3(0.0, ROOF_TOP + 0.45 + i * 1.1, HOUSE_Z0 - 5.0 + i * 0.6), _print)


	for x in [-10.0, 10.0]:
		_decor(Vector3(2.4, 0.9, 0.05), Vector3(x, 3.0, HOUSE_Z0 + 0.74), 
			_print)
		_decor(Vector3(1.4, 0.22, 0.04), 
			Vector3(x, 2.68, HOUSE_Z0 + 0.78), _taupe)

	_decor(Vector3(4.6, 1.0, 0.06), Vector3(0.0, 6.2, HOUSE_Z0 + 0.62), 
		_print)
	var sign: = Label3D.new()
	sign.text = "BLOCK 6.6"
	sign.font_size = 96
	sign.pixel_size = 0.0062
	sign.position = Vector3(0.0, 6.2, HOUSE_Z0 + 0.68)
	sign.modulate = Color(0.18, 0.14, 0.1, 1.0)
	sign.shaded = false
	sign.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sign.no_depth_test = false
	add_child(sign)



func _roof_tiles() -> void :
	var parts: Array = []
	var cols: = 15
	var rows: = 8
	var tile: = Vector3(2.1, 0.1, 2.3)
	for row in rows:
		for col in cols:
			if (row + col) % 4 == 3:
				continue
			var pos: = Vector3( - HOUSE_HALF_X + 1.2 + col * 2.24, 
				ROOF_TOP + 0.05, HOUSE_Z1 + 1.3 + row * 2.42)
			parts.append([MeshKit.box_mesh(tile), Transform3D(Basis.IDENTITY, pos)])
	_merged(self, parts, _yellow)





func _build_second_floor() -> void :
	var top: = HOUSE_Y + 0.3
	var center_y: = top - 0.25

	_solid(Vector3(34.0, 0.5, 3.0), Vector3(0.0, center_y, -11.5), _taupe_light)
	_solid(Vector3(34.0, 0.5, 7.0), Vector3(0.0, center_y, -26.5), _taupe_light)
	for side in [-1.0, 1.0]:
		_solid(Vector3(11.0, 0.5, 10.0), Vector3(side * 11.5, center_y, -18.0), 
			_taupe_light)

	_decor(Vector3(12.3, 0.12, 0.24), Vector3(0.0, top + 0.06, -13.0), 
		_yellow)
	_decor(Vector3(12.3, 0.12, 0.24), Vector3(0.0, top + 0.06, -23.0), 
		_yellow)
	for side in [-1.0, 1.0]:
		_decor(Vector3(0.24, 0.12, 10.4), 
			Vector3(side * 6.0, top + 0.06, -18.0), _yellow)




func _build_roof_access() -> void :

	_solid(Vector3(24.0, 0.5, 10.0), Vector3(29.0, HOUSE_ROOF + 0.25, -25.0), _taupe)

	var ramp_size: = Vector3(7.5, 0.5, 40.0)
	var ramp_pos: = Vector3(36.0, 5.2, -10.0)
	var ramp_rot: = Vector3(14.0, 0.0, 0.0)
	_solid(ramp_size, ramp_pos, _taupe, ramp_rot)


	_ramp_trim(ramp_size, ramp_pos, ramp_rot, _accent)

	_solid(Vector3(24.0, 0.9, 0.4), Vector3(29.0, ROOF_TOP + 0.95, -30.0), _taupe)
	_solid(Vector3(0.4, 0.9, 10.0), Vector3(41.0, ROOF_TOP + 0.95, -25.0), _taupe)


func _build_balcony_ramps() -> void :

	_solid(Vector3(34.0, 0.5, 3.4), Vector3(0.0, HOUSE_Y + 0.05, -8.3), _taupe)



	for i in 8:
		var x: = -16.0 + i * 4.6
		_solid(Vector3(0.34, 1.0, 0.34), Vector3(x, HOUSE_Y + 0.8, -6.9), _taupe)
	_solid(Vector3(34.0, 0.18, 0.3), Vector3(0.0, HOUSE_Y + 1.35, -6.9), _accent)
	for side in [-1.0, 1.0]:
		_solid(Vector3(11.0, 0.5, 5.0), Vector3(side * 22.0, HOUSE_Y + 0.05, -9.0), 
			_taupe)

		var ramp_size: = Vector3(7.0, 0.45, 24.0)
		var ramp_pos: = Vector3(side * 29.5, 2.6, 2.0)
		var ramp_rot: = Vector3(13.5, 0.0, 0.0)



		_solid(ramp_size, ramp_pos, _taupe, ramp_rot)
		_ramp_trim(ramp_size, ramp_pos, ramp_rot, _accent)




func _build_towers() -> void :

	_cube_tower(Vector3(-37.0, 0.0, 2.0), 2.4, 5)
	_cube_tower(Vector3(-33.5, 0.0, -6.0), 2.4, 3)
	_cube_tower(Vector3(34.0, 0.0, -34.0), 2.4, 4)
	_cube_tower(Vector3(28.0, 0.0, 30.0), 2.2, 3)
	_cube_tower(Vector3(-27.0, 0.0, 27.0), 2.2, 2)


func _cube_tower(base: Vector3, size: float, levels: int) -> void :
	for i in levels:
		var mat: = _taupe if i % 3 == 2 else (_yellow if i % 2 == 0 else _yellow_deep)
		var offset: = Vector3(sin(float(i) * 2.1) * 0.16, 0.0, 
			cos(float(i) * 1.7) * 0.16)
		var pos: = base + offset + Vector3(0.0, size * (float(i) + 0.5), 0.0)
		_solid(Vector3(size, size, size), pos, mat)
		if i % 2 == 0:
			_plate(pos + Vector3(0.0, size * 0.18, size * 0.5 + 0.005), size * 0.9)


func _build_plaza() -> void :

	var stacks: = [
		[Vector3(-20.0, 0.0, 14.0), 2.2, 2], 
		[Vector3(-16.6, 0.0, 15.2), 1.6, 1], 
		[Vector3(22.0, 0.0, 20.0), 2.0, 3], 
		[Vector3(19.4, 0.0, 23.0), 1.5, 2], 
		[Vector3(32.0, 0.0, 8.0), 2.2, 2], 
		[Vector3(-32.0, 0.0, -20.0), 2.4, 3], 
		[Vector3(-28.0, 0.0, -24.0), 1.7, 1], 
		[Vector3(24.0, 0.0, -20.0), 2.0, 2], 
		[Vector3(-8.0, 0.0, 26.0), 1.5, 1], 
		[Vector3(7.0, 0.0, 24.0), 1.8, 1], 
	]
	for spec in stacks:
		var base: Vector3 = spec[0]
		var size: float = spec[1]
		var levels: int = spec[2]
		for i in levels:
			var mat: = _yellow if (i + int(base.x)) % 2 == 0 else _yellow_deep
			var pos: = base + Vector3(0.0, size * (float(i) + 0.5), 0.0)
			_solid(Vector3(size, size, size), pos, mat)
			if i == 0:
				_plate(pos + Vector3(0.0, size * 0.1, size * 0.5 + 0.005), size * 0.85)


	for spec in [
		[Vector3(-26.0, 0.8, 10.0), Vector3(12.0, 1.6, 1.4)], 
		[Vector3(26.0, 0.8, 10.0), Vector3(12.0, 1.6, 1.4)], 
		[Vector3(-16.0, 0.8, -4.0), Vector3(1.4, 1.6, 9.0)], 
		[Vector3(16.0, 0.8, -4.0), Vector3(1.4, 1.6, 9.0)], 
		[Vector3(0.0, 0.8, 18.0), Vector3(9.0, 1.6, 1.4)], 
	]:
		var pos: Vector3 = spec[0]
		var size: Vector3 = spec[1]
		_solid(size, pos, _taupe)
		_clad_face(size, pos, _yellow)


	for spec in [
		[Vector3(-22.0, 0.0, -8.0), 2.6], 
		[Vector3(22.0, 0.0, -10.0), 2.6], 
		[Vector3(-14.0, 0.0, 4.0), 1.8], 
		[Vector3(14.0, 0.0, 2.0), 2.0], 
	]:
		var base: Vector3 = spec[0]
		var size: float = spec[1]
		var pos: = base + Vector3(0.0, size * 0.5, 0.0)
		_solid(Vector3(size, size, size), pos, _yellow)
		_plate(pos + Vector3(0.0, size * 0.12, size * 0.5 + 0.005), size * 0.8)


func _build_ramps() -> void :

	for side in [-1.0, 1.0]:
		var ramp_size: = Vector3(7.0, 0.42, 12.0)
		var ramp_pos: = Vector3(side * 11.0, 1.0, 12.0)
		var ramp_rot: = Vector3(16.0, 0.0, 0.0)
		_solid(ramp_size, ramp_pos, _taupe, ramp_rot)
		_ramp_trim(ramp_size, ramp_pos, ramp_rot, _accent)

	for i in 7:
		var step_h: = 0.75
		_solid(Vector3(2.4, step_h, 2.4), 
			Vector3(20.0, step_h * 0.5 + step_h * i, 2.0 - i * 2.1), _yellow_deep)


func _build_pads() -> void :
	_bounce_pad(Vector3(12.0, 0.0, 28.0))
	_bounce_pad(Vector3(-14.0, 0.0, 24.0))
	_bounce_pad(Vector3(30.0, 0.0, -2.0))
	_bounce_pad(Vector3(-30.0, 0.0, -8.0))


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

	_decor(Vector3(2.6, 0.16, 2.6), pos + Vector3(0.0, 0.08, 0.0), 
		_pad_mat)
	_decor(Vector3(2.0, 0.1, 2.0), pos + Vector3(0.0, 0.2, 0.0), 
		_pad_mat)


func _build_lights() -> void :
	for spec in [
		[Vector3(0.0, 4.6, -20.0), 2.4, 26.0], 
		[Vector3(-8.0, 4.2, -20.0), 1.6, 15.0], 
		[Vector3(8.0, 4.2, -20.0), 1.6, 15.0], 
		[Vector3(0.0, 7.6, -12.0), 1.3, 18.0], 
		[Vector3(0.0, 7.6, -26.0), 1.3, 18.0], 
		[Vector3(0.0, 8.0, 6.0), 1.0, 30.0], 
		[Vector3(-32.0, 7.0, -6.0), 0.8, 24.0], 
		[Vector3(32.0, 7.0, -6.0), 0.8, 24.0], 
	]:
		var light: = OmniLight3D.new()
		var light_pos: Vector3 = spec[0]
		light.position = light_pos
		light.light_color = Color(1.0, 0.84, 0.62, 1.0)
		light.light_energy = float(spec[1])
		light.omni_range = float(spec[2])
		light.shadow_enabled = false


		light.add_to_group("arena_decor_lights")
		add_child(light)


func _build_spawn_points() -> void :
	spawn_points = [

		Vector3(0.0, 0.05, 30.0), 
		Vector3(-10.0, 0.05, 26.0), 
		Vector3(10.0, 0.05, 27.0), 
		Vector3(-22.0, 0.05, 18.0), 
		Vector3(22.0, 0.05, 16.0), 
		Vector3(-30.0, 0.05, 8.0), 
		Vector3(30.0, 0.05, 6.0), 
		Vector3(-12.0, 0.05, 6.0), 
		Vector3(12.0, 0.05, 8.0), 

		Vector3(-36.0, 0.05, -14.0), 
		Vector3(36.0, 0.05, -14.0), 
		Vector3(-26.0, 0.05, -22.0), 
		Vector3(26.0, 0.05, -22.0), 
		Vector3(-20.0, 0.05, -4.0), 
		Vector3(20.0, 0.05, -4.0), 

		Vector3(0.0, 0.05, -14.0), 
		Vector3(-8.0, 0.05, -22.0), 
		Vector3(8.0, 0.05, -22.0), 
		Vector3(0.0, 0.05, -27.0), 

		Vector3(-12.0, HOUSE_Y + 0.35, -8.3), 
		Vector3(0.0, HOUSE_Y + 0.35, -8.3), 
		Vector3(12.0, HOUSE_Y + 0.35, -8.3), 
		Vector3(-11.5, HOUSE_Y + 0.35, -18.0), 
		Vector3(11.5, HOUSE_Y + 0.35, -18.0), 
		Vector3(0.0, HOUSE_Y + 0.35, -26.5), 
		Vector3(0.0, ROOF_TOP + 0.05, -20.0), 
		Vector3(26.0, ROOF_TOP + 0.05, -25.0), 
		Vector3(-14.0, ROOF_TOP + 0.05, -16.0), 
	]






func _clad_wall(size: Vector3, pos: Vector3, rot: = Vector3.ZERO) -> void :
	_solid(size, pos, _mortar, rot)
	var basis: = Basis.from_euler(rot * (PI / 180.0))
	var cols: = maxi(int(floor(size.x / TILE_W)), 1)
	var rows: = maxi(int(floor(size.y / TILE_H)), 1)
	var tile_w: = size.x / float(cols)
	var tile_h: = size.y / float(rows)
	var yellow_parts: Array = []
	var taupe_parts: Array = []
	var print_parts: Array = []
	for face in [-1.0, 1.0]:
		for row in rows:
			for col in cols:
				var dark: = row % 4 == 3 or col == 0 or col == cols - 1\
				or (row * 7 + col * 5 + int(face)) % 23 == 0
				var local: = Vector3( - size.x * 0.5 + tile_w * (float(col) + 0.5), 
					- size.y * 0.5 + tile_h * (float(row) + 0.5), 
					face * (size.z * 0.5 + 0.035))
				var xf: = Transform3D(basis, pos + basis * local)
				var tile: = Vector3(tile_w - 0.08, tile_h - 0.08, 0.07)
				var parts: Array = taupe_parts if dark else yellow_parts
				parts.append([MeshKit.box_mesh(tile), xf])
				if not dark and (row * 5 + col * 3 + int(face)) % 17 == 0:
					var plate_xf: = Transform3D(basis, pos + basis * (local
						+ Vector3(tile_w * 0.16, tile_h * 0.12, face * 0.045)))
					print_parts.append([MeshKit.box_mesh(
						Vector3(0.52, 0.2, 0.02)), plate_xf])
	_merged(self, yellow_parts, _yellow)
	_merged(self, taupe_parts, _taupe)
	_merged(self, print_parts, _print)




func _clad_face(size: Vector3, pos: Vector3, mat: Material) -> void :
	var parts: Array = []
	var cols: = maxi(int(size.x / TILE_W), 1)
	var rows: = maxi(int(size.y / TILE_H), 1)
	var tile_w: = size.x / float(cols)
	var tile_h: = size.y / float(rows)
	for face in [-1.0, 1.0]:
		for row in rows:
			for col in cols:
				var local: = Vector3( - size.x * 0.5 + tile_w * (float(col) + 0.5), 0.0, 
					face * (size.z * 0.5 + 0.03))
				var tile: = Vector3(tile_w - 0.08, tile_h - 0.08, 0.06)
				var y: = - size.y * 0.5 + tile_h * (float(row) + 0.5)
				parts.append([MeshKit.box_mesh(tile), 
					Transform3D(Basis.IDENTITY, pos + local + Vector3(0.0, y, 0.0))])
	_merged(self, parts, mat)



func _brick_pillar(base: Vector3, height: float, width: float) -> void :
	_solid(Vector3(width, height, width), base + Vector3(0.0, height * 0.5, 0.0), 
		_mortar)
	var levels: = maxi(int(round(height / 1.5)), 1)
	var step: = height / float(levels)
	var yellow_parts: Array = []
	var taupe_parts: Array = []
	for i in levels:
		var dark: = i % 3 == 2
		var parts: Array = taupe_parts if dark else yellow_parts
		var size: = Vector3(width + 0.14, step - 0.1, width + 0.14)
		var xf: = Transform3D(Basis.IDENTITY, 
			base + Vector3(0.0, step * (float(i) + 0.5), 0.0))
		parts.append([MeshKit.box_mesh(size), xf])
	_merged(self, yellow_parts, _yellow)
	_merged(self, taupe_parts, _taupe)



func _plate(pos: Vector3, width: float) -> void :
	_decor(Vector3(minf(width * 0.55, 1.2), 0.26, 0.02), pos, _print)
	_decor(Vector3(minf(width * 0.3, 0.66), 0.07, 0.025), 
		pos + Vector3(0.0, -0.02, 0.01), _taupe)





func _merged(_parent: Node3D, parts: Array, mat: Material) -> void :
	if parts.is_empty():
		return
	if not _batches.has(mat):
		_batches[mat] = []
	_batches[mat].append_array(parts)



func _decor(size: Vector3, pos: Vector3, mat: Material, 
		rot: = Vector3.ZERO) -> void :
	_batch(size, pos, mat, rot)


func _batch(size: Vector3, pos: Vector3, mat: Material, rot: Vector3) -> void :
	if not _batches.has(mat):
		_batches[mat] = []
	var basis: = Basis.from_euler(rot * (PI / 180.0))
	_batches[mat].append([MeshKit.box_mesh(size), Transform3D(basis, pos)])




func _ramp_trim(size: Vector3, pos: Vector3, rot: Vector3, mat: Material, 
		trim: = 0.22, thick: = 0.06) -> void :
	var basis: = Basis.from_euler(rot * (PI / 180.0))
	var inset: = 0.18
	var top: = size.y * 0.5 + thick * 0.5 - 0.012
	if absf(rot.x) >= absf(rot.z):
		var high: = -1.0 if rot.x > 0.0 else 1.0
		_decor(Vector3(size.x - inset * 2.0, thick, trim), 
			pos + basis * Vector3(0.0, top, high * (size.z * 0.5 - trim * 0.5)), 
			mat, rot)
		for side in [-1.0, 1.0]:
			_decor(Vector3(trim, thick, size.z - inset * 2.0), 
				pos + basis * Vector3(side * (size.x * 0.5 - trim * 0.5), 
					top, 0.0), mat, rot)
	else:
		var high: = 1.0 if rot.z > 0.0 else -1.0
		_decor(Vector3(trim, thick, size.z - inset * 2.0), 
			pos + basis * Vector3(high * (size.x * 0.5 - trim * 0.5), 
				top, 0.0), mat, rot)
		for side in [-1.0, 1.0]:
			_decor(Vector3(size.x - inset * 2.0, thick, trim), 
				pos + basis * Vector3(0.0, top, 
					side * (size.z * 0.5 - trim * 0.5)), mat, rot)





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


func _solid(size: Vector3, pos: Vector3, mat: Material, 
		rot: = Vector3.ZERO) -> StaticBody3D:
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
	return body
