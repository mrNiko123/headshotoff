extends SceneTree
## Одноразовая чистка OBJ: оставляет только самую большую связную
## компоненту (сам пистолет), убирает магазин/патрон. Запуск:
## godot --headless --script res://tools/deagle_clean.gd

const SRC: = "res://assets/models/deagle/source/unzip/1obj.obj"
const OUT: = "res://assets/models/deagle/pistol.obj"


func _init() -> void :
	var f: = FileAccess.open(SRC, FileAccess.READ)
	var verts: PackedVector3Array = PackedVector3Array()
	var face_faces: Array = []
	while not f.eof_reached():
		var line: = f.get_line()
		if line.begins_with("v "):
			var p: = line.substr(2).split_floats(" ")
			verts.append(Vector3(p[0], p[1], p[2]))
		elif line.begins_with("f "):
			var parts: = line.substr(2).strip_edges().split(" ")
			var out_line: = ""
			var ids: = []
			for part in parts:
				var vi: = int(part.get_slice("/", 0)) - 1
				ids.append(vi)
				out_line += "%d " % (vi + 1)
			face_faces.append([ids, out_line])
	f.close()

	# рёбра по Index
	var adj: Array = []
	adj.resize(verts.size())
	for i in verts.size():
		adj[i] = []
	for face in face_faces:
		var ids: Array = face[0]
		for k in ids.size():
			var a: int = ids[k]
			var b: int = ids[(k + 1) % ids.size()]
			adj[a].append(b)
			adj[b].append(a)

	var comp: PackedInt32Array = PackedInt32Array()
	comp.resize(verts.size())
	var sizes: Dictionary = {}
	var next_id: = 1
	for start in verts.size():
		if comp[start] != 0:
			continue
		var stack: Array = [start]
		comp[start] = next_id
		var count: = 0
		while not stack.is_empty():
			var v: int = stack.pop_back()
			count += 1
			for u in adj[v]:
				if comp[u] == 0:
					comp[u] = next_id
					stack.append(u)
		sizes[next_id] = count
		next_id += 1

	var best: = 0
	var best_size: = 0
	for id in sizes:
		if sizes[id] > best_size:
			best_size = sizes[id]
			best = id
	print("COMPONENTS=", next_id - 1, "  BEST=", best, " SIZE=", best_size)

	#Faces лучшей компоненты
	var kept_faces: PackedStringArray = PackedStringArray()
	var used: = {}
	for face in face_faces:
		var ids: Array = face[0]
		var ok: = false
		for id in ids:
			if comp[id] == best:
				ok = true
				break
		if not ok:
			continue
		kept_faces.append(face[1])
		for id in ids:
			used[id] = true

	# перенумерация вершин
	var remap: Dictionary = {}
	var out_verts: PackedStringArray = PackedStringArray()
	for v in used:
		remap[v] = out_verts.size()
		var p: = verts[v]
		out_verts.append("v %.6f %.6f %.6f" % [p.x, p.y, p.z])

	var out_faces: PackedStringArray = PackedStringArray()
	for face in kept_faces:
		var parts: PackedStringArray = []
		for tok in face.strip_edges().split(" "):
			if tok.is_empty():
				continue
			parts.append(str(remap[int(tok) - 1] + 1))
		out_faces.append("f " + " ".join(parts))

	var o: = FileAccess.open(OUT, FileAccess.WRITE)
	for line in out_verts:
		o.store_line(line)
	for line in out_faces:
		o.store_line(line)
	o.close()
	print("OUT verts=", out_verts.size(), " faces=", out_faces.size())
	quit()
