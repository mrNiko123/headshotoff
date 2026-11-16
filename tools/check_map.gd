extends Node

# Рендер игровой сцены на заданной карте (arg -- map=mesa).

const OUT: = "res://tools"


func _ready() -> void :
	var args: = OS.get_cmdline_user_args()
	for arg in args:
		if arg.begins_with("map="):
			Settings.map_id = arg.substr(4)
	Settings.apply_display()
	var game: Node = load("res://game.tscn").instantiate()
	add_child(game)
	await get_tree().create_timer(1.2).timeout
	await _shot("awp")
	get_tree().quit()


func _shot(name: String) -> void :
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	image.save_png("%s/view_map_%s.png" % [OUT, name])
	print("MAP_SHOT_SAVED ", name)
