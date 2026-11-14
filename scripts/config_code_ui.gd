extends VBoxContainer











const UITheme = preload("res://scripts/ui_theme.gd")

var _text: TextEdit
var _status: Label
var _details: VBoxContainer
var _manual_button: Button
var _get_code: Callable
var _apply_code: Callable


func setup(title: String, hint: String, get_code: Callable, 
		apply_code: Callable) -> void :
	_get_code = get_code
	_apply_code = apply_code
	add_theme_constant_override("separation", 4)

	var header: = HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	add_child(header)

	var caption: = Label.new()
	caption.text = title
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	caption.add_theme_font_override("font", UITheme.ui_font(700))
	caption.add_theme_font_size_override("font_size", 12)
	caption.add_theme_color_override("font_color", UITheme.ACCENT_BRIGHT)
	header.add_child(caption)

	var copy: = _small_button("КОПИРОВАТЬ", 118)
	copy.tooltip_text = "Создать код текущих настроек и положить в буфер обмена."
	copy.pressed.connect(_on_copy)
	header.add_child(copy)

	var paste: = _small_button("ВСТАВИТЬ", 104)
	paste.tooltip_text = "Взять код из буфера обмена и применить его сразу."
	paste.pressed.connect(_on_paste)
	header.add_child(paste)

	_manual_button = _small_button("ВРУЧНУЮ", 96)
	_manual_button.toggle_mode = true
	_manual_button.tooltip_text = "Показать поле для ручной вставки и правки кода."
	_manual_button.toggled.connect(_on_manual_toggled)
	header.add_child(_manual_button)

	_status = Label.new()
	_status.visible = false
	_status.add_theme_font_override("font", UITheme.ui_font(400))
	_status.add_theme_font_size_override("font_size", 10)
	_status.add_theme_color_override("font_color", UITheme.MUTED)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)

	_details = VBoxContainer.new()
	_details.visible = false
	_details.add_theme_constant_override("separation", 4)
	add_child(_details)

	var help: = Label.new()
	help.text = hint
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.add_theme_font_override("font", UITheme.ui_font(400))
	help.add_theme_font_size_override("font_size", 10)
	help.add_theme_color_override("font_color", UITheme.MUTED)
	_details.add_child(help)

	_text = TextEdit.new()
	_text.custom_minimum_size = Vector2(0, 56)
	_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_text.placeholder_text = "Вставьте CFG-код и нажмите «ПРИМЕНИТЬ»"
	_text.add_theme_font_size_override("font_size", 10)
	_details.add_child(_text)

	var apply: = _small_button("ПРИМЕНИТЬ КОД", 170)
	apply.tooltip_text = "Применить код из поля ввода."
	apply.pressed.connect(_on_apply)
	_details.add_child(apply)


func _small_button(text: String, width: int) -> Button:
	var button: = Button.new()
	button.text = text
	button.theme_type_variation = &"SmallButton"
	button.custom_minimum_size = Vector2(width, 30)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return button


func _on_manual_toggled(shown: bool) -> void :
	_details.visible = shown
	_manual_button.text = "СКРЫТЬ" if shown else "ВРУЧНУЮ"
	if shown:
		_text.grab_focus()


func _on_copy() -> void :
	if not _get_code.is_valid():
		return
	var code: = str(_get_code.call()).strip_edges()
	if code.is_empty():
		_set_status("Не удалось создать код.", true)
		return
	_text.text = code
	var copied: = _clipboard_set(code)
	if copied:
		_set_status("Код скопирован — отправьте его другому игроку.", false)
	else:
		_show_manual()
		_set_status("Код создан в поле ниже — скопируйте его вручную.", false)


func _on_paste() -> void :
	var code: = _clipboard_get()
	if code.is_empty():
		_show_manual()
		_set_status("Буфер обмена пуст: вставьте код в поле вручную.", true)
		return
	_apply(code)


func _on_apply() -> void :
	var code: = _text.text.strip_edges()
	if code.is_empty():
		code = _clipboard_get()
	if code.is_empty():
		_set_status("Поле пустое: вставьте код или скопируйте его в буфер.", true)
		return
	_apply(code)


func _apply(code: String) -> void :
	if not _apply_code.is_valid():
		return
	var result: Variant = _apply_code.call(code)
	if result is bool and result:
		_text.text = ""
		_set_status("Настройки применены.", false)
	else:
		_set_status("Код не подошёл, повреждён или предназначен для другого раздела.", 
			true)


func _show_manual() -> void :
	if _manual_button.button_pressed:
		return
	_manual_button.button_pressed = true
	_details.visible = true
	_manual_button.text = "СКРЫТЬ"




func _clipboard_get() -> String:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		return ""
	return DisplayServer.clipboard_get().strip_edges()


func _clipboard_set(text: String) -> bool:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
		return false
	DisplayServer.clipboard_set(text)
	return true


func _set_status(text: String, error: bool) -> void :
	if _status == null:
		return
	_status.text = text
	_status.visible = not text.is_empty()
	_status.add_theme_color_override("font_color", 
		Color(1.0, 0.48, 0.42) if error else UITheme.ACCENT_BRIGHT)
