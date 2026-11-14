extends Control






const UITheme = preload("res://scripts/ui_theme.gd")
const ButtonIcon = preload("res://scripts/mobile_button_icon.gd")

const BASE_STICK: = 168.0
const BASE_BUTTON: = 96.0
const ITEM_ORDER: = ["stick", "fire", "jump", "aim", "reload", "melee", 
	"crouch", "inspect", "left_hand", "scoreboard", "spawn"]
const ITEM_LABELS: = {
	"stick": "ДЖОЙСТИК", 
	"fire": "ОГОНЬ", 
	"jump": "ПРЫЖОК", 
	"aim": "ПРИЦЕЛ", 
	"reload": "ПЕРЕЗАР.", 
	"melee": "ОРУЖИЕ", 
	"crouch": "ПРИСЕСТЬ", 
	"inspect": "ОСМОТР", 
	"left_hand": "ЛЕВАЯ", 
	"scoreboard": "ТАБЛО", 
	"spawn": "МАНЕКЕН", 
}


const TAP_SLOP: = 12.0

var _layer: CanvasLayer
var _stage: Control
var _bar: PanelContainer
var _inspector: PanelContainer
var _inspector_title: Label
var _status: Label
var _nodes: Dictionary = {}
var _selection_ring: Panel
var _layout: Dictionary = {}


var _slots: Array = []
var _slot: = 0
var _slot_buttons: Array = []
var _selected: = ""
var _size_slider: HSlider
var _size_value: Label
var _alpha_slider: HSlider
var _alpha_value: Label
var _drag_key: = ""
var _drag_offset: = Vector2.ZERO
var _press_position: = Vector2.ZERO
var _dragging: = false
var _press_handled: = false
var _on_saved: = Callable()


func open(host: Node, on_saved: = Callable()) -> void :
	if host == null or not host.is_inside_tree():
		return

	var tree: = host.get_tree()
	if tree == null:
		return
	var existing: = tree.root.get_node_or_null("MobileLayoutEditor")
	if existing != null and not existing.is_queued_for_deletion():
		return
	_on_saved = on_saved
	_layer = CanvasLayer.new()
	_layer.name = "MobileLayoutEditor"
	_layer.layer = 120
	_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_layer.add_child(self)
	tree.root.add_child(_layer)


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = UITheme.make_theme(Settings.hud_accent)
	_slots = Settings.get_mobile_slots_copy()
	_slot = clampi(Settings.mobile_slot, 0, _slots.size() - 1)
	_load_slot(_slot)
	Settings.mobile_editor_open = true
	_build()
	_place_all()
	resized.connect(_on_resized)


func _load_slot(index: int) -> void :
	_slot = clampi(index, 0, maxi(_slots.size() - 1, 0))
	if _slots.is_empty():
		return
	var entry: Dictionary = _slots[_slot]
	_layout = (entry.get("layout", Settings.MOBILE_LAYOUT_DEFAULT) as Dictionary)\
	.duplicate(true)
	if not _layout.has(_selected):
		_selected = ""
	_update_slot_buttons()
	_update_inspector()


func _store_slot() -> void :
	if _slots.is_empty():
		return
	_slots[_slot] = {
		"layout": _layout.duplicate(true), 
		"stick": 1.0, 
		"button": 1.0, 
	}


func _switch_slot(index: int) -> void :
	if index == _slot:
		return
	_store_slot()
	_load_slot(index)
	_selected = ""
	_status.text = "Раскладка %d выбрана." % (_slot + 1)
	_update_inspector()
	_place_all()


func _update_slot_buttons() -> void :
	for i in _slot_buttons.size():
		var button: Button = _slot_buttons[i]
		button.theme_type_variation = &"AccentButton"\
		if i == _slot else &"SmallButton"


func _on_resized() -> void :
	_place_all()
	_update_inspector_geometry()


func _close() -> void :
	Settings.mobile_editor_open = false
	if _layer != null and is_instance_valid(_layer):
		_layer.queue_free()
	else:
		queue_free()




func _exit_tree() -> void :
	if is_instance_valid(Settings):
		Settings.mobile_editor_open = false




func _build() -> void :
	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.026, 0.032, 0.94)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	_stage = Control.new()
	_stage.name = "Stage"
	_stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)

	var frame: = Panel.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _box(
		Color(0.0, 0.0, 0.0, 0.0), Color(0.3, 0.34, 0.38, 0.55), 1, 0))
	_stage.add_child(frame)

	for key in ITEM_ORDER:
		_make_widget(key)



	_selection_ring = Panel.new()
	_selection_ring.name = "SelectionRing"
	_selection_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_selection_ring.visible = false
	_stage.add_child(_selection_ring)

	_build_toolbar()
	_build_inspector()


func _make_widget(key: String) -> void :
	var panel: = Panel.new()
	panel.name = "Widget_" + key
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(panel)

	var label: = _label(str(ITEM_LABELS.get(key, key)), 11, UITheme.TEXT)
	label.name = "Label"
	label.anchor_top = 0.6
	label.anchor_right = 1.0
	label.anchor_bottom = 0.97
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.85))
	label.add_theme_constant_override("outline_size", 3)
	panel.add_child(label)


	var icon: = ButtonIcon.new()
	icon.name = "Icon"
	icon.anchor_left = 0.17
	icon.anchor_top = 0.06
	icon.anchor_right = 0.83
	icon.anchor_bottom = 0.64
	panel.add_child(icon)

	_nodes[key] = panel


func _build_toolbar() -> void :
	_bar = PanelContainer.new()
	_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_bar.offset_left = 20.0
	_bar.offset_right = -20.0
	_bar.offset_top = 16.0
	_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	_bar.add_theme_stylebox_override("panel", _box(UITheme.PANEL, UITheme.BORDER, 1, 6))
	add_child(_bar)

	var margin: = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	_bar.add_child(margin)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	margin.add_child(column)

	var title_row: = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	column.add_child(title_row)
	var title: = _label("КАСТОМИЗАЦИЯ UI", 22, UITheme.TEXT)
	title.theme_type_variation = &"DisplayLabel"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	title_row.add_child(_action_button("ОТМЕНА", false, _close, 112))
	title_row.add_child(_action_button("СОХРАНИТЬ", true, _save, 150))

	_status = _label(
		"Тапните по кнопке — откроются её размер и прозрачность. "
		+ "Перетаскивание двигает виджет.", 10, UITheme.MUTED)
	column.add_child(_status)

	var slot_row: = HBoxContainer.new()
	slot_row.add_theme_constant_override("separation", 8)
	var slot_caption: = _label("РАСКЛАДКА", 11, UITheme.TEXT)
	slot_caption.custom_minimum_size = Vector2(104, 0)
	slot_row.add_child(slot_caption)
	for i in Settings.MOBILE_SLOT_COUNT:
		var slot_button: = Button.new()
		slot_button.text = str(i + 1)
		slot_button.custom_minimum_size = Vector2(0, 32)
		slot_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_button.theme_type_variation = &"AccentButton"\
		if i == _slot else &"SmallButton"
		slot_button.tooltip_text = "Раскладка %d" % (i + 1)
		slot_button.pressed.connect(_switch_slot.bind(i))
		slot_row.add_child(slot_button)
		_slot_buttons.append(slot_button)

	var preset: = OptionButton.new()
	preset.custom_minimum_size = Vector2(152, 32)


	preset.add_item("ПРЕСЕТ")
	preset.set_item_disabled(0, true)
	for entry in Settings.MOBILE_PRESETS:
		preset.add_item(str(entry))
	preset.select(0)
	preset.tooltip_text = "Заменить текущую раскладку готовым пресетом."
	preset.item_selected.connect( func(index: int) -> void :
		if index <= 0:
			return
		_apply_preset(index - 1)
		preset.select(0))
	slot_row.add_child(preset)

	slot_row.add_child(_action_button("СБРОС", false, _reset, 96))
	column.add_child(slot_row)


func _build_inspector() -> void :
	_inspector = PanelContainer.new()
	_inspector.name = "WidgetInspector"
	_inspector.visible = false
	_inspector.mouse_filter = Control.MOUSE_FILTER_STOP
	_inspector.add_theme_stylebox_override("panel", 
		_box(Color(0.07, 0.083, 0.099, 0.98), UITheme.ACCENT, 1, 6))
	add_child(_inspector)

	var margin: = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	_inspector.add_child(margin)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	margin.add_child(column)

	var header: = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	column.add_child(header)
	_inspector_title = _label("", 12, UITheme.ACCENT_BRIGHT)
	_inspector_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_inspector_title)
	header.add_child(_action_button("РАЗМЕР ПО УМОЛЧАНИЮ", false, 
		_reset_selected, 210))
	header.add_child(_action_button("ГОТОВО", false, _deselect, 100))

	var size_row: = _slider_row("РАЗМЕР", Settings.MOBILE_SIZE_MIN, 
		Settings.MOBILE_SIZE_MAX, 0.05, _on_size_changed)
	column.add_child(size_row["row"])
	_size_slider = size_row["slider"]
	_size_value = size_row["value"]

	var alpha_row: = _slider_row("ПРОЗРАЧНОСТЬ", Settings.MOBILE_ALPHA_MIN, 
		Settings.MOBILE_ALPHA_MAX, 0.05, _on_alpha_changed)
	column.add_child(alpha_row["row"])
	_alpha_slider = alpha_row["slider"]
	_alpha_value = alpha_row["value"]

	_update_inspector_geometry()
	if _bar != null and not _bar.resized.is_connected(_update_inspector_geometry):
		_bar.resized.connect(_update_inspector_geometry)
	call_deferred("_update_inspector_geometry")


func _slider_row(caption: String, min_value: float, max_value: float, 
		step: float, on_change: Callable) -> Dictionary:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var name_label: = _label(caption, 11, UITheme.TEXT)
	name_label.custom_minimum_size = Vector2(128, 0)
	row.add_child(name_label)

	var slider: = HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = max_value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(slider)

	var shown: = _label("", 11, UITheme.ACCENT_BRIGHT)
	shown.custom_minimum_size = Vector2(58, 0)
	shown.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(shown)

	slider.value_changed.connect( func(value: float) -> void : on_change.call(value))
	return {"row": row, "slider": slider, "value": shown}


func _action_button(text: String, accent: bool, on_press: Callable, 
		width: = 160) -> Button:
	var button: = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(width, 34)
	button.theme_type_variation = &"AccentButton" if accent else &"SmallButton"
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.pressed.connect(Sfx.play_click)
	button.pressed.connect(on_press)
	return button


func _update_inspector_geometry() -> void :
	if _inspector == null:
		return


	var top: = 132.0
	if _bar != null and _bar.size.y > 1.0:
		top = _bar.position.y + _bar.size.y + 8.0
	_inspector.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_inspector.offset_left = 20.0
	_inspector.offset_right = -20.0
	_inspector.offset_top = top
	_inspector.offset_bottom = top + 124.0




func _update_inspector() -> void :
	if _inspector == null:
		return
	if _selected.is_empty() or not _layout.has(_selected):
		_inspector.visible = false
		return
	var entry: Dictionary = _layout[_selected]
	var size_value: = float(entry.get("size", 1.0))
	var alpha_value: = float(entry.get("alpha", 1.0))
	_inspector_title.text = "НАСТРОЙКА: %s" % str(
		ITEM_LABELS.get(_selected, _selected))
	_size_slider.set_value_no_signal(size_value)
	_size_value.text = "×%.2f" % size_value
	_alpha_slider.set_value_no_signal(alpha_value)
	_alpha_value.text = "%d%%" % int(round(alpha_value * 100.0))
	_inspector.visible = true


func _select_widget(key: String) -> void :
	if key == _selected:
		_update_inspector()
		return
	_selected = key
	_update_inspector()
	_place_all()
	_report_selected()


func _deselect() -> void :
	if _selected.is_empty():
		return
	_selected = ""
	_inspector.visible = false
	_place_all()
	_status.text = "Тапните по кнопке — откроются её размер и прозрачность. "\
	+ "Перетаскивание двигает виджет."


func _report_selected() -> void :
	if _selected.is_empty():
		return
	var entry: Dictionary = _layout.get(_selected, {})
	_status.text = "%s · X %d%% · Y %d%% · размер ×%.2f · прозрачность %d%%" % [
		str(ITEM_LABELS.get(_selected, _selected)), 
		int(round(float(entry.get("x", 0.5)) * 100.0)), 
		int(round(float(entry.get("y", 0.5)) * 100.0)), 
		float(entry.get("size", 1.0)), 
		int(round(float(entry.get("alpha", 1.0)) * 100.0)), 
	]


func _on_size_changed(value: float) -> void :
	if _selected.is_empty() or not _layout.has(_selected):
		return
	_layout[_selected]["size"] = clampf(value, Settings.MOBILE_SIZE_MIN, 
		Settings.MOBILE_SIZE_MAX)
	_size_value.text = "×%.2f" % value
	_place(_selected)
	_report_selected()


func _on_alpha_changed(value: float) -> void :
	if _selected.is_empty() or not _layout.has(_selected):
		return
	_layout[_selected]["alpha"] = clampf(value, Settings.MOBILE_ALPHA_MIN, 
		Settings.MOBILE_ALPHA_MAX)
	_alpha_value.text = "%d%%" % int(round(value * 100.0))
	_place(_selected)
	_report_selected()


func _reset_selected() -> void :
	if _selected.is_empty() or not _layout.has(_selected):
		return
	var fallback: Dictionary = Settings.MOBILE_LAYOUT_DEFAULT.get(_selected, {})
	_layout[_selected]["size"] = float(fallback.get("size", 1.0))
	_layout[_selected]["alpha"] = 1.0
	_update_inspector()
	_place(_selected)
	_status.text = "%s: размер и прозрачность сброшены." % str(
		ITEM_LABELS.get(_selected, _selected))




func _widget_size(key: String) -> float:
	var entry: Dictionary = _layout.get(key, {})
	var base: = BASE_STICK if key == "stick" else BASE_BUTTON
	var scale: = minf(size.x, size.y) / 720.0
	return base * float(entry.get("size", 1.0)) * scale


func _place(key: String) -> void :
	var node: Panel = _nodes.get(key)
	if node == null:
		return
	var entry: Dictionary = _layout.get(key, {})
	var widget_size: = _widget_size(key)
	var center: = Vector2(float(entry.get("x", 0.5)) * size.x, 
		float(entry.get("y", 0.5)) * size.y)
	node.size = Vector2(widget_size, widget_size)
	node.position = center - node.size * 0.5
	node.modulate = Color(1.0, 1.0, 1.0, clampf(float(entry.get("alpha", 1.0)), 
		Settings.MOBILE_ALPHA_MIN, Settings.MOBILE_ALPHA_MAX))

	var radius: = int(maxf(widget_size * 0.5, 1.0))
	var accent: = Settings.hud_accent
	var selected: = key == _selected
	var border: = UITheme.ACCENT_BRIGHT if selected else\
	(accent if key == "fire" else Color(0.8, 0.84, 0.9, 0.55))
	var width: = 3 if selected else 2
	if key == "fire":
		node.add_theme_stylebox_override("panel", 
			_circle(Color(accent.r, accent.g, accent.b, 0.42), border, width, radius))
	else:
		var bg: = Color(0.06, 0.07, 0.09, 0.55)
		if selected:
			bg = Color(accent.r, accent.g, accent.b, 0.28)
		node.add_theme_stylebox_override("panel", 
			_circle(bg, border, width, radius))

	var icon: = node.get_node_or_null("Icon") as Control
	if icon != null:
		icon.setup(key, Color(0.1, 0.06, 0.02, 0.92) if key == "fire"
			else UITheme.TEXT)
	var label: = node.get_node_or_null("Label") as Label
	if label != null:
		label.add_theme_font_size_override("font_size", 
			int(clampf(widget_size * 0.105, 7.5, 11.0)))
	if key == _selected:
		_place_ring()


func _place_ring() -> void :
	if _selection_ring == null:
		return
	if _selected.is_empty() or not _nodes.has(_selected):
		_selection_ring.visible = false
		return
	var node: Panel = _nodes[_selected]
	var rect: = Rect2(node.position, node.size).grow(5.0)
	_selection_ring.position = rect.position
	_selection_ring.size = rect.size
	_selection_ring.add_theme_stylebox_override("panel", 
		_box(Color(0.0, 0.0, 0.0, 0.0), UITheme.ACCENT_BRIGHT, 3, 
			int(maxf(rect.size.x * 0.5, 1.0))))
	_selection_ring.visible = true


func _place_all() -> void :
	if _stage == null:
		return
	if _selection_ring != null:
		_selection_ring.visible = false
	for key in ITEM_ORDER:
		_place(key)


func _widget_center(key: String) -> Vector2:
	var entry: Dictionary = _layout.get(key, {})
	return Vector2(float(entry.get("x", 0.5)) * size.x, 
		float(entry.get("y", 0.5)) * size.y)




func _input(event: InputEvent) -> void :
	if event.is_action_pressed("ui_cancel"):
		if not _selected.is_empty():
			_deselect()
		else:
			_close()
		get_viewport().set_input_as_handled()
		return

	if Settings.is_touch_device():
		if event is InputEventScreenTouch:
			var touch: = event as InputEventScreenTouch
			if touch.pressed:
				_press_handled = _handle_press(touch.position)
			else:
				if _press_handled:
					_handle_release()
					get_viewport().set_input_as_handled()
					_press_handled = false
		elif event is InputEventScreenDrag and not _drag_key.is_empty():
			_handle_drag((event as InputEventScreenDrag).position)
			get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		var mouse: = event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_press_handled = _handle_press(mouse.position)
			if _press_handled:
				get_viewport().set_input_as_handled()
		else:
			if _press_handled:
				_handle_release()
				get_viewport().set_input_as_handled()
				_press_handled = false
	elif event is InputEventMouseMotion and not _drag_key.is_empty():
		_handle_drag((event as InputEventMouseMotion).position)
		get_viewport().set_input_as_handled()


func _handle_press(pos: Vector2) -> bool:
	if _ui_blocks(pos):
		return false
	var key: = _hit_widget(pos)
	_press_position = pos
	_dragging = false
	if key.is_empty():
		_deselect()
		return true
	_drag_key = key
	_drag_offset = _widget_center(key) - pos
	_select_widget(key)
	return true


func _handle_drag(pos: Vector2) -> void :
	if _drag_key.is_empty():
		return
	if not _dragging and pos.distance_to(_press_position) < TAP_SLOP:
		return
	_dragging = true
	_move_widget(_drag_key, pos + _drag_offset)


func _handle_release() -> void :
	_drag_key = ""
	_dragging = false




func _ui_blocks(pos: Vector2) -> bool:
	if _bar != null and _bar.get_global_rect().has_point(pos):
		return true
	if _inspector != null and _inspector.visible\
	and _inspector.get_global_rect().has_point(pos):
		return true
	return false


func _hit_widget(pos: Vector2) -> String:
	for key in ITEM_ORDER:
		var node: Panel = _nodes.get(key)
		if node == null:
			continue
		if node.get_global_rect().grow(4.0).has_point(pos):
			return key
	return ""


func _move_widget(key: String, center: Vector2) -> void :
	if not _layout.has(key):
		return
	var entry: Dictionary = _layout[key]
	entry["x"] = clampf(center.x / maxf(size.x, 1.0), 0.02, 0.98)
	entry["y"] = clampf(center.y / maxf(size.y, 1.0), 0.05, 0.95)
	_place(key)
	_report_selected()




func _apply_preset(index: int) -> void :
	_layout = Settings.make_mobile_preset(index)
	_selected = ""
	_update_inspector()
	_place_all()
	_status.text = "Пресет «%s» применён к раскладке %d." % [
		str(Settings.MOBILE_PRESETS[clampi(index, 0, 
			Settings.MOBILE_PRESETS.size() - 1)]), _slot + 1]


func _reset() -> void :
	_layout = Settings.MOBILE_LAYOUT_DEFAULT.duplicate(true)
	_selected = ""
	_update_inspector()
	_place_all()
	_status.text = "Раскладка %d сброшена — нажмите «СОХРАНИТЬ»." % (_slot + 1)


func _save() -> void :
	_store_slot()
	Settings.set_mobile_slots(_slots, _slot)
	if _on_saved.is_valid():
		_on_saved.call()
	_close()




func _label(text: String, font_size: int, color: Color) -> Label:
	var label: = Label.new()
	label.text = text
	label.add_theme_font_override("font", UITheme.ui_font(500))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _circle(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var box: = _box(bg, border, width, radius)
	box.set_corner_radius_all(radius)
	return box


func _box(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	return box
