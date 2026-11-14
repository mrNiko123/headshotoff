extends Node




func _ready() -> void :
	var scene: Node3D = load("res://models/AWP.fbx").instantiate()
	add_child(scene)
	await get_tree().process_frame
	var mi: MeshInstance3D = scene.find_children("*", "MeshInstance3D", true, false)[0]
	var xform: = mi.global_transform
	var arrays: Array = mi.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var world: = PackedVector3Array()
	for v in verts:
		world.append(xform * v)

	var bins: = 24
	for b in bins:
		var from: = -6.0 + 12.0 * b / bins
		var to: = -6.0 + 12.0 * (b + 1) / bins
		var lo: = 99.0
		var hi: = -99.0
		var count: = 0
		for v in world:
			if v.x >= from and v.x < to:
				lo = minf(lo, v.y)
				hi = maxf(hi, v.y)
				count += 1
		print("x %6.2f..%6.2f n=%4d y %6.3f..%6.3f" % [from, to, count, lo, hi])

	var grip_lo: = Vector3(99, 99, 99)
	var grip_hi: = Vector3(-99, -99, -99)
	for v in world:
		if v.x > 3.0 and v.x < 4.4 and v.y < -0.4:
			grip_lo = grip_lo.min(v)
			grip_hi = grip_hi.max(v)
	print("grip box ", grip_lo, " .. ", grip_hi)
	print("grip center ", (grip_lo + grip_hi) * 0.5)

	var fore: = Vector3(99, 99, 99)
	var fore_hi: = Vector3(-99, -99, -99)
	for v in world:
		if v.x > -4.2 and v.x < -2.6:
			fore = fore.min(v)
			fore_hi = fore_hi.max(v)
	print("fore-end box ", fore, " .. ", fore_hi)
	print("fore-end center ", (fore + fore_hi) * 0.5)

	var tip: = Vector3(99, 99, 99)
	for v in world:
		if v.x < -5.4:
			tip = tip.min(v)
	print("barrel tip ", tip)
	var scope: = Vector3(-99, -99, -99)
	for v in world:
		scope = scope.max(v)
	print("max y (scope top) ", scope.y, " at ", scope)
	print("PROBE OK")
	get_tree().quit()
