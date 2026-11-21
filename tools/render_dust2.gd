extends Node3D

# Рендер карты Dust2 сверху и с уровня игрока (для проверки геометрии).

const MESH_PATH: = "res://assets/maps/dust2/dust2_mesh.res"


func _ready() -> void :
	var env: = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.09, 0.1, 0.12)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.88, 1.0)
	env.ambient_light_energy = 1.1
	var we: = WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun: = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	sun.light_energy = 1.5
	add_child(sun)

	var mesh: Mesh = load(MESH_PATH) as Mesh
	if mesh == null:
		print("NO_MESH")
		get_tree().quit()
		return
	var body: = MeshInstance3D.new()
	body.mesh = mesh
	add_child(body)

	body.mesh.surface_get_material(0)
	var box: AABB = mesh.get_aabb()
	var cam: = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = maxf(box.size.x, box.size.z)
	cam.near = 0.1
	cam.far = 200.0
	cam.position = box.get_center() + Vector3(0.0, 60.0, 0.0)
	cam.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	add_child(cam)
	cam.make_current()
	await _shot("res://tools/view_dust2_top.png")

	cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	cam.fov = 80.0
	cam.position = Vector3(-8.0, 0.4, 12.0)
	cam.rotation_degrees = Vector3(-8.0, 20.0, 0.0)
	await _shot("res://tools/view_dust2_ground.png")
	print("DUST2_SHOTS_OK")
	get_tree().quit()


func _shot(path: String) -> void :
	await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	image.save_png(path)
