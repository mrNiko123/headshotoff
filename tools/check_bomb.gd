extends Node

# Проверка режима «Закладка бомбы»: запуск + скриншот от лица игрока.

func _ready() -> void :
	Settings.apply_display()
	var scene: Node = load("res://bomb.tscn").instantiate()
	add_child(scene)
	await get_tree().create_timer(4.0).timeout
	var map: Node = scene.get_node("Map")
	print("BOMB_TSPAWN ", map.call("get_t_spawn"))
	print("BOMB_CT ", map.call("get_ct_spawns"))
	print("BOMB_SITES ", map.call("get_site_center", 0), " ", map.call("get_site_center", 1))
	print("BOMB_NAV ", map.get("bot_nav_points").size(), " LINKS ", 
		map.get("bot_nav_links").size())
	var player: Node3D = scene.get_node("Player")
	print("BOMB_PLAYER ", player.global_position)
	for bot in scene.get_node("Bots").get_children():
		print("BOT ", bot.name, " ", (bot as Node3D).global_position)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://tools/view_bomb.png")
	print("BOMB_SHOT_SAVED")
	get_tree().quit()
