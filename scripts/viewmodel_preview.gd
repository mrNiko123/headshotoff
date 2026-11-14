extends PanelContainer






const Viewmodel = preload("res://scripts/viewmodel.gd")



const PREVIEW_HEIGHT: = 200.0

const VIEWMODEL_LAYER: = 4

var _viewport: SubViewport
var _holder: SubViewportContainer
var _camera: Camera3D


var _viewmodel
var _picker: OptionButton
var _shown_weapon: = ""
var _shown_skin: = ""


var _show_knife: = false


func _ready() -> void :
	theme_type_variation = &"CardPanel"
	custom_minimum_size = Vector2(0.0, PREVIEW_HEIGHT + 56.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)



	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	box.add_child(head)

	var caption: = Label.new()
	caption.text = "ПРЕДПРОСМОТР"
	caption.theme_type_variation = &"KickerLabel"
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(caption)

	_picker = OptionButton.new()
	_picker.add_item("AWP", 0)
	_picker.add_item("НОЖ", 1)
	_picker.custom_minimum_size = Vector2(92, 28)
	_picker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_picker.item_selected.connect(_on_pick_weapon)
	head.add_child(_picker)

	var holder: = SubViewportContainer.new()


	holder.stretch = false
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.resized.connect(_sync_viewport_size)
	box.add_child(holder)
	_holder = holder

	_viewport = SubViewport.new()

	_viewport.own_world_3d = true
	_viewport.transparent_bg = false
	_viewport.size = Vector2i(16, 16)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	holder.add_child(_viewport)

	_build_environment()

	_camera = Camera3D.new()
	_camera.cull_mask = VIEWMODEL_LAYER
	_camera.fov = Settings.fov
	_camera.near = 0.02
	_camera.far = 6.0
	_camera.current = true
	_viewport.add_child(_camera)

	_viewmodel = Viewmodel.new()
	_viewmodel.preview_mode = true
	_camera.add_child(_viewmodel)


	_viewmodel.process_mode = Node.PROCESS_MODE_ALWAYS
	_shown_weapon = Settings.weapon_id
	_shown_skin = Settings.weapon_skin

	Settings.settings_changed.connect(_on_settings_changed)
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()

	call_deferred("_sync_viewport_size")



func _sync_viewport_size() -> void :
	if _viewport == null or _holder == null:
		return
	var w: = maxi(int(_holder.size.x), 2)
	var h: = maxi(int(_holder.size.y), 2)
	var target: = Vector2i(w, h)
	if _viewport.size != target:
		_viewport.size = target




func _build_environment() -> void :
	var env: = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.052, 0.031, 0.008, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.76, 0.78, 0.86, 1.0)
	env.ambient_light_energy = 0.58

	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 0.98
	var world_env: = WorldEnvironment.new()
	world_env.environment = env
	_viewport.add_child(world_env)

	var key: = DirectionalLight3D.new()
	key.layers = VIEWMODEL_LAYER
	key.light_cull_mask = VIEWMODEL_LAYER
	key.light_color = Color(1.0, 0.95, 0.88, 1.0)
	key.light_energy = 1.3

	key.shadow_enabled = true
	key.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	key.directional_shadow_max_distance = 6.0
	key.shadow_bias = 0.03
	key.shadow_normal_bias = 1.0
	key.rotation_degrees = Vector3(-38.0, -30.0, 0.0)
	_viewport.add_child(key)

	var rim: = DirectionalLight3D.new()
	rim.layers = VIEWMODEL_LAYER
	rim.light_cull_mask = VIEWMODEL_LAYER
	rim.light_color = Color(1.0, 0.78, 0.38, 1.0)
	rim.light_energy = 0.55
	rim.shadow_enabled = false
	rim.rotation_degrees = Vector3(26.0, 158.0, 0.0)
	_viewport.add_child(rim)


func _on_settings_changed() -> void :
	if _camera != null:

		_camera.fov = Settings.fov
	if _show_knife:
		return
	if _shown_weapon != Settings.weapon_id or _shown_skin != Settings.weapon_skin:
		_show_weapon(Settings.weapon_id, Settings.weapon_skin)


func _on_pick_weapon(index: int) -> void :
	_show_knife = index == 1
	if _show_knife:
		_show_weapon("knife", Settings.knife_skin)
	else:
		_show_weapon(Settings.weapon_id, Settings.weapon_skin)




func _show_weapon(weapon_id: String, skin_id: String) -> void :
	_shown_weapon = weapon_id
	_shown_skin = skin_id
	if _viewmodel == null:
		return
	_viewmodel.preview_mode = true
	_viewmodel.build_for(weapon_id, skin_id)



func _on_visibility_changed() -> void :
	set_active(is_visible_in_tree())




func set_active(on: bool) -> void :
	if _viewport == null:
		return
	if on:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	if _viewmodel != null:
		_viewmodel.set_process(on)
