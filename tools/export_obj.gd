extends SceneTree

# Экспортёр импортированных моделей (.scn) в OBJ+MTL, чтобы файлы
# открывались вне Godot. Аргументов нет — список пар внутри.

const PAIRS: = [
	["C:/Users/user/Desktop/Headshot/.godot/imported/AWP.fbx-43dbd6a2f743dacabdaccbb64a3b98cc.scn", 
		"C:/Users/user/Desktop/Headshot/models/AWP.obj"], 
	["C:/Users/user/Desktop/Headshot/.godot/imported/Butterfly.fbx-dd8acfd7239e41899d7ab876a68f806d.scn", 
		"C:/Users/user/Desktop/Headshot/knife/Butterfly.obj"], 
	["C:/Users/user/Desktop/Headshot/.godot/imported/Bayonet.fbx-12a6d9fd14c8c65a1cbc286f48be21db.scn", 
		"C:/Users/user/Desktop/Headshot/knife/Bayonet.obj"], 
	["C:/Users/user/Desktop/Headshot/.godot/imported/Karambit.fbx-1b5f0b358e57f9340fb3f3294b9e03ab.scn", 
		"C:/Users/user/Desktop/Headshot/knife/Karambit.obj"], 
	["C:/Users/user/Desktop/Headshot/.godot/imported/Skeleton.fbx-0cf904758e855c06ce3bedf0798b527a.scn", 
		"C:/Users/user/Desktop/Headshot/knife/Skeleton.obj"], 
	["C:/Users/user/Desktop/Headshot/.godot/imported/Dagger.fbx-7943b409bb86b7a30797152d1a123ad3.scn", 
		"C:/Users/user/Desktop/Headshot/knife/Dagger.obj"], 
	["C:/Users/user/Desktop/Headshot/.godot/imported/CombatKnife.fbx-a5ff27a53d7e490e0582da4311dab7e8.scn", 
		"C:/Users/user/Desktop/Headshot/knife/CombatKnife.obj"], 
	["C:/Users/user/Desktop/Headshot/.godot/imported/Nomad (2).fbx-849b285cc27723e5a78df652107eec6b.scn", 
		"C:/Users/user/Desktop/Headshot/knife/Nomad.obj"], 
]


func _init() -> void :
	var ok: = 0
	for pair in PAIRS:
		if _export_obj(str(pair[0]), str(pair[1])):
			ok += 1
	print("OBJ_EXPORTED=", ok)
	quit()


func _export_obj(src_path: String, out_path: String) -> bool:
	var res: = ResourceLoader.load(src_path)
	if res == null:
		print("FAIL_LOAD ", src_path)
		return false
	var scene: = res as PackedScene
	if scene == null:
		print("FAIL_SCENE ", src_path)
		return false

	var node: = scene.instantiate()
	var out_name: = out_path.get_basename().get_file()
	var body: PackedStringArray = []
	body.append("# Экспортировано из Godot")
	body.append("mtllib %s.mtl" % out_name)
	var mtl: PackedStringArray = []
	mtl.append("newmtl skin")
	mtl.append("Kd 0.8 0.8 0.8")
	mtl.append("map_Kd %s_texture.png" % out_name)
	_v_offset = 0
	_n_offset = 0
	_collect(node, Transform3D.IDENTITY, body)
	node.free()

	var file: = FileAccess.open(out_path, FileAccess.WRITE)
	if file == null:
		print("FAIL_WRITE ", out_path)
		return false
	for line in body:
		file.store_line(line)
	file.close()
	var mtl_path: = out_path.get_basename() + ".mtl"
	var mfile: = FileAccess.open(mtl_path, FileAccess.WRITE)
	for line in mtl:
		mfile.store_line(line)
	mfile.close()
	print("OK ", out_path)
	return true


func _collect(node: Node, xform: Transform3D, body: PackedStringArray) -> void :
	var mi: = node as MeshInstance3D
	if mi != null and mi.mesh != null:
		var local: = xform
		var p: Node = mi
		while p != null:
			var n3: = p as Node3D
			if n3 != null:
				local = n3.transform * local
			p = p.get_parent()
		_write_mesh_obj(mi.mesh, local, body)

	for child in node.get_children():
		_collect(child, xform, body)


var _v_offset: = 0
var _n_offset: = 0


func _write_mesh_obj(mesh: Mesh, xform: Transform3D, body: PackedStringArray) -> void :
	for s in mesh.get_surface_count():
		var arrays: = mesh.surface_get_arrays(s)
		if arrays == null:
			continue
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		var index: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		if verts.is_empty():
			continue
		body.append("o part_%d_%d" % [body.size(), s])
		for v in verts:
			var w: = xform * v
			body.append("v %.5f %.5f %.5f" % [w.x, w.y, w.z])
		for n in normals:
			var wn: = xform.basis * n
			body.append("vn %.4f %.4f %.4f" % [wn.x, wn.y, wn.z])
		if not uvs.is_empty():
			for uv in uvs:
				# OBJ-конвенция: V снизу; Godot при импорте перевернёт обратно.
				body.append("vt %.5f %.5f" % [uv.x, 1.0 - uv.y])
		body.append("usemtl skin")
		# Зеркальная трансформация (отрицательный детерминант) переворачивает
		# обход треугольников — иначе модель рендерится «наизнанку» (x-ray).
		var flip: = xform.basis.determinant() < 0.0
		if index.is_empty():
			for i in verts.size():
				body.append(_face(i, i, i, not uvs.is_empty()))
		else:
			for i in range(0, index.size(), 3):
				if flip:
					body.append(_face(index[i], index[i + 2], index[i + 1], 
						not uvs.is_empty()))
				else:
					body.append(_face(index[i], index[i + 1], index[i + 2], 
						not uvs.is_empty()))
		_v_offset += verts.size()
		_n_offset += normals.size()


func _face(a: int, b: int, c: int, has_uv: bool) -> String:
	var va: = _v_offset + a + 1
	var vb: = _v_offset + b + 1
	var vc: = _v_offset + c + 1
	if has_uv:
		return "f %d/%d/%d %d/%d/%d %d/%d/%d" % [va, va, va, vb, vb, vb, vc, vc, vc]
	return "f %d//%d %d//%d %d//%d" % [va, va, vb, vb, vc, vc]
