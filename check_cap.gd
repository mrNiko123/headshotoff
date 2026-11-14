extends Node



const OUT: = "res://.tmpshots"


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	Settings.apply_display()

	var game: Node = load("res://game.tscn").instantiate()
	add_child(game)
	await get_tree().process_frame
	var player: Node = game.get_node("Player")
	var cam: Camera3D = game.get_node("Player/Head/Camera3D")
	await get_tree().create_timer(1.0).timeout



	Input.action_press("aim")
	await get_tree().create_timer(0.9).timeout
	await _shot("scope")
	print("scope fov ", cam.fov, " visible vm ", player.viewmodel.visible)
	Input.action_release("aim")
	await get_tree().create_timer(0.4).timeout

	var hud: Node = game.get_node("HUD")
	if hud.has_method("show_pause"):
		hud.show_pause()
		await get_tree().create_timer(0.4).timeout
		await _shot("pause")
		hud.hide_pause()
	game.queue_free()
	await get_tree().process_frame

	var menu: Node = load("res://main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().create_timer(1.6).timeout
	await _shot("menu")
	print("MENU OK")
	get_tree().quit()


func _shot(tag: String) -> void :
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("%s/check_%s.png" % [OUT, tag]))
	print("shot ", tag, " ", img.get_size())
