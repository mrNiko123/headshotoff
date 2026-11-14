extends Control





const UITheme = preload("res://scripts/ui_theme.gd")
const HudScene = preload("res://scenes/hud.tscn")

const WIDGET_ORDER: = ["session", "streamer", "killfeed", "killzone", 
	"weapons", "strafe", "fps", "input_overlay", "hint"]
const WIDGET_LABELS: = {
	"session": "ТАЙМЕР СЕССИИ", 
	"streamer": "ВИДЖЕТ РЕЙТИНГА", 
	"killfeed": "КИЛЛФИД", 
	"killzone": "ЧЕРЕП · ПАТРОНЫ", 
	"weapons": "СЛОТЫ ОРУЖИЯ", 
	"strafe": "СТРЕЙФ", 
	"fps": "FPS", 
	"input_overlay": "КЛАВИШИ", 
	"hint": "ПОДСКАЗКА", 
}

const RESIZE_ZONE: = 20.0

var _layer: CanvasLayer
var _stage: Control
var _panel: PanelContainer
var _status: Label
var _hud: Node
var _preview: Node
var _nodes: Dictionary = {}
var _layout: Dictionary = {}
var _drag_key: = ""
var _drag_mode: = ""
var _drag_offset: = Vector2.ZERO
var _start_scale: = 1.0
var _start_distance: = 1.0
var _on_closed: = Callable()


func open(host: Node, hud: Node = null, on_closed: = Callable()) -> void :
	if host == null or not host.is_inside_tree():
		return
	_hud = hud
	_on_closed = on_closed
	_layer = CanvasLayer.new()
	_layer.name = "HudLayoutEditor"
	_layer.layer = 120
	_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_layer.add_child(self)
	host.get_tree().root.add_child(_layer)


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = UITheme.make_theme(Settings.hud_accent)
	Settings.hud_editor_open = true
	_layout = Settings.hud_layout.duplicate(true)
	if _hud == null:
		_create_preview()
	if _hud != null and _hud.has_method("set_editor_preview"):
		_hud.call("set_editor_preview", true)
	_build()


	await get_tree().process_frame
	await get_tree().process_frame
	_sync_handles()


func _input(event: InputEvent) -> void :
	if event.is_action_pressed("ui_cancel"):
		_cancel()
		get_viewport().set_input_as_handled()




func _create_preview() -> void :
	_preview = HudScene.instantiate()
	_preview.name = "HudLayoutPreview"
	_preview.layer = 118
	get_tree().root.add_child(_preview)
	_hud = _preview
	await get_tree().process_frame
	if not is_instance_valid(_hud):
		return

	_hud.call("set_ammo", {
		"ammo": 5, "magazine": 5, "reloading": false, "melee": false, 
	})
	_hud.call("set_session_time", 75.0)
	_hud.call("set_movement", 12.4, 3, false)
	_hud.call("add_killfeed", {
		"weapon": "awp", "headshot": true, "airborne": false, "noscope": false, 
	}, true)
	var session: Control = _hud.get("_session_label")
	if session != null:
		session.visible = true
	var overlay: Control = _hud.get("_input_overlay")
	if overlay != null:
		overlay.visible = true
	var fps: Control = _hud.get("_fps_counter")
	if fps != null:
		fps.visible = true
	var strafe: Control = _hud.get("_strafe_meter")
	if strafe != null:
		strafe.modulate.a = 1.0
	var hint: Label = _hud.get("hint")
	if hint != null:
		hint.modulate.a = 1.0




func _build() -> void :
	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.026, 0.032, 0.55)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	_stage = Control.new()
	_stage.name = "Stage"
	_stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)

	for key in WIDGET_ORDER:
		_make_handle(key)

	_build_panel()


func _make_handle(key: String) -> void :
	var handle: = Panel.new()
	handle.name = "Handle_" + key
	handle.mouse_filter = Control.MOUSE_FILTER_STOP
	handle.gui_input.connect(_on_handle_input.bind(key))
	_stage.add_child(handle)

	var label: = _label(str(WIDGET_LABELS.get(key, key)), 10, UITheme.TEXT)
	label.name = "Label"
	label.position = Vector2(8.0, 4.0)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.9))
	label.add_theme_constant_override("outline_size", 3)
	handle.add_child(label)


	var grip: = ColorRect.new()
	grip.name = "Grip"
	grip.color = Color(UITheme.ACCENT_BRIGHT.r, UITheme.ACCENT_BRIGHT.g, 
		UITheme.ACCENT_BRIGHT.b, 0.92)
	grip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grip.anchor_left = 1.0
	grip.anchor_top = 1.0
	grip.anchor_right = 1.0
	grip.anchor_bottom = 1.0
	grip.offset_left = -16.0
	grip.offset_top = -16.0
	grip.offset_right = -3.0
	grip.offset_bottom = -3.0
	handle.add_child(grip)

	_nodes[key] = handle
	_refresh_handle_style(key, false)


func _build_panel() -> void :
	_panel = PanelContainer.new()
	_panel.name = "EditorPanel"
	_panel.anchor_left = 0.0
	_panel.anchor_top = 0.5
	_panel.anchor_right = 0.0
	_panel.anchor_bottom = 0.5
	_panel.offset_left = 16.0
	_panel.offset_right = 286.0
	_panel.offset_top = -238.0
	_panel.offset_bottom = 238.0
	_panel.add_theme_stylebox_override("panel", 
		_box(UITheme.PANEL, UITheme.BORDER, 1, 6))
	add_child(_panel)

	var margin: = MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	_panel.add_child(margin)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	var title: = _label("РАСПОЛОЖЕНИЕ HUD", 18, UITheme.TEXT)
	title.theme_type_variation = &"DisplayLabel"
	column.add_child(title)
	column.add_child(_label(
		"Перетаскивайте блоки. Потяните за угол, чтобы изменить размер.", 
		10, UITheme.MUTED))
	column.add_child(_label(
		"ESC — отмена, несохранённые изменения не применятся.", 
		10, UITheme.MUTED))

	_status = _label("", 10, UITheme.ACCENT_BRIGHT)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_status)

	var spacer: = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	column.add_child(_action_button("СБРОС", false, _reset))
	column.add_child(_action_button("ОТМЕНА", false, _cancel))
	column.add_child(_action_button("СОХРАНИТЬ", true, _save))




func _sync_handles() -> void :
	if _hud == null or not is_instance_valid(_hud):
		return
	var rects: Dictionary = _hud.call("get_hud_editor_rects")
	var current: Dictionary = _hud.call("get_hud_editor_layout")
	for key in WIDGET_ORDER:
		var handle: Panel = _nodes.get(key)
		if handle == null:
			continue
		var rect: Rect2 = rects.get(key, Rect2())
		handle.position = rect.position
		handle.size = Vector2(maxf(rect.size.x, 26.0), maxf(rect.size.y, 22.0))
		handle.visible = rect.size.x > 1.0 and rect.size.y > 1.0
		var scale: = _entry_scale(key, current)
		var label: = handle.get_node_or_null("Label") as Label
		if label != null:
			label.text = "%s   ×%.2f" % [str(WIDGET_LABELS.get(key, key)), scale]


func _entry_scale(key: String, current: Dictionary) -> float:
	if _layout.has(key) and _layout[key] is Dictionary:
		return float((_layout[key] as Dictionary).get("scale", 1.0))
	if current.has(key) and current[key] is Dictionary:
		return float((current[key] as Dictionary).get("scale", 1.0))
	return 1.0


func _ensure_entry(key: String) -> Dictionary:
	if _layout.has(key) and _layout[key] is Dictionary:
		return _layout[key] as Dictionary
	var current: Dictionary = _hud.call("get_hud_editor_layout")
	if current.has(key) and current[key] is Dictionary:
		_layout[key] = (current[key] as Dictionary).duplicate(true)
	else:
		_layout[key] = {"x": 0.5, "y": 0.5, "scale": 1.0}
	return _layout[key] as Dictionary


func _on_handle_input(event: InputEvent, key: String) -> void :
	var handle: Panel = _nodes.get(key)
	if handle == null:
		return



	if event is InputEventScreenTouch:
		var touch: = event as InputEventScreenTouch
		if touch.index != 0:
			return
		if touch.pressed:
			_begin_drag(key, handle, touch.position)
		else:
			_end_drag()
		accept_event()
	elif event is InputEventScreenDrag:
		var drag: = event as InputEventScreenDrag
		if drag.index != 0:
			return
		if _drag_key == key:
			_drag_to(key, _event_global(handle, drag.position))
		accept_event()
	elif event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			_begin_drag(key, handle, mouse_event.position)
		else:
			_end_drag()
		accept_event()
	elif event is InputEventMouseMotion and _drag_key == key:
		_drag_to(key, _event_global(handle, (event as InputEventMouseMotion).position))
		accept_event()





func _event_global(handle: Control, local: Vector2) -> Vector2:
	return handle.get_global_transform_with_canvas() * local


func _begin_drag(key: String, handle: Panel, local: Vector2) -> void :
	var resizing: = local.x > handle.size.x - RESIZE_ZONE\
	and local.y > handle.size.y - RESIZE_ZONE
	var pointer: = _event_global(handle, local)
	var center: = handle.get_global_rect().get_center()
	if resizing:
		var entry: = _ensure_entry(key)
		_start_scale = float(entry.get("scale", 1.0))
		_start_distance = maxf(pointer.distance_to(center), 8.0)
	else:
		_drag_offset = center - pointer
	_drag_key = key
	_drag_mode = "resize" if resizing else "move"
	_refresh_handle_style(key, true)
	_show_status(key)


func _drag_to(key: String, pointer: Vector2) -> void :
	if _drag_mode == "resize":
		_resize_widget(key, pointer)
	else:
		_move_widget(key, pointer + _drag_offset)


func _end_drag() -> void :
	if _drag_key != "":
		_refresh_handle_style(_drag_key, false)
	_drag_key = ""
	_drag_mode = ""


func _move_widget(key: String, center: Vector2) -> void :
	var entry: = _ensure_entry(key)
	entry["x"] = clampf(center.x / maxf(size.x, 1.0), 0.0, 1.0)
	entry["y"] = clampf(center.y / maxf(size.y, 1.0), 0.0, 1.0)
	_apply_preview()
	_show_status(key)


func _resize_widget(key: String, pointer: Vector2) -> void :
	var handle: Panel = _nodes[key]
	var center: = handle.get_global_rect().get_center()
	var distance: = maxf(pointer.distance_to(center), 4.0)
	var entry: = _ensure_entry(key)
	entry["scale"] = clampf(_start_scale * (distance / _start_distance), 
		Settings.HUD_SCALE_MIN, Settings.HUD_SCALE_MAX)
	_apply_preview()
	_show_status(key)


func _apply_preview() -> void :
	_hud.call("apply_hud_layout_preview", _layout)
	_sync_handles()


func _show_status(key: String) -> void :
	var current: Dictionary = _hud.call("get_hud_editor_layout")
	var entry: Dictionary = _layout.get(key, current.get(key, {}))
	if entry.is_empty():
		return
	_status.text = "%s · X %d%% · Y %d%% · размер ×%.2f" % [
		str(WIDGET_LABELS.get(key, key)), 
		int(round(float(entry.get("x", 0.5)) * 100.0)), 
		int(round(float(entry.get("y", 0.5)) * 100.0)), 
		float(entry.get("scale", 1.0)), 
	]


func _refresh_handle_style(key: String, active: bool) -> void :
	var handle: Panel = _nodes.get(key)
	if handle == null:
		return
	var accent: = Settings.hud_accent
	var border: = UITheme.ACCENT_BRIGHT if active else Color(
		accent.r, accent.g, accent.b, 0.72)
	var bg: = Color(accent.r, accent.g, accent.b, 0.18 if active else 0.08)
	handle.add_theme_stylebox_override("panel", _box(bg, border, 2 if active else 1, 3))




func _reset() -> void :
	_layout = {}
	_hud.call("apply_hud_layout_preview", {})
	_status.text = "Стандартная раскладка. Нажмите «СОХРАНИТЬ»."
	_sync_handles()


func _cancel() -> void :
	if _hud != null and is_instance_valid(_hud):
		_hud.call("apply_hud_layout_preview", Settings.hud_layout)
	if _on_closed.is_valid():
		_on_closed.call()
	_close()


func _save() -> void :
	Settings.set_hud_layout(_layout)
	if _on_closed.is_valid():
		_on_closed.call()
	_close()


func _close() -> void :
	Settings.hud_editor_open = false
	if _hud != null and is_instance_valid(_hud)\
	and _hud.has_method("set_editor_preview"):
		_hud.call("set_editor_preview", false)
	if _preview != null and is_instance_valid(_preview):
		_preview.queue_free()
		_preview = null
	if _layer != null and is_instance_valid(_layer):
		_layer.queue_free()
	else:
		queue_free()




func _label(text: String, font_size: int, color: Color) -> Label:
	var label: = Label.new()
	label.text = text
	label.add_theme_font_override("font", UITheme.ui_font(500))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _action_button(text: String, accent: bool, on_press: Callable) -> Button:
	var button: = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 36)
	button.theme_type_variation = &"AccentButton" if accent else &"SmallButton"
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.pressed.connect(Sfx.play_click)
	button.pressed.connect(on_press)
	return button


func _box(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	return box
