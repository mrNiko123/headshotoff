extends Node

# Печать AABB новых OBJ-моделей.

func _ready() -> void :
	await get_tree().process_frame
	for path in ["res://models/AWP.obj", "res://knife/Karambit.obj", "res://knife/Butterfly.obj"]:
		var mesh: Mesh = load(path) as Mesh
		if mesh == null:
			print("NULL ", path)
			continue
		var aabb: AABB = mesh.get_aabb()
		print("AABB ", path.get_file(), " pos=", aabb.position, " size=", aabb.size)
	get_tree().quit()
