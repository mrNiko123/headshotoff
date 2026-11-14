extends Label





const UITheme = preload("res://scripts/ui_theme.gd")

const REFRESH_INTERVAL: = 0.25

var _elapsed: = 0.0


func _ready() -> void :
	name = "FpsCounter"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_theme_font_override("font", UITheme.ui_font(600))
	add_theme_font_size_override("font_size", 12)
	add_theme_color_override("font_color", Color(0.92, 0.93, 0.95, 0.84))

	add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.78))
	add_theme_constant_override("outline_size", 3)
	Settings.settings_changed.connect(_on_settings_changed)
	_refresh_visibility()
	_refresh_text()


func _process(delta: float) -> void :
	if not visible:
		return
	_elapsed += delta
	if _elapsed < REFRESH_INTERVAL:
		return
	_elapsed = 0.0
	_refresh_text()


func _refresh_text() -> void :
	text = "FPS %d" % Engine.get_frames_per_second()


func _refresh_visibility() -> void :
	visible = Settings.show_fps

	set_process(visible)


func _on_settings_changed() -> void :
	_refresh_visibility()
