extends Node

# Рендер страниц меню: игра (карточка BR) и выбор подрежима БАТЛ РОЯЛЯ.


func _ready() -> void :
	Settings.apply_display()
	var menu: Node = load("res://main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().create_timer(1.5).timeout
	menu._open_page("play")
	await get_tree().create_timer(0.6).timeout
	await _shot("menu_play_br")
	menu._open_page("br")
	await get_tree().create_timer(0.6).timeout
	await _shot("menu_br_choice")
	get_tree().quit()


func _shot(shot_name: String) -> void :
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	image.save_png("res://tools/view_%s.png" % shot_name)
	print("SHOT_SAVED ", shot_name)
