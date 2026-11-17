extends Node

# Рендер главного меню на скриншот.

func _ready() -> void :
	Settings.apply_display()
	var menu: Node = load("res://main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().create_timer(1.5).timeout
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	image.save_png("res://tools/view_menu.png")
	print("MENU_SHOT_SAVED")
	get_tree().quit()
