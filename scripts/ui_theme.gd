extends RefCounted





const BG: = Color(0.028, 0.033, 0.04, 1.0)
const PANEL: = Color(0.058, 0.07, 0.084, 0.97)
const PANEL_2: = Color(0.082, 0.097, 0.115, 1.0)
const PANEL_3: = Color(0.112, 0.128, 0.148, 1.0)
const BORDER: = Color(0.165, 0.19, 0.22, 1.0)
const BORDER_LIGHT: = Color(0.285, 0.315, 0.355, 1.0)
const TEXT: = Color(0.91, 0.9, 0.878, 1.0)
const MUTED: = Color(0.52, 0.565, 0.615, 1.0)


const MUTED_BRIGHT: = Color(0.7, 0.745, 0.795, 1.0)
const ACCENT: = Color(0.886, 0.651, 0.239, 1.0)
const ACCENT_BRIGHT: = Color(0.968, 0.77, 0.395, 1.0)
const ACCENT_DARK: = Color(0.47, 0.32, 0.095, 1.0)
const DANGER: = Color(0.89, 0.345, 0.31, 1.0)
const GREEN: = Color(0.32, 1.0, 0.48, 1.0)




const GOLD: = Color(0.93, 0.84, 0.3, 1.0)
const GOLD_BRIGHT: = Color(1.0, 0.94, 0.55, 1.0)
const GOLD_DEEP: = Color(0.34, 0.3, 0.12, 1.0)
const ESPRESSO: = Color(0.05, 0.058, 0.072, 1.0)
const ESPRESSO_2: = Color(0.075, 0.088, 0.108, 1.0)
const ESPRESSO_3: = Color(0.1, 0.118, 0.142, 1.0)
const MENU_BORDER: = Color(0.13, 0.155, 0.19, 1.0)
const MENU_BORDER_LIGHT: = Color(0.3, 0.36, 0.44, 1.0)
const MENU_TEXT: = Color(0.95, 0.96, 0.97, 1.0)
const MENU_MUTED: = Color(0.56, 0.61, 0.67, 1.0)

const DARK_TEXT: = Color(0.165, 0.088, 0.01, 1.0)

const FONT_UI_FILE = preload("res://assets/fonts/Manrope-Variable.ttf")
const FONT_DISPLAY_FILE = preload("res://assets/fonts/Unbounded-Variable.ttf")

static var _font_cache: Dictionary = {}





const WGHT_TAG: = 2003265652


static func ui_font(weight: = 400) -> FontVariation:
	var key: = "ui_%d" % weight
	if _font_cache.has(key):
		return _font_cache[key] as FontVariation
	var font: = FontVariation.new()
	font.base_font = FONT_UI_FILE
	font.variation_opentype = {WGHT_TAG: float(weight)}
	_font_cache[key] = font
	return font


static func display_font(weight: = 600) -> FontVariation:
	var key: = "display_%d" % weight
	if _font_cache.has(key):
		return _font_cache[key] as FontVariation
	var font: = FontVariation.new()
	font.base_font = FONT_DISPLAY_FILE
	font.variation_opentype = {WGHT_TAG: float(weight)}
	_font_cache[key] = font
	return font


static func make_theme(accent: Color = ACCENT) -> Theme:
	var theme: = Theme.new()
	var accent_bright: = accent.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.34)
	var accent_dark: = accent.darkened(0.46)
	var body: = ui_font(400)
	var body_medium: = ui_font(500)
	var body_bold: = ui_font(700)
	var display: = display_font(600)
	var display_medium: = display_font(500)
	var display_regular: = display_font(400)

	theme.default_font = body
	theme.default_font_size = 15


	theme.set_font("font", "Label", body)
	theme.set_font_size("font_size", "Label", 15)
	theme.set_color("font_color", "Label", TEXT)
	theme.set_color("font_shadow_color", "Label", Color(0.0, 0.0, 0.0, 0.6))
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 1)

	theme.set_type_variation("DisplayLabel", "Label")
	theme.set_font("font", "DisplayLabel", display)
	theme.set_font_size("font_size", "DisplayLabel", 38)
	theme.set_color("font_color", "DisplayLabel", TEXT)

	theme.set_type_variation("DisplayMedium", "Label")
	theme.set_font("font", "DisplayMedium", display_medium)
	theme.set_font_size("font_size", "DisplayMedium", 26)
	theme.set_color("font_color", "DisplayMedium", TEXT)

	theme.set_type_variation("KickerLabel", "Label")
	theme.set_font("font", "KickerLabel", body_bold)
	theme.set_font_size("font_size", "KickerLabel", 11)
	theme.set_color("font_color", "KickerLabel", MUTED)

	theme.set_type_variation("StatLabel", "Label")
	theme.set_font("font", "StatLabel", display)
	theme.set_font_size("font_size", "StatLabel", 40)
	theme.set_color("font_color", "StatLabel", TEXT)

	theme.set_type_variation("StatSmall", "Label")
	theme.set_font("font", "StatSmall", display_medium)
	theme.set_font_size("font_size", "StatSmall", 24)
	theme.set_color("font_color", "StatSmall", TEXT)

	theme.set_type_variation("AccentLabel", "Label")
	theme.set_font("font", "AccentLabel", body_bold)
	theme.set_font_size("font_size", "AccentLabel", 12)
	theme.set_color("font_color", "AccentLabel", accent)


	theme.set_font("font", "Button", display)
	theme.set_font_size("font_size", "Button", 20)
	theme.set_color("font_color", "Button", Color(0.84, 0.85, 0.86, 1.0))
	theme.set_color("font_hover_color", "Button", TEXT)
	theme.set_color("font_pressed_color", "Button", Color(0.06, 0.055, 0.045, 1.0))
	theme.set_color("font_focus_color", "Button", TEXT)
	theme.set_color("font_disabled_color", "Button", MUTED)
	theme.set_stylebox("normal", "Button", _button_box(PANEL_2, BORDER, 1))
	theme.set_stylebox("hover", "Button", _button_box(PANEL_3, BORDER_LIGHT, 1))
	theme.set_stylebox("pressed", "Button", _button_box(accent, accent, 1))
	theme.set_stylebox("focus", "Button", _focus_box(accent))
	theme.set_stylebox("disabled", "Button", _button_box(PANEL, BORDER, 1))

	theme.set_type_variation("AccentButton", "Button")
	theme.set_color("font_color", "AccentButton", Color(0.075, 0.065, 0.045, 1.0))
	theme.set_color("font_hover_color", "AccentButton", Color(0.075, 0.065, 0.045, 1.0))
	theme.set_color("font_pressed_color", "AccentButton", Color(0.98, 0.97, 0.94, 1.0))
	theme.set_color("font_focus_color", "AccentButton", Color(0.075, 0.065, 0.045, 1.0))
	theme.set_stylebox("normal", "AccentButton", _button_box(accent, accent, 1))
	theme.set_stylebox("hover", "AccentButton", _button_box(accent_bright, accent_bright, 1))
	theme.set_stylebox("pressed", "AccentButton", _button_box(accent_dark, accent, 1))
	theme.set_stylebox("focus", "AccentButton", _focus_box(TEXT))

	theme.set_type_variation("GhostButton", "Button")
	theme.set_stylebox("normal", "GhostButton", _button_box(Color(0.0, 0.0, 0.0, 0.0), Color(0, 0, 0, 0), 0))
	theme.set_stylebox("hover", "GhostButton", _button_box(PANEL_2, BORDER, 1))
	theme.set_stylebox("pressed", "GhostButton", _button_box(accent, accent, 1))

	theme.set_type_variation("NavButton", "Button")
	theme.set_font_size("font_size", "NavButton", 22)
	theme.set_color("font_color", "NavButton", Color(0.82, 0.835, 0.85, 1.0))
	theme.set_stylebox("normal", "NavButton", _nav_box(Color(0.0, 0.0, 0.0, 0.0), Color(0, 0, 0, 0)))
	theme.set_stylebox("hover", "NavButton", _nav_box(Color(accent.r, accent.g, accent.b, 0.1), accent))
	theme.set_stylebox("pressed", "NavButton", _nav_box(accent, accent))
	theme.set_stylebox("focus", "NavButton", _nav_box(Color(accent.r, accent.g, accent.b, 0.1), accent))

	theme.set_type_variation("SmallButton", "Button")
	theme.set_font("font", "SmallButton", body_bold)
	theme.set_font_size("font_size", "SmallButton", 14)
	theme.set_stylebox("normal", "SmallButton", _button_box(PANEL_2, BORDER, 1, 10.0, 7.0))
	theme.set_stylebox("hover", "SmallButton", _button_box(PANEL_3, accent, 1, 10.0, 7.0))
	theme.set_stylebox("pressed", "SmallButton", _button_box(accent, accent, 1, 10.0, 7.0))


	var panel: = StyleBoxFlat.new()
	panel.bg_color = PANEL
	panel.border_color = BORDER
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(3)
	theme.set_stylebox("panel", "PanelContainer", panel)
	theme.set_stylebox("panel", "Panel", panel)
	theme.set_stylebox("panel", "PopupPanel", panel)

	theme.set_type_variation("CardPanel", "PanelContainer")
	var card: = StyleBoxFlat.new()
	card.bg_color = Color(0.07, 0.083, 0.099, 0.92)
	card.border_color = BORDER
	card.set_border_width_all(1)
	card.set_corner_radius_all(3)
	card.content_margin_left = 14.0
	card.content_margin_right = 14.0
	card.content_margin_top = 10.0
	card.content_margin_bottom = 10.0
	theme.set_stylebox("panel", "CardPanel", card)


	theme.set_font("font", "LineEdit", body)
	theme.set_font_size("font_size", "LineEdit", 18)
	theme.set_color("font_color", "LineEdit", TEXT)
	theme.set_color("font_placeholder_color", "LineEdit", MUTED)
	theme.set_color("caret_color", "LineEdit", accent)
	theme.set_color("selection_color", "LineEdit", Color(accent.r, accent.g, accent.b, 0.35))
	theme.set_stylebox("normal", "LineEdit", _input_box(PANEL_2, BORDER))
	theme.set_stylebox("focus", "LineEdit", _input_box(PANEL_3, accent))
	theme.set_stylebox("read_only", "LineEdit", _input_box(PANEL, BORDER))


	theme.set_font("font", "OptionButton", body_bold)
	theme.set_font_size("font_size", "OptionButton", 15)
	theme.set_color("font_color", "OptionButton", TEXT)
	theme.set_color("font_hover_color", "OptionButton", TEXT)
	theme.set_color("font_pressed_color", "OptionButton", TEXT)
	theme.set_stylebox("normal", "OptionButton", _button_box(PANEL_2, BORDER, 1))
	theme.set_stylebox("hover", "OptionButton", _button_box(PANEL_3, accent_dark, 1))
	theme.set_stylebox("pressed", "OptionButton", _button_box(PANEL_3, accent, 1))
	theme.set_stylebox("focus", "OptionButton", _focus_box(accent))


	var popup: = StyleBoxFlat.new()
	popup.bg_color = PANEL
	popup.border_color = BORDER_LIGHT
	popup.set_border_width_all(1)
	popup.set_corner_radius_all(3)
	popup.content_margin_left = 6.0
	popup.content_margin_right = 6.0
	popup.content_margin_top = 6.0
	popup.content_margin_bottom = 6.0
	theme.set_stylebox("panel", "PopupMenu", popup)
	var hover: = StyleBoxFlat.new()
	hover.bg_color = Color(accent.r, accent.g, accent.b, 0.18)
	hover.set_corner_radius_all(2)
	theme.set_stylebox("hover", "PopupMenu", hover)
	theme.set_color("font_color", "PopupMenu", TEXT)
	theme.set_color("font_hover_color", "PopupMenu", accent_bright)
	theme.set_font("font", "PopupMenu", body_bold)
	theme.set_font_size("font_size", "PopupMenu", 15)


	theme.set_stylebox("slider", "HSlider", _slider_track())
	theme.set_stylebox("grabber_area", "HSlider", _slider_fill(accent))
	theme.set_stylebox("grabber_area_highlight", "HSlider", _slider_fill(accent))
	theme.set_icon("grabber", "HSlider", _grabber_texture(16, accent))
	theme.set_icon("grabber_highlight", "HSlider", _grabber_texture(18, accent_bright))
	theme.set_icon("grabber_disabled", "HSlider", _grabber_texture(16, MUTED))


	theme.set_font("font", "CheckButton", body_bold)
	theme.set_font_size("font_size", "CheckButton", 15)
	theme.set_color("font_color", "CheckButton", TEXT)
	theme.set_color("font_hover_color", "CheckButton", accent_bright)
	theme.set_color("font_pressed_color", "CheckButton", accent_bright)
	theme.set_stylebox("normal", "CheckButton", _button_box(PANEL_2, BORDER, 1, 14.0, 8.0))
	theme.set_stylebox("hover", "CheckButton", _button_box(PANEL_3, accent_dark, 1, 14.0, 8.0))
	theme.set_stylebox("pressed", "CheckButton", _toggle_box(accent))
	theme.set_stylebox("focus", "CheckButton", _focus_box(accent))


	var separator: = StyleBoxFlat.new()
	separator.bg_color = BORDER
	separator.content_margin_top = 0.5
	separator.content_margin_bottom = 0.5
	theme.set_stylebox("separator", "HSeparator", separator)
	theme.set_constant("separation", "HSeparator", 2)


	theme.set_stylebox("scroll", "VScrollBar", _scroll_track())
	theme.set_stylebox("grabber", "VScrollBar", _scroll_grabber())
	theme.set_stylebox("grabber_highlight", "VScrollBar", _scroll_grabber())
	theme.set_stylebox("grabber_pressed", "VScrollBar", _scroll_grabber())

	return theme




static func make_menu_theme() -> Theme:
	var theme: = make_theme(GOLD)
	var dark: = Color(0.09, 0.05, 0.01, 0.94)
	var dark_hover: = Color(0.15, 0.088, 0.02, 0.98)
	var field: = Color(0.06, 0.033, 0.006, 0.96)
	var panel: = StyleBoxFlat.new()
	panel.bg_color = Color(0.095, 0.054, 0.012, 0.96)
	panel.border_color = MENU_BORDER
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(6)
	panel.shadow_color = Color(0.0, 0.0, 0.0, 0.32)
	panel.shadow_size = 10
	panel.shadow_offset = Vector2(0.0, 4.0)


	theme.set_color("font_color", "Label", MENU_TEXT)
	theme.set_color("font_shadow_color", "Label", Color(0.0, 0.0, 0.0, 0.55))
	theme.set_color("font_color", "DisplayLabel", MENU_TEXT)
	theme.set_color("font_color", "DisplayMedium", MENU_TEXT)
	theme.set_color("font_color", "KickerLabel", MENU_MUTED)
	theme.set_color("font_color", "AccentLabel", GOLD_BRIGHT)
	theme.set_color("font_color", "StatLabel", MENU_TEXT)
	theme.set_color("font_color", "StatSmall", MENU_TEXT)


	theme.set_color("font_color", "Button", MENU_TEXT)
	theme.set_color("font_hover_color", "Button", GOLD_BRIGHT)
	theme.set_color("font_pressed_color", "Button", ESPRESSO)
	theme.set_color("font_focus_color", "Button", GOLD_BRIGHT)
	theme.set_color("font_disabled_color", "Button", MENU_MUTED)
	theme.set_stylebox("normal", "Button", _button_box(dark, MENU_BORDER, 1))
	theme.set_stylebox("hover", "Button", _button_box(dark_hover, GOLD, 1))
	theme.set_stylebox("pressed", "Button", _button_box(GOLD, GOLD_BRIGHT, 1))
	theme.set_stylebox("focus", "Button", _focus_box(GOLD_BRIGHT))
	theme.set_stylebox("disabled", "Button", 
		_button_box(Color(0.06, 0.034, 0.008, 0.72), MENU_BORDER, 1))

	theme.set_color("font_color", "AccentButton", ESPRESSO)
	theme.set_color("font_hover_color", "AccentButton", ESPRESSO)
	theme.set_color("font_pressed_color", "AccentButton", MENU_TEXT)
	theme.set_color("font_focus_color", "AccentButton", ESPRESSO)
	theme.set_stylebox("normal", "AccentButton", _button_box(GOLD, GOLD_BRIGHT, 1))
	theme.set_stylebox("hover", "AccentButton", 
		_button_box(GOLD_BRIGHT, Color(1.0, 0.94, 0.62, 1.0), 1))
	theme.set_stylebox("pressed", "AccentButton", _button_box(GOLD_DEEP, GOLD, 1))
	theme.set_stylebox("focus", "AccentButton", _focus_box(MENU_TEXT))




	var primary: = _button_box(Color(0.07, 0.039, 0.007, 0.96), GOLD, 2)
	primary.shadow_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.3)
	primary.shadow_size = 16
	primary.shadow_offset = Vector2(0.0, 4.0)
	theme.set_color("font_color", "PrimaryButton", GOLD_BRIGHT)
	theme.set_color("font_hover_color", "PrimaryButton", ESPRESSO)
	theme.set_color("font_pressed_color", "PrimaryButton", ESPRESSO)
	theme.set_color("font_focus_color", "PrimaryButton", GOLD_BRIGHT)
	theme.set_stylebox("normal", "PrimaryButton", primary)
	theme.set_stylebox("hover", "PrimaryButton", 
		_button_box(GOLD, GOLD_BRIGHT, 2))
	theme.set_stylebox("pressed", "PrimaryButton", 
		_button_box(GOLD_DEEP, GOLD_BRIGHT, 2))
	theme.set_stylebox("focus", "PrimaryButton", _focus_box(GOLD_BRIGHT))

	theme.set_stylebox("normal", "GhostButton", 
		_button_box(Color(0.0, 0.0, 0.0, 0.0), Color(0, 0, 0, 0), 0))
	theme.set_stylebox("hover", "GhostButton", _button_box(dark_hover, MENU_BORDER, 1))
	theme.set_stylebox("pressed", "GhostButton", _button_box(GOLD, GOLD_BRIGHT, 1))

	theme.set_color("font_color", "SmallButton", MENU_TEXT)
	theme.set_color("font_hover_color", "SmallButton", GOLD_BRIGHT)
	theme.set_color("font_pressed_color", "SmallButton", ESPRESSO)
	theme.set_stylebox("normal", "SmallButton", 
		_button_box(dark, MENU_BORDER, 1, 12.0, 7.0))
	theme.set_stylebox("hover", "SmallButton", 
		_button_box(dark_hover, GOLD, 1, 12.0, 7.0))
	theme.set_stylebox("pressed", "SmallButton", 
		_button_box(GOLD, GOLD_BRIGHT, 1, 12.0, 7.0))


	theme.set_stylebox("panel", "PanelContainer", panel)
	theme.set_stylebox("panel", "Panel", panel)
	theme.set_stylebox("panel", "PopupPanel", panel)
	var card: = panel.duplicate() as StyleBoxFlat
	card.bg_color = Color(0.08, 0.045, 0.01, 0.94)
	card.content_margin_left = 14.0
	card.content_margin_right = 14.0
	card.content_margin_top = 10.0
	card.content_margin_bottom = 10.0
	theme.set_stylebox("panel", "CardPanel", card)


	theme.set_color("font_color", "LineEdit", MENU_TEXT)
	theme.set_color("font_placeholder_color", "LineEdit", MENU_MUTED)
	theme.set_color("caret_color", "LineEdit", GOLD)
	theme.set_color("selection_color", "LineEdit", Color(GOLD.r, GOLD.g, GOLD.b, 0.35))
	theme.set_stylebox("normal", "LineEdit", _input_box(field, MENU_BORDER))
	theme.set_stylebox("focus", "LineEdit", _input_box(dark_hover, GOLD))
	theme.set_stylebox("read_only", "LineEdit", _input_box(ESPRESSO, MENU_BORDER))

	theme.set_color("font_color", "OptionButton", MENU_TEXT)
	theme.set_color("font_hover_color", "OptionButton", GOLD_BRIGHT)
	theme.set_color("font_pressed_color", "OptionButton", GOLD_BRIGHT)
	theme.set_stylebox("normal", "OptionButton", _button_box(dark, MENU_BORDER, 1))
	theme.set_stylebox("hover", "OptionButton", _button_box(dark_hover, GOLD, 1))
	theme.set_stylebox("pressed", "OptionButton", _button_box(ESPRESSO_3, GOLD, 1))
	theme.set_stylebox("focus", "OptionButton", _focus_box(GOLD_BRIGHT))


	var popup: = panel.duplicate() as StyleBoxFlat
	popup.content_margin_left = 6.0
	popup.content_margin_right = 6.0
	popup.content_margin_top = 6.0
	popup.content_margin_bottom = 6.0
	theme.set_stylebox("panel", "PopupMenu", popup)
	var hover: = StyleBoxFlat.new()
	hover.bg_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.2)
	hover.set_corner_radius_all(3)
	theme.set_stylebox("hover", "PopupMenu", hover)
	theme.set_color("font_color", "PopupMenu", MENU_TEXT)
	theme.set_color("font_hover_color", "PopupMenu", GOLD_BRIGHT)


	theme.set_stylebox("slider", "HSlider", _slider_track(true))
	theme.set_stylebox("grabber_area", "HSlider", _slider_fill(GOLD))
	theme.set_stylebox("grabber_area_highlight", "HSlider", _slider_fill(GOLD_BRIGHT))
	theme.set_icon("grabber", "HSlider", _grabber_texture(16, GOLD))
	theme.set_icon("grabber_highlight", "HSlider", _grabber_texture(18, GOLD_BRIGHT))
	theme.set_icon("grabber_disabled", "HSlider", _grabber_texture(16, MENU_MUTED))
	theme.set_color("font_color", "CheckButton", MENU_TEXT)
	theme.set_color("font_hover_color", "CheckButton", GOLD_BRIGHT)
	theme.set_color("font_pressed_color", "CheckButton", GOLD_BRIGHT)
	theme.set_stylebox("normal", "CheckButton", 
		_button_box(dark, MENU_BORDER, 1, 14.0, 8.0))
	theme.set_stylebox("hover", "CheckButton", 
		_button_box(dark_hover, GOLD, 1, 14.0, 8.0))
	theme.set_stylebox("pressed", "CheckButton", _toggle_box(GOLD))
	theme.set_stylebox("focus", "CheckButton", _focus_box(GOLD_BRIGHT))

	var separator: = StyleBoxFlat.new()
	separator.bg_color = MENU_BORDER
	separator.content_margin_top = 0.5
	separator.content_margin_bottom = 0.5
	theme.set_stylebox("separator", "HSeparator", separator)

	theme.set_stylebox("scroll", "VScrollBar", _scroll_track(true))
	theme.set_stylebox("grabber", "VScrollBar", _scroll_grabber(GOLD_DEEP))
	theme.set_stylebox("grabber_highlight", "VScrollBar", _scroll_grabber(GOLD))
	theme.set_stylebox("grabber_pressed", "VScrollBar", _scroll_grabber(GOLD))
	return theme


static func _button_box(bg: Color, border: Color, border_width: int, 
		pad_x: = 18.0, pad_y: = 11.0) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(2)
	box.content_margin_left = pad_x
	box.content_margin_right = pad_x
	box.content_margin_top = pad_y
	box.content_margin_bottom = pad_y
	box.anti_aliasing = true
	return box


static func _nav_box(bg: Color, border: Color) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.border_width_left = 3
	box.content_margin_left = 22.0
	box.content_margin_right = 18.0
	box.content_margin_top = 12.0
	box.content_margin_bottom = 12.0
	box.set_corner_radius_all(2)
	return box


static func _input_box(bg: Color, border: Color) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(2)
	box.content_margin_left = 12.0
	box.content_margin_right = 12.0
	box.content_margin_top = 9.0
	box.content_margin_bottom = 9.0
	return box


static func _toggle_box(accent: Color = ACCENT) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(accent.r, accent.g, accent.b, 0.14)
	box.border_color = accent
	box.set_border_width_all(1)
	box.set_corner_radius_all(2)
	box.content_margin_left = 14.0
	box.content_margin_right = 14.0
	box.content_margin_top = 8.0
	box.content_margin_bottom = 8.0
	return box


static func _focus_box(color: Color) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	box.border_color = Color(color.r, color.g, color.b, 0.9)
	box.set_border_width_all(1)
	box.set_corner_radius_all(2)
	box.set_expand_margin_all(2.0)
	return box


static func _slider_track(warm: = false) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.06, 0.034, 0.008, 1.0) if warm\
	else Color(0.05, 0.06, 0.072, 1.0)
	box.border_color = MENU_BORDER if warm else BORDER
	box.set_border_width_all(1)
	box.set_corner_radius_all(1)
	box.content_margin_top = 3.0
	box.content_margin_bottom = 3.0
	return box


static func _slider_fill(accent: Color = ACCENT) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(accent.r, accent.g, accent.b, 0.72)
	box.set_corner_radius_all(1)
	box.content_margin_top = 3.0
	box.content_margin_bottom = 3.0
	return box


static func _grabber_texture(diameter: int, color: Color) -> Texture2D:
	var image: = Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	var radius: = diameter * 0.5
	for y in diameter:
		for x in diameter:
			var distance: = Vector2(x + 0.5 - radius, y + 0.5 - radius).length()
			var alpha: = clampf(radius - distance, 0.0, 1.0)
			var pixel: = color
			if distance < radius - 2.5:
				pixel = color.darkened(0.12)
			image.set_pixel(x, y, Color(pixel.r, pixel.g, pixel.b, alpha))
	return ImageTexture.create_from_image(image)


static func _scroll_track(warm: = false) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.06, 0.034, 0.008, 0.8) if warm\
	else Color(0.035, 0.045, 0.055, 0.65)
	box.content_margin_left = 2.0
	box.content_margin_right = 2.0
	return box


static func _scroll_grabber(color: Color = BORDER_LIGHT) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(2)
	box.content_margin_left = 2.0
	box.content_margin_right = 2.0
	return box


static func rarity_color(kind: String) -> Color:
	match kind:
		"rare":
			return Color(0.33, 0.64, 0.93, 1.0)
		"epic":
			return Color(0.66, 0.42, 0.95, 1.0)
		"legendary":
			return Color(0.93, 0.64, 0.23, 1.0)
		_:
			return Color(0.62, 0.67, 0.72, 1.0)
