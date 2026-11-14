extends Node

# Рендер консоли для визуальной проверки.

func _ready() -> void :
	await get_tree().process_frame
	var console: = get_node("/root/Console")
	console.execute("help")
	console.execute("sensitivity 1.35")
	console.execute("nosuchcommand")
	console.open_console()
	for i in 30:
		await get_tree().process_frame
	var image: = get_viewport().get_texture().get_image()
	image.save_png("res://tools/view_console.png")
	print("CONSOLE_SHOT_SAVED")
	# восстановление
	console.close_console()
	Settings.queue_save_settings(0.1)
	get_tree().quit()
