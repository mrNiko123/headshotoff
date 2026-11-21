extends SceneTree

# РЎРЅРёРјР°РµС‚ РєР°СЂС‚Сѓ РІС‹СЃРѕС‚ Dust2 (РїРѕР») РґР»СЏ РІС‹Р±РѕСЂР° СЃРїР°РІРЅРѕРІ Рё СЃР°Р№С‚РѕРІ.

const MESH_PATH: = "res://assets/maps/dust2/dust2_mesh.res"
const GRID: = 64


func _init() -> void :
	var mesh: Mesh = load(MESH_PATH) as Mesh
	if mesh == null:
		print("NO_MESH")
		quit()
		return
	var arrays: Array = mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var aabb: AABB = mesh.get_aabb()
	print("AABB ", aabb)
	var cell: = aabb.size.x / float(GRID)
	var floors: Array = []
	floors.resize(GRID * GRID)
	var i: = 0
	while i + 2 < verts.size():
		var a: = verts[i]
		var b: = verts[i + 1]
		var c: = verts[i + 2]
		var n: = normals[i]
		i += 3
		if absf(n.y) < 0.62:
			continue
		var y: = (a.y + b.y + c.y) / 3.0
		for t in 3:
			var wa: = 0.6 if t == 0 else 0.2
			var wb: = 0.2 if t == 0 else 0.4
			var wc: = 1.0 - wa - wb
			var px: = a.x * wa + b.x * wb + c.x * wc
			var pz: = a.z * wa + b.z * wb + c.z * wc
			var gx: = int((px - aabb.position.x) / cell)
			var gz: = int((pz - aabb.position.z) / cell)
			if gx < 0 or gz < 0 or gx >= GRID or gz >= GRID:
				continue
			var idx: = gz * GRID + gx
			var old: Variant = floors[idx]
			if old == null or y < float(old):
				floors[idx] = y
	print("FLOOR_GRID cell=", snappedf(cell, 0.01), " origin=", aabb.position)
	var out: = ""
	for gz in GRID:
		var row: = ""
		for gx in GRID:
			var v: Variant = floors[gz * GRID + gx]
			row += "." if v == null else str(clampi(int((float(v) - aabb.position.y) / 8.0 * 9.0), 0, 9))
		out += row + "\n"
	print(out)
	quit()
