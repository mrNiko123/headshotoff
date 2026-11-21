extends SceneTree

# Собирает de_dust2 из исходного OBJ в один меш с цветами палитры игры.
# Оригинальные текстуры используются только для подбора оттенка и в игру не попадают.

const SRC_OBJ: = "C:/Users/user/AppData/Local/Temp/opencode/dust2/map/CSS de_dust2/Generic_Item.obj"
const SRC_MTL: = "C:/Users/user/AppData/Local/Temp/opencode/dust2/map/CSS de_dust2/Generic_Item.mtl"
const TEX_DIR: = "C:/Users/user/AppData/Local/Temp/opencode/dust2/textures/"
const OUT_DIR: = "res://assets/maps/dust2"
const OUT_MESH: = "res://assets/maps/dust2/dust2_mesh.res"

var _tex_cache: Dictionary = {}
var _mat_tex: Dictionary = {}


func _init() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_parse_mtl()
	var mesh: ArrayMesh = _parse_obj()
	if mesh == null:
		print("DUST2_BUILD_FAILED")
		quit()
		return
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.roughness = 0.92
	mat.metallic = 0.0
	mesh.surface_set_material(0, mat)
	var err: = ResourceSaver.save(mesh, OUT_MESH)
	print("DUST2_SAVED err=", err, " verts=", mesh.surface_get_array_len(0))
	quit()


func _parse_mtl() -> void :
	var file: = FileAccess.open(SRC_MTL, FileAccess.READ)
	if file == null:
		return
	var current: = ""
	while not file.eof_reached():
		var line: = file.get_line().strip_edges()
		if line.begins_with("newmtl "):
			current = line.substr(7).strip_edges()
		elif line.begins_with("map_Kd ") and not current.is_empty():
			_mat_tex[current] = line.substr(7).strip_edges().get_file()
	file.close()


func _texture_color(texture_name: String) -> Color:
	if _tex_cache.has(texture_name):
		return _tex_cache[texture_name] as Color
	var color: = Color(0.62, 0.56, 0.44, 1.0)
	var path: = TEX_DIR + texture_name
	if FileAccess.file_exists(path):
		var image: = Image.load_from_file(path)
		if image != null:
			image.resize(6, 6, Image.INTERPOLATE_BILINEAR)
			var sum: = Color(0.0, 0.0, 0.0, 1.0)
			var count: = 0
			for y in image.get_height():
				for x in image.get_width():
					var px: = image.get_pixel(x, y)
					sum.r += px.r
					sum.g += px.g
					sum.b += px.b
					count += 1
			if count > 0:
				color = Color(sum.r / count, sum.g / count, sum.b / count, 1.0)
	_tex_cache[texture_name] = color
	return color


func _material_color(material_name: String) -> Color:
	var texture: = str(_mat_tex.get(material_name, ""))
	var avg: = _texture_color(texture) if not texture.is_empty() else Color(0.6, 0.55, 0.45, 1.0)
	var l: = avg.get_luminance()
	var sand: = Color(0.82, 0.72, 0.53)
	var stone: = Color(0.58, 0.57, 0.52)
	var dark: = Color(0.29, 0.28, 0.25)
	var base: = sand.lerp(stone, clampf((0.62 - l) * 2.4, 0.0, 1.0))
	base = base.lerp(dark, clampf((0.3 - l) * 1.8, 0.0, 0.75))
	var color: = avg.lerp(base, 0.62)
	var h: = absi(hash(material_name))
	var jitter: = 0.9 + 0.18 * float(h % 1000) / 1000.0
	return Color(clampf(color.r * jitter, 0.06, 0.94), 
		clampf(color.g * jitter, 0.06, 0.94), 
		clampf(color.b * jitter, 0.06, 0.94), 1.0)


func _parse_obj() -> ArrayMesh:
	var file: = FileAccess.open(SRC_OBJ, FileAccess.READ)
	if file == null:
		return null
	var verts: = PackedVector3Array()
	var normals: = PackedVector3Array()
	var out_verts: = PackedVector3Array()
	var out_normals: = PackedVector3Array()
	var out_colors: = PackedColorArray()
	var current_color: = Color(0.65, 0.6, 0.5, 1.0)
	var color_cache: Dictionary = {}
	var face_count: = 0
	while not file.eof_reached():
		var line: = file.get_line().strip_edges()
		if line.is_empty():
			continue
		var space: = line.find(" ")
		if space < 0:
			continue
		var tag: = line.substr(0, space)
		if tag == "v":
			var p: = line.substr(space + 1).split(" ", false)
			if p.size() >= 3:
				verts.append(Vector3(p[0].to_float(), p[1].to_float(), p[2].to_float()))
		elif tag == "vn":
			var n: = line.substr(space + 1).split(" ", false)
			if n.size() >= 3:
				normals.append(Vector3(n[0].to_float(), n[1].to_float(), n[2].to_float()))
		elif tag == "usemtl":
			var name: = line.substr(space + 1).strip_edges()
			if color_cache.has(name):
				current_color = color_cache[name] as Color
			else:
				current_color = _material_color(name)
				color_cache[name] = current_color
		elif tag == "f":
			var corners: = line.substr(space + 1).split(" ", false)
			if corners.size() < 3:
				continue
			var positions: Array[Vector3] = []
			var dirs: Array[Vector3] = []
			for corner in corners:
				var parts: = str(corner).split("/")
				var vi: = int(parts[0])
				if vi < 0:
					vi = verts.size() + vi + 1
				if vi < 1 or vi > verts.size():
					continue
				positions.append(verts[vi - 1])
				var normal: = Vector3.UP
				if parts.size() >= 3 and not str(parts[2]).is_empty():
					var ni: = int(parts[2])
					if ni < 0:
						ni = normals.size() + ni + 1
					if ni >= 1 and ni <= normals.size():
						normal = normals[ni - 1]
				dirs.append(normal)
			for i in range(1, positions.size() - 1):
				var edge_a: = positions[i] - positions[0]
				var edge_b: = positions[i + 1] - positions[0]
				var face_normal: = edge_a.cross(edge_b)
				var flat: = 0.0
				if face_normal.length_squared() > 0.000001:
					flat = absf(face_normal.normalized().y)
				var shade: = 0.6 + 0.4 * flat
				var tint: = Color(current_color.r * shade, 
					current_color.g * shade, current_color.b * shade, 1.0)
				out_verts.append(positions[0])
				out_verts.append(positions[i])
				out_verts.append(positions[i + 1])
				out_normals.append(dirs[0])
				out_normals.append(dirs[i])
				out_normals.append(dirs[i + 1])
				out_colors.append(tint)
				out_colors.append(tint)
				out_colors.append(tint)
				face_count += 1
	file.close()
	if out_verts.is_empty():
		return null
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = out_verts
	arrays[Mesh.ARRAY_NORMAL] = out_normals
	arrays[Mesh.ARRAY_COLOR] = out_colors
	var mesh: = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	print("DUST2_TRIS=", face_count, " MATS=", color_cache.size())
	return mesh
