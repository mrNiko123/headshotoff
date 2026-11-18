extends CanvasLayer
## HUD СТРОЙКИ БАТЛ РОЯЛЯ: три иконки материалов с количеством
## под панелью слотов + подпись выбранного элемента в режиме стройки.

const UITheme = preload("res://scripts/ui_theme.gd")

const MAT_COLORS: = [
	Color(0.76, 0.6, 0.38, 1.0), 
	Color(0.55, 0.55, 0.52, 1.0), 
	Color(0.6, 0.64, 0.7, 1.0), 
]
const MAT_KEYS: = ["ДЕРЕВО", "КАМЕНЬ", "МЕТАЛЛ"]
const KIND_NAMES: = {
	"wall": "СТЕНА [Q]", "floor": "ПОЛ [Z]", 
	"stairs": "ЛЕСТНИЦА [X]", "roof": "КРЫША [C]", 
}

var _root: Control
var _boxes: Array = []
var _count_labels: Array = []
var _mode_label: Label
var _hint_label: Label


func _ready() -> void :
	layer = 21
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	var bottom: = VBoxContainer.new()
	bottom.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	bottom.offset_left = - 190.0
	bottom.offset_top = - 118.0
	bottom.offset_right = 190.0
	bottom.offset_bottom = - 64.0
	bottom.alignment = BoxContainer.ALIGNMENT_END
	bottom.add_theme_constant_override("separation", 3)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(bottom)

	_mode_label = _label("", 13, Color(0.36, 1.0, 0.55, 1.0))
	_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mode_label.visible = false
	bottom.add_child(_mode_label)

	var row: = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(row)

	for i in 3:
		var box: = PanelContainer.new()
		var style: = StyleBoxFlat.new()
		style.bg_color = Color(0.02, 0.03, 0.05, 0.85)
		style.set_corner_radius_all(8)
		style.border_color = MAT_COLORS[i]
		style.set_border_width_all(2)
		box.add_theme_stylebox_override("panel", style)
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(box)
		var margin: = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_top", 3)
		margin.add_theme_constant_override("margin_bottom", 3)
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(margin)
		var column: = VBoxContainer.new()
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_theme_constant_override("separation", -3)
		margin.add_child(column)
		var icon: = _label(_mat_icon(i), 16, MAT_COLORS[i])
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(icon)
		var count: = _label("0", 13, Color(0.94, 0.93, 0.9, 1.0))
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(count)
		_boxes.append(box)
		_count_labels.append(count)

	_hint_label = _label("", 10, Color(0.62, 0.665, 0.725, 1.0))
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom.add_child(_hint_label)


func _mat_icon(index: int) -> String:
	return ["▤", "▣", "⬛"][index]


func _label(text: String, font_size: int, color: Color) -> Label:
	var label: = Label.new()
	label.text = text
	label.add_theme_font_override("font", UITheme.ui_font(700))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", 
		Color(0.02, 0.02, 0.02, 0.95))
	label.add_theme_constant_override("outline_size", 4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func update_mats(wood: int, stone: int, metal: int, selected: int) -> void :
	var counts: = [wood, stone, metal]
	for i in 3:
		(_count_labels[i] as Label).text = str(counts[i])
		var box: = _boxes[i] as PanelContainer
		var style: = box.get_theme_stylebox("panel") as StyleBoxFlat
		if style != null:
			style.bg_color = Color(0.05, 0.09, 0.06, 0.95) if i == selected \
				else Color(0.02, 0.03, 0.05, 0.85)


func update_mode(active: bool, kind: String) -> void :
	_mode_label.visible = active
	if active:
		_mode_label.text = str(KIND_NAMES.get(kind, kind)) \
			+ "  ·  ЛКМ ПОСТАВИТЬ  ·  1-3 МАТЕРИАЛ  ·  G ПРОЁМ"
	_hint_label.visible = not active
