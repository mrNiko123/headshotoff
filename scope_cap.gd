extends Node



const OUT: = "res://.tmpshots"


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	Settings.apply_display()
	var game: Node = load("res://game.tscn").instantiate()
	add_child(game)
	await get_tree().create_timer(1.0).timeout
	var player: Node = game.get_node("Player")
	var cam: Camera3D = game.get_node("Player/Head/Camera3D")
	var vm: Node3D = player.viewmodel

	Input.action_press("aim")
	await get_tree().create_timer(0.9).timeout
	await RenderingServer.frame_post_draw
	print("scoped=", player._scoped, " fov=", cam.fov, " vm=", vm.visible)
	var img: = get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(OUT + "/check_scope.png"))
	Input.action_release("aim")
	await get_tree().create_timer(0.4).timeout
	print("after release scoped=", player._scoped, " fov=", cam.fov, 
		" vm=", vm.visible)
	print("SCOPE OK")
	get_tree().quit()
