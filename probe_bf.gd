extends Node




const WeaponBuilder = preload("res://scripts/weapon_builder.gd")


func _ready() -> void :
	var holder: = Node3D.new()
	add_child(holder)
	var weapon: = WeaponBuilder.build(holder, "knife", "ember", false)
	await get_tree().process_frame
	var inv: = weapon.global_transform.affine_inverse()
	print("weapon origin ", weapon.global_position)
	for arm_name in ["BladeArm", "Lever1Arm", "Lever2Arm"]:
		var arm: = weapon.find_child(arm_name, true, false) as Node3D
		if arm == null:
			print(arm_name, " missing")
			continue
		var box: = _box_in(arm, inv)
		print(arm_name, " center=", box.get_center(), " size=", box.size)
	var rig: = weapon.find_child("FoldRig", true, false) as Node3D
	if rig != null:
		print("FoldRig (hinge) local=", inv * rig.global_position)
	print("grip local=", Vector3(0.0, 0.0, -0.096))
	get_tree().quit()


func _box_in(node: Node3D, inv: Transform3D) -> AABB:
	var box: = AABB()
	var found: = false
	var stack: Array = [[node, inv * node.global_transform]]
	while not stack.is_empty():
		var entry: Array = stack.pop_back()
		var current: = entry[0] as Node3D
		var xf: Transform3D = entry[1]
		if current is MeshInstance3D:
			var mesh: = current as MeshInstance3D
			if mesh.mesh != null:
				var part: = xf * mesh.mesh.get_aabb()
				box = part if not found else box.merge(part)
				found = true
		for child in current.get_children():
			if child is Node3D:
				stack.append([child, xf * (child as Node3D).transform])
	return box
