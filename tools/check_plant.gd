extends Node

# Проверка плантации бомбы: телепорт на сайт A, удержание E, контроль таймера.

func _ready() -> void :
	Settings.apply_display()
	var scene: Node = load("res://bomb.tscn").instantiate()
	add_child(scene)
	await get_tree().create_timer(5.0).timeout
	var map: Node = scene.get_node("Map")
	var player: Node3D = scene.get_node("Player")
	var site: Vector3 = map.call("get_site_center", 0)
	player.global_position = site + Vector3(0.0, 0.3, 0.0)
	await get_tree().create_timer(0.3).timeout
	Input.action_press("plant_bomb")
	await get_tree().create_timer(3.6).timeout
	Input.action_release("plant_bomb")
	print("PLANT_PHASE ", scene.get("phase"))
	print("PLANT_TIMER ", scene.get("_bomb_time"))
	print("PLANT_DEAD ", not scene.get("_player_alive"))
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://tools/view_bomb_plant.png")
	print("PLANT_SHOT_SAVED")
	get_tree().quit()
