extends Node

# Тул: проверка мобильного управления. Запуск:
# godot --path . --resolution 900x600 res://tools/mobile_preview.tscn -- --mobile-preview

func _ready() -> void :
	await get_tree().process_frame
	var game_scene: PackedScene = load("res://game.tscn") as PackedScene
	if game_scene == null:
		print("MP_ERR no game scene")
		get_tree().quit()
		return
	add_child(game_scene.instantiate())
	print("IS_MOBILE=", Settings.is_mobile())
	# Ждём, пока матч прогрузится и игрок станет active.
	for i in 240:
		await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png("res://tools/view_mobile_preview.png")
	print("MP_SAVED=1")
	get_tree().quit()
