extends RefCounted




const UITheme = preload("res://scripts/ui_theme.gd")


static func open(host: Control, theme_ref: Theme, current: Color, setter: Callable, 
		target: PanelContainer) -> PopupPanel:
	var popup: = PopupPanel.new()
	popup.process_mode = Node.PROCESS_MODE_ALWAYS
	if theme_ref != null:
		popup.theme = theme_ref
	popup.add_theme_stylebox_override("panel", 
		flat_box(Color(0.043, 0.052, 0.064, 1.0), UITheme.BORDER, 1, 4))

	var margin: = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	popup.add_child(margin)

	var picker: = ColorPicker.new()
	picker.picker_shape = ColorPicker.SHAPE_HSV_WHEEL
	picker.color_mode = ColorPicker.MODE_HSV
	picker.edit_alpha = false
	picker.edit_intensity = false
	picker.presets_visible = false
	picker.color_modes_visible = false
	picker.sampler_visible = false
	picker.custom_minimum_size = Vector2(286, 0)
	margin.add_child(picker)

	picker.color_changed.connect( func(color: Color) -> void :
		var shown: = Color(color.r, color.g, color.b, 1.0)
		if setter.is_valid():
			setter.call(shown)
		if target != null and is_instance_valid(target):
			target.add_theme_stylebox_override("panel", 
				flat_box(shown, UITheme.TEXT, 1, 3)))

	picker.set_block_signals(true)
	picker.color = current
	picker.set_block_signals(false)

	popup.popup_hide.connect(popup.queue_free)
	host.add_child(popup)
	popup.popup_centered()
	return popup


static func flat_box(bg: Color, border: Color, border_width: int, 
		radius: int) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	return box
