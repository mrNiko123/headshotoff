extends Node

# Полный игровой рендер: AWP + нож из сейва пользователя.

const OUT: = "res://tools"


func _ready() -> void :
	Settings.apply_display()
	var game: Node = load("res://game.tscn").instantiate()
	add_child(game)
	await get_tree().create_timer(1.2).timeout
	await _shot("ingame_awp")
	# переключение на нож (слот 3)
	var player: Node = game.get_node_or_null("Player")
	if player != null:
		player.call("_switch_slot", 2)
	await get_tree().create_timer(0.8).timeout
	await _shot("ingame_knife")
	get_tree().quit()


func _shot(name: String) -> void :
	await RenderingServer.frame_post_draw
	var image: = get_viewport().get_texture().get_image()
	image.save_png("%s/view_%s.png" % [OUT, name])
	print("SHOT_SAVED ", name)
