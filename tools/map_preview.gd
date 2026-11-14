extends Node3D

# Рендер превью карт тренировки (yard/mesa) в assets/maps/*.png.
# Запуск с окном: Godot_console.exe --path ... res://tools/map_preview.tscn

const SHOTS: = [
	{"layout": "yard", "path": "res://assets/maps/yard.png"}, 
	{"layout": "mesa", "path": "res://assets/maps/mesa.png"}, 
	{"layout": "lego", "path": "res://assets/maps/lego.png"}, 
]


func _ready() -> void :
	await get_tree().process_frame
	for spec in SHOTS:
		var scene: PackedScene = load("res://scenes/arena_%s.tscn" % str(spec["layout"])) as PackedScene
		if scene == null:
			continue
		var arena: Node3D = scene.instantiate() as Node3D
		add_child(arena)
		for i in 8:
			await get_tree().process_frame
		var img: = get_viewport().get_texture().get_image()
		img.save_png(str(spec["path"]))
		arena.queue_free()
		await get_tree().process_frame
	print("SAVES=", SHOTS.size())
	get_tree().quit()
