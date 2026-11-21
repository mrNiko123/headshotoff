extends Control




const UITheme = preload("res://scripts/ui_theme.gd")
const WeaponData = preload("res://scripts/weapon_data.gd")
const UIIcon = preload("res://scripts/ui_icon.gd")
const WeaponBuilder = preload("res://scripts/weapon_builder.gd")
const CrosshairScript = preload("res://scripts/crosshair.gd")
const WeaponPreview = preload("res://scripts/weapon_preview.gd")
const MeshKit = preload("res://scripts/mesh_kit.gd")
const ColorWheel = preload("res://scripts/color_wheel.gd")
const LayoutEditor = preload("res://scripts/mobile_layout_editor.gd")
const HudLayoutEditor = preload("res://scripts/hud_layout_editor.gd")
const ViewmodelPreview = preload("res://scripts/viewmodel_preview.gd")
const ConfigCodeUI = preload("res://scripts/config_code_ui.gd")
const MapData = preload("res://scripts/map_data.gd")
const LevelBadge = preload("res://scripts/level_badge.gd")
const RatingButton = preload("res://scripts/rating_button.gd")
const OnlineCounter = preload("res://scripts/online_counter.gd")
const CountryData = preload("res://scripts/country_data.gd")
const CountryFlag = preload("res://scripts/country_flag.gd")
const PlayerSkinData = preload("res://scripts/player_skin_data.gd")
const PlayerPreview = preload("res://scripts/player_preview.gd")
const GLOW_SHADER = preload("res://shaders/glow_radial.gdshader")

const GAME_SCENE: = "res://game.tscn"
const DUEL_SCENE: = "res://duel.tscn"
const BOMB_SCENE: = "res://bomb.tscn"

const MENU_3D_FPS: = 30.0



const RATING_MINT: = Color(0.36, 0.98, 0.76, 1.0)
const RATING_MINT_DARK: = Color(0.05, 0.16, 0.13, 1.0)
const RATING_VIOLET: = Color(0.64, 0.52, 1.0, 1.0)
const RATING_ROSE: = Color(1.0, 0.4, 0.46, 1.0)



const SETTINGS_TAB_ORDER: = ["game", "crosshair", "colors", "hands", "screen", 
	"binds", "profile"]
const SETTINGS_TAB_CAPTIONS: = {
	"game": "ИГРА", 
	"crosshair": "ПРИЦЕЛ", 
	"colors": "ЦВЕТА", 
	"hands": "РУКИ", 
	"screen": "ЭКРАН", 
	"binds": "КЛАВИШИ", 
	"profile": "ПРОФИЛЬ", 
}
const SETTINGS_TAB_HINTS: = {
	"game": "Чувствительность, FOV, манекены, громкость и таймер сессии.", 
	"crosshair": "Цвет, форма и поведение прицела, прозрачная оптика AWP.", 
	"colors": "Акцент HUD, небо, рукав и кисть: пресеты или любой цвет.", 
	"hands": "Положение и размер рук, покачивание и левая рука.", 
	"screen": "Растяжение кадра, FPS, графика, экран и расположение HUD.", 
	"binds": "Клавиши и кнопки мыши для всех действий — по три пары в ряд.", 
	"profile": "Никнейм, аватар, статистика и её сброс.", 
}

var _ui: Control
var _fade: ColorRect
var _toast_label: Label
var _toast_tween: Tween

var _nickname_label: Label
var _rating_label: Label
var _loadout_label: Label
var _map_label: Label
var _stats_label: Label

var _page: = ""
var _settings_tab: = "game"
var _page_root: Control
var _page_title: Label
var _page_body: VBoxContainer
var _page_footer: HBoxContainer
var _page_footer_rule: ColorRect
var _page_sheet: PanelContainer
var _page_dim: ColorRect
var _page_close: Button

var _confirm_overlay: Control
var _confirm_panel: PanelContainer


var _stats_overlay: Control
var _stats_panel: PanelContainer

var _notice_overlay: Control


var _page_fade: ColorRect
var _page_transitioning: = false


var _settings_tab_bar: HBoxContainer
var _settings_tab_hint: Label




var _menu_column: VBoxContainer
var _info_panel: PanelContainer

var _online_counter: OnlineCounter
var _online_count_label: Label
var _online_players_label: Label
var _online_dot: Label

var _selected_weapon: = ""
var _selected_skin: = ""
var _inventory_status: Label
var _equip_button: Button
var _detail_name: Label
var _detail_rarity: Label
var _detail_stats: Label

var _theme_accent: = Color.BLACK
var _is_mobile: = false
var _mobile_box: VBoxContainer

var _rebind_action: = ""
var _rebind_button: Button
var _bind_buttons: Dictionary = {}

var _menu_time: = 0.0
var _menu_knife_pivot: Node3D
var _menu_knife_holder: Node3D
var _menu_knife_skin: = ""
var _menu_camera: Camera3D
var _menu_rim: OmniLight3D
var _menu_glow: MeshInstance3D


var _menu_viewport: SubViewport
var _menu_focused: = true
var _menu_render_clock: = 0.0

var _transitioning: = false

var _mm_overlay: Control
var _mm_status: Label
var _mm_details: Label
var _mm_timer_label: Label
var _mm_cancel: Button
var _mm_searching: = false
var _mm_elapsed: = 0.0
var _mm_duration: = 3.0
var _mm_token: = 0


func _ready() -> void :
	theme = UITheme.make_menu_theme()


	_is_mobile = _detect_mobile_platform()
	_theme_accent = Settings.hud_accent
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_fade = %Fade
	_fade.visible = true
	_fade.color = UITheme.ESPRESSO
	get_tree().node_added.connect(_on_node_added)
	_build_gold_background()
	_build_background_3d()
	_build_ui()
	_build_online_counter()
	_build_page()
	_build_matchmaking_overlay()
	_refresh_header()
	_animate_in()
	if Settings.last_session_crashed:
		_toast("ПРОШЛЫЙ ЗАПУСК ЗАВЕРШИЛСЯ АВАРИЙНО · ВКЛЮЧЁН РЕЖИМ СОВМЕСТИМОСТИ")
	var leave_notice: String = Settings.take_leave_notice()
	if not leave_notice.is_empty():
		call_deferred("_show_leave_notice", leave_notice)

	if not Settings.settings_changed.is_connected(_on_settings_changed):
		Settings.settings_changed.connect(_on_settings_changed)




func _detect_mobile_platform() -> bool:
	if OS.has_feature("mobile") or OS.get_name() == "Android":
		return true
	if OS.get_name() == "iOS":
		return true
	return OS.get_cmdline_user_args().has("--mobile-preview")


func _process(delta: float) -> void :
	_menu_time += delta
	if _online_dot != null:

		_online_dot.modulate.a = 0.62 + 0.38 * (0.5 + 0.5 * sin(_menu_time * 3.4))
	if _mm_searching:
		_mm_elapsed += delta
		if _mm_timer_label != null:
			_mm_timer_label.text = "%.1f С" % _mm_elapsed
		if _mm_status != null:
			_mm_status.text = "ПОИСК СОПЕРНИКА" + ".".repeat(
				int(_mm_elapsed * 2.0) % 4)
		if _mm_elapsed >= _mm_duration:
			_show_match_found()
	if _menu_knife_pivot != null:
		# манекен стоит на месте: лёгкое дыхание и микропокачивание
		_menu_knife_pivot.rotation_degrees = Vector3(
			sin(_menu_time * 0.62) * 1.5, 
			-16.0 + sin(_menu_time * 0.4) * 4.0, 0.0
		)
		_menu_knife_pivot.position.y = -0.44 + sin(_menu_time * 0.8) * 0.014
	if _menu_camera != null:
		_menu_camera.position = Vector3(
			sin(_menu_time * 0.26) * 0.06, 
			0.5 + sin(_menu_time * 0.41) * 0.02, 
			5.8
		)


	if not _menu_focused or _menu_viewport == null:
		return
	_menu_render_clock += delta
	if _menu_render_clock < 1.0 / MENU_3D_FPS:
		return
	_menu_render_clock = 0.0
	_menu_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _notification(what: int) -> void :



	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_menu_focused = false
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_menu_focused = true
	else:
		return
	if _menu_viewport == null:
		return
	_menu_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED\
	if not _menu_focused else SubViewport.UPDATE_ONCE


func _unhandled_input(event: InputEvent) -> void :
	if _notice_overlay != null and is_instance_valid(_notice_overlay):
		if event.is_action_pressed("ui_cancel"):
			_close_leave_notice()
			get_viewport().set_input_as_handled()
		return
	if _stats_overlay != null and is_instance_valid(_stats_overlay):
		if event.is_action_pressed("ui_cancel"):
			_close_rating_stats()
			get_viewport().set_input_as_handled()
		return
	if _confirm_overlay != null and is_instance_valid(_confirm_overlay):
		if event.is_action_pressed("ui_cancel"):
			_close_rating_reset_confirm()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		if Settings.mobile_editor_open:

			get_viewport().set_input_as_handled()
			return
		if Settings.hud_editor_open:

			get_viewport().set_input_as_handled()
			return
		if _page != "":
			_close_page()
			get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void :
	if _rebind_action == "":
		return
	if event is InputEventKey:
		var key_event: = event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		if key_event.keycode == KEY_ESCAPE:
			_cancel_rebind()
		else:
			_finish_rebind(key_event.physical_keycode)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_event: = event as InputEventMouseButton
		if not mouse_event.pressed:
			return

		_finish_rebind( - int(mouse_event.button_index))
		get_viewport().set_input_as_handled()


func _on_settings_changed() -> void :
	_refresh_header()
	_refresh_menu_knife()
	if Settings.hud_accent != _theme_accent:
		_theme_accent = Settings.hud_accent
		theme = UITheme.make_menu_theme()
	if _menu_rim != null:
		_menu_rim.light_color = UITheme.GOLD
	if _menu_glow != null:
		_menu_glow.material_override = _glow_material(UITheme.GOLD, 0.18)
	if _page == "inventory":
		_refresh_inventory_state()



func _on_node_added(node: Node) -> void :
	if node is BaseButton and _ui != null and _ui.is_ancestor_of(node):
		var button: = node as BaseButton
		var action: = Callable(Sfx, "play_click")
		if not button.pressed.is_connected(action):
			button.pressed.connect(action)


func _refresh_header() -> void :
	if _nickname_label != null:
		_nickname_label.text = Settings.nickname.to_upper()
	if _rating_label != null:
		_rating_label.text = "LVL %d · %s · %d ELO" % [
			Settings.rating_level(), Settings.rating_level_name(), Settings.rating_elo
		]
	if _loadout_label != null:
		_loadout_label.text = Settings.get_equipped_label()
	if _map_label != null:
		_map_label.text = str(MapData.get_map(Settings.map_id)["name"])
	if _stats_label != null:
		var accuracy: = 0.0
		if Settings.total_shots > 0:
			accuracy = float(Settings.total_hits) / float(Settings.total_shots) * 100.0
		_stats_label.text = "УБИЙСТВ %d   ·   ХЕДШОТОВ %d   ·   ТОЧНОСТЬ %.1f%%\nЛУЧШАЯ СКОРОСТЬ %.1f" % [
			Settings.total_kills, Settings.total_headshots, accuracy, Settings.best_speed
		]








func _build_gold_background() -> void :
	var gradient: = Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.46, 1.0])
	gradient.colors = PackedColorArray([
		Color(0.055, 0.062, 0.078, 1.0), 
		Color(0.043, 0.05, 0.064, 1.0), 
		Color(0.032, 0.037, 0.047, 1.0), 
	])
	var texture: = GradientTexture2D.new()
	texture.width = 512
	texture.height = 512
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2(1.0, 0.0)
	texture.fill_to = Vector2(0.0, 1.0)
	var background: = TextureRect.new()
	background.name = "GoldBackground"
	background.texture = texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 1)

	var stage_texture: = GradientTexture2D.new()
	var stage: = Gradient.new()
	stage.offsets = PackedFloat32Array([0.0, 0.58, 1.0])
	stage.colors = PackedColorArray([
		Color(0.02, 0.024, 0.032, 0.74), 
		Color(0.02, 0.024, 0.032, 0.3), 
		Color(0.02, 0.024, 0.032, 0.0), 
	])
	stage_texture.width = 512
	stage_texture.height = 512
	stage_texture.gradient = stage
	stage_texture.fill = GradientTexture2D.FILL_RADIAL
	stage_texture.fill_from = Vector2(0.5, 0.5)
	stage_texture.fill_to = Vector2(1.0, 0.5)
	var stage_rect: = TextureRect.new()
	stage_rect.name = "GoldStage"
	stage_rect.texture = stage_texture
	stage_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stage_rect.stretch_mode = TextureRect.STRETCH_SCALE
	stage_rect.set_anchors_preset(Control.PRESET_CENTER)
	stage_rect.offset_left = -400.0
	stage_rect.offset_top = -450.0
	stage_rect.offset_right = 540.0
	stage_rect.offset_bottom = 450.0
	stage_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage_rect)
	move_child(stage_rect, 2)


func _build_background_3d() -> void :
	var container: = SubViewportContainer.new()
	container.name = "Menu3D"


	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(container)
	move_child(container, 3)

	var viewport: = SubViewport.new()
	viewport.size = Vector2i(1440, 860)
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.msaa_3d = Viewport.MSAA_2X
	container.add_child(viewport)
	_menu_viewport = viewport

	var environment: = Environment.new()

	environment.background_mode = Environment.BG_SKY
	var sky_mat: = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.36, 0.6, 0.94, 1.0)
	sky_mat.sky_horizon_color = Color(0.85, 0.92, 1.0, 1.0)
	sky_mat.sky_curve = 0.16
	sky_mat.ground_horizon_color = Color(0.55, 0.75, 0.55, 1.0)
	sky_mat.ground_bottom_color = Color(0.25, 0.5, 0.3, 1.0)
	var sky: = Sky.new()
	sky.sky_material = sky_mat
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR


	environment.ambient_light_color = Color(0.8, 0.86, 1.0, 1.0)
	environment.ambient_light_energy = 0.55
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world: = WorldEnvironment.new()
	world.environment = environment
	viewport.add_child(world)

	var camera: = Camera3D.new()
	camera.fov = 30.0
	camera.position = Vector3(0.0, 0.5, 5.8)
	viewport.add_child(camera)
	_menu_camera = camera
	camera.look_at(Vector3(1.0, -0.1, 0.0), Vector3.UP)

	var key: = DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-28.0, -42.0, 0.0)

	key.light_color = Color(0.97, 0.98, 1.0, 1.0)
	key.light_energy = 2.15
	viewport.add_child(key)

	var rim: = OmniLight3D.new()
	rim.position = Vector3(0.35, 0.3, 0.75)
	rim.light_color = UITheme.GOLD
	rim.light_energy = 2.6
	rim.omni_range = 4.0
	rim.shadow_enabled = false
	viewport.add_child(rim)
	_menu_rim = rim

	var fill: = OmniLight3D.new()
	fill.position = Vector3(-0.65, -0.2, 0.9)
	fill.light_color = Color(1.0, 0.52, 0.18, 1.0)
	fill.light_energy = 0.55
	fill.omni_range = 3.4
	fill.shadow_enabled = false
	viewport.add_child(fill)

	var pivot: = Node3D.new()
	pivot.name = "MenuHeroPivot"
	pivot.position = Vector3(-0.34, -0.44, 0.0)
	viewport.add_child(pivot)
	_menu_knife_pivot = pivot

	var holder: = Node3D.new()
	pivot.add_child(holder)
	_menu_knife_holder = holder
	_build_menu_lego_stage(viewport)
	_refresh_menu_knife()



	var glow: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(2.2, 2.2)
	glow.mesh = quad
	glow.position = Vector3(-0.3, -0.05, -2.2)
	glow.material_override = _glow_material(UITheme.GOLD, 0.18)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	viewport.add_child(glow)
	_menu_glow = glow



# Лего-подиум под героем меню: базовая пластина с шипами и цветные кирпичи.
func _build_menu_lego_stage(viewport: SubViewport) -> void :
	var parts: Array = []

	# зелёная базовая пластина
	var plate: = MeshInstance3D.new()
	plate.mesh = MeshKit.box_mesh(Vector3(15.0, 0.24, 11.0))
	plate.material_override = MeshKit.material(Color(0.24, 0.55, 0.28, 1.0), 
		0.4, 0.0)
	plate.position = Vector3(0.0, -0.56, -1.2)
	plate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	viewport.add_child(plate)

	# шипы на пластине (лего-стад)
	var stud_mat: = MeshKit.material(Color(0.28, 0.6, 0.32, 1.0), 0.4, 0.0)
	for cx in 16:
		for rz in 12:
			var pos: = Vector3(
				-7.2 + float(cx) * 0.96, 
				-0.38, 
				-6.6 + float(rz) * 0.96)
			parts.append([MeshKit.box_mesh(Vector3(0.4, 0.12, 0.4)), 
				Transform3D(Basis(), pos)])
	if not parts.is_empty():
		var studs: = MeshInstance3D.new()
		studs.mesh = MeshKit.merged_boxes(parts)
		studs.material_override = stud_mat
		studs.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		viewport.add_child(studs)

	# белая башня и цветные кирпичи вокруг
	var tower_mat: = MeshKit.material(Color(0.92, 0.93, 0.95, 1.0), 0.4, 0.0)
	var red_mat: = MeshKit.material(Color(0.9, 0.22, 0.18, 1.0), 0.4, 0.0)
	var yellow_mat: = MeshKit.material(Color(0.95, 0.72, 0.1, 1.0), 0.4, 0.0)
	var blue_mat: = MeshKit.material(Color(0.15, 0.55, 0.95, 1.0), 0.4, 0.0)
	var bricks: = [
		[Vector3(-6.4, 0.35, -5.4), Vector3(2.4, 2.2, 1.8), tower_mat], 
		[Vector3(-6.4, 1.5, -5.4), Vector3(1.8, 0.7, 1.4), red_mat], 
		[Vector3(7.6, 0.3, -6.2), Vector3(2.8, 1.1, 1.6), yellow_mat], 
		[Vector3(9.0, 0.95, -5.8), Vector3(1.4, 0.6, 1.2), blue_mat], 
		[Vector3(-7.6, 0.25, -2.4), Vector3(1.6, 0.9, 1.6), blue_mat], 
		[Vector3(8.2, 0.25, -2.0), Vector3(1.8, 0.9, 1.4), red_mat], 
		[Vector3(-9.6, 0.2, -6.6), Vector3(1.8, 0.8, 1.8), yellow_mat], 
		[Vector3(10.0, 0.2, -7.0), Vector3(1.6, 0.8, 1.6), blue_mat], 
	]
	for spec in bricks:
		var block: = MeshInstance3D.new()
		var size: Vector3 = spec[1]
		block.mesh = MeshKit.box_mesh(size)
		block.material_override = spec[2]
		block.position = spec[0]
		block.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		viewport.add_child(block)


func _glow_material(color: Color, strength: float) -> ShaderMaterial:
	var mat: = ShaderMaterial.new()
	mat.shader = GLOW_SHADER
	mat.set_shader_parameter("glow_color", color)
	mat.set_shader_parameter("strength", strength)
	return mat




func _refresh_menu_knife() -> void :
	if _menu_knife_holder == null:
		return
	var skin_key: = Settings.player_skin
	if _menu_knife_skin == skin_key and _menu_knife_holder.get_child_count() > 0:
		return
	_menu_knife_skin = skin_key
	for child in _menu_knife_holder.get_children():
		_menu_knife_holder.remove_child(child)
		child.queue_free()
	# Герой меню: экипированный скин игрока (модель скина или манекен).
	var hero: Node3D = null
	var model_path: = PlayerSkinData.model_path(skin_key)
	if not model_path.is_empty() and ResourceLoader.exists(model_path):
		var mesh: Mesh = load(model_path) as Mesh
		if mesh != null:
			PlayerSkinData.brighten_mesh(mesh)
			var body: = MeshInstance3D.new()
			body.mesh = mesh
			hero = Node3D.new()
			hero.add_child(body)
	if hero == null:
		var mannequin_scene: = preload("res://scenes/mannequin.tscn") as PackedScene
		if mannequin_scene == null:
			return
		hero = mannequin_scene.instantiate() as Node3D
	if hero == null:
		return
	hero.rotation.y = PI
	_menu_knife_holder.add_child(hero)
	hero.scale = Vector3.ONE * 0.46
	hero.position = Vector3(0.0, 0.0, 0.0)



func _fit_weapon(root: Node3D, target: float) -> void :
	if root == null:
		return
	var bounds: = _weapon_bounds(root)
	var extent: = maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if extent <= 0.0001:
		return
	var factor: = target / extent
	root.scale = Vector3.ONE * factor
	root.position = - bounds.get_center() * factor



func _weapon_bounds(root: Node3D) -> AABB:
	var bounds: = AABB()
	var found: = false
	var to_local: = root.global_transform.affine_inverse()
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
			var mesh_instance: = node as MeshInstance3D
			var box: = to_local * mesh_instance.global_transform * mesh_instance.mesh.get_aabb()
			bounds = bounds.merge(box) if found else box
			found = true
		for child in node.get_children():
			stack.append(child)
	return bounds




func _build_ui() -> void :
	_ui = Control.new()
	_ui.name = "Root"
	_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UILayer.add_child(_ui)

	_build_header()
	_build_menu()
	_build_info_panel()
	_build_footer()
	_build_toast()


var _top_bar: Control
var _side_strip: PanelContainer


func _build_header() -> void :
	var bar: = Control.new()
	bar.name = "TopBar"
	bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bar.offset_bottom = 68.0
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(bar)
	_top_bar = bar

	var bg: = ColorRect.new()
	bg.color = Color(0.028, 0.033, 0.042, 0.0)
	bg.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bg.offset_bottom = 60.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(bg)

	var row: = HBoxContainer.new()
	row.anchor_bottom = 1.0
	row.offset_left = 14.0
	row.offset_right = -80.0
	row.offset_bottom = 60.0
	row.add_theme_constant_override("separation", 10)
	bar.add_child(row)

	var brand: = _label("HEADSHOT", &"DisplayLabel", 22, UITheme.GOLD_BRIGHT)
	brand.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(brand)

	row.add_child(_spacer(6))

	for spec in [["МЕНЮ", "home"], ["НАСТРОЙКИ", "settings"], ["ВЫХОД", "quit"]]:
		var icon: = Button.new()
		icon.text = str(spec[0])
		icon.flat = true
		icon.theme_type_variation = &"SmallButton"
		_strip_button_background(icon)
		icon.custom_minimum_size = Vector2(0, 40)
		icon.add_theme_font_size_override("font_size", 13)
		var action: String = str(spec[1])
		if action == "home":
			icon.pressed.connect( func() -> void : _close_page())
		elif action == "settings":
			icon.pressed.connect( func() -> void : _open_page("settings"))
		else:
			icon.pressed.connect( func() -> void : _quit_game())
		row.add_child(icon)

	row.add_child(_expander())

	var nav: = HBoxContainer.new()
	nav.add_theme_constant_override("separation", 6)
	row.add_child(nav)
	for entry in [["inventory", "ИНВЕНТАРЬ"], ["play", "ИГРАТЬ"], ["maps", "КАРТЫ"]]:
		var tab: = Button.new()
		tab.text = str(entry[1])
		tab.flat = true
		tab.theme_type_variation = &"SmallButton"
		_strip_button_background(tab)
		tab.custom_minimum_size = Vector2(160, 62)
		tab.add_theme_font_size_override("font_size", 19)
		var page: String = str(entry[0])
		tab.pressed.connect( func() -> void : _open_page(page))
		nav.add_child(tab)

	row.add_child(_expander())

	_build_side_strip()


func _strip_button_background(button: Button) -> void :
	# прозрачные кнопки меню: без подложки, только текст
	for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())


func _build_side_strip() -> void :
	var strip: = PanelContainer.new()
	strip.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	strip.offset_left = -62.0
	strip.offset_top = 60.0
	strip.add_theme_stylebox_override("panel", _flat_box(
		Color(0.028, 0.033, 0.042, 0.0), Color(1.0, 1.0, 1.0, 0.0), 0, 0, 0.0))
	_ui.add_child(strip)
	_side_strip = strip

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	strip.add_child(column)

	var profile: = Button.new()
	profile.icon = load("res://assets/brand/ui_profile.png")
	profile.expand_icon = true
	profile.custom_minimum_size = Vector2(48, 48)
	profile.tooltip_text = "ПРОФИЛЬ"
	profile.pressed.connect( func() -> void : _open_page("settings"))
	var profile_center: = CenterContainer.new()
	profile_center.add_child(profile)
	column.add_child(profile_center)

	var rating_b: = Button.new()
	rating_b.icon = load("res://assets/brand/ui_rank.png")
	rating_b.expand_icon = true
	rating_b.custom_minimum_size = Vector2(48, 48)
	rating_b.tooltip_text = "РЕЙТИНГ"
	rating_b.pressed.connect( func() -> void : _open_page("rating"))
	var rating_center: = CenterContainer.new()
	rating_center.add_child(rating_b)
	column.add_child(rating_center)

	column.add_child(_expander())

func _build_menu() -> void :
	var column: = VBoxContainer.new()
	column.visible = false
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(column)
	_menu_column = column


func _build_online_counter() -> void :
	_online_counter = OnlineCounter.new()
	add_child(_online_counter)
	_online_counter.updated.connect(_on_online_updated)
	_on_online_updated(_online_counter.current_count())


func _on_online_updated(count: int) -> void :
	if _online_count_label == null:
		return
	_online_count_label.text = _format_number(count)
	if _online_players_label != null:
		_online_players_label.text = "%s ОНЛАЙН" % _players_word(count)


func _players_word(count: int) -> String:
	var mod100: = count % 100
	var mod10: = count % 10
	if mod100 >= 11 and mod100 <= 14:
		return "ИГРОКОВ"
	if mod10 == 1:
		return "ИГРОК"
	if mod10 >= 2 and mod10 <= 4:
		return "ИГРОКА"
	return "ИГРОКОВ"


func _quit_game() -> void :
	Settings.save_settings()
	get_tree().quit()


func _build_info_panel() -> void :
	var panel: = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -446.0
	panel.offset_top = 168.0
	panel.offset_right = -74.0
	# Высоту не фиксируем: PanelContainer сам растянется по содержимому,
	# и панель больше не наезжает на ВЫХОД, версию и статистику.
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _flat_box(
		Color(0.07, 0.082, 0.1, 0.92), UITheme.MENU_BORDER_LIGHT, 1, 10, 22.0))
	_ui.add_child(panel)
	_info_panel = panel

	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(content)

	content.add_child(_label("ЭКИПИРОВАНО", &"KickerLabel", 10, UITheme.MENU_MUTED))

	_loadout_label = _label("AWP | CLASSIC", &"DisplayMedium", 19, UITheme.MENU_TEXT)
	_loadout_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_loadout_label)

	content.add_child(_spacer(2))
	content.add_child(_label("КАРТА", &"KickerLabel", 10, UITheme.MENU_MUTED))
	_map_label = _label("БЛОКИ 6.6", &"DisplayMedium", 17, UITheme.GOLD_BRIGHT)
	content.add_child(_map_label)

	content.add_child(HSeparator.new())

	content.add_child(_label("СТАТИСТИКА", &"KickerLabel", 10, UITheme.MENU_MUTED))

	_stats_label = _label("", &"Label", 13, UITheme.MENU_TEXT)
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_stats_label)

	content.add_child(_spacer(4))

	content.add_child(_label(
		"SPACE — баннихоп  ·  A/D в воздухе — стрейф  ·  рампы дают slide boost\n1 — оружие  ·  2 — пистолет  ·  3 — нож  ·  F — осмотр  ·  TAB — табло", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))


func _build_footer() -> void :
	var build: = _label("BETA v0.2.1", &"KickerLabel", 10, Color(0.24, 0.27, 0.32, 0.72))
	build.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	build.offset_left = -248.0
	build.offset_top = -44.0
	build.offset_right = -48.0
	build.offset_bottom = -22.0
	build.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	build.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(build)




	var quit: = Button.new()
	quit.name = "QuitButton"
	quit.text = "ВЫХОД"
	quit.theme_type_variation = &"SmallButton"
	quit.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	quit.offset_left = -188.0
	quit.offset_top = -98.0
	quit.offset_right = -48.0
	quit.offset_bottom = -54.0
	quit.add_theme_font_size_override("font_size", 14)
	quit.pressed.connect(_quit_game)
	_ui.add_child(quit)


func _build_toast() -> void :
	_toast_label = _label("", &"Label", 14, UITheme.GOLD_BRIGHT)
	_toast_label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.0, 0.9))
	_toast_label.add_theme_constant_override("outline_size", 4)
	_toast_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_toast_label.offset_left = -320.0
	_toast_label.offset_top = -92.0
	_toast_label.offset_right = 320.0
	_toast_label.offset_bottom = -62.0
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_label.modulate.a = 0.0
	_ui.add_child(_toast_label)


func _toast(text: String) -> void :
	if _toast_tween != null and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_label.text = text
	_toast_label.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(1.5)
	_toast_tween.tween_property(_toast_label, "modulate:a", 0.0, 0.4)


func _start_game() -> void :
	if _transitioning:
		return
	_transitioning = true
	Settings.save_settings()
	_fade.visible = true
	var tween: = create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, 0.22)
	await tween.finished
	get_tree().change_scene_to_file(GAME_SCENE)


func _start_bomb() -> void :
	if _transitioning:
		return
	_transitioning = true
	Settings.save_settings()
	_fade.visible = true
	var tween: = create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, 0.22)
	await tween.finished
	get_tree().change_scene_to_file(BOMB_SCENE)


func _start_duel() -> void :
	if _transitioning:
		return
	_transitioning = true
	_mm_searching = false
	_mm_token += 1
	if _mm_overlay != null:
		_mm_overlay.visible = false
	Settings.save_settings()
	_fade.visible = true
	var tween: = create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, 0.22)
	await tween.finished
	get_tree().change_scene_to_file(DUEL_SCENE)




func _animate_in() -> void :
	_fade.modulate.a = 1.0
	var tween: = create_tween()
	tween.tween_property(_fade, "modulate:a", 0.0, 0.28)
	tween.tween_callback( func() -> void : _fade.visible = false)




func _build_page() -> void :
	_page_root = Control.new()
	_page_root.name = "PageRoot"
	_page_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_page_root.visible = false
	_ui.add_child(_page_root)
	if _top_bar != null:
		_ui.move_child(_top_bar, _ui.get_child_count() - 1)
	if _side_strip != null:
		_ui.move_child(_side_strip, _ui.get_child_count() - 1)



	_page_fade = ColorRect.new()
	_page_fade.name = "PageFade"
	_page_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_page_fade.color = Color(0.004, 0.005, 0.006, 1.0)
	_page_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	_page_fade.visible = false
	_ui.add_child(_page_fade)

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


	dim.color = Color(0.055, 0.03, 0.004, 0.82)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.gui_input.connect( func(event: InputEvent) -> void :
		if event is InputEventMouseButton and event.pressed:
			_close_page())
	_page_root.add_child(dim)
	_page_dim = dim

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page_root.add_child(center)

	_page_sheet = PanelContainer.new()
	_page_sheet.custom_minimum_size = Vector2(1000, 640)
	_page_sheet.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_page_sheet.add_theme_stylebox_override("panel", _flat_box(
		Color(0.05, 0.058, 0.072, 0.985), UITheme.MENU_BORDER_LIGHT, 1, 12, 0.0))
	center.add_child(_page_sheet)

	var margin: = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_page_sheet.add_child(margin)

	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	var header: = HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	content.add_child(header)

	_page_title = _label("", &"DisplayLabel", 26, UITheme.MENU_TEXT)
	_page_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_page_title)

	var close: = Button.new()
	close.text = "ЗАКРЫТЬ"
	close.theme_type_variation = &"SmallButton"
	close.custom_minimum_size = Vector2(96, 32)
	close.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	close.pressed.connect(_close_page)
	header.add_child(close)
	_page_close = close

	content.add_child(HSeparator.new())

	_settings_tab_bar = HBoxContainer.new()
	_settings_tab_bar.add_theme_constant_override("separation", 6)
	_settings_tab_bar.visible = false
	content.add_child(_settings_tab_bar)

	_settings_tab_hint = _label("", &"KickerLabel", 13, UITheme.MENU_MUTED)
	_settings_tab_hint.add_theme_font_override("font", UITheme.ui_font(700))
	_settings_tab_hint.visible = false
	content.add_child(_settings_tab_hint)

	var scroll: = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED



	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	content.add_child(scroll)

	var body_margin: = MarginContainer.new()
	body_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_margin.add_theme_constant_override("margin_right", 16)
	scroll.add_child(body_margin)

	_page_body = VBoxContainer.new()
	_page_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_body.add_theme_constant_override("separation", 6)
	body_margin.add_child(_page_body)



	var footer_rule: = ColorRect.new()
	footer_rule.custom_minimum_size = Vector2(0, 1)
	footer_rule.color = Color(1.0, 1.0, 1.0, 0.08)
	footer_rule.visible = false
	content.add_child(footer_rule)
	_page_footer_rule = footer_rule

	_page_footer = HBoxContainer.new()
	_page_footer.add_theme_constant_override("separation", 12)
	_page_footer.visible = false
	content.add_child(_page_footer)


func _build_matchmaking_overlay() -> void :
	_mm_overlay = Control.new()
	_mm_overlay.name = "Matchmaking"
	_mm_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mm_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_mm_overlay.visible = false
	_ui.add_child(_mm_overlay)

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.014, 0.006, 0.86)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_mm_overlay.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mm_overlay.add_child(center)

	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(500.0, 0.0)
	panel.add_theme_stylebox_override("panel", _flat_box(
		Color(0.05, 0.058, 0.072, 0.99), UITheme.MENU_BORDER_LIGHT, 1, 12, 30.0))
	center.add_child(panel)

	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)

	content.add_child(_label("РЕЙТИНГОВЫЙ МАТЧ 1×1", &"KickerLabel", 10, 
		UITheme.MENU_MUTED))

	_mm_status = _label("ПОИСК СОПЕРНИКА", &"DisplayLabel", 30, 
		UITheme.GOLD_BRIGHT)
	_mm_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_mm_status)

	_mm_details = _label("ПОДБИРАЕМ СОПЕРНИКА ПО ВАШЕМУ ELO", &"Label", 13, 
		UITheme.MENU_TEXT)
	_mm_details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mm_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_mm_details)

	_mm_timer_label = _label("0.0 С", &"DisplayMedium", 20, UITheme.MENU_TEXT)
	_mm_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_mm_timer_label)

	content.add_child(HSeparator.new())

	_mm_cancel = Button.new()
	_mm_cancel.text = "ОТМЕНИТЬ ПОИСК"
	_mm_cancel.theme_type_variation = &"SmallButton"
	_mm_cancel.custom_minimum_size = Vector2(220.0, 42.0)
	_mm_cancel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_mm_cancel.pressed.connect(_cancel_matchmaking)
	content.add_child(_mm_cancel)




func _start_matchmaking() -> void :
	if _transitioning or _mm_searching:
		return
	_mm_token += 1
	_mm_searching = true
	_mm_elapsed = 0.0
	_mm_duration = randf_range(2.4, 4.2)
	_mm_status.text = "ПОИСК СОПЕРНИКА"
	_mm_status.add_theme_color_override("font_color", UITheme.GOLD_BRIGHT)
	_mm_details.text = "ВАШ РЕЙТИНГ: %d ELO   ·   LVL %d   ·   ИЩЕМ СОПЕРНИКА" % [
		int(Settings.rating_elo), Settings.rating_level()
	]
	_mm_timer_label.text = "0.0 С"
	_mm_cancel.visible = true
	_mm_cancel.disabled = false
	_mm_overlay.visible = true
	_mm_overlay.modulate.a = 0.0
	var tween: = create_tween()
	tween.tween_property(_mm_overlay, "modulate:a", 1.0, 0.16)
	_mm_cancel.grab_focus()


func _show_match_found() -> void :
	if not _mm_searching:
		return
	_mm_searching = false
	var token: = _mm_token



	var rival: Dictionary = Settings.pick_duel_rival()
	var rival_elo: = int(rival["elo"])
	var rival_name: = str(rival["name"])
	var level: = int(rival["level"])
	var gap: = rival_elo - int(Settings.rating_elo)
	var gap_text: = ("+%d" % gap) if gap >= 0 else str(gap)
	_mm_status.text = "СОПЕРНИК НАЙДЕН"
	_mm_status.add_theme_color_override("font_color", Color(0.42, 1.0, 0.56, 1.0))
	_mm_details.text = "%s   ·   LVL %d   ·   %d ELO (%s)\nВАШ РЕЙТИНГ %d ELO   ·   МАТЧ ДО 5 ПОБЕД" % [
		rival_name, level, rival_elo, gap_text, int(Settings.rating_elo)
	]
	_mm_timer_label.text = "ПОДКЛЮЧЕНИЕ К МАТЧУ"
	_mm_cancel.visible = false
	await get_tree().create_timer(1.35, false).timeout
	if token != _mm_token or not is_inside_tree():
		return
	_start_duel()


func _cancel_matchmaking() -> void :
	_mm_token += 1
	_mm_searching = false
	if _mm_overlay != null:
		_mm_overlay.visible = false
	_mm_status.add_theme_color_override("font_color", UITheme.GOLD_BRIGHT)


func _open_page(name: String) -> void :
	if _page_transitioning:
		return
	if _page == name:
		_close_page()
		return
	if name == "rating":
		_open_rating_page()
		return
	_apply_page_style(false)
	_page = name
	_page_root.visible = true
	_page_root.modulate.a = 0.0
	var tween: = create_tween()
	tween.tween_property(_page_root, "modulate:a", 1.0, 0.15)
	_sync_home_visibility()
	_render_page()




func _open_rating_page() -> void :
	_page_transitioning = true
	_page_fade.visible = true
	_page_fade.modulate.a = 0.0
	var tween: = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(_page_fade, "modulate:a", 1.0, 0.18)
	await tween.finished
	_page = "rating"
	_apply_page_style(true)
	_page_root.visible = true
	_page_root.modulate.a = 1.0
	_sync_home_visibility()
	_render_page()
	await get_tree().create_timer(0.1).timeout
	if not is_inside_tree():
		return
	var reveal: = create_tween()
	reveal.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	reveal.tween_property(_page_fade, "modulate:a", 0.0, 0.34)
	await reveal.finished
	_page_fade.visible = false
	_page_transitioning = false




func _apply_page_style(rating: bool) -> void :
	if _page_sheet == null:
		return
	if rating:



		_page_sheet.custom_minimum_size = Vector2(1080, 560)
		_page_sheet.add_theme_stylebox_override("panel", _flat_box(
			Color(0.01, 0.011, 0.014, 0.995), Color(1.0, 1.0, 1.0, 0.1), 
			1, 4, 0.0))
		if _page_dim != null:
			_page_dim.color = Color(0.002, 0.003, 0.004, 0.997)
		_page_title.add_theme_color_override("font_color", 
			Color(0.965, 0.96, 0.945, 1.0))
	else:
		_page_sheet.custom_minimum_size = Vector2(1000, 640)
		_page_sheet.add_theme_stylebox_override("panel", _flat_box(
			Color(0.05, 0.058, 0.072, 0.985), UITheme.MENU_BORDER_LIGHT, 
			1, 12, 0.0))
		if _page_dim != null:
			_page_dim.color = Color(0.055, 0.03, 0.004, 0.82)
		_page_title.add_theme_color_override("font_color", UITheme.MENU_TEXT)
	_style_rating_close(rating)




func _style_rating_close(rating: bool) -> void :
	if _page_close == null:
		return
	if rating:
		_page_close.add_theme_color_override("font_color", 
			Color(0.8, 0.84, 0.86, 1.0))
		_page_close.add_theme_color_override("font_hover_color", 
			RATING_MINT)
		_page_close.add_theme_color_override("font_pressed_color", 
			Color(0.02, 0.06, 0.05, 1.0))
		_page_close.add_theme_stylebox_override("normal", _rating_pill(
			Color(1.0, 1.0, 1.0, 0.035), Color(1.0, 1.0, 1.0, 0.14), 1))
		_page_close.add_theme_stylebox_override("hover", _rating_pill(
			Color(RATING_MINT.r, RATING_MINT.g, RATING_MINT.b, 0.14), 
			RATING_MINT, 1))
		_page_close.add_theme_stylebox_override("pressed", _rating_pill(
			RATING_MINT, RATING_MINT, 1))
	else:
		for key in ["normal", "hover", "pressed"]:
			_page_close.remove_theme_stylebox_override(key)
		for key in ["font_color", "font_hover_color", "font_pressed_color"]:
			_page_close.remove_theme_color_override(key)


func _close_page() -> void :
	_close_rating_stats()
	_close_rating_reset_confirm()
	_page = ""
	_page_root.visible = false
	_apply_page_style(false)
	_rebind_action = ""
	_rebind_button = null
	if _mm_searching:
		_cancel_matchmaking()
	_sync_home_visibility()




func _sync_home_visibility() -> void :
	var home: = _page == ""
	if _menu_column != null:
		_menu_column.visible = home
	if _info_panel != null:
		_info_panel.visible = home


func _render_page() -> void :
	for child in _page_body.get_children():
		_page_body.remove_child(child)
		child.queue_free()
	if _page_footer != null:
		for child in _page_footer.get_children():
			_page_footer.remove_child(child)
			child.queue_free()
		_page_footer.visible = false
	if _page_footer_rule != null:
		_page_footer_rule.visible = false
	_bind_buttons.clear()
	_equip_button = null
	_inventory_status = null

	match _page:
		"play":
			_page_title.text = "ВЫБОР РЕЖИМА"
			_render_play()
		"maps":
			_page_title.text = "ВЫБОР КАРТЫ"
			_render_maps()
		"rating":
			_page_title.text = "РЕЙТИНГ"
			_render_rating()
		"inventory":
			_page_title.text = "ИНВЕНТАРЬ"
			_render_inventory()
		"settings":
			_page_title.text = "НАСТРОЙКИ"
			_render_settings()
		_:
			_page_title.text = ""
	_page_root.visible = _page != ""

	var settings_open: = _page == "settings"
	if _settings_tab_bar != null:
		_settings_tab_bar.visible = settings_open
	if _settings_tab_hint != null:
		_settings_tab_hint.visible = settings_open






func _render_play() -> void :
	_page_body.add_child(_label(
		"Свободная тренировка не меняет рейтинг. Рейтинговая дуэль — "
			+ "матч 1×1 со случайным оружием и картой.", 
		&"Label", 12, UITheme.MENU_MUTED))

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page_body.add_child(row)

	row.add_child(_freeplay_card())
	row.add_child(_bomb_card())
	row.add_child(_bomb_card())

	_page_body.add_child(_spacer(2))
	_page_body.add_child(_label(
		"Рейтинг: ИГРАТЬ → РЕЙТИНГ — случайная карта и оружие на матч.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))


func _freeplay_card() -> Button:
	var selected_map: = _current_map_entry()
	var map_name: = str(selected_map.get("name", "ТРЕНИРОВОЧНАЯ"))

	var card: = _mode_card(false)
	card.pressed.connect( func() -> void : _open_page("maps"))

	var column: = _mode_card_column(card)

	var preview: = TextureRect.new()
	preview.custom_minimum_size = Vector2(0, 186)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var preview_path: = str(selected_map.get("preview", ""))
	if not preview_path.is_empty() and ResourceLoader.exists(preview_path):
		preview.texture = load(preview_path)
	column.add_child(preview)

	var title_row: = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title_row)

	var title: = _label("СВОБОДНАЯ ИГРА", &"DisplayLabel", 21, UITheme.MENU_TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.clip_text = true
	title_row.add_child(title)
	title_row.add_child(_mode_chip("ТРЕНИРОВКА", UITheme.MENU_MUTED, 
		UITheme.MENU_BORDER))

	column.add_child(_label("БОЛЬШАЯ КАРТА  ·  БЕЗ ТАЙМЕРА", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))

	var desc: = _label(
		"Спокойный вход: выберите площадку, разомнитесь и играйте без "
			+ "таймера, счёта и давления рейтинга. Сейчас выбрана «%s»."
			%map_name, 
		&"Label", 12, UITheme.MENU_TEXT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0, 72)
	desc.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	column.add_child(desc)

	var tags: = HBoxContainer.new()
	tags.add_theme_constant_override("separation", 6)
	tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(tags)
	tags.add_child(_mode_chip("СВОБОДНЫЙ ВЫБОР", UITheme.MENU_MUTED, 
		UITheme.MENU_BORDER))
	tags.add_child(_mode_chip("ТРЕНИРОВКА", UITheme.MENU_MUTED, 
		UITheme.MENU_BORDER))

	column.add_child(_spacer(0, true))
	column.add_child(_mode_action("ВЫБРАТЬ КАРТУ  →", UITheme.MENU_MUTED))
	return card


func _bomb_card() -> Button:
	var card: = _mode_card(false)
	card.pressed.connect( func() -> void : _start_bomb())
	var column: = _mode_card_column(card)

	var preview: = TextureRect.new()
	preview.custom_minimum_size = Vector2(0, 186)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var preview_path: = "res://tools/view_dust2_ground.png"
	if ResourceLoader.exists(preview_path):
		preview.texture = load(preview_path)
	column.add_child(preview)

	var title_row: = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title_row)
	var title: = _label("ЗАКЛАДКА БОМБЫ", &"DisplayLabel", 21, UITheme.MENU_TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.clip_text = true
	title_row.add_child(title)
	title_row.add_child(_mode_chip("DE_DUST2", UITheme.GOLD, UITheme.MENU_BORDER))

	column.add_child(_label("T ПРОТИВ 3 CT  ·  40 СЕК", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))

	var desc: = _label(
		"Ты — террорист с бомбой. Дойди до сайта A или B, удерживай E три "
			+ "секунды и не дай ботам разминировать. До трёх побед в раундах.", 
		&"Label", 12, UITheme.MENU_TEXT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0, 72)
	desc.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	column.add_child(desc)

	var tags: = HBoxContainer.new()
	tags.add_theme_constant_override("separation", 6)
	tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(tags)
	tags.add_child(_mode_chip("БОМБА", UITheme.GOLD, UITheme.MENU_BORDER))
	tags.add_child(_mode_chip("БОТЫ", UITheme.MENU_MUTED, UITheme.MENU_BORDER))

	column.add_child(_spacer(0, true))
	column.add_child(_mode_action("НАЧАТЬ  →", UITheme.GOLD))
	return card


func _mode_card(highlight: bool) -> Button:
	var card: = Button.new()
	card.text = ""
	card.focus_mode = Control.FOCUS_NONE
	card.custom_minimum_size = Vector2(0, 448)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("normal", _mode_card_box(highlight, false))
	card.add_theme_stylebox_override("hover", _mode_card_box(highlight, true))
	card.add_theme_stylebox_override("pressed", _mode_card_box(highlight, true))
	card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return card


func _mode_card_column(card: Button) -> VBoxContainer:
	var margin: = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(column)
	return column


func _mode_action(text: String, color: Color) -> Label:
	var action: = _label(text, &"KickerLabel", 12, color)
	action.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return action


func _mode_chip(text: String, color: Color, border: Color, 
		fill: = Color(0.15, 0.086, 0.018, 1.0)) -> PanelContainer:
	var chip: = PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box: = _flat_box(fill, border, 1, 4, 6.0)
	box.content_margin_top = 2.0
	box.content_margin_bottom = 2.0
	chip.add_theme_stylebox_override("panel", box)
	var label: = _label(text, &"KickerLabel", 9, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.add_child(label)
	return chip


func _mode_card_box(highlight: bool, hover: bool) -> StyleBoxFlat:
	var bg: = Color(0.128, 0.074, 0.016, 0.99) if hover\
	else Color(0.082, 0.046, 0.01, 0.98)
	var border: = UITheme.GOLD_BRIGHT if highlight or hover\
	else UITheme.MENU_BORDER
	var box: = _flat_box(bg, border, 2 if highlight or hover else 1, 10, 0.0)
	box.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	box.shadow_size = 14 if highlight else 7
	box.shadow_offset = Vector2(0.0, 3.0)
	return box


func _current_map_entry() -> Dictionary:
	for entry in MapData.MAPS:
		if str(entry.get("id", "")) == Settings.map_id:
			return entry
	if not MapData.MAPS.is_empty():
		return MapData.MAPS[0]
	return {}






func _render_maps() -> void :
	_page_body.add_child(_label(
		"Выберите площадку — загрузка начнётся сразу. "
			+ "Выбор сохраняется до следующего запуска.", 
		&"Label", 12, UITheme.MENU_MUTED))

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page_body.add_child(row)

	for entry in MapData.MAPS:
		row.add_child(_map_card(entry))






func _render_rating() -> void :
	var level: int = Settings.rating_level()
	var level_name: String = Settings.rating_level_name()
	var elo: int = Settings.rating_elo
	var bounds: Dictionary = Settings.rating_level_bounds()
	var progress: float = Settings.rating_level_progress()

	var tint: = LevelBadge.color_for(level)

	var kicker: = HBoxContainer.new()
	kicker.add_theme_constant_override("separation", 10)
	_page_body.add_child(kicker)
	kicker.add_child(_label("СЕЗОН · ДУЭЛЬ 1×1", &"KickerLabel", 10, 
		Color(0.48, 0.5, 0.54, 1.0)))
	kicker.add_child(_expander())
	kicker.add_child(_label("МАТЧ ДО 5 ПОБЕД · 100 HP · СВОЁ ОРУЖИЕ", 
		&"KickerLabel", 10, Color(0.4, 0.42, 0.46, 1.0)))

	var hairline: = ColorRect.new()
	hairline.custom_minimum_size = Vector2(0, 1)
	hairline.color = Color(1.0, 1.0, 1.0, 0.08)
	_page_body.add_child(hairline)

	var hero: = HBoxContainer.new()
	hero.add_theme_constant_override("separation", 20)
	_page_body.add_child(hero)



	var badge_shift: = Control.new()
	badge_shift.custom_minimum_size = Vector2(10.0, 0.0)
	badge_shift.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(badge_shift)

	var badge: = LevelBadge.new()
	badge.custom_minimum_size = Vector2(104, 104)
	badge.level = level
	badge.current = true
	badge.tooltip_text = "LVL %d · %s · %d ELO" % [level, level_name, elo]
	hero.add_child(badge)

	var hero_text: = VBoxContainer.new()
	hero_text.alignment = BoxContainer.ALIGNMENT_CENTER
	hero_text.add_theme_constant_override("separation", -1)
	hero.add_child(hero_text)
	hero_text.add_child(_label("ТЕКУЩИЙ УРОВЕНЬ", &"KickerLabel", 9, 
		Color(0.42, 0.44, 0.48, 1.0)))
	hero_text.add_child(_label("LVL %d · %s" % [level, level_name], 
		&"DisplayLabel", 32, Color(0.96, 0.95, 0.93, 1.0)))
	var next_text: = ""
	if level >= 10:
		next_text = "МАКСИМАЛЬНЫЙ УРОВЕНЬ · ЭЛО РАСТЁТ БЕЗ ПОТОЛКА"
	else:
		var need: = maxi(int(bounds["high"]) - elo, 0)
		next_text = "ДО УРОВНЯ %d — %d ELO · ЦЕЛЬ %d · %d%%" % [
			level + 1, need, int(bounds["high"]), 
			int(round(clampf(progress, 0.0, 1.0) * 100.0))]
	hero_text.add_child(_label(next_text, &"KickerLabel", 9, tint))

	hero.add_child(_expander())

	var elo_box: = VBoxContainer.new()
	elo_box.alignment = BoxContainer.ALIGNMENT_CENTER
	elo_box.add_theme_constant_override("separation", -2)
	hero.add_child(elo_box)
	var elo_caption: = _label("РЕЙТИНГ", &"KickerLabel", 9, 
		Color(0.42, 0.44, 0.48, 1.0))
	elo_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	elo_box.add_child(elo_caption)
	var elo_value: = _label("0", &"DisplayLabel", 64, 
		Color(0.985, 0.975, 0.95, 1.0))
	elo_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	elo_box.add_child(elo_value)
	var elo_suffix: = _label("ELO", &"KickerLabel", 10, 
		Color(0.48, 0.5, 0.54, 1.0))
	elo_suffix.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	elo_box.add_child(elo_suffix)


	var elo_tween: = create_tween()
	elo_tween.tween_interval(0.24)
	elo_tween.tween_method( func(value: float) -> void :
		if is_instance_valid(elo_value):
			elo_value.text = _format_number(int(round(value))), 
		0.0, float(elo), 0.85).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


	var track: = Control.new()
	track.custom_minimum_size = Vector2(0, 8)
	_page_body.add_child(track)
	var track_bg: = ColorRect.new()
	track_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	track_bg.color = Color(1.0, 1.0, 1.0, 0.07)
	track.add_child(track_bg)
	var fill: = ColorRect.new()
	fill.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	fill.anchor_right = 0.0
	fill.offset_right = 0.0
	fill.color = tint
	track.add_child(fill)
	var fill_tween: = create_tween()
	fill_tween.tween_interval(0.24)
	fill_tween.tween_property(fill, "anchor_right", clampf(progress, 0.0, 1.0), 
		0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	var rule: = ColorRect.new()
	rule.custom_minimum_size = Vector2(0, 1)
	rule.color = Color(1.0, 1.0, 1.0, 0.07)
	_page_body.add_child(rule)


	var form_row: = HBoxContainer.new()
	form_row.add_theme_constant_override("separation", 8)
	_page_body.add_child(form_row)
	var form_caption: = _label("ПОСЛЕДНИЕ МАТЧИ", &"KickerLabel", 9, 
		Color(0.42, 0.44, 0.48, 1.0))
	form_caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	form_row.add_child(form_caption)
	form_row.add_child(_recent_form_strip(5))
	form_row.add_child(_expander())
	var form_hint: = _label("ЗЕЛЁНАЯ — ПОБЕДА   ·   КРАСНАЯ — ПОРАЖЕНИЕ", 
		&"KickerLabel", 9, Color(0.36, 0.38, 0.42, 1.0))
	form_hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	form_row.add_child(form_hint)



	_page_footer.visible = true
	_page_footer_rule.visible = true

	var fight: = _rating_button("НАЧАТЬ ПОИСК", Vector2(260, 54), 19)
	_style_rating_action(fight, RATING_MINT, true)
	fight.pressed.connect(_start_matchmaking)
	_page_footer.add_child(fight)

	var training: = _rating_button("ТРЕНИРОВКА", Vector2(162, 54), 14)
	_style_rating_action(training, Color(0.82, 0.86, 0.9, 1.0), false)
	training.pressed.connect( func() -> void : _open_page("maps"))
	_page_footer.add_child(training)



	var stats_button: = _rating_button("СТАТИСТИКА", Vector2(166, 54), 14)
	_style_rating_action(stats_button, RATING_VIOLET, false)
	stats_button.pressed.connect(_open_rating_stats)
	_page_footer.add_child(stats_button)




	_page_body.add_child(_label("УРОВНИ", &"KickerLabel", 9, 
		Color(0.42, 0.44, 0.48, 1.0)))

	var ladder: = HBoxContainer.new()
	ladder.alignment = BoxContainer.ALIGNMENT_CENTER
	ladder.add_theme_constant_override("separation", 16)
	_page_body.add_child(ladder)

	for entry in Settings.RATING_LEVELS:
		var chip_level: = int(entry["level"])
		var column: = VBoxContainer.new()
		column.alignment = BoxContainer.ALIGNMENT_CENTER
		column.add_theme_constant_override("separation", 3)
		ladder.add_child(column)

		var chip: = LevelBadge.new()
		chip.custom_minimum_size = Vector2(54, 54)
		chip.level = chip_level
		chip.current = chip_level == level
		chip.passed = chip_level < level
		chip.tooltip_text = "LVL %d · %s · от %d ELO" % [
			chip_level, str(entry["name"]), int(entry["min"])]
		column.add_child(chip)

		var threshold: = _label(_format_number(int(entry["min"])), 
			&"KickerLabel", 8, tint if chip_level == level
			else Color(0.36, 0.38, 0.42, 1.0))
		threshold.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(threshold)


		chip.modulate.a = 0.0
		chip.scale = Vector2(0.72, 0.72)
		chip.pivot_offset = Vector2(27, 27)
		var pop: = create_tween()
		pop.tween_interval(0.42 + float(chip_level - 1) * 0.035)
		pop.tween_property(chip, "modulate:a", 1.0, 0.18)
		pop.parallel().tween_property(chip, "scale", Vector2.ONE, 0.28)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)



	var rules: = HBoxContainer.new()
	rules.add_theme_constant_override("separation", 10)
	_page_body.add_child(rules)
	rules.add_child(_label("ПОБЕДА +20…+40", &"KickerLabel", 9, 
		Color(0.42, 0.95, 0.55, 1.0)))
	rules.add_child(_label("·", &"KickerLabel", 9, 
		Color(0.32, 0.34, 0.38, 1.0)))
	rules.add_child(_label("СЕРИЯ ДО +8", &"KickerLabel", 9, 
		Color(1.0, 0.85, 0.35, 1.0)))
	rules.add_child(_label("·", &"KickerLabel", 9, 
		Color(0.32, 0.34, 0.38, 1.0)))
	rules.add_child(_label("ПОРАЖЕНИЕ −15…−22", &"KickerLabel", 9, 
		Color(1.0, 0.52, 0.46, 1.0)))
	rules.add_child(_expander())
	rules.add_child(_label("ВЫХОД ИЗ МАТЧА −40 ELO", &"KickerLabel", 9, 
		RATING_ROSE))




func _rating_stat(caption: String, value: String, color: Color) -> PanelContainer:
	var cell: = PanelContainer.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(1.0, 1.0, 1.0, 0.022)
	box.border_color = Color(1.0, 1.0, 1.0, 0.06)
	box.border_width_bottom = 1
	box.content_margin_left = 14.0
	box.content_margin_right = 14.0
	box.content_margin_top = 8.0
	box.content_margin_bottom = 9.0
	cell.add_theme_stylebox_override("panel", box)
	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", -1)
	cell.add_child(column)
	var value_label: = _label(value, &"DisplayMedium", 28, color)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	column.add_child(value_label)
	column.add_child(_label(caption, &"KickerLabel", 8, 
		Color(0.42, 0.44, 0.48, 1.0)))
	return cell


func _recent_form_strip(count: int) -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var recent: Array = Settings.recent_results
	for i in count:
		var letter: = _label("П", &"DisplayMedium", 18, UITheme.MENU_MUTED)
		if i < recent.size():
			letter.add_theme_color_override("font_color", 
				Color(0.42, 1.0, 0.56, 1.0) if bool(recent[i])
				else Color(1.0, 0.32, 0.26, 1.0))
		else:
			letter.modulate.a = 0.28
		letter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(letter)
	return row




func _rating_button(text: String, size: Vector2, font_size: int) -> Button:
	var button: = Button.new()
	button.text = text
	button.custom_minimum_size = size
	button.add_theme_font_size_override("font_size", font_size)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pivot_offset = size * 0.5
	button.resized.connect( func() -> void :
		if is_instance_valid(button):
			button.pivot_offset = button.size * 0.5)
	button.mouse_entered.connect( func() -> void :
		if is_instance_valid(button):
			var tween: = create_tween().bind_node(button)
			tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(button, "scale", Vector2(1.025, 1.025), 0.16))
	button.mouse_exited.connect( func() -> void :
		if is_instance_valid(button):
			var tween: = create_tween().bind_node(button)
			tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(button, "scale", Vector2.ONE, 0.14))
	return button


func _style_rating_action(button: Button, accent: Color, filled: bool, 
		danger: = false) -> void :
	var ink: = Color(0.012, 0.03, 0.026, 1.0) if filled\
	else Color(0.88, 0.92, 0.94, 1.0)
	if danger and not filled:
		ink = Color(1.0, 0.72, 0.75, 1.0)
	var hover_ink: = ink
	var pressed_ink: = ink
	var normal: StyleBoxFlat
	var hover: StyleBoxFlat
	var pressed: StyleBoxFlat
	if filled:
		normal = _rating_pill(accent, accent.lerp(Color.WHITE, 0.35), 1, 
			Color(accent.r, accent.g, accent.b, 0.28))
		hover = _rating_pill(accent.lerp(Color.WHITE, 0.2), 
			Color.WHITE, 1, 
			Color(accent.r, accent.g, accent.b, 0.42))
		pressed = _rating_pill(accent.darkened(0.24), accent, 1)
		hover_ink = ink
		pressed_ink = ink
	else:
		var tint: = accent if not danger else RATING_ROSE
		normal = _rating_pill(Color(1.0, 1.0, 1.0, 0.028), 
			Color(tint.r, tint.g, tint.b, 0.32), 1)
		hover = _rating_pill(Color(tint.r, tint.g, tint.b, 0.14), 
			tint, 1, Color(tint.r, tint.g, tint.b, 0.22))
		pressed = _rating_pill(Color(tint.r, tint.g, tint.b, 0.85), 
			tint, 1)
		hover_ink = tint
		pressed_ink = Color(0.012, 0.03, 0.026, 1.0)
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", hover_ink)
	button.add_theme_color_override("font_pressed_color", pressed_ink)
	button.add_theme_color_override("font_focus_color", hover_ink)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", _rating_pill(
		Color(0.0, 0.0, 0.0, 0.0), Color(accent.r, accent.g, accent.b, 0.8), 1))


func _rating_pill(bg: Color, border: Color, border_width: int, 
		glow: = Color(0.0, 0.0, 0.0, 0.0)) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(18)
	box.content_margin_left = 22.0
	box.content_margin_right = 22.0
	box.content_margin_top = 10.0
	box.content_margin_bottom = 10.0
	box.anti_aliasing = true
	if glow.a > 0.0:
		box.shadow_color = glow
		box.shadow_size = 16
		box.shadow_offset = Vector2(0.0, 3.0)
	return box




func _show_leave_notice(text: String) -> void :
	if text.is_empty():
		return
	if _notice_overlay != null and is_instance_valid(_notice_overlay):
		_notice_overlay.queue_free()
	var overlay: = Control.new()
	overlay.name = "LeavePenaltyNotice"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.modulate.a = 0.0
	_ui.add_child(overlay)
	_notice_overlay = overlay

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.004, 0.003, 0.002, 0.88)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.gui_input.connect( func(event: InputEvent) -> void :
		if event is InputEventMouseButton and event.pressed:
			_close_leave_notice())
	overlay.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 0)
	var box: = _rating_pill(Color(0.026, 0.02, 0.014, 0.99), 
		Color(UITheme.GOLD.r, UITheme.GOLD.g, UITheme.GOLD.b, 0.6), 1, 
		Color(UITheme.GOLD.r, UITheme.GOLD.g, UITheme.GOLD.b, 0.18))
	box.set_corner_radius_all(22)
	box.content_margin_left = 32.0
	box.content_margin_right = 32.0
	box.content_margin_top = 28.0
	box.content_margin_bottom = 26.0
	panel.add_theme_stylebox_override("panel", box)
	center.add_child(panel)
	panel.scale = Vector2(0.94, 0.94)
	panel.pivot_offset = Vector2(280, 120)

	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	content.add_child(_label("РЕЙТИНГОВАЯ ДУЭЛЬ", &"KickerLabel", 10, 
		UITheme.GOLD_BRIGHT))
	var title: = _label("ЭЛО СНЯТО ЗА ВЫХОД", &"DisplayLabel", 27, 
		Color(0.98, 0.96, 0.92, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	var body: = _label(text, &"Label", 13, Color(0.84, 0.82, 0.78, 1.0))
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(body)

	var rating: = _label("СЕЙЧАС: %d ELO · УРОВЕНЬ %d · %s" % [
		int(Settings.rating_elo), Settings.rating_level(), 
		Settings.rating_level_name()], &"KickerLabel", 10, UITheme.MUTED)
	rating.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(rating)

	var row: = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	content.add_child(row)

	var button: = _rating_button("ПОНЯТНО", Vector2(220, 46), 14)
	_style_rating_action(button, UITheme.GOLD, true)
	button.pressed.connect(_close_leave_notice)
	row.add_child(button)

	var tween: = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.18)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.24)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	button.grab_focus()


func _close_leave_notice() -> void :
	if _notice_overlay == null or not is_instance_valid(_notice_overlay):
		return
	var overlay: = _notice_overlay
	_notice_overlay = null
	var tween: = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.14)
	tween.tween_callback( func() -> void :
		if is_instance_valid(overlay):
			overlay.queue_free())




func _open_rating_reset_confirm() -> void :
	if _confirm_overlay != null and is_instance_valid(_confirm_overlay):
		_confirm_overlay.queue_free()
		_confirm_overlay = null
	var overlay: = Control.new()
	overlay.name = "RatingResetConfirm"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.modulate.a = 0.0
	_ui.add_child(overlay)
	_confirm_overlay = overlay

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.002, 0.004, 0.005, 0.9)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.gui_input.connect( func(event: InputEvent) -> void :
		if event is InputEventMouseButton and event.pressed:
			_close_rating_reset_confirm())
	overlay.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 0)
	var box: = _rating_pill(Color(0.018, 0.022, 0.026, 0.99), 
		Color(RATING_ROSE.r, RATING_ROSE.g, RATING_ROSE.b, 0.55), 1, 
		Color(RATING_ROSE.r, RATING_ROSE.g, RATING_ROSE.b, 0.16))
	box.set_corner_radius_all(22)
	box.content_margin_left = 30.0
	box.content_margin_right = 30.0
	box.content_margin_top = 26.0
	box.content_margin_bottom = 26.0
	panel.add_theme_stylebox_override("panel", box)
	center.add_child(panel)
	_confirm_panel = panel
	panel.scale = Vector2(0.94, 0.94)
	panel.pivot_offset = Vector2(270, 120)

	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	content.add_child(_label("СБРОС РЕЙТИНГА", &"KickerLabel", 10, RATING_ROSE))
	var title: = _label("СБРОСИТЬ СТАТИСТИКУ?", &"DisplayLabel", 25, 
		Color(0.97, 0.96, 0.95, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	var warning: = _label(
		"ELO, победы, поражения, серия, матчи и рекорд вернутся к 1000 ELO.\n"
			+ "Это действие нельзя отменить. Продолжить?", 
		&"Label", 13, Color(0.78, 0.81, 0.84, 1.0))
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(warning)

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(row)

	var cancel: = _rating_button("ОТМЕНА", Vector2(180, 44), 13)
	_style_rating_action(cancel, Color(0.82, 0.86, 0.9, 1.0), false)
	cancel.pressed.connect(_close_rating_reset_confirm)
	row.add_child(cancel)

	var confirm: = _rating_button("ДА, СБРОСИТЬ", Vector2(200, 44), 13)
	_style_rating_action(confirm, RATING_ROSE, true)
	confirm.pressed.connect(_confirm_rating_reset)
	row.add_child(confirm)

	var tween: = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.16)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.22)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	cancel.grab_focus()


func _close_rating_reset_confirm() -> void :
	if _confirm_overlay == null or not is_instance_valid(_confirm_overlay):
		return
	var overlay: = _confirm_overlay
	_confirm_overlay = null
	var tween: = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.12)
	tween.tween_callback( func() -> void :
		if is_instance_valid(overlay):
			overlay.queue_free())


func _confirm_rating_reset() -> void :
	Settings.reset_rating()
	_close_rating_reset_confirm()
	_refresh_header()
	_render_page()
	_toast("РЕЙТИНГ СБРОШЕН ДО 1000 ELO")





func _open_rating_stats() -> void :
	if _stats_overlay != null and is_instance_valid(_stats_overlay):
		_stats_overlay.queue_free()
		_stats_overlay = null
	var overlay: = Control.new()
	overlay.name = "RatingStats"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.modulate.a = 0.0
	_ui.add_child(overlay)
	_stats_overlay = overlay

	var dim: = ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.002, 0.004, 0.005, 0.9)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.gui_input.connect( func(event: InputEvent) -> void :
		if event is InputEventMouseButton and event.pressed:
			_close_rating_stats())
	overlay.add_child(dim)

	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var panel: = PanelContainer.new()
	panel.custom_minimum_size = Vector2(780, 0)
	var box: = _rating_pill(Color(0.018, 0.022, 0.026, 0.99), 
		Color(RATING_MINT.r, RATING_MINT.g, RATING_MINT.b, 0.55), 1, 
		Color(RATING_MINT.r, RATING_MINT.g, RATING_MINT.b, 0.14))
	box.set_corner_radius_all(22)
	box.content_margin_left = 28.0
	box.content_margin_right = 28.0
	box.content_margin_top = 24.0
	box.content_margin_bottom = 24.0
	panel.add_theme_stylebox_override("panel", box)
	center.add_child(panel)
	_stats_panel = panel
	panel.scale = Vector2(0.94, 0.94)
	panel.pivot_offset = Vector2(390, 200)

	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	content.add_child(_label("РЕЙТИНГ · ДУЭЛЬ 1×1", &"KickerLabel", 10, 
		RATING_MINT))
	var title: = _label("СТАТИСТИКА", &"DisplayLabel", 28, 
		Color(0.97, 0.96, 0.95, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	var subtitle: = _label("МАТЧЕЙ %d · РЕКОРД %s ELO · ВИНРЕЙТ %.0f%%" % [
		Settings.rating_matches, _format_number(Settings.rating_best), 
		Settings.rating_winrate()], &"KickerLabel", 9, 
		Color(0.52, 0.55, 0.6, 1.0))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(subtitle)

	var grid: = GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	content.add_child(grid)
	grid.add_child(_rating_stat("ПОБЕДЫ", str(Settings.rating_wins), 
		Color(0.42, 0.95, 0.55, 1.0)))
	grid.add_child(_rating_stat("ПОРАЖЕНИЯ", str(Settings.rating_losses), 
		Color(1.0, 0.42, 0.36, 1.0)))
	grid.add_child(_rating_stat("ВИНРЕЙТ", "%.0f%%" % Settings.rating_winrate(), 
		Color(0.96, 0.95, 0.93, 1.0)))
	var streak_bonus: = mini(Settings.rating_streak * 2, 8)
	grid.add_child(_rating_stat(
		"СЕРИЯ · +%d ELO" % streak_bonus if Settings.rating_streak > 0
			else "СЕРИЯ", str(Settings.rating_streak), 
		Color(1.0, 0.85, 0.35, 1.0)))
	grid.add_child(_rating_stat("МАТЧЕЙ", str(Settings.rating_matches), 
		Color(0.96, 0.95, 0.93, 1.0)))
	grid.add_child(_rating_stat("РЕКОРД", _format_number(Settings.rating_best), 
		Color(1.0, 0.85, 0.35, 1.0)))
	grid.add_child(_rating_stat("ТОЧНОСТЬ", 
		("%.1f%%" % Settings.rating_accuracy()) if Settings.rating_shots > 0
			else "—", 
		Color(0.58, 0.86, 1.0, 1.0)))
	grid.add_child(_rating_stat("ХЕДШОТЫ", 
		("%.0f%%" % Settings.rating_headshot_rate()) if Settings.rating_hits > 0
			else "—", 
		Color(0.98, 0.72, 1.0, 1.0)))
	grid.add_child(_rating_stat("СР. УРОН", 
		_format_number(int(round(Settings.rating_avg_damage())))
			if Settings.rating_damage > 0 else "—", 
		Color(0.74, 0.92, 0.7, 1.0)))
	grid.add_child(_rating_stat("ЛУЧШАЯ СЕРИЯ", 
		str(Settings.rating_best_streak), 
		Color(1.0, 0.85, 0.35, 1.0)))

	var form: = HBoxContainer.new()
	form.add_theme_constant_override("separation", 8)
	content.add_child(form)
	var form_caption: = _label("ПОСЛЕДНИЕ МАТЧИ", &"KickerLabel", 9, 
		Color(0.42, 0.44, 0.48, 1.0))
	form_caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	form.add_child(form_caption)
	form.add_child(_recent_form_strip(5))
	form.add_child(_expander())
	var form_hint: = _label("ЗЕЛЁНАЯ — ПОБЕДА   ·   КРАСНАЯ — ПОРАЖЕНИЕ", 
		&"KickerLabel", 9, Color(0.36, 0.38, 0.42, 1.0))
	form_hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	form.add_child(form_hint)

	var close_row: = HBoxContainer.new()
	close_row.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(close_row)
	var close: = _rating_button("ЗАКРЫТЬ", Vector2(200, 44), 13)
	_style_rating_action(close, RATING_MINT, true)
	close.pressed.connect(_close_rating_stats)
	close_row.add_child(close)

	var tween: = create_tween()
	tween.set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.16)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.22)\
	.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	close.grab_focus()


func _close_rating_stats() -> void :
	if _stats_overlay == null or not is_instance_valid(_stats_overlay):
		return
	var overlay: = _stats_overlay
	_stats_overlay = null
	var tween: = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.12)
	tween.tween_callback( func() -> void :
		if is_instance_valid(overlay):
			overlay.queue_free())


func _map_card(entry: Dictionary) -> Button:
	var id: = str(entry["id"])
	var selected: bool = Settings.map_id == id

	var card: = Button.new()
	card.text = ""
	card.focus_mode = Control.FOCUS_NONE
	card.custom_minimum_size = Vector2(0, 424)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("normal", _map_card_box(selected, false))
	card.add_theme_stylebox_override("hover", _map_card_box(selected, true))
	card.add_theme_stylebox_override("pressed", _map_card_box(selected, true))
	card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	card.pressed.connect( func() -> void : _choose_map(id))

	var margin: = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(column)


	var preview: = TextureRect.new()
	preview.custom_minimum_size = Vector2(0, 186)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var preview_path: = str(entry["preview"])
	if ResourceLoader.exists(preview_path):
		preview.texture = load(preview_path)
	column.add_child(preview)

	var title_row: = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title_row)

	var title: = _label(str(entry["name"]), &"DisplayLabel", 22, UITheme.MENU_TEXT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.clip_text = true
	title_row.add_child(title)

	if selected:
		title_row.add_child(_map_chip("ВЫБРАНА", UITheme.GOLD_BRIGHT, UITheme.GOLD))

	column.add_child(_label(str(entry["kicker"]), &"KickerLabel", 10, UITheme.MENU_MUTED))

	var desc: = _label(str(entry["desc"]), &"Label", 12, UITheme.MENU_TEXT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0, 72)
	desc.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	column.add_child(desc)

	var tags: = HBoxContainer.new()
	tags.add_theme_constant_override("separation", 6)
	tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(tags)
	for tag in entry["tags"]:
		tags.add_child(_map_chip(str(tag), UITheme.MENU_MUTED, UITheme.MENU_BORDER))

	column.add_child(_spacer(0, true))

	var action: = _label(
		"ИГРАТЬ СНОВА  →" if selected else "ВЫБРАТЬ И ИГРАТЬ  →", 
		&"KickerLabel", 12, UITheme.GOLD_BRIGHT)
	action.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(action)

	return card


func _map_card_box(selected: bool, hover: bool) -> StyleBoxFlat:
	var bg: = Color(0.128, 0.074, 0.016, 0.99) if hover\
	else Color(0.082, 0.046, 0.01, 0.98)
	var border: = UITheme.GOLD_BRIGHT if selected or hover else UITheme.MENU_BORDER
	var box: = _flat_box(bg, border, 2 if selected or hover else 1, 10, 0.0)
	box.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	box.shadow_size = 12 if selected else 6
	box.shadow_offset = Vector2(0.0, 3.0)
	return box


func _map_chip(text: String, color: Color, border: Color) -> PanelContainer:
	var chip: = PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box: = _flat_box(Color(0.15, 0.086, 0.018, 1.0), border, 1, 4, 6.0)
	box.content_margin_top = 2.0
	box.content_margin_bottom = 2.0
	chip.add_theme_stylebox_override("panel", box)
	var label: = _label(text, &"KickerLabel", 9, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.add_child(label)
	return chip


func _choose_map(id: String) -> void :
	if _transitioning:
		return
	Settings.map_id = id
	Settings.save_settings()
	_start_game()




func _render_inventory() -> void :
	_build_store_tabs()
	match _store_tab:
		"shop":
			_render_shop()
			return
		"skins":
			_render_skins()
			return
		"market":
			_render_market()
			return
		_:
			pass
	if _selected_weapon == "":
		var equipped: = _first_owned()
		_selected_weapon = str(equipped.get("weapon", "awp"))
		_selected_skin = str(equipped.get("skin", "default"))

	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	_page_body.add_child(row)

	var grid: = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	row.add_child(grid)

	for item in WeaponData.ITEMS:
		var weapon: = str(item["weapon"])
		var skin: = str(item["skin"])
		if not Settings.owns_item(weapon, skin):
			continue
		grid.add_child(_item_card(weapon, skin))

	var details: = PanelContainer.new()
	details.custom_minimum_size = Vector2(300, 0)
	details.add_theme_stylebox_override("panel", _flat_box(
		Color(0.07, 0.082, 0.1, 0.96), UITheme.MENU_BORDER, 1, 8, 18.0))
	row.add_child(details)

	var info: = VBoxContainer.new()
	info.add_theme_constant_override("separation", 8)
	details.add_child(info)

	_detail_rarity = _label("", &"KickerLabel", 10, UITheme.MENU_MUTED)
	info.add_child(_detail_rarity)

	_detail_name = _label("", &"DisplayMedium", 24, UITheme.MENU_TEXT)
	_detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_detail_name)

	_detail_stats = _label("", &"Label", 13, UITheme.MENU_MUTED)
	_detail_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_detail_stats)

	info.add_child(_spacer(8, true))

	_equip_button = Button.new()
	_equip_button.text = "ЭКИПИРОВАТЬ"
	_equip_button.theme_type_variation = &"AccentButton"
	_equip_button.custom_minimum_size = Vector2(0, 46)
	_equip_button.pressed.connect(_equip_selected)
	info.add_child(_equip_button)
	_sell_button = Button.new()
	_sell_button.text = "ПРОДАТЬ"
	_sell_button.theme_type_variation = &"SmallButton"
	_sell_button.custom_minimum_size = Vector2(0, 40)
	_sell_button.visible = false
	_sell_button.pressed.connect(_sell_selected)
	info.add_child(_sell_button)
	_inventory_status = _label("", &"KickerLabel", 10, UITheme.MENU_MUTED)
	_inventory_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_inventory_status)

	_update_item_details()


func _item_card(weapon_id: String, skin_id: String) -> PanelContainer:
	var skin: = WeaponData.get_skin(weapon_id, skin_id)
	var rarity: = WeaponData.get_rarity(skin)
	var rarity_color: Color = rarity.get("color", UITheme.MENU_MUTED)
	var selected: = weapon_id == _selected_weapon and skin_id == _selected_skin
	var equipped: bool = Settings.is_equipped(weapon_id, skin_id)

	var card: = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 118)
	card.add_theme_stylebox_override("panel", _item_box(rarity_color, selected))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.gui_input.connect( func(event: InputEvent) -> void :
		if event is InputEventMouseButton and event.pressed:
			_selected_weapon = weapon_id
			_selected_skin = skin_id
			_render_page())

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(column)

	var content: = HBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(content)

	var preview = WeaponPreview.new()
	preview.setup(weapon_id, skin_id)
	if equipped:
		preview.tint = Settings.item_tint(weapon_id)
	preview.custom_minimum_size = Vector2(150, 76)
	preview.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(preview)

	var text: = VBoxContainer.new()
	text.add_theme_constant_override("separation", 2)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(text)

	var kind: = _label(str(WeaponData.get_weapon(weapon_id).get("name", "")).to_upper(), 
		&"KickerLabel", 9, UITheme.MENU_MUTED)
	text.add_child(kind)
	var name_label: = _label(str(skin.get("name", "SKIN")), &"DisplayMedium", 19, UITheme.MENU_TEXT)
	text.add_child(name_label)
	var footer: = HBoxContainer.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text.add_child(footer)
	var rarity_label: = _label(str(rarity.get("label", "")), &"KickerLabel", 9, rarity_color)
	footer.add_child(rarity_label)
	if equipped:
		footer.add_child(_expander())
		footer.add_child(_label("В РУКАХ", &"KickerLabel", 9, UITheme.GOLD))

	var bar: = ColorRect.new()
	bar.color = rarity_color
	bar.custom_minimum_size = Vector2(0, 4)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(bar)

	return card



var _store_tab: = "inv"
var _coins_label: Label
var _market_listings: Array = []
var _coins_listener_set: = false


const CASE_DB: = [
	["БАЗА · КЕЙС", 250, {"common": 50.0, "rare": 29.0, "epic": 11.0, "legendary": 10.0}], 
	["ОГОНЬ · КЕЙС", 600, {"common": 0.0, "rare": 57.0, "epic": 33.0, "legendary": 10.0}], 
	["ЛЕГЕНДА · КЕЙС", 1400, {"common": 0.0, "rare": 0.0, "epic": 90.0, "legendary": 10.0}], 
]


func _item_price(rarity: Dictionary) -> int:
	var base: = 0
	match str(rarity.get("label", "")):
		"RARE":
			base = 850
		"EPIC":
			base = 1600
		"LEGENDARY":
			base = 3200
		_:
			base = 350
	return base


func _build_store_tabs() -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_page_body.add_child(row)
	for entry in [["inv", "ИНВЕНТАРЬ"], ["shop", "МАГАЗИН"], ["skins", "СКИНЫ"], ["market", "РЫНОК"]]:
		var tab: = Button.new()
		tab.text = str(entry[1])
		tab.custom_minimum_size = Vector2(150, 44)
		tab.add_theme_font_size_override("font_size", 16)
		if _store_tab == str(entry[0]):
			tab.theme_type_variation = &"AccentButton"
		else:
			tab.theme_type_variation = &"SmallButton"
		var target: String = str(entry[0])
		tab.pressed.connect( func() -> void :
			_store_tab = target
			_render_page())
		row.add_child(tab)

	row.add_child(_expander())

	if not _coins_listener_set and not Settings.coins_changed.is_connected(_on_coins_changed):
		Settings.coins_changed.connect(_on_coins_changed)
		_coins_listener_set = true
	_coins_label = _label("%d МОНЕТ" % Settings.coins, &"DisplayMedium", 20, UITheme.GOLD_BRIGHT)
	row.add_child(_coins_label)


func _on_coins_changed() -> void :
	if _coins_label != null and is_instance_valid(_coins_label):
		_coins_label.text = "%d МОНЕТ" % Settings.coins


func _roll_case(weights: Dictionary) -> Array:
	var total: = 0.0
	for item in WeaponData.ITEMS:
		var skin: = WeaponData.get_skin(str(item["weapon"]), str(item["skin"]))
		total += float(weights.get(str(skin.get("rarity", "common")), 0.0))
	var pick: = randf() * total
	for item in WeaponData.ITEMS:
		var weapon: = str(item["weapon"])
		var skin_id: = str(item["skin"])
		var skin: = WeaponData.get_skin(weapon, skin_id)
		var share: = float(weights.get(str(skin.get("rarity", "common")), 0.0))
		if pick <= share:
			return [weapon, skin_id]
		pick -= share
	var fallback: = WeaponData.ITEMS[0]
	return [str(fallback["weapon"]), str(fallback["skin"])]


func _render_skins() -> void :
	_page_body.add_child(_label(
		"Скины игрока меняют внешний вид персонажа: герой меню, превью " 
			+ "и тело при смерти. Это не оружейные скины — продать или " 
			+ "купить их на рынке нельзя, только здесь.", 
		&"Label", 12, UITheme.MENU_MUTED))

	var grid: = GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	_page_body.add_child(grid)
	for skin in PlayerSkinData.all():
		grid.add_child(_player_skin_card(skin))

	_page_body.add_child(_spacer(2))
	_page_body.add_child(_label(
		"РЫНОК: ТОЛЬКО ОРУЖИЕ. СКИНЫ ИГРОКА НЕ ПРОДАЮТСЯ И НЕ ПОКУПАЮТСЯ.", 
		&"KickerLabel", 10, UITheme.GOLD))


func _player_skin_card(skin: Dictionary) -> PanelContainer:
	var skin_id: = str(skin.get("id", PlayerSkinData.DEFAULT_ID))
	var rarity: Dictionary = WeaponData.get_rarity(skin)
	var rarity_color: Color = rarity.get("color", UITheme.MENU_MUTED)
	var owned: bool = Settings.owns_player_skin(skin_id)
	var equipped: bool = Settings.player_skin == skin_id
	var price: = int(skin.get("price", 0))

	var card: = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 300)
	card.add_theme_stylebox_override("panel", _item_box(rarity_color, equipped))
	card.mouse_filter = Control.MOUSE_FILTER_STOP

	var column: = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(column)

	var preview: = PlayerPreview.new()
	preview.setup(skin_id)
	preview.custom_minimum_size = Vector2(0, 168)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(preview)

	var head: = HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(head)
	var name_label: = _label(str(skin.get("name", "СКИН")), &"DisplayMedium", 20, 
		UITheme.MENU_TEXT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name_label)
	head.add_child(_label(str(skin.get("tag", "")), &"KickerLabel", 9, rarity_color))

	var desc: = _label(str(skin.get("desc", "")), &"Label", 11, UITheme.MENU_MUTED)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0, 62)
	desc.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	column.add_child(desc)

	var bar: = ColorRect.new()
	bar.color = rarity_color
	bar.custom_minimum_size = Vector2(0, 3)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(bar)

	column.add_child(_spacer(2))
	var button: = Button.new()
	button.custom_minimum_size = Vector2(0, 40)
	if not owned:
		button.text = "КУПИТЬ · %d МОНЕТ" % price
		button.theme_type_variation = &"AccentButton"
		button.disabled = Settings.coins < price
		button.pressed.connect( func() -> void : _buy_player_skin(skin_id))
	elif equipped:
		button.text = "ЭКИПИРОВАНО"
		button.theme_type_variation = &"SmallButton"
		button.disabled = true
	else:
		button.text = "ЭКИПИРОВАТЬ"
		button.theme_type_variation = &"AccentButton"
		button.pressed.connect( func() -> void : _equip_player_skin(skin_id))
	column.add_child(button)
	return card


func _buy_player_skin(skin_id: String) -> void :
	var skin: Dictionary = PlayerSkinData.get_skin(skin_id)
	if not Settings.buy_player_skin(skin_id):
		_toast("НЕ ХВАТАЕТ МОНЕТ")
		return
	Settings.equip_player_skin(skin_id)
	_toast("КУПЛЕНО: СКИН %s" % str(skin.get("name", "")))
	_render_page()


func _equip_player_skin(skin_id: String) -> void :
	if not Settings.equip_player_skin(skin_id):
		_toast("СКИН НЕ КУПЛЕН")
		return
	var skin: Dictionary = PlayerSkinData.get_skin(skin_id)
	_toast("ЭКИПИРОВАНО: %s" % str(skin.get("name", "")))
	_render_page()


func _render_shop() -> void :
	var grid: = GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	_page_body.add_child(grid)
	for case_entry in CASE_DB:
		var card: = PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 190)
		card.add_theme_stylebox_override("panel", _flat_box(
			Color(0.058, 0.07, 0.085, 0.98), UITheme.MENU_BORDER, 1, 10, 14.0))
		grid.add_child(card)

		var box: = VBoxContainer.new()
		box.add_theme_constant_override("separation", 8)
		card.add_child(box)

		var title: = _label(str(case_entry[0]), &"DisplayMedium", 20, UITheme.MENU_TEXT)
		box.add_child(title)
		var prices: = _label("ШАНСЫ: ОБЫЧН. %d%% · РЕДК. %d%% · ЭПИК %d%% · ЛЕГ. %d%%" % [
			int(case_entry[2]["common"]), int(case_entry[2]["rare"]), 
			int(case_entry[2]["epic"]), int(case_entry[2]["legendary"]), 
		], &"KickerLabel", 9, UITheme.MENU_MUTED)
		box.add_child(prices)

		box.add_child(_expander())
		var buy: = Button.new()
		buy.text = "ОТКРЫТЬ · %d МОНЕТ" % int(case_entry[1])
		buy.theme_type_variation = &"AccentButton"
		buy.custom_minimum_size = Vector2(0, 42)
		buy.pressed.connect( func() -> void : _open_case(int(case_entry[1]), case_entry[2]))
		box.add_child(buy)


func _open_case(price: int, weights: Dictionary) -> void :
	if not Settings.spend_coins(price):
		_toast("НЕ ХВАТАЕТ МОНЕТ")
		return
	var item: = _roll_case(weights)
	var key: = "%s|%s" % [item[0], item[1]]
	if not Settings.owned_items.has(key):
		Settings.owned_items.append(key)
		Settings.queue_save_settings()
	var full: String = WeaponData.get_item(str(item[0]), str(item[1]))["full_name"]
	_toast("ДРОП: %s" % full)


func _render_market() -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_page_body.add_child(row)
	var refresh: = Button.new()
	refresh.text = "ОБНОВИТЬ ЛЕНТУ"
	refresh.theme_type_variation = &"SmallButton"
	refresh.custom_minimum_size = Vector2(190, 40)
	refresh.pressed.connect( func() -> void :
		_market_listings.clear()
		_render_page())
	row.add_child(refresh)
	row.add_child(_expander())
	row.add_child(_label("ПРОДАЖА ОРУЖИЯ — КНОПКА В КАРТОЧКЕ ИНВЕНТАРЯ", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))

	_page_body.add_child(_label(
		"СКИНЫ ИГРОКА (НАПРИМЕР «АНГЕЛ») НА РЫНКЕ НЕ ТОРГУЮТСЯ — " 
			+ "ИХ НЕЛЬЗЯ НИ КУПИТЬ, НИ ПРОДАТЬ ЗДЕСЬ. ТОЛЬКО ВКЛАДКА «СКИНЫ».", 
		&"KickerLabel", 10, UITheme.GOLD))

	_market_ensure_listings()
	var grid: = GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	_page_body.add_child(grid)
	for i in _market_listings.size():
		var listing: Dictionary = _market_listings[i]
		var idx: int = i
		grid.add_child(_market_card(listing, idx))


func _market_ensure_listings() -> void :
	var attempts: = 0
	while _market_listings.size() < 9 and attempts < 60:
		attempts += 1
		var source: Dictionary = WeaponData.ITEMS[randi() % WeaponData.ITEMS.size()]
		var weapon: = str(source["weapon"])
		var skin_id: = str(source["skin"])
		if Settings.owns_item(weapon, skin_id):
			continue
		_market_listings.append({
			"weapon": weapon, 
			"skin": skin_id, 
			"price": _item_price(WeaponData.get_skin(weapon, skin_id)), 
		})


func _market_card(listing: Dictionary, idx: int) -> PanelContainer:
	var weapon_id: = str(listing["weapon"])
	var skin_id: = str(listing["skin"])
	var skin: = WeaponData.get_skin(weapon_id, skin_id)
	var rarity: = WeaponData.get_rarity(skin)
	var rarity_color: Color = rarity.get("color", UITheme.MENU_MUTED)
	var card: = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 150)
	card.add_theme_stylebox_override("panel", _item_box(rarity_color, false))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	var content: = VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(content)
	var head: = HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(head)
	var preview = WeaponPreview.new()
	preview.setup(weapon_id, skin_id)
	preview.custom_minimum_size = Vector2(120, 58)
	preview.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(preview)
	var text: = VBoxContainer.new()
	text.add_theme_constant_override("separation", 2)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(text)
	text.add_child(_label(str(WeaponData.get_weapon(weapon_id).get("name", "")).to_upper(), 
		&"KickerLabel", 9, UITheme.MENU_MUTED))
	text.add_child(_label(str(skin.get("name", "SKIN")), &"DisplayMedium", 16, UITheme.MENU_TEXT))

	var bar: = ColorRect.new()
	bar.color = rarity_color
	bar.custom_minimum_size = Vector2(0, 3)
	content.add_child(bar)

	var foot: = HBoxContainer.new()
	foot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(foot)
	foot.add_child(_expander())
	var buy: = Button.new()
	buy.text = "КУПИТЬ · %d" % int(listing["price"])
	buy.theme_type_variation = &"SmallButton"
	buy.custom_minimum_size = Vector2(150, 32)
	if Settings.coins < int(listing["price"]):
		buy.disabled = true
	buy.pressed.connect( func() -> void : _buy_listing(idx))
	foot.add_child(buy)
	return card


func _buy_listing(idx: int) -> void :
	if idx < 0 or idx >= _market_listings.size():
		return
	var listing: Dictionary = _market_listings[idx]
	if not Settings.spend_coins(int(listing["price"])):
		_toast("НЕ ХВАТАЕТ МОНЕТ")
		return
	var key: = "%s|%s" % [listing["weapon"], listing["skin"]]
	if not Settings.owned_items.has(key):
		Settings.owned_items.append(key)
		Settings.queue_save_settings()
	_market_listings.remove_at(idx)
	_toast("КУПЛЕНО: %s" % key.replace("|", " | "))
	_render_page()

var _sell_button: Button


func _update_item_details() -> void :
	if _detail_name == null:
		return
	var weapon_id: = _selected_weapon
	var skin_id: = _selected_skin
	var item: = WeaponData.get_item(weapon_id, skin_id)
	var skin: Dictionary = item["skin"]
	var rarity: = WeaponData.get_rarity(skin)
	_detail_name.text = str(item["full_name"])
	_detail_rarity.text = str(rarity.get("label", "")).to_upper()
	_detail_rarity.add_theme_color_override("font_color", rarity.get("color", UITheme.MENU_MUTED))

	var weapon: Dictionary = item["weapon"]
	if WeaponData.is_melee(weapon_id):
		_detail_stats.text = "БЛИЖНИЙ БОЙ\nРАДИУС %.1f М" % float(weapon.get("melee_range", 2.4))
	else:
		_detail_stats.text = "МАГАЗИН %d ПАТРОНОВ\nПЕРЕЗАРЯДКА %.2f С\nРАЗБРОС %.2f°" % [
			int(weapon.get("magazine", 5)), 
			float(weapon.get("reload_time", 2.5)), 
			float(weapon.get("spread", 0.0012)) * 1000.0, 
		]

	if _equip_button != null:
		var equipped: bool = Settings.is_equipped(weapon_id, skin_id)
		_equip_button.visible = true
		_equip_button.disabled = equipped
		_equip_button.text = "ЭКИПИРОВАНО" if equipped else "ЭКИПИРОВАТЬ"
	if _sell_button != null:
		var owned: bool = Settings.owns_item(weapon_id, skin_id)
		var equipped: bool = Settings.is_equipped(weapon_id, skin_id)
		var starter_sell: bool = Settings.DEFAULT_OWNED.has(
			"%s|%s" % [weapon_id, skin_id])
		# стартовые предметы не продаются
		_sell_button.visible = owned and not equipped and not starter_sell
		if _sell_button.visible:
			_sell_button.text = "ПРОДАТЬ · %d МОНЕТ" % _item_price(rarity)
	if _inventory_status != null:
		_inventory_status.text = ""


func _equip_selected() -> void :
	if Settings.set_loadout(_selected_weapon, _selected_skin):
		_toast("ЭКИПИРОВАНО: %s" % WeaponData.get_item(_selected_weapon, _selected_skin)["full_name"])
		_render_page()
	else:
		if _inventory_status != null:
			_inventory_status.text = "Этот предмет вам не принадлежит."


func _sell_selected() -> void :
	var weapon_id: = _selected_weapon
	var skin_id: = _selected_skin
	var key: = "%s|%s" % [weapon_id, skin_id]
	if not Settings.owned_items.has(key) or Settings.is_equipped(weapon_id, skin_id) \
			or not WeaponData.WEAPONS.has(weapon_id):
		return
	var skin: = WeaponData.get_skin(weapon_id, skin_id)
	var price: = _item_price(WeaponData.get_rarity(skin))
	Settings.owned_items.erase(key)
	Settings.add_coins(price)
	_toast("ПРОДАНО: %s · +%d МОНЕТ" % [
		WeaponData.get_item(weapon_id, skin_id)["full_name"], price])
	var next: = _first_owned()
	_selected_weapon = str(next.get("weapon", "awp"))
	_selected_skin = str(next.get("skin", "default"))
	_render_page()


func _refresh_inventory_state() -> void :
	if _detail_name != null:
		_update_item_details()


func _first_owned() -> Dictionary:
	for item in WeaponData.ITEMS:
		if Settings.owns_item(str(item["weapon"]), str(item["skin"])):
			return item
	return {"weapon": "awp", "skin": "default"}




func _render_settings() -> void :


	var tabs: Array = []
	for entry in SETTINGS_TAB_ORDER:
		var tab_name: = str(entry)

		if tab_name == "binds" and _is_mobile:
			continue
		tabs.append(tab_name)
	if not tabs.has(_settings_tab):
		_settings_tab = "game"

	for child in _settings_tab_bar.get_children():
		_settings_tab_bar.remove_child(child)
		child.queue_free()
	for entry in tabs:
		var tab_name: = str(entry)
		var button: = Button.new()
		button.text = str(SETTINGS_TAB_CAPTIONS.get(tab_name, tab_name))
		button.theme_type_variation = &"AccentButton"\
		if _settings_tab == tab_name else &"SmallButton"
		button.custom_minimum_size = Vector2(0, 38)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 15)
		button.add_theme_font_override("font", UITheme.ui_font(800))
		button.tooltip_text = str(SETTINGS_TAB_HINTS.get(tab_name, ""))
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.pressed.connect( func() -> void :
			_settings_tab = tab_name
			_render_page())
		_settings_tab_bar.add_child(button)
	_settings_tab_hint.text = str(SETTINGS_TAB_HINTS.get(_settings_tab, ""))

	var body: = VBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_body.add_child(body)
	match _settings_tab:
		"crosshair":
			_settings_crosshair(body)
		"colors":
			_settings_colors(body)
		"hands":
			_settings_hands(body)
		"screen":
			_settings_screen(body)
		"binds":
			_settings_binds(body)
		"profile":
			_settings_profile(body)
		_:
			_settings_game(body)

	var scroll: = _page_body.get_parent().get_parent()
	if scroll is ScrollContainer:
		scroll.scroll_vertical = 0


func _settings_game(parent: VBoxContainer) -> void :
	parent.add_child(_section_header("ИГРА"))
	_add_slider(parent, "ЧУВСТВИТЕЛЬНОСТЬ", 
		Settings.SENS_MIN, Settings.SENS_MAX, 0.01, 
		Settings.mouse_sensitivity, "×%.2f", func(value: float) -> void :
			Settings.set_mouse_sensitivity(value))


	_add_slider(parent, "УГОЛ ОБЗОРА (FOV)", Settings.FOV_MIN, Settings.FOV_MAX, 1.0, 
		Settings.fov, "%.0f°", func(value: float) -> void :
			Settings.set_fov(value))
	_add_slider(parent, "МАНЕКЕНОВ НА АРЕНЕ", Settings.MANNEQUIN_MIN, Settings.MANNEQUIN_MAX, 
		1.0, Settings.mannequin_count, "%.0f", func(value: float) -> void :
			Settings.set_mannequin_count(int(round(value))))
	_color_row(parent, "ЦВЕТ МАНЕКЕНА", Settings.mannequin_color, 
		Settings.MANNEQUIN_PRESETS, Settings.set_mannequin_color)
	var game_toggles: = HBoxContainer.new()
	game_toggles.add_theme_constant_override("separation", 18)
	parent.add_child(game_toggles)
	game_toggles.add_child(_toggle("РАЗНОЦВЕТНЫЙ · ПЕРЕЛИВАЕТСЯ", 
		Settings.mannequin_rainbow, func(value: bool) -> void :
			Settings.set_mannequin_rainbow(value)))
	game_toggles.add_child(_toggle("ТАЙМЕР СЕССИИ", Settings.session_timer, 
		func(value: bool) -> void : Settings.set_session_timer(value)))
	_add_slider(parent, "ГРОМКОСТЬ", 0.0, 1.0, 0.01, Settings.master_volume, "%d%%", 
		func(value: float) -> void : Settings.set_master_volume(value))
	parent.add_child(_toggle("ПРИСЕД И ПРИЦЕЛ: НАЖАТИЕ", 
		Settings.tap_crouch_aim, func(value: bool) -> void :
			Settings.set_tap_crouch_aim(value)))
	parent.add_child(_label(
		"Выключено — удержание. Включено — одно нажатие переключает "
		+ "присед и прицел. Работает на ПК и телефоне.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))

	_render_mobile_settings(parent)


func _settings_crosshair(parent: VBoxContainer) -> void :
	parent.add_child(_section_header("ПРИЦЕЛ"))
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	parent.add_child(row)
	row.add_child(_crosshair_preview())

	var controls: = VBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(controls)
	_color_row(controls, "ЦВЕТ ПРИЦЕЛА", Settings.crosshair_color, 
		Settings.CROSSHAIR_PRESETS, Settings.set_crosshair_color)
	_add_slider(controls, "ЗАЗОР", 0.0, 18.0, 0.5, Settings.crosshair_gap, "%.1f", 
		func(value: float) -> void : Settings.set_crosshair_gap(value))
	_add_slider(controls, "ДЛИНА", 0.0, 18.0, 0.5, Settings.crosshair_length, "%.1f", 
		func(value: float) -> void : Settings.set_crosshair_length(value))
	_add_slider(controls, "ТОЛЩИНА", 1.0, 6.0, 0.5, Settings.crosshair_thickness, "%.1f", 
		func(value: float) -> void : Settings.set_crosshair_thickness(value))
	_add_option(controls, "ПОВЕДЕНИЕ ПРИЦЕЛА", 
		["ДИНАМИЧНЫЙ", "СТАТИЧНЫЙ"], 0 if Settings.crosshair_dynamic else 1, 
		func(index: int) -> void : Settings.set_crosshair_dynamic(index == 0))

	var toggles: = HBoxContainer.new()
	toggles.add_theme_constant_override("separation", 18)
	parent.add_child(toggles)
	toggles.add_child(_toggle("ТОЧКА", Settings.crosshair_dot, 
		func(value: bool) -> void : Settings.set_crosshair_dot(value)))
	toggles.add_child(_toggle("ОБВОДКА", Settings.crosshair_outline, 
		func(value: bool) -> void : Settings.set_crosshair_outline(value)))
	toggles.add_child(_toggle("ПРОЗРАЧНЫЙ ПРИЦЕЛ AWP", Settings.scope_transparent, 
		func(value: bool) -> void : Settings.set_scope_transparent(value)))
	parent.add_child(_label(
		"Прозрачная оптика: круг и перекрестие без чёрных полей.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))

	var reset_crosshair: = Button.new()
	reset_crosshair.text = "СБРОСИТЬ ПРИЦЕЛ"
	reset_crosshair.theme_type_variation = &"SmallButton"
	reset_crosshair.custom_minimum_size = Vector2(220, 34)
	reset_crosshair.pressed.connect( func() -> void :
		Settings.reset_crosshair()
		_render_page())
	parent.add_child(reset_crosshair)

	var code: = ConfigCodeUI.new()
	code.setup("КОД ПРИЦЕЛА", 
		"Скопируйте код и отправьте другу: у него будет такой же цвет, зазор, "
		+ "длина и толщина прицела. Вставьте чужой код и нажмите «ПРИМЕНИТЬ».", 
		Settings.get_crosshair_code, _apply_crosshair_code)
	parent.add_child(code)


func _settings_colors(parent: VBoxContainer) -> void :
	parent.add_child(_section_header("КАСТОМИЗАЦИЯ"))
	parent.add_child(_label(
		"Цвета применяются к HUD, небу арены, рукам, оружию, ножу и карте в игре.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	_color_row(parent, "ЦВЕТ HUD", Settings.hud_accent, Settings.HUD_PRESETS, 
		Settings.set_hud_accent)
	_color_row(parent, "НЕБО · ВЕРХ", Settings.sky_top, Settings.SKY_PRESETS, 
		Settings.set_sky_top)
	_color_row(parent, "НЕБО · ГОРИЗОНТ", Settings.sky_horizon, Settings.SKY_PRESETS, 
		Settings.set_sky_horizon)
	_color_row(parent, "РУКАВ", Settings.arm_sleeve, Settings.ARM_PRESETS, 
		Settings.set_arm_sleeve)
	_color_row(parent, "КИСТЬ", Settings.arm_glove, Settings.GLOVE_PRESETS, 
		Settings.set_arm_glove)
	parent.add_child(_toggle("РЕЗКИЙ ПЕРЕХОД РУК", Settings.arm_sharp_split, 
		func(value: bool) -> void : Settings.set_arm_sharp_split(value)))
	parent.add_child(_label(
		"Резкая граница «перчатка / рукав» вместо плавного градиента.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))

	parent.add_child(_section_header("ОРУЖИЕ"))
	parent.add_child(_label(
		"Перекраска корпуса поверх скина: рисунок и светотень сохраняются. "
		+ "У винтовки и ножа свои цвета — включите нужный и выберите оттенок "
		+ "пресетом или любым цветом.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	parent.add_child(_toggle("ЦВЕТ ОРУЖИЯ", Settings.weapon_tint_enabled, 
		func(value: bool) -> void : Settings.set_weapon_tint_enabled(value)))
	_color_row(parent, "ОРУЖИЕ", Settings.weapon_tint, Settings.WEAPON_TINT_PRESETS, 
		Settings.set_weapon_tint)
	parent.add_child(_toggle("ЦВЕТ НОЖА", Settings.knife_tint_enabled, 
		func(value: bool) -> void : Settings.set_knife_tint_enabled(value)))
	_color_row(parent, "НОЖ", Settings.knife_tint, Settings.KNIFE_TINT_PRESETS, 
		Settings.set_knife_tint)


	parent.add_child(ViewmodelPreview.new())

	parent.add_child(_section_header("МИР"))
	parent.add_child(_toggle("ПЕРЕКРАШИВАТЬ КАРТУ", Settings.world_tint_enabled, 
		func(value: bool) -> void : Settings.set_world_tint_enabled(value)))
	parent.add_child(_label(
		"Все поверхности карты окрашиваются в выбранный цвет. "
		+ "Светотень и швы сохраняются, HUD и оружие не меняются.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	_color_row(parent, "ЦВЕТ КАРТЫ", Settings.world_tint_color, 
		Settings.WORLD_TINT_PRESETS, Settings.set_world_tint_color)

	var reset_colors: = Button.new()
	reset_colors.text = "СБРОСИТЬ ЦВЕТА"
	reset_colors.theme_type_variation = &"SmallButton"
	reset_colors.custom_minimum_size = Vector2(220, 34)
	reset_colors.pressed.connect( func() -> void :
		Settings.reset_colors()
		_render_page())
	parent.add_child(reset_colors)

	var code: = ConfigCodeUI.new()
	code.setup("КОД ЦВЕТОВ", 
		"Один код переносит акцент HUD, небо, рукав, кисть и цвет карты "
		+ "на телефон или ПК. Цвета прицела и манекенов передаются "
		+ "отдельными кодами.", 
		Settings.get_colors_code, _apply_colors_code)
	parent.add_child(code)


func _settings_hands(parent: VBoxContainer) -> void :
	parent.add_child(_section_header("РУКИ И ОРУЖИЕ"))
	parent.add_child(_label(
		"Положение рук и оружия от первого лица. «ЛЕВАЯ РУКА» зеркалит "
		+ "вьюмодель; бинд — на вкладке «КЛАВИШИ».", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))



	var hands: BoxContainer
	if _is_mobile:
		hands = VBoxContainer.new()
	else:
		hands = HBoxContainer.new()
	hands.add_theme_constant_override("separation", 16)
	parent.add_child(hands)
	var vm_preview: = ViewmodelPreview.new()
	hands.add_child(vm_preview)
	if not _is_mobile:
		vm_preview.custom_minimum_size = Vector2(360.0, 
			vm_preview.custom_minimum_size.y)
		vm_preview.size_flags_horizontal = Control.SIZE_FILL
		vm_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var vm_rows: = VBoxContainer.new()
	vm_rows.add_theme_constant_override("separation", 8)
	vm_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hands.add_child(vm_rows)
	_add_slider(vm_rows, "СМЕЩЕНИЕ ВПРАВО", Settings.VM_OFFSET_MIN, 
		Settings.VM_OFFSET_MAX, 0.005, Settings.vm_offset.x, "%.2f", 
		func(value: float) -> void :
			Settings.set_vm_offset(Vector3(value, Settings.vm_offset.y, 
				Settings.vm_offset.z)))
	_add_slider(vm_rows, "СМЕЩЕНИЕ ВВЕРХ", Settings.VM_OFFSET_MIN, 
		Settings.VM_OFFSET_MAX, 0.005, Settings.vm_offset.y, "%.2f", 
		func(value: float) -> void :
			Settings.set_vm_offset(Vector3(Settings.vm_offset.x, value, 
				Settings.vm_offset.z)))
	_add_slider(vm_rows, "БЛИЖЕ / ДАЛЬШЕ", Settings.VM_DEPTH_MIN, 
		Settings.VM_DEPTH_MAX, 0.005, Settings.vm_offset.z, "%.2f", 
		func(value: float) -> void :
			Settings.set_vm_offset(Vector3(Settings.vm_offset.x, Settings.vm_offset.y, 
				value)))
	_add_slider(vm_rows, "ПОВОРОТ ВЛЕВО / ВПРАВО", Settings.VM_ROTATION_MIN, 
		Settings.VM_ROTATION_MAX, 1.0, Settings.vm_rotation.y, "%.0f°", 
		func(value: float) -> void :
			Settings.set_vm_rotation(Vector3(Settings.vm_rotation.x, value, 
				Settings.vm_rotation.z)))
	_add_slider(vm_rows, "ПОВОРОТ ВВЕРХ / ВНИЗ", Settings.VM_ROTATION_MIN, 
		Settings.VM_ROTATION_MAX, 1.0, Settings.vm_rotation.x, "%.0f°", 
		func(value: float) -> void :
			Settings.set_vm_rotation(Vector3(value, Settings.vm_rotation.y, 
				Settings.vm_rotation.z)))
	_add_slider(vm_rows, "НАКЛОН", Settings.VM_ROTATION_MIN, 
		Settings.VM_ROTATION_MAX, 1.0, Settings.vm_rotation.z, "%.0f°", 
		func(value: float) -> void :
			Settings.set_vm_rotation(Vector3(Settings.vm_rotation.x, 
				Settings.vm_rotation.y, value)))
	_add_slider(vm_rows, "МАСШТАБ РУК", Settings.VM_SCALE_MIN, Settings.VM_SCALE_MAX, 
		0.01, Settings.vm_scale, "×%.2f", func(value: float) -> void :
			Settings.set_vm_scale(value))
	_add_slider(vm_rows, "ПОКАЧИВАНИЕ", Settings.VM_SWAY_MIN, Settings.VM_SWAY_MAX, 
		0.05, Settings.vm_sway, "×%.2f", func(value: float) -> void :
			Settings.set_vm_sway(value))
	vm_rows.add_child(_toggle("ЛЕВАЯ РУКА", Settings.left_hand, 
		func(value: bool) -> void : Settings.set_left_hand(value)))
	var vm_reset: = Button.new()
	vm_reset.text = "СБРОСИТЬ ПОЛОЖЕНИЕ РУК"
	vm_reset.theme_type_variation = &"SmallButton"
	vm_reset.custom_minimum_size = Vector2(240, 34)
	vm_reset.pressed.connect( func() -> void :
		Settings.reset_viewmodel()
		_render_page())
	vm_rows.add_child(vm_reset)

	var hands_code: = ConfigCodeUI.new()
	hands_code.setup("КОД РУК", 
		"Переносит смещение, поворот, масштаб, покачивание и сторону рук.", 
		Settings.get_hands_code, _apply_hands_code)
	parent.add_child(hands_code)


func _settings_screen(parent: VBoxContainer) -> void :
	parent.add_child(_section_header("ЭКРАН И ГРАФИКА"))
	_add_slider(parent, "РАСТЯЖЕНИЕ ЭКРАНА", Settings.STRETCH_MIN, Settings.STRETCH_MAX, 
		0.01, Settings.screen_stretch, "%d%%", func(value: float) -> void :
			Settings.set_screen_stretch(value))
	parent.add_child(_label(
		"0% — исходные пропорции, 100% — растянутое 4:3, 200% — максимум.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	_add_option(parent, "ЛИМИТ FPS", Settings.FPS_LABELS, _fps_index(), 
		func(index: int) -> void : Settings.set_fps_limit(int(Settings.FPS_VALUES[index])))
	var hud_toggles: = HBoxContainer.new()
	hud_toggles.add_theme_constant_override("separation", 18)
	parent.add_child(hud_toggles)
	hud_toggles.add_child(_toggle("ПОКАЗЫВАТЬ FPS", Settings.show_fps, 
		func(value: bool) -> void : Settings.set_show_fps(value)))
	var keys_toggle: = _toggle("КЛАВИШИ И МЫШЬ", Settings.show_input_overlay, 
		func(value: bool) -> void : Settings.set_show_input_overlay(value))
	keys_toggle.visible = not _is_mobile
	hud_toggles.add_child(keys_toggle)
	parent.add_child(_label(
		"FPS — счётчик кадров справа сверху. «Клавиши и мышь» — WASD, ЛКМ/ПКМ "
		+ "и пробел слева снизу."
		if not _is_mobile else "FPS — счётчик кадров справа сверху.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	parent.add_child(_section_header("ВИДЖЕТ РЕЙТИНГА"))
	parent.add_child(_label(
		"Компактная карточка профиля слева сверху: уровень, ник, эло, форма "
		+ "последних матчей и счёт. Включите виджет и отметьте нужные строки. "
		+ "Положение и размер меняются в «РАСПОЛОЖЕНИЕ HUD».", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	var rating_row: = HBoxContainer.new()
	rating_row.add_theme_constant_override("separation", 18)
	parent.add_child(rating_row)
	rating_row.add_child(_toggle("ПОКАЗЫВАТЬ", Settings.show_rating_widget, 
		func(value: bool) -> void : Settings.set_show_rating_widget(value)))
	var rating_parts: = HBoxContainer.new()
	rating_parts.add_theme_constant_override("separation", 18)
	parent.add_child(rating_parts)
	rating_parts.add_child(_toggle("УРОВЕНЬ", Settings.rating_widget_level, 
		func(value: bool) -> void : Settings.set_rating_widget_level(value)))
	rating_parts.add_child(_toggle("НИК", Settings.rating_widget_nickname, 
		func(value: bool) -> void : Settings.set_rating_widget_nickname(value)))
	rating_parts.add_child(_toggle("ЭЛО", Settings.rating_widget_elo, 
		func(value: bool) -> void : Settings.set_rating_widget_elo(value)))
	var rating_parts_second: = HBoxContainer.new()
	rating_parts_second.add_theme_constant_override("separation", 18)
	parent.add_child(rating_parts_second)
	rating_parts_second.add_child(_toggle("ФОРМА", Settings.rating_widget_form, 
		func(value: bool) -> void : Settings.set_rating_widget_form(value)))
	rating_parts_second.add_child(_toggle("СЧЁТ", Settings.rating_widget_record, 
		func(value: bool) -> void : Settings.set_rating_widget_record(value)))
	_add_option(parent, "ВИД ВИДЖЕТА", Settings.RATING_WIDGET_STYLES, 
		Settings.rating_widget_style, 
		func(index: int) -> void : Settings.set_rating_widget_style(index))
	parent.add_child(_label(
		"«МИНИМАЛЬНЫЙ» — тонкая подпись, «КЛАССИКА» — компактная карточка "
		+ "с колонками статистики, «ШИРОКИЙ» — большой профиль, «ПРОГРЕСС» — "
		+ "эло с трендом и полосой уровня, «CS» — вертикальная карточка. "
		+ "Положение меняется в «РАСПОЛОЖЕНИЕ HUD».", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	_add_option(parent, "СГЛАЖИВАНИЕ (MSAA)", Settings.MSAA_LABELS, 
		Settings.msaa_level, 
		func(index: int) -> void : Settings.set_msaa_level(index))
	_add_option(parent, "ЭФФЕКТЫ", Settings.EFFECTS_LABELS, 
		Settings.effects_quality, 
		func(index: int) -> void : Settings.set_effects_quality(index))
	var perf_toggles: = HBoxContainer.new()
	perf_toggles.add_theme_constant_override("separation", 18)
	parent.add_child(perf_toggles)
	perf_toggles.add_child(_toggle("АДАПТИВНОЕ РАЗРЕШЕНИЕ", 
		Settings.adaptive_resolution, func(value: bool) -> void :
			Settings.set_adaptive_resolution(value)))
	perf_toggles.add_child(_toggle("РЕЖИМ ЗАПИСИ / СТРИМА", Settings.stream_mode, 
		func(value: bool) -> void : Settings.set_stream_mode(value)))
	parent.add_child(_label(
		"Первое снижает разрешение 3D при просадках, второе держит 60 FPS "
		+ "и запас GPU для OBS.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	var perf_button: = Button.new()
	perf_button.text = "РЕЖИМ ПРОИЗВОДИТЕЛЬНОСТИ"
	perf_button.theme_type_variation = &"SmallButton"
	perf_button.custom_minimum_size = Vector2(260, 34)
	perf_button.pressed.connect( func() -> void :
		Settings.apply_performance_preset()
		_render_page())
	parent.add_child(perf_button)
	parent.add_child(_toggle("РЕЖИМ СОВМЕСТИМОСТИ", 
		Settings.safe_mode, func(value: bool) -> void :
			Settings.set_safe_mode(value)))
	parent.add_child(_label(
		"Минимальная графика для слабых устройств и восстановления после "
		+ "падения. Карта, управление и прогресс не меняются.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	var screen_toggles: = HBoxContainer.new()
	screen_toggles.add_theme_constant_override("separation", 18)
	parent.add_child(screen_toggles)
	var fullscreen_toggle: = _toggle("ПОЛНЫЙ ЭКРАН", Settings.fullscreen, 
		func(value: bool) -> void : Settings.set_fullscreen(value))

	fullscreen_toggle.visible = not _is_mobile
	screen_toggles.add_child(fullscreen_toggle)
	screen_toggles.add_child(_toggle("VSYNC", Settings.vsync, 
		func(value: bool) -> void : Settings.set_vsync(value)))
	screen_toggles.add_child(_toggle("ТУМАН", Settings.fog_enabled, 
		func(value: bool) -> void : Settings.set_fog_enabled(value)))
	_add_slider(parent, "ЯРКОСТЬ", Settings.BRIGHTNESS_MIN, Settings.BRIGHTNESS_MAX, 0.01, 
		Settings.brightness, "%d%%", func(value: float) -> void : Settings.set_brightness(value))

	parent.add_child(_section_header("РАСПОЛОЖЕНИЕ HUD"))
	parent.add_child(_label(
		"Двигайте блоки HUD и меняйте их размер: киллфид, череп с патронами, "
		+ "слоты оружия, таймер, стрейф, FPS, клавиши, подсказку и виджет "
		+ "рейтинга. Изменения сохраняются в профиль.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))
	var hud_layout_button: = Button.new()
	hud_layout_button.text = "НАСТРОИТЬ HUD"
	hud_layout_button.theme_type_variation = &"SmallButton"
	hud_layout_button.custom_minimum_size = Vector2(240, 38)
	hud_layout_button.pressed.connect(_open_hud_layout_editor)
	parent.add_child(hud_layout_button)


func _settings_binds(parent: VBoxContainer) -> void :
	parent.add_child(_section_header("УПРАВЛЕНИЕ"))
	parent.add_child(_label(
		"Клавиша или кнопка мыши: ЛКМ, ПКМ, СКМ, колесо и боковые.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))

	var binds: = GridContainer.new()
	binds.columns = 6
	binds.add_theme_constant_override("h_separation", 12)
	binds.add_theme_constant_override("v_separation", 6)
	parent.add_child(binds)
	for entry in Settings.BIND_ORDER:
		var action: = str(entry[0])
		var caption: = _label(str(entry[1]), &"Label", 12, UITheme.MENU_TEXT)
		caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		binds.add_child(caption)
		var button: = Button.new()
		button.text = Settings.get_key_label(action)
		button.theme_type_variation = &"SmallButton"
		button.custom_minimum_size = Vector2(118, 30)
		button.pressed.connect( func() -> void : _begin_rebind(action, button))
		binds.add_child(button)
		_bind_buttons[action] = button

	var reset_binds: = Button.new()
	reset_binds.text = "СБРОСИТЬ РАСКЛАДКУ"
	reset_binds.theme_type_variation = &"SmallButton"
	reset_binds.custom_minimum_size = Vector2(220, 34)
	reset_binds.pressed.connect( func() -> void :
		Settings.reset_keybinds()
		_render_page())
	parent.add_child(reset_binds)


func _settings_profile(parent: VBoxContainer) -> void :
	parent.add_child(_section_header("ПРОФИЛЬ"))
	var profile_row: = HBoxContainer.new()
	profile_row.add_theme_constant_override("separation", 10)
	parent.add_child(profile_row)

	var nickname_edit: = LineEdit.new()
	nickname_edit.text = Settings.nickname
	nickname_edit.max_length = 16
	nickname_edit.custom_minimum_size = Vector2(260, 38)
	profile_row.add_child(nickname_edit)

	var save: = Button.new()
	save.text = "СОХРАНИТЬ"
	save.custom_minimum_size = Vector2(140, 38)
	save.pressed.connect( func() -> void :
		Settings.set_profile(nickname_edit.text, Settings.avatar_index)
		_toast("ПРОФИЛЬ СОХРАНЁН")
		_refresh_header())
	profile_row.add_child(save)




	var country_row: = HBoxContainer.new()
	country_row.add_theme_constant_override("separation", 10)
	parent.add_child(country_row)

	var country_caption: = _label("СТРАНА", &"Label", 14, UITheme.MENU_TEXT)
	country_caption.custom_minimum_size = Vector2(150, 0)
	country_caption.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	country_row.add_child(country_caption)

	var country_flag: = CountryFlag.new()
	country_flag.custom_minimum_size = Vector2(30, 20)
	country_flag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	country_flag.set_country(Settings.country)
	country_row.add_child(country_flag)

	var country_option: = OptionButton.new()
	country_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	country_option.add_theme_font_override("font", UITheme.ui_font(800))
	country_option.add_theme_font_size_override("font_size", 15)
	country_option.get_popup().add_theme_font_override("font", 
		UITheme.ui_font(800))
	country_option.get_popup().add_theme_font_size_override("font_size", 15)
	for i in CountryData.COUNTRIES.size():
		country_option.add_item(CountryData.label_at(i))
	country_option.selected = CountryData.index_of(Settings.country)
	country_option.item_selected.connect( func(index: int) -> void :
		Settings.set_country(CountryData.code_at(index))
		country_flag.set_country(Settings.country)
		_toast("СТРАНА: %s" % Settings.get_country_name()))
	country_row.add_child(country_option)

	parent.add_child(_label(
		"Флаг страны показывается в виджете рейтинга рядом с ником.", 
		&"KickerLabel", 12, UITheme.MENU_MUTED))

	var avatars: = GridContainer.new()
	avatars.columns = 8
	avatars.add_theme_constant_override("h_separation", 8)
	avatars.add_theme_constant_override("v_separation", 8)
	parent.add_child(avatars)
	for i in Settings.AVATARS.size():
		var avatar_button: = Button.new()
		avatar_button.custom_minimum_size = Vector2(46, 46)
		avatar_button.icon = load(Settings.AVATARS[i]) as Texture2D
		avatar_button.expand_icon = true
		avatar_button.theme_type_variation = &"SmallButton" if i != Settings.avatar_index else &"AccentButton"
		avatar_button.pressed.connect( func() -> void :
			Settings.set_profile(Settings.nickname, i)
			_render_page())
		avatars.add_child(avatar_button)

	parent.add_child(_label(
		"Сброс очищает накопленные выстрелы, попадания и рекорд скорости.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))

	var reset_stats: = Button.new()
	reset_stats.text = "СБРОСИТЬ СТАТИСТИКУ"
	reset_stats.theme_type_variation = &"SmallButton"
	reset_stats.custom_minimum_size = Vector2(220, 34)
	reset_stats.pressed.connect( func() -> void :
		Settings.reset_stats()
		_refresh_header()
		_toast("СТАТИСТИКА СБРОШЕНА"))
	parent.add_child(reset_stats)


func _section_header(text: String) -> Control:
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	var label: = _label(text, &"AccentLabel", 15, UITheme.GOLD)
	label.add_theme_font_override("font", UITheme.ui_font(800))
	box.add_child(label)
	box.add_child(HSeparator.new())
	return box





func _render_mobile_settings(parent: VBoxContainer) -> void :
	_mobile_box = VBoxContainer.new()
	_mobile_box.name = "MobileControlsSettings"
	_mobile_box.add_theme_constant_override("separation", 6)
	parent.add_child(_mobile_box)
	# Раскладка мобильных кнопок доступна и на ПК — чтобы настроить заранее.
	_mobile_box.visible = true

	_mobile_box.add_child(_section_header("МОБИЛЬНОЕ УПРАВЛЕНИЕ"))
	_mobile_box.add_child(_label(
		"Три раскладки сохраняются отдельно. Размер и прозрачность "
		+ "настраиваются у каждой кнопки отдельно — тапом в редакторе.", 
		&"KickerLabel", 10, UITheme.MENU_MUTED))

	var slot_row: = HBoxContainer.new()
	slot_row.add_theme_constant_override("separation", 6)
	var slot_caption: = _label("РАСКЛАДКА", &"Label", 12, UITheme.MENU_TEXT)
	slot_caption.custom_minimum_size = Vector2(96, 0)
	slot_row.add_child(slot_caption)
	for i in Settings.MOBILE_SLOT_COUNT:
		var slot_button: = Button.new()
		slot_button.text = str(i + 1)
		slot_button.custom_minimum_size = Vector2(0, 32)
		slot_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_button.theme_type_variation = &"AccentButton"\
		if i == Settings.mobile_slot else &"SmallButton"
		slot_button.tooltip_text = "Активная раскладка %d." % (i + 1)
		slot_button.pressed.connect(_select_mobile_slot.bind(i))
		slot_row.add_child(slot_button)

	var preset: = OptionButton.new()
	preset.custom_minimum_size = Vector2(148, 32)
	preset.tooltip_text = "Заменить активную раскладку готовым пресетом."


	preset.add_item("ПРЕСЕТ")
	preset.set_item_disabled(0, true)
	for entry in Settings.MOBILE_PRESETS:
		preset.add_item(str(entry))
	preset.select(0)
	preset.item_selected.connect( func(index: int) -> void :
		if index <= 0:
			return
		Settings.set_mobile_preset(index - 1)
		preset.select(0))
	slot_row.add_child(preset)
	_mobile_box.add_child(slot_row)

	var gyro_row: = HBoxContainer.new()
	gyro_row.add_theme_constant_override("separation", 8)
	gyro_row.add_child(_toggle("ГИРОСКОП", Settings.gyro_enabled,
		func(value: bool) -> void : Settings.set_gyro_enabled(value)))
	gyro_row.add_child(_expander())
	var calibrate: = Button.new()
	calibrate.text = "КАЛИБРОВАТЬ"
	calibrate.theme_type_variation = &"SmallButton"
	calibrate.custom_minimum_size = Vector2(170, 32)
	calibrate.tooltip_text = "Положите телефон ровно и откалибруйте ноль гироскопа."
	calibrate.pressed.connect( func() -> void :
		Settings.request_gyro_calibration()
		_toast("ГИРОСКОП КАЛИБРУЕТСЯ — ДЕРЖИТЕ ТЕЛЕФОН РОВНО"))
	gyro_row.add_child(calibrate)
	gyro_row.visible = _is_mobile
	_mobile_box.add_child(gyro_row)
	var gyro_slider_row: HBoxContainer = _add_slider(_mobile_box, "СИЛА ГИРОСКОПА",
		Settings.GYRO_SENS_MIN, Settings.GYRO_SENS_MAX, 0.05,
		Settings.gyro_sensitivity, "×%.2f",
		func(value: float) -> void : Settings.set_gyro_sensitivity(value))
	gyro_slider_row.visible = _is_mobile

	var customize: = Button.new()
	customize.name = "CustomizeUIButton"
	customize.text = "НАСТРОИТЬ КНОПКИ И ДЖОЙСТИК"
	customize.custom_minimum_size = Vector2(0, 42)
	customize.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	customize.tooltip_text = "Перетаскивайте виджеты и настраивайте каждый тапом."
	customize.pressed.connect(_open_mobile_editor)
	_mobile_box.add_child(customize)

	var ui_code: = ConfigCodeUI.new()
	ui_code.setup("КОД РАСКЛАДОК", 
		"Переносит все три раскладки, размеры и прозрачность кнопок.", 
		Settings.get_mobile_code, _apply_mobile_code)
	_mobile_box.add_child(ui_code)





func _apply_crosshair_code(code: String) -> bool:
	if not Settings.apply_crosshair_code(code):
		return false
	call_deferred("_render_page")
	return true


func _apply_colors_code(code: String) -> bool:
	if not Settings.apply_colors_code(code):
		return false
	call_deferred("_render_page")
	return true


func _apply_mobile_code(code: String) -> bool:
	if not Settings.apply_mobile_code(code):
		return false
	call_deferred("_render_page")
	return true


func _apply_hands_code(code: String) -> bool:
	if not Settings.apply_hands_code(code):
		return false
	call_deferred("_render_page")
	return true


func _select_mobile_slot(index: int) -> void :
	Settings.select_mobile_slot(index)
	_render_page()



func _open_mobile_editor() -> void :
	LayoutEditor.new().open(self, func() -> void : _render_page())




func _open_hud_layout_editor() -> void :
	HudLayoutEditor.new().open(self, null, func() -> void : _render_page())


func _add_slider(parent: VBoxContainer, caption: String, min_value: float, max_value: float, 
		step: float, value: float, fmt: String, on_change: Callable) -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var name_label: = _label(caption, &"Label", 13, UITheme.MENU_TEXT)
	name_label.custom_minimum_size = Vector2(150, 0)
	row.add_child(name_label)

	var slider: = HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(slider)

	var value_label: = _label(fmt % (value * 100.0 if fmt.contains("%%") else value), 
		&"KickerLabel", 15, UITheme.GOLD_BRIGHT)
	value_label.add_theme_font_override("font", UITheme.ui_font(800))
	value_label.custom_minimum_size = Vector2(50, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)

	slider.value_changed.connect( func(new_value: float) -> void :
		var shown: = new_value * 100.0 if fmt.contains("%%") else new_value
		value_label.text = fmt % shown
		on_change.call(new_value))
	return row


func _add_option(parent: VBoxContainer, caption: String, labels: Array, selected: int, 
		on_change: Callable) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var name_label: = _label(caption, &"Label", 13, UITheme.MENU_TEXT)
	name_label.custom_minimum_size = Vector2(150, 0)
	row.add_child(name_label)

	var option: = OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.add_theme_font_override("font", UITheme.ui_font(800))
	option.add_theme_font_size_override("font_size", 15)
	option.get_popup().add_theme_font_override("font", UITheme.ui_font(800))
	option.get_popup().add_theme_font_size_override("font_size", 15)
	for entry in labels:
		option.add_item(str(entry))
	option.selected = clampi(selected, 0, maxi(labels.size() - 1, 0))
	option.item_selected.connect( func(index: int) -> void : on_change.call(index))
	row.add_child(option)


func _toggle(caption: String, value: bool, on_change: Callable) -> CheckButton:
	var toggle: = CheckButton.new()
	toggle.text = caption
	toggle.button_pressed = value
	toggle.add_theme_font_override("font", UITheme.ui_font(800))
	toggle.add_theme_font_size_override("font_size", 15)
	toggle.add_theme_color_override("font_color", UITheme.MENU_TEXT)
	toggle.toggled.connect( func(pressed: bool) -> void : on_change.call(pressed))
	return toggle


func _crosshair_preview() -> Control:
	var frame: = PanelContainer.new()
	frame.custom_minimum_size = Vector2(260, 140)
	frame.add_theme_stylebox_override("panel", _flat_box(
		Color(0.04, 0.022, 0.004, 1.0), UITheme.MENU_BORDER, 1, 8, 10.0))
	var center: = CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(center)

	var preview: = Control.new()
	preview.set_script(CrosshairScript)
	preview.set("preview_scale", 3.4)
	preview.set("show_hitmarker", false)
	preview.custom_minimum_size = Vector2(230, 120)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(preview)
	return frame


func _color_row(parent: VBoxContainer, caption: String, current: Color, presets: Array, 
		setter: Callable) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var name_label: = _label(caption, &"Label", 13, UITheme.MENU_TEXT)
	name_label.custom_minimum_size = Vector2(150, 0)
	row.add_child(name_label)

	var current_box: = PanelContainer.new()
	current_box.custom_minimum_size = Vector2(26, 24)
	current_box.add_theme_stylebox_override("panel", 
		_flat_box(current, UITheme.MENU_TEXT, 1, 3, 0.0))
	row.add_child(current_box)



	var live: = {"color": current}
	var apply: = func(color: Color) -> void :
		live["color"] = color
		setter.call(color)
		current_box.add_theme_stylebox_override("panel", 
			_flat_box(color, UITheme.MENU_TEXT, 1, 3, 0.0))

	for preset in presets:
		var color: Color = preset
		var swatch: = Button.new()
		swatch.custom_minimum_size = Vector2(30, 26)
		var box: = _flat_box(color, UITheme.MENU_BORDER_LIGHT, 1, 3, 0.0)
		swatch.add_theme_stylebox_override("normal", box)
		var hover: = box.duplicate() as StyleBoxFlat
		hover.border_color = UITheme.MENU_TEXT
		hover.set_border_width_all(2)
		swatch.add_theme_stylebox_override("hover", hover)
		swatch.add_theme_stylebox_override("pressed", hover)
		swatch.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		swatch.pressed.connect( func() -> void : apply.call(color))
		row.add_child(swatch)

	var wheel: = Button.new()
	wheel.text = "ЛЮБОЙ ЦВЕТ"
	wheel.theme_type_variation = &"SmallButton"
	wheel.custom_minimum_size = Vector2(136, 26)
	wheel.tooltip_text = "RGB-круг: выбрать любой оттенок"
	wheel.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	wheel.pressed.connect( func() -> void :
		ColorWheel.open(_ui, theme, live["color"], apply, current_box))
	row.add_child(wheel)


func _fps_index() -> int:
	var index: int = Settings.FPS_VALUES.find(Settings.fps_limit)
	return maxi(index, 0)


func _begin_rebind(action: String, button: Button) -> void :
	_rebind_action = action
	_rebind_button = button
	button.text = "НАЖМИТЕ КЛАВИШУ ИЛИ КНОПКУ МЫШИ..."



func _finish_rebind(code: int) -> void :
	Settings.set_keybind(_rebind_action, code)
	_rebind_action = ""
	_rebind_button = null
	_render_page()



func _cancel_rebind() -> void :
	if is_instance_valid(_rebind_button):
		_rebind_button.text = Settings.get_key_label(_rebind_action)
	_rebind_action = ""
	_rebind_button = null




func _label(text: String, variation: StringName, size: int, color: Color) -> Label:
	var label: = Label.new()
	label.text = text
	if variation != &"" and variation != &"Label":
		label.theme_type_variation = variation


	var settings_page: = _page == "settings"
	var shown_size: = size
	if settings_page:
		if variation == &"Label":
			label.add_theme_font_override("font", UITheme.ui_font(800))
			shown_size = maxi(size, 15)
		elif variation == &"KickerLabel":
			label.add_theme_font_override("font", UITheme.ui_font(700))
			shown_size = maxi(size, 13)
	elif variation == &"KickerLabel":
		label.add_theme_font_override("font", UITheme.ui_font(700))


	if settings_page and text.length() > 44:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size.x = 0.0
	label.add_theme_font_size_override("font_size", shown_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _spacer(height: int, expand: = false) -> Control:
	var spacer: = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if expand:
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return spacer


func _expander() -> Control:
	var node: = Control.new()
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return node


func _flat_box(bg: Color, border: Color, border_width: int, radius: int, 
		pad: float) -> StyleBoxFlat:
	var box: = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = pad
	box.content_margin_right = pad
	box.content_margin_top = pad
	box.content_margin_bottom = pad
	return box


func _item_box(rarity_color: Color, selected: bool) -> StyleBoxFlat:
	var box: = _flat_box(
		Color(0.085, 0.048, 0.01, 0.98) if not selected else Color(0.15, 0.088, 0.02, 1.0), 
		rarity_color if selected else UITheme.MENU_BORDER, 2 if selected else 1, 8, 14.0)
	box.border_width_left = 4
	return box


func _format_number(value: int) -> String:
	var text: = str(maxi(value, 0))
	var out: = ""
	var count: = 0
	for i in range(text.length() - 1, -1, -1):
		out = text[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = " " + out
	return out
