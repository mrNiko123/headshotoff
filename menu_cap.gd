extends Node



const OUT: = "res://.tmpshots"


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	Settings.apply_display()
	var menu: Node = load("res://main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().create_timer(1.4).timeout
	await _shot("menu_home")
	menu._open_page("inventory")
	await get_tree().create_timer(0.4).timeout
	await _shot("menu_inv")
	menu._open_page("settings")
	await get_tree().create_timer(0.4).timeout
	for tab in ["game", "crosshair", "colors", "hands", "screen", "binds", "profile"]:
		menu._settings_tab = tab
		menu._render_page()
		await get_tree().create_timer(0.25).timeout
		await _shot("menu_set_" + tab)
	print("MENU CAP OK")
	get_tree().quit()


func _shot(tag: String) -> void :
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("%s/%s.png" % [OUT, tag]))
	print("shot ", tag, " ", img.get_size())
