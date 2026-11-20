extends Node

# Рендер вкладки «СКИНЫ» с экипированным скином «Ангел».

func _ready() -> void :
	Settings.apply_display()
	if not Settings.owned_player_skins.has("angel"):
		Settings.owned_player_skins.append("angel")
	Settings.player_skin = "angel"
	var menu: Node = load("res://main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	menu.set("_page", "inventory")
	menu.set("_store_tab", "skins")
	menu.call("_render_page")
	await get_tree().create_timer(2.5).timeout
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	image.save_png("res://tools/view_skins.png")
	print("SKINS_SHOT_SAVED")
	get_tree().quit()
