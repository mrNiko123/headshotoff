extends SubViewportContainer

# Живое 3D-превью скина игрока для карточки магазина скинов.

const MannequinScene := preload("res://scenes/mannequin.tscn")
const PlayerSkinData := preload("res://scripts/player_skin_data.gd")

const PREVIEW_SIZE: = Vector2(200, 168)
const PREVIEW_FOV: = 30.0
const FIT_MARGIN: = 1.1

const BASE_YAW: = 198.0
const SWAY_YAW: = 10.0

const PREVIEW_FPS: = 24.0


var skin_id: = PlayerSkinData.DEFAULT_ID

var _viewport: SubViewport
var _camera: Camera3D
var _holder: Node3D
var _framed: = AABB()
var _phase: = 0.0
var _active: = false
var _render_clock: = 0.0


func _ready() -> void :
	stretch = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = PREVIEW_SIZE

	_viewport = SubViewport.new()
	_viewport.own_world_3d = true
	_viewport.transparent_bg = true
	_viewport.size = Vector2i(int(PREVIEW_SIZE.x), int(PREVIEW_SIZE.y))
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_viewport.msaa_3d = Viewport.MSAA_2X
	add_child(_viewport)

	_build_environment()

	_camera = Camera3D.new()
	_camera.fov = PREVIEW_FOV
	_camera.near = 0.01
	_camera.far = 16.0
	_camera.current = true
	_viewport.add_child(_camera)

	_holder = Node3D.new()
	_holder.rotation_degrees = Vector3(0.0, BASE_YAW, 0.0)
	_viewport.add_child(_holder)

	_rebuild()
	resized.connect(_on_resized)

	_phase = float(skin_id.length()) * 0.41


func setup(new_skin: String) -> void :
	skin_id = new_skin
	if _holder != null:
		_rebuild()


func _process(delta: float) -> void :
	if _viewport == null:
		return
	var on: = is_visible_in_tree()
	if on != _active:
		_active = on
		if not on:
			_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		else:
			_request_render()
	if not on or _holder == null:
		return
	_phase += delta
	_holder.rotation_degrees = Vector3(0.0, 
		BASE_YAW + sin(_phase * 0.5) * SWAY_YAW, 0.0)
	_render_clock += delta
	if _render_clock >= 1.0 / PREVIEW_FPS:
		_render_clock = 0.0
		_request_render()


func _request_render() -> void :
	if _viewport != null:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _on_resized() -> void :
	if _viewport == null:
		return
	var target: = Vector2i(maxi(int(size.x), 2), maxi(int(size.y), 2))
	if _viewport.size != target:
		_viewport.size = target
	_fit_camera(_framed)
	_request_render()


func _build_environment() -> void :
	var env: = Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.84, 0.89, 1.0, 1.0)
	env.ambient_light_energy = 0.85
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 1.02
	var world_env: = WorldEnvironment.new()
	world_env.environment = env
	_viewport.add_child(world_env)

	var key: = DirectionalLight3D.new()
	key.light_color = Color(1.0, 0.95, 0.86, 1.0)
	key.light_energy = 1.6
	key.shadow_enabled = false
	key.rotation_degrees = Vector3(-30.0, -35.0, 0.0)
	_viewport.add_child(key)

	var rim: = DirectionalLight3D.new()
	rim.light_color = Color(1.0, 0.78, 0.34, 1.0)
	rim.light_energy = 1.15
	rim.shadow_enabled = false
	rim.rotation_degrees = Vector3(22.0, 148.0, 0.0)
	_viewport.add_child(rim)


func _rebuild() -> void :
	for child in _holder.get_children():
		_holder.remove_child(child)
		child.queue_free()

	var skin: Dictionary = PlayerSkinData.get_skin(skin_id)
	var model_path: = str(skin.get("model", ""))
	var built: = false
	if not model_path.is_empty() and ResourceLoader.exists(model_path):
		var mesh: Mesh = load(model_path) as Mesh
		if mesh != null:
			PlayerSkinData.brighten_mesh(mesh)
			var body: = MeshInstance3D.new()
			body.mesh = mesh
			_holder.add_child(body)
			built = true
	if not built:
		var hero: Node3D = MannequinScene.instantiate() as Node3D
		if hero != null:
			_holder.add_child(hero)

	_framed = _bounds(_holder)
	_fit_camera(_framed)
	_request_render()


func _bounds(root: Node3D) -> AABB:
	var box: = AABB()
	var has_box: = false
	var inv: Transform3D = root.global_transform.affine_inverse()
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = node as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var local: Transform3D = inv * mi.global_transform
		var part: AABB = local * mi.mesh.get_aabb()
		if has_box:
			box = box.merge(part)
		else:
			box = part
			has_box = true
	if not has_box:
		return AABB(Vector3(0.0, 0.95, 0.0), Vector3(0.6, 1.9, 0.6))
	return box


func _fit_camera(box: AABB) -> void :
	if _camera == null or box.size == Vector3.ZERO:
		return
	var w: = maxf(size.x, PREVIEW_SIZE.x)
	var h: = maxf(size.y, PREVIEW_SIZE.y)
	var half_fov: = deg_to_rad(PREVIEW_FOV) * 0.5
	var h_tan: = maxf(tan(half_fov) * (w / h), 0.01)
	var v_tan: = maxf(tan(half_fov), 0.01)
	var distance: = maxf(box.size.x * 0.5 / h_tan, box.size.y * 0.5 / v_tan) * FIT_MARGIN
	distance = maxf(distance, 0.05)
	var center: = box.get_center()
	_camera.position = center + Vector3(0.0, 0.0, distance)
	_camera.look_at(center, Vector3.UP)
