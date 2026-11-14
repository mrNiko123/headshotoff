extends RefCounted




static var _mesh_cache: Dictionary = {}
static var _mat_cache: Dictionary = {}


static func box_mesh(size: Vector3) -> BoxMesh:
	var key: = "b|%s" % size
	if _mesh_cache.has(key):
		return _mesh_cache[key] as BoxMesh
	var mesh: = BoxMesh.new()
	mesh.size = size
	_mesh_cache[key] = mesh
	return mesh



static func rounded_box(size: Vector3, _radius: = 0.0, _segments: = 0) -> BoxMesh:
	return box_mesh(size)


static func material(
	color: Color, 
	roughness: = 0.85, 
	metallic: = 0.0, 
	emission: = Color(0.0, 0.0, 0.0, 1.0), 
	emission_energy: = 0.0, 
	overlay: = false
) -> StandardMaterial3D:
	var key: = "m|%s|%.3f|%.3f|%s|%.3f|%s" % [
		color.to_html(), roughness, metallic, emission.to_html(), emission_energy, str(overlay)
	]
	if _mat_cache.has(key):
		return _mat_cache[key] as StandardMaterial3D
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	mat.metallic_specular = 0.35
	if emission_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = emission_energy
	if overlay:
		mat.no_depth_test = true
		mat.disable_fog = true
		mat.render_priority = 2
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_mat_cache[key] = mat
	return mat


static func additive(color: Color) -> StandardMaterial3D:
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = color
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_fog = true
	return mat


static func box(parent: Node3D, size: Vector3, pos: Vector3, mat: Material, 
		_radius: = 0.0, rot: = Vector3.ZERO, _segments: = 0) -> MeshInstance3D:
	return block(parent, size, pos, mat, rot)


static func block(parent: Node3D, size: Vector3, pos: Vector3, mat: Material, 
		rot: = Vector3.ZERO) -> MeshInstance3D:
	var inst: = MeshInstance3D.new()
	inst.mesh = box_mesh(size)
	inst.material_override = mat
	inst.position = pos
	inst.rotation_degrees = rot
	inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(inst)
	return inst






static func ramp_trim(parent: Node3D, size: Vector3, pos: Vector3, rot: Vector3, 
		mat: Material, trim: = 0.22, thick: = 0.06) -> void :
	var basis: = Basis.from_euler(rot * (PI / 180.0))
	var inset: = 0.18

	var top: = size.y * 0.5 + thick * 0.5 - 0.012
	if absf(rot.x) >= absf(rot.z):

		var high: = -1.0 if rot.x > 0.0 else 1.0
		block(parent, Vector3(size.x - inset * 2.0, thick, trim), 
			pos + basis * Vector3(0.0, top, 
				high * (size.z * 0.5 - trim * 0.5)), mat, rot)
		for side in [-1.0, 1.0]:
			block(parent, Vector3(trim, thick, size.z - inset * 2.0), 
				pos + basis * Vector3(side * (size.x * 0.5 - trim * 0.5), 
					top, 0.0), mat, rot)
	else:

		var high: = 1.0 if rot.z > 0.0 else -1.0
		block(parent, Vector3(trim, thick, size.z - inset * 2.0), 
			pos + basis * Vector3(high * (size.x * 0.5 - trim * 0.5), 
				top, 0.0), mat, rot)
		for side in [-1.0, 1.0]:
			block(parent, Vector3(size.x - inset * 2.0, thick, trim), 
				pos + basis * Vector3(0.0, top, 
					side * (size.z * 0.5 - trim * 0.5)), mat, rot)


static func limb(parent: Node3D, from: Vector3, to: Vector3, thickness: float, 
		mat: Material, flatness: = 1.0) -> MeshInstance3D:

	var dir: = to - from
	var length: = dir.length()
	if length < 0.001:
		length = 0.001
	var inst: = MeshInstance3D.new()
	inst.mesh = box_mesh(Vector3(thickness, length, thickness * flatness))
	inst.material_override = mat
	inst.position = (from + to) * 0.5
	var basis: = Basis.looking_at(dir.normalized(), Vector3.UP)
	basis = basis * Basis(Vector3.RIGHT, - PI * 0.5)
	inst.basis = basis
	inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(inst)
	return inst




static func limb_transform(from: Vector3, to: Vector3) -> Transform3D:
	var dir: = to - from
	var length: = dir.length()
	if length < 0.001:
		length = 0.001
	var basis: = Basis.looking_at(dir.normalized(), Vector3.UP)
	basis = basis * Basis(Vector3.RIGHT, - PI * 0.5)
	return Transform3D(basis, (from + to) * 0.5)





static func merged_boxes(parts: Array) -> ArrayMesh:
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for part in parts:
		var mesh: = part[0] as Mesh
		var xform: Transform3D = part[1]
		st.append_from(mesh, 0, xform)
	return st.commit()


static func cylinder(parent: Node3D, radius: float, height: float, pos: Vector3, 
		mat: Material, rot: = Vector3(90.0, 0.0, 0.0), segments: = 10) -> MeshInstance3D:
	var mesh: = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	var inst: = MeshInstance3D.new()
	inst.mesh = mesh
	inst.material_override = mat
	inst.position = pos
	inst.rotation_degrees = rot
	inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(inst)
	return inst


static func segment(parent: Node3D, from: Vector3, to: Vector3, thickness: float, 
		mat: Material, _radius: = 0.0) -> MeshInstance3D:
	return limb(parent, from, to, thickness, mat)
