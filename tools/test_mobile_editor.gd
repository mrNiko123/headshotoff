extends Node

# Тул: проверка редактора мобильной раскладки на ПК.

func _ready() -> void :
	await get_tree().process_frame
	var editor_script: GDScript = load("res://scripts/mobile_layout_editor.gd") as GDScript
	var editor: Node = editor_script.new()
	editor.open(self, Callable())
	for i in 30:
		await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png("res://tools/view_mobile_editor.png")
	print("ED_SAVED=1")
	get_tree().quit()
