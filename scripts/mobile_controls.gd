extends CanvasLayer







const UITheme = preload("res://scripts/ui_theme.gd")
const ButtonIcon = preload("res://scripts/mobile_button_icon.gd")
const WeaponData = preload("res://scripts/weapon_data.gd")

const BASE_STICK: = 168.0
const BASE_BUTTON: = 96.0
const DEADZONE: = 0.18
const TOUCH_SLACK: = 14.0
const STICK_TOUCH_SCALE: = 1.55






const BUTTONS: = [
	{"key": "fire", "action": "shoot", "label": "ОГОНЬ", "accent": true}, 
	{"key": "jump", "action": "jump", "label": "ПРЫЖОК"}, 
	{"key": "crouch", "action": "crouch", "label": "ПРИСЕЛ."}, 
	{"key": "aim", "action": "aim", "label": "ПРИЦЕЛ"}, 
	{"key": "reload", "action": "reload", "label": "ПЕРЕЗАР."}, 
	{"key": "inspect", "action": "inspect", "label": "ОСМОТР"}, 
	{"key": "left_hand", "action": "toggle_left_hand", "label": "ЛЕВАЯ"}, 
	{"key": "scoreboard", "action": "scoreboard", "label": "ТАБЛО", 
		"event": true}, 
	{"key": "spawn", "action": "spawn_mannequin", "label": "МАНЕКЕН"}, 
	{"key": "melee", "action": "slot_melee", "label": "НОЖ", "toggle": true}, 
]

var _root: Control
var _stick: Panel
var _stick_marks: Control
var _knob: Panel
var _pause_button: Button
var _buttons: Dictionary = {}
var _touches: Dictionary = {}
var _pressed_axes: Dictionary = {}
var _press_actions: Dictionary = {}

var _stick_index: = -1
var _stick_center: = Vector2.ZERO
var _stick_radius: = 1.0
var _stick_vector: = Vector2.ZERO
var _knob_rest: = Vector2.ZERO




var _look_index: = -1
var _look_order: Array[int] = []


var _player: Node


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS

	layer = 2
	visible = false
	_build()
	if not Settings.mobile_layout_changed.is_connected(_relayout):
		Settings.mobile_layout_changed.connect(_relayout)
	if not Settings.settings_changed.is_connected(_on_settings_changed):
		Settings.settings_changed.connect(_on_settings_changed)
	get_viewport().size_changed.connect(_relayout)

	_root.resized.connect(_relayout)


	if not Settings.is_mobile():
		set_process(false)


func _exit_tree() -> void :
	_release_all()


func _process(_delta: float) -> void :
	var wanted: = false
	if Settings.is_mobile():
		var player: = _get_player()
		wanted = player != null and bool(player.get("active")) and not get_tree().paused
	if wanted != visible:
		visible = wanted
		if not wanted:
			_release_all()
		else:
			_refresh_visual_state()





func _on_player_weapon_changed(_state: Dictionary = {}) -> void :
	if visible:
		_update_weapon_label()


func _on_settings_changed() -> void :
	if visible:
		_update_left_hand_state()


func _refresh_visual_state() -> void :
	_update_weapon_label()
	_update_left_hand_state()




func _get_player() -> Node:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		if _player != null:
			var callback: = Callable(self, "_on_player_weapon_changed")
			if not _player.is_connected("weapon_changed", callback):
				_player.connect("weapon_changed", callback)
			if visible:
				_refresh_visual_state()
	return _player





func _update_weapon_label() -> void :
	var data: Dictionary = _buttons.get("melee", {})
	if data.is_empty():
		return
	var player: = _get_player()
	var melee: = player != null and bool(player.call("is_melee"))
	var primary: = str(WeaponData.get_weapon(Settings.weapon_id).get("name", "AWP"))
	var text: = primary if melee else "НОЖ"
	var label: Label = data["label"]
	if label.text != text:
		label.text = text
	var icon: Control = data["icon"]
	icon.set_icon("rifle" if melee else "melee")




func _update_left_hand_state() -> void :
	var data: Dictionary = _buttons.get("left_hand", {})
	if data.is_empty():
		return
	var active: = Settings.left_hand
	var accent: = Settings.hud_accent
	var color: = accent if active else UITheme.TEXT
	var icon: Control = data["icon"]
	icon.set_tint(color)
	var label: Label = data["label"]
	if label.get_theme_color("font_color") != color:
		label.add_theme_color_override("font_color", color)

	if int(data.get("shown", -1)) == int(active):
		return
	data["shown"] = int(active)
	var node: Panel = data["node"]
	var radius: = int(data.get("radius", 24))
	if active:
		node.add_theme_stylebox_override("panel", _circle(
			Color(accent.r, accent.g, accent.b, 0.3), accent, 2, radius))
	else:
		node.add_theme_stylebox_override("panel", _circle(
			Color(0.05, 0.06, 0.08, 0.46), Color(0.8, 0.84, 0.9, 0.4), 2, radius))




func _build() -> void :
	_root = Control.new()
	_root.name = "MobileControls"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_stick = Panel.new()
	_stick.name = "Joystick"
	_stick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_stick)


	_stick_marks = ButtonIcon.new()
	_stick_marks.name = "StickMarks"
	_stick_marks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stick.add_child(_stick_marks)

	_knob = Panel.new()
	_knob.name = "Knob"
	_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stick.add_child(_knob)

	for entry in BUTTONS:
		var key: = str(entry["key"])
		var panel: = Panel.new()
		panel.name = "Button_" + key
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_root.add_child(panel)



		var icon: = ButtonIcon.new()
		icon.name = "Icon"
		icon.anchor_left = 0.17
		icon.anchor_top = 0.06
		icon.anchor_right = 0.83
		icon.anchor_bottom = 0.64
		panel.add_child(icon)

		var label: = Label.new()
		label.text = str(entry["label"])
		label.anchor_left = 0.0
		label.anchor_top = 0.6
		label.anchor_right = 1.0
		label.anchor_bottom = 0.97
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_override("font", UITheme.display_font(600))
		label.add_theme_color_override("font_color", UITheme.TEXT)


		label.add_theme_color_override("font_outline_color", 
			Color(0.02, 0.03, 0.04, 0.85))
		label.add_theme_constant_override("outline_size", 3)
		panel.add_child(label)

		_buttons[key] = {
			"node": panel, 
			"icon": icon, 
			"label": label, 
			"action": str(entry["action"]), 
			"accent": bool(entry.get("accent", false)), 
			"toggle": bool(entry.get("toggle", false)), 
			"event": bool(entry.get("event", false)), 
		}

	_build_pause_button()
	_relayout()




func _build_pause_button() -> void :
	_pause_button = Button.new()
	_pause_button.name = "PauseButton"


	_pause_button.text = ""
	_pause_button.focus_mode = Control.FOCUS_NONE
	_pause_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_pause_button.offset_left = -26.0
	_pause_button.offset_right = 26.0
	_pause_button.offset_top = 10.0
	_pause_button.offset_bottom = 62.0
	_pause_button.add_theme_font_override("font", UITheme.display_font(600))
	_pause_button.add_theme_font_size_override("font_size", 18)
	_pause_button.add_theme_color_override("font_color", UITheme.TEXT)
	_pause_button.add_theme_stylebox_override("normal", _circle(
		Color(0.05, 0.06, 0.08, 0.55), Color(0.8, 0.84, 0.9, 0.5), 2, 26))
	_pause_button.add_theme_stylebox_override("hover", _circle(
		Color(0.09, 0.11, 0.14, 0.8), Color(1.0, 1.0, 1.0, 0.75), 2, 26))
	_pause_button.add_theme_stylebox_override("pressed", _circle(
		Color(0.16, 0.18, 0.22, 0.9), Color(1.0, 1.0, 1.0, 0.9), 2, 26))
	_pause_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_pause_button.pressed.connect(_request_pause)

	var pause_icon: = ButtonIcon.new()
	pause_icon.name = "PauseIcon"
	pause_icon.anchor_left = 0.34
	pause_icon.anchor_top = 0.24
	pause_icon.anchor_right = 0.66
	pause_icon.anchor_bottom = 0.76
	_pause_button.add_child(pause_icon)
	pause_icon.setup("pause", UITheme.TEXT)

	_root.add_child(_pause_button)


func _request_pause() -> void :
	_release_all()


	var event: = InputEventAction.new()
	event.action = "pause"
	event.pressed = true
	Input.parse_input_event(event)


func _relayout() -> void :
	if _root == null:
		return
	var view: = _root.size
	if view.x < 1.0 or view.y < 1.0:
		return

	var stick_rect: = Settings.mobile_widget_rect("stick", view, BASE_STICK)
	_stick.position = stick_rect.position
	_stick.size = stick_rect.size
	_stick.modulate = Color(1.0, 1.0, 1.0, Settings.mobile_widget_alpha("stick"))
	_stick_center = stick_rect.position + stick_rect.size * 0.5
	_stick_radius = stick_rect.size.x * 0.5
	_stick.add_theme_stylebox_override("panel", _circle(
		Color(0.05, 0.06, 0.08, 0.34), Color(0.85, 0.88, 0.92, 0.34), 2, 
		int(maxf(_stick_radius, 1.0))))

	var knob_size: = stick_rect.size * 0.4
	_knob.size = knob_size
	_knob_rest = (stick_rect.size - knob_size) * 0.5
	_knob.position = _knob_rest
	var accent: = Settings.hud_accent
	_knob.add_theme_stylebox_override("panel", _circle(
		Color(accent.r, accent.g, accent.b, 0.72), Color(1.0, 0.98, 0.9, 0.55), 2, 
		int(maxf(knob_size.x * 0.5, 1.0))))
	_stick_marks.setup("stick", Color(0.92, 0.94, 0.98, 0.3))

	for key in _buttons:
		var data: Dictionary = _buttons[key]
		var node: Panel = data["node"]
		var rect: = Settings.mobile_widget_rect(key, view, BASE_BUTTON)
		node.position = rect.position
		node.size = rect.size
		var alpha: = Settings.mobile_widget_alpha(key)
		data["alpha"] = alpha
		node.modulate = Color(1.0, 1.0, 1.0, alpha)
		var radius: = int(maxf(rect.size.x * 0.5, 1.0))
		if bool(data["accent"]):
			node.add_theme_stylebox_override("panel", _circle(
				Color(accent.r, accent.g, accent.b, 0.42), accent, 2, radius))
		else:
			node.add_theme_stylebox_override("panel", _circle(
				Color(0.05, 0.06, 0.08, 0.46), Color(0.8, 0.84, 0.9, 0.4), 2, radius))
		var icon: Control = data["icon"]


		icon.setup(key, Color(0.1, 0.06, 0.02, 0.92) if bool(data["accent"])
			else UITheme.TEXT)
		var label: Label = data["label"]
		label.add_theme_font_size_override("font_size", 
			int(clampf(rect.size.x * 0.105, 7.5, 11.0)))


		if key == "left_hand":
			data["radius"] = radius
			data["shown"] = -1


	_update_left_hand_state()


func _circle(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	return box




func _input(event: InputEvent) -> void :
	if not visible:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			var key: = _hit_test(event.position)
			if key.is_empty():



				_claim_look(event.index)
				return
			_touch_down(event.index, event.position)



			if key != "stick":
				_claim_look(event.index)
		else:
			_release_look(event.index)
			if not _touches.has(event.index):
				return
			_touch_up(event.index)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:


		if event.index == _look_index:
			_apply_touch_look(event as InputEventScreenDrag)
		if _touches.has(event.index):
			_touch_move(event.index, event.position)
			get_viewport().set_input_as_handled()
		elif event.index == _look_index:
			get_viewport().set_input_as_handled()
	elif not Settings.is_touch_device() and event is InputEventMouseButton\
	and event.button_index == MOUSE_BUTTON_LEFT:


		if event.pressed:
			if _hit_test(event.position).is_empty():
				return
			_touch_down(-1, event.position)
		else:
			if not _touches.has(-1):
				return
			_touch_up(-1)
		get_viewport().set_input_as_handled()
	elif not Settings.is_touch_device() and event is InputEventMouseMotion\
	and _touches.has(-1):
		_touch_move(-1, event.position)
		get_viewport().set_input_as_handled()


func _hit_test(pos: Vector2) -> String:
	for key in _buttons:
		var data: Dictionary = _buttons[key]
		var node: Panel = data["node"]
		var rect: = Rect2(node.position, node.size).grow(TOUCH_SLACK)
		if rect.has_point(pos):
			return key
	if pos.distance_to(_stick_center) <= _stick_radius * STICK_TOUCH_SCALE:
		return "stick"
	return ""


func _touch_down(index: int, pos: Vector2) -> void :
	if _touches.has(index):
		return
	var key: = _hit_test(pos)
	if key.is_empty():
		return
	_touches[index] = key
	if key == "stick":
		_stick_index = index
		_touch_move(index, pos)
		return
	var data: Dictionary = _buttons[key]
	data["node"].modulate = Color(1.3, 1.3, 1.3, float(data.get("alpha", 1.0)))
	var action: = _resolve_action(key)
	if action.is_empty():
		return
	_press_actions[index] = action
	_press_action(action, true)





func _press_action(action: String, down: bool) -> void :
	if action == "shoot":
		var player: = get_tree().get_first_node_in_group("player")
		if player != null and player.has_method("set_touch_fire"):
			player.call("set_touch_fire", down)
		return
	if action == "spawn_mannequin":


		if down:
			var player: = _get_player()
			if player != null and is_instance_valid(player)\
			and player.has_signal("spawned_mannequin_requested"):
				player.emit_signal("spawned_mannequin_requested")
		return
	if action == "scoreboard":
		var event: = InputEventAction.new()
		event.action = action
		event.pressed = down
		Input.parse_input_event(event)
		return
	if down:
		Input.action_press(action, 1.0)
	else:
		Input.action_release(action)



func _resolve_action(key: String) -> String:
	var data: Dictionary = _buttons[key]
	if not bool(data.get("toggle", false)):
		return str(data["action"])
	var player: = get_tree().get_first_node_in_group("player")
	if player != null and bool(player.call("is_melee")):
		return "slot_primary"
	return "slot_melee"


func _touch_move(index: int, pos: Vector2) -> void :
	if not _touches.has(index):
		return
	if index != _stick_index:
		return
	var reach: = maxf(_stick_radius * 0.62, 1.0)
	var delta: = (pos - _stick_center).limit_length(reach)
	_knob.position = _knob_rest + delta
	_stick_vector = delta / reach
	if _stick_vector.length() > 1.0:
		_stick_vector = _stick_vector.normalized()
	_apply_stick()






func _apply_touch_look(drag: InputEventScreenDrag) -> void :
	if not Settings.is_touch_device():
		return
	var player: = _get_player()
	if player == null or not is_instance_valid(player) or not bool(player.get("active")):
		return
	var relative: Vector2 = drag.screen_relative
	if relative == Vector2.ZERO:
		relative = drag.relative
	if relative == Vector2.ZERO or not player.has_method("apply_look"):
		return
	player.call("apply_look", relative)





func _claim_look(index: int) -> void :
	if _look_order.has(index):
		return
	_look_order.append(index)
	if _look_index < 0:
		_look_index = index


func _release_look(index: int) -> void :
	var position: = _look_order.find(index)
	if position >= 0:
		_look_order.remove_at(position)
	if _look_index == index:
		_look_index = _look_order[0] if not _look_order.is_empty() else -1


func _touch_up(index: int) -> void :
	var key: String = _touches.get(index, "")
	_touches.erase(index)
	if key.is_empty():
		return
	if key == "stick":
		_stick_index = -1
		_stick_vector = Vector2.ZERO
		_knob.position = _knob_rest
		_apply_stick()
		return
	var data: Dictionary = _buttons[key]
	data["node"].modulate = Color(1.0, 1.0, 1.0, float(data.get("alpha", 1.0)))
	var action: String = _press_actions.get(index, "")
	_press_actions.erase(index)
	if not action.is_empty():
		_press_action(action, false)




func _apply_stick() -> void :
	var value: = _stick_vector
	var length: = value.length()
	if length < DEADZONE:
		value = Vector2.ZERO
	elif length < 1.0:

		value = value.normalized() * ((length - DEADZONE) / (1.0 - DEADZONE))
	_set_axis("move_right", maxf(0.0, value.x))
	_set_axis("move_left", maxf(0.0, - value.x))
	_set_axis("move_back", maxf(0.0, value.y))
	_set_axis("move_forward", maxf(0.0, - value.y))


func _set_axis(action: String, strength: float) -> void :
	if strength <= 0.01:
		if _pressed_axes.has(action):
			_pressed_axes.erase(action)
			Input.action_release(action)
		return
	_pressed_axes[action] = strength
	Input.action_press(action, strength)


func _release_all() -> void :
	for index in _touches.keys():
		_touch_up(int(index))
	for action in _pressed_axes.keys():
		Input.action_release(str(action))
	_pressed_axes.clear()
	_press_actions.clear()
	for key in _buttons:
		var data: Dictionary = _buttons[key]
		data["node"].modulate = Color(1.0, 1.0, 1.0, float(data.get("alpha", 1.0)))
	_stick_vector = Vector2.ZERO
	_stick_index = -1
	_look_index = -1
	_look_order.clear()
	_knob.position = _knob_rest
