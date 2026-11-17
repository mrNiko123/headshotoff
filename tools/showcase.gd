extends Node3D

# Витрина: рендерит всё оружие и ножи игры с трёх ракурсов
# и сохраняет PNG в папку на рабочем столе.

const Builder: = preload("res://scripts/weapon_builder.gd")

const OUT_DIR: = "C:/Users/user/Desktop/HEADSHOT ОРУЖИЕ"

const PAIRS: = [
	["awp", "default"], ["awp", "asiimov"], 
	["ak47", "classic"], ["ak47", "vulcan"], 
	["m4a1", "steel"], ["m4a1", "printstream"], 
	["deagle", "chrome"], ["deagle", "blaze"], 
	["knife", "forest"], ["knife", "lava"], 
	["knife", "bayonet"], ["knife", "karambit"], 
	["knife", "skeleton"], ["knife", "dagger"], 
	["knife", "combat"], ["knife", "nomad"], 
]

# Ракурсы: yaw/pitch вокруг модели в градусах.
const VIEWS: = [
	Vector2(35.0, 14.0), 
	Vector2(125.0, 8.0), 
	Vector2(215.0, 26.0), 
]

var _cam: Camera3D


func _ready() -> void :
	var env: = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.16, 0.19, 0.24)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.85, 0.9, 1.0)
	env.ambient_light_energy = 0.9
	var world: = WorldEnvironment.new()
	world.environment = env
	add_child(world)

	var sun: = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42.0, -35.0, 0.0)
	sun.light_energy = 3.0
	add_child(sun)
	var fill: = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-14.0, 150.0, 0.0)
	fill.light_energy = 1.4
	add_child(fill)
	var rim: = DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(18.0, 60.0, 0.0)
	rim.light_energy = 1.1
	add_child(rim)

	_cam = Camera3D.new()
	_cam.fov = 45.0
	_cam.current = true
	add_child(_cam)

	DirAccess.make_dir_recursive_absolute(OUT_DIR)

	var saved: = 0
	for pair in PAIRS:
		saved += await _render_pair(str(pair[0]), str(pair[1]))
	print("SHOWCASE_SAVES=", saved)
	get_tree().quit()


func _render_pair(weapon_id: String, skin_id: String) -> int:
	var holder: = Node3D.new()
	add_child(holder)
	Builder.build(holder, weapon_id, skin_id, false)
	var box: = Builder.model_aabb(holder)
	var center: = box.get_center()
	var longest: = maxf(maxf(box.size.x, box.size.y), box.size.z)
	var dist: = maxf(longest * 1.05, 0.55)

	var count: = 0
	for i in VIEWS.size():
		var yaw: = deg_to_rad(float(VIEWS[i].x))
		var pitch: = deg_to_rad(float(VIEWS[i].y))
		var dir: = Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))
		_cam.position = center + dir * dist
		_cam.look_at(center, Vector3.UP)
		for f in 6:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var img: = get_viewport().get_texture().get_image()
		var path: = "%s/%s_%s_%d.png" % [OUT_DIR, weapon_id.to_upper(), 
			skin_id.to_upper(), i]
		img.save_png(path)
		count += 1
	holder.queue_free()
	await get_tree().process_frame
	return count
