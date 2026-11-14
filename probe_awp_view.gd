extends Node3D



const OUT: = "res://.tmpshots"


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var cam: = Camera3D.new()
	cam.fov = 35.0
	add_child(cam)
	cam.position = Vector3(0.0, 0.0, 3.0)

	var light: = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35.0, -35.0, 0.0)
	light.light_energy = 1.2
	add_child(light)
	var fill: = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-10.0, 145.0, 0.0)
	fill.light_energy = 0.5
	add_child(fill)

	var world_env: = WorldEnvironment.new()
	var env: = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.1, 0.11, 0.13, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.55, 0.62, 1.0)
	env.ambient_light_energy = 0.7
	world_env.environment = env
	add_child(world_env)

	var scene: Node3D = load("res://models/AWP.fbx").instantiate()
	add_child(scene)
	var mi: MeshInstance3D = scene.find_children("*", "MeshInstance3D", true, false)[0]
	var mesh: = mi.mesh
	var arrays: = mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	print("verts=", verts.size(), " uvs=", uvs.size())
	var umin: = Vector2(9.0, 9.0)
	var umax: = Vector2(-9.0, -9.0)
	for uv in uvs:
		umin.x = minf(umin.x, uv.x)
		umin.y = minf(umin.y, uv.y)
		umax.x = maxf(umax.x, uv.x)
		umax.y = maxf(umax.y, uv.y)
	print("uv range ", umin, " .. ", umax)
	print("format flags=", mesh.surface_get_format(0))

	var tex: Texture2D = load("res://models/textures/RC4qv11Y.png")
	var mat: = StandardMaterial3D.new()
	mat.albedo_texture = tex
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.roughness = 0.45
	mat.metallic = 0.25
	mi.material_override = mat

	var aabb: = mesh.get_aabb()
	mi.position = - aabb.get_center()
	await get_tree().process_frame

	await _shot("side", Vector3(0.0, 0.0, 13.5), Vector3(0.0, 0.0, 0.0))
	await _shot("top", Vector3(0.0, 13.5, 0.0), Vector3(0.0, 0.0, - PI / 2.0))
	await _shot("iso", Vector3(6.0, 7.0, 9.0), Vector3.ZERO)
	await _shot("iso2", Vector3(-6.0, 7.0, 9.0), Vector3.ZERO)
	print("PROBE OK")
	get_tree().quit()


func _shot(tag: String, pos: Vector3, rot: Vector3) -> void :
	var cam: Camera3D = get_child(0)
	cam.position = pos
	cam.rotation = rot
	if tag == "top":
		cam.rotation = Vector3( - PI / 2.0, 0.0, 0.0)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("%s/fbx_%s.png" % [OUT, tag]))
	print("shot ", tag)
