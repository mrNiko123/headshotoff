extends CanvasLayer
## Магазин-лапа выбора оружия (клавиша B) для тренировки и командного боя.

signal weapon_picked(weapon_id: String, skin_id: String)

const WeaponData = preload("res://scripts/weapon_data.gd")

const PANEL: = Color(0.02, 0.028, 0.04, 0.96)
const PANEL_2: = Color(0.05, 0.062, 0.082, 1.0)
const BORDER: = Color(0.17, 0.205, 0.25, 1.0)
const TEXT: = Color(0.94, 0.93, 0.9, 1.0)
const MUTED: = Color(0.62, 0.665, 0.725, 1.0)

var _root: Control
var _grid: GridContainer
var _coins_label: Label
var _open_state: = false


func _ready() -> void :
	layer = 20
	_root = Control.new()
	_root.name = "BuyMenuRoot"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)

	var dim: = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(dim)

	var sheet: = PanelContainer.new()
	sheet.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	sheet.offset_left = -430.0
	sheet.offset_top = -258.0
	sheet.offset_right = 430.0
	sheet.offset_bottom = 258.0
	var box: = StyleBoxFlat.new()
	box.bg_color = PANEL
	box.border_color = BORDER
	box.set_border_width_all(1)
	box.set_corner_radius_all(12)
	box.content_margin_left = 18.0
	box.content_margin_right = 18.0
	box.content_margin_top = 14.0
	box.content_margin_bottom = 14.0
	sheet.add_theme_stylebox_override("panel", box)
	_root.add_child(sheet)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	sheet.add_child(column)

	var header: = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	column.add_child(header)
	var title: = _label("МАГАЗИН  ·  ВЫБОР ОРУЖИЯ", 22, TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_coins_label = _label("", 14, Color(1.0, 0.8, 0.4, 1.0))
	header.add_child(_coins_label)

	var hint: = _label("B / ESC — ЗАКРЫТЬ  ·  ОРУЖИЕ ЗАМЕНЯЕТСЯ СРАЗУ", 11, MUTED)
	column.add_child(hint)

	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	column.add_child(_grid)


func is_open() -> bool:
	return _open_state


func toggle() -> void :
	if _open_state:
		close()
	else:
		open()


func open() -> void :
	_open_state = true
	_root.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh()


func close() -> void :
	_open_state = false
	_root.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func handle_key(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			toggle()
			return true
		if event.keycode == KEY_ESCAPE and _open_state:
			close()
			return true
	return false


func _refresh() -> void :
	if _coins_label != null:
		_coins_label.text = "%d МОНЕТ" % Settings.coins
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	var seen: = {}
	for entry in WeaponData.ITEMS:
		var weapon_id: = str(entry["weapon"])
		var skin_id: = str(entry["skin"])
		var key: = "%s|%s" % [weapon_id, skin_id]
		if seen.has(key):
			continue
		if not Settings.owns_item(weapon_id, skin_id):
			continue
		seen[key] = true
		_grid.add_child(_item_button(weapon_id, skin_id))


func _item_button(weapon_id: String, skin_id: String) -> Button:
	var weapon: = WeaponData.get_weapon(weapon_id)
	var skin: = WeaponData.get_skin(weapon_id, skin_id)
	var rarity: = WeaponData.get_rarity(skin)
	var rarity_color: Color = rarity.get("color", MUTED)
	var button: = Button.new()
	button.custom_minimum_size = Vector2(262, 64)
	button.clip_text = false
	var box: = StyleBoxFlat.new()
	box.bg_color = PANEL_2
	box.border_color = rarity_color
	box.set_border_width_all(1)
	box.border_width_bottom = 3
	box.set_corner_radius_all(8)
	box.content_margin_left = 12.0
	button.add_theme_stylebox_override("normal", box)
	var hover: = box.duplicate() as StyleBoxFlat
	hover.bg_color = Color(PANEL_2.r + 0.05, PANEL_2.g + 0.05, PANEL_2.b + 0.06, 1.0)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 1)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(column)
	column.add_child(_label(str(weapon.get("name", "")).to_upper(), 10, MUTED))
	column.add_child(_label(str(skin.get("name", "SKIN")).to_upper(), 16, TEXT))
	var kind: = "НОЖ" if WeaponData.is_melee(weapon_id) else "ОРУЖИЕ"
	column.add_child(_label(kind + "  ·  СНАРЯДИТЬ", 9, rarity_color))

	var wid: = weapon_id
	var sid: = skin_id
	button.pressed.connect( func() -> void :
		weapon_picked.emit(wid, sid)
		close())
	return button


func _label(text: String, size: int, color: Color) -> Label:
	var label: = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
