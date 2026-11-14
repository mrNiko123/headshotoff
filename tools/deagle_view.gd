extends Node3D

func _ready() -> void :
	var sun: = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-38.0, -30.0, 0.0)
	sun.light_energy = 2.4
	add_child(sun)
	var fill: = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20.0, 140.0, 0.0)
	fill.light_energy = 1.1
	add_child(fill)

	var env: = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.28, 0.42, 0.62)
	var world: = WorldEnvironment.new()
	world.environment = env
	add_child(world)

	var cam: = Camera3D.new()
	cam.position = Vector3(0.0, 0.0, 0.9)
	cam.fov = 38.0
	add_child(cam)

	var mesh: = load("res://assets/models/deagle/pistol.obj") as Mesh
	print("MESH=", mesh)
	var inst: = MeshInstance3D.new()
	if mesh != null:
		inst.mesh = mesh
		var mat: = StandardMaterial3D.new()
		mat.albedo_color = Color(0.62, 0.66, 0.72)
		mat.metallic = 0.85
		mat.roughness = 0.3
		inst.material_override = mat
		var bounds: = mesh.get_aabb()
		var maxdim: = maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
		var s: = 0.36 / maxdim
		inst.scale = Vector3.ONE * s
		inst.position = -bounds.get_center() * s
	add_child(inst)

	# ~0.18s на прогрев кадра с обычным движком, потом 4 вью на обороте
	var drag: = 0
	await get_tree().process_frame
	await get_tree().process_frame
	for i in 4:
		inst.rotation = Vector3(0.0, deg_to_rad(90.0 * i), 0.0)
		for j in 4:
			await get_tree().process_frame
		var img: = get_viewport().get_texture().get_image()
		img.save_png("res://tools/view_%d.png" % i)
		drag += 1
	print("SAVES=", drag)
	get_tree().quit()
