extends Control






const UITheme = preload("res://scripts/ui_theme.gd")

const CELL: = 34.0
const GAP: = 4.0
const SPACE_HEIGHT: = 21.0
const WIDTH: = CELL * 3.0 + GAP * 2.0
const HEIGHT: = CELL * 3.0 + GAP * 3.0 + SPACE_HEIGHT

var _labels: Dictionary = {}
var _pressed: Dictionary = {}
var _box_idle: StyleBoxFlat
var _box_hot: StyleBoxFlat
var _font_key: Font


func _ready() -> void :
	name = "InputOverlay"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font_key = UITheme.display_font(600)
	_refresh_style()
	_refresh_labels()
	_refresh_visibility()
	Settings.settings_changed.connect(_on_settings_changed)


func _process(_delta: float) -> void :
	if not visible:
		return

	var jump_hot: = Input.is_action_pressed("jump")
	if Settings.is_wheel_bind("jump"):

		jump_hot = Input.is_action_just_pressed("jump")
	var pressed: = {
		"forward": Input.is_action_pressed("move_forward"), 
		"left": Input.is_action_pressed("move_left"), 
		"back": Input.is_action_pressed("move_back"), 
		"right": Input.is_action_pressed("move_right"), 
		"jump": jump_hot, 
		"lmb": Input.is_action_pressed("shoot"), 
		"rmb": Input.is_action_pressed("aim"), 
	}
	if pressed == _pressed:
		return
	_pressed = pressed
	queue_redraw()


func _draw() -> void :
	var row2: = CELL + GAP
	var mouse_y: = row2 + CELL + GAP
	var space_y: = mouse_y + CELL + GAP
	var mouse_w: = (WIDTH - GAP) * 0.5

	_draw_key(Rect2(GAP + CELL, 0.0, CELL, CELL), 
		str(_labels.get("forward", "W")), bool(_pressed.get("forward", false)))
	_draw_key(Rect2(0.0, row2, CELL, CELL), 
		str(_labels.get("left", "A")), bool(_pressed.get("left", false)))
	_draw_key(Rect2(GAP + CELL, row2, CELL, CELL), 
		str(_labels.get("back", "S")), bool(_pressed.get("back", false)))
	_draw_key(Rect2((GAP + CELL) * 2.0, row2, CELL, CELL), 
		str(_labels.get("right", "D")), bool(_pressed.get("right", false)))

	_draw_key(Rect2(0.0, mouse_y, mouse_w, CELL), 
		str(_labels.get("lmb", "LMB")), bool(_pressed.get("lmb", false)), 11)
	_draw_key(Rect2(mouse_w + GAP, mouse_y, mouse_w, CELL), 
		str(_labels.get("rmb", "RMB")), bool(_pressed.get("rmb", false)), 11)

	_draw_key(Rect2(0.0, space_y, WIDTH, SPACE_HEIGHT), 
		str(_labels.get("jump", "SPACE")), bool(_pressed.get("jump", false)), 10)


func _draw_key(rect: Rect2, label: String, hot: bool, base_size: = 12) -> void :
	draw_style_box(_box_hot if hot else _box_idle, rect)
	var size: = _fit_size(label, base_size, rect.size.x - 10.0)
	var color: = _text_hot() if hot else _text_idle()
	var baseline: = rect.position.y + rect.size.y * 0.5\
	+ (_font_key.get_ascent(size) - _font_key.get_descent(size)) * 0.5
	draw_string(_font_key, Vector2(rect.position.x, baseline), label, 
		HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, size, color)




func _fit_size(label: String, base: int, width: float) -> int:
	var size: = base
	while size > 7 and _font_key.get_string_size(label, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width:
		size -= 1
	return size




func _refresh_style() -> void :
	var accent: = Settings.hud_accent
	_box_idle = StyleBoxFlat.new()
	_box_idle.bg_color = Color(0.045, 0.055, 0.07, 0.76)
	_box_idle.border_color = Color(0.78, 0.82, 0.88, 0.26)
	_box_idle.set_border_width_all(1)
	_box_idle.set_corner_radius_all(7)
	_box_idle.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	_box_idle.shadow_size = 2
	_box_idle.shadow_offset = Vector2(0.0, 2.0)

	_box_hot = StyleBoxFlat.new()
	_box_hot.bg_color = Color(accent.r, accent.g, accent.b, 0.92)
	_box_hot.border_color = Color(accent.r, accent.g, accent.b, 1.0)
	_box_hot.set_border_width_all(2)
	_box_hot.set_corner_radius_all(7)
	_box_hot.shadow_color = Color(accent.r, accent.g, accent.b, 0.24)
	_box_hot.shadow_size = 4


func _refresh_labels() -> void :
	_labels = {
		"forward": _key_text("move_forward"), 
		"left": _key_text("move_left"), 
		"back": _key_text("move_back"), 
		"right": _key_text("move_right"), 
		"jump": _key_text("jump"), 
		"lmb": _mouse_text("shoot", "LMB"), 
		"rmb": _mouse_text("aim", "RMB"), 
	}





func _key_text(action: String) -> String:
	var label: = Settings.get_key_label_compact(action)
	if label == "—":
		return "?"
	return label




func _mouse_text(action: String, fallback: String) -> String:
	var label: = Settings.get_key_label_compact(action)
	if label == "—":
		return fallback
	return label


func _text_idle() -> Color:
	return Color(0.92, 0.92, 0.9, 0.94)


func _text_hot() -> Color:
	return Color(0.09, 0.06, 0.02, 0.96)


func _refresh_visibility() -> void :
	visible = Settings.show_input_overlay and not Settings.is_mobile()

	set_process(visible)


func _on_settings_changed() -> void :
	_refresh_style()
	_refresh_labels()
	_refresh_visibility()
	queue_redraw()
