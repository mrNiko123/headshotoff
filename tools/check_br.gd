extends Node

# Рендер сцены БАТЛ РОЯЛЯ на скриншот + лог состояния.

func _ready() -> void :
	Settings.apply_display()
	var br: Node = load("res://br.tscn").instantiate()
	add_child(br)
	await get_tree().create_timer(2.5).timeout
	await _shot("br_spawn")
	get_tree().quit()


func _shot(shot_name: String) -> void :
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	image.save_png("res://tools/view_%s.png" % shot_name)
	print("SHOT_SAVED ", shot_name)
