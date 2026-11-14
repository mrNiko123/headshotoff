extends RefCounted







static func apply(root: Node, material: Material) -> void :
	if root == null:
		return
	if root is MeshInstance3D:
		(root as MeshInstance3D).material_overlay = material
	for child in root.get_children():
		apply(child, material)


static func clear(root: Node) -> void :
	apply(root, null)
