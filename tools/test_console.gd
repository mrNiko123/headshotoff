extends Node

# Автотест консоли: прогоняет команды и проверяет эффект.

func _ready() -> void :
	await get_tree().process_frame
	var console: = get_node("/root/Console")
	var old_sens: = Settings.mouse_sensitivity
	var old_fps: = Settings.show_fps

	console.execute("sensitivity 2")
	console.execute("cl_showfps 1")
	console.execute("sv_cheats 1")
	console.execute("host_timescale 1.5")
	console.execute("host_timescale 999")
	console.execute("sensitivity")
	console.execute("fps_max=60")
	console.execute("fps_max = 30")
	console.execute("fps_max")
	console.execute("map nosuchmap")
	console.execute("find crosshair")
	console.execute("status")
	await get_tree().process_frame
	await get_tree().process_frame

	print("TEST sens=", Settings.mouse_sensitivity)
	print("TEST showfps=", Settings.show_fps)
	print("TEST timescale=", Engine.time_scale)
	print("TEST map=", Settings.map_id)
	print("TEST fpsmax=", Settings.fps_limit)
	print("TEST cheats=", console._cheats)
	# восстановление
	Settings.mouse_sensitivity = old_sens
	Settings.show_fps = old_fps
	Engine.time_scale = 1.0
	console._cheats = false
	Settings.map_id = Settings.MAP_DEFAULT
	Settings.queue_save_settings(0.1)
	get_tree().quit()
