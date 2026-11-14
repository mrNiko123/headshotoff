extends Node3D

# Превью вьюмодели от первого лица: камера в позиции игрока,
# оружие прикреплено к камере — как в игре. Аргументы: weapon skin.

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
	env.background_color = Color(0.25, 0.3, 0.4)
	var world: = WorldEnvironment.new()
	world.environment = env
	add_child(world)

	var cam: = Camera3D.new()
	cam.fov = 90.0
	cam.current = true
	add_child(cam)

	var weapon_id: = "deagle"
	var weapon_skin: = "chrome"
	var args: = OS.get_cmdline_user_args()
	if args.size() >= 2:
		weapon_id = str(args[0])
		weapon_skin = str(args[1])

	# оружие как в игре: узел под камерой в нуле
	var vm: = Node3D.new()
	vm.name = "VM"
	cam.add_child(vm)
	var builder: = load("res://scripts/weapon_builder.gd")
	var gun: Node3D = builder.call("build", vm, weapon_id, weapon_skin, false)
	var bounds: AABB = builder.call("model_aabb", gun)
	print("VM_BOUNDS pos=", bounds.position, " size=", bounds.size)

	for i in 2:
		if i == 1:
			cam.position = Vector3(0.0, -0.25, 0.0)
			cam.rotation_degrees = Vector3(14.0, 0.0, 0.0)
		else:
			cam.position = Vector3.ZERO
			cam.rotation_degrees = Vector3.ZERO
		for f in 6:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: = get_viewport().get_texture().get_image()
		img.save_png("res://tools/view_%s_%s_%d.png" % [weapon_id, weapon_skin, i])
	print("SAVES=2")
	get_tree().quit()
