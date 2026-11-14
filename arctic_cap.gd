extends Node



const OUT: = "res://.tmpshots"


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	Settings.apply_display()
	Settings.weapon_skin = "arctic"
	var game: Node = load("res://game.tscn").instantiate()
	add_child(game)
	await get_tree().create_timer(2.0).timeout
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + "/arctic_game.png"))
	print("ARCTIC OK")
	get_tree().quit()
