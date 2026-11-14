extends SubViewportContainer






const WeaponBuilder = preload("res://scripts/weapon_builder.gd")


const PREVIEW_SIZE: = Vector2(150, 62)
const PREVIEW_FOV: = 40.0

const FIT_MARGIN: = 1.16


const BASE_ROTATION: = Vector3(-16.0, -72.0, 8.0)
const SWAY_YAW: = 13.0
const SWAY_PITCH: = 5.0
const SWAY_ROLL: = 3.0



const PAIR_SKINS: = ["dagger"]
const PAIR_TILT: = 20.0


const PAIR_GAP: = 0.014



const PREVIEW_FPS: = 30.0

var weapon_id: = "awp"
var skin_id: = "default"


var tint: = Color.TRANSPARENT

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
	_holder.rotation_degrees = BASE_ROTATION
	_viewport.add_child(_holder)

	_rebuild()
	resized.connect(_on_resized)


	_phase = float(weapon_id.length()) * 0.37 + float(skin_id.length()) * 0.53

	_render_clock = fposmod(_phase, 1.0) / PREVIEW_FPS



func setup(new_weapon: String, new_skin: String) -> void :
	weapon_id = new_weapon
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
	_holder.rotation_degrees = Vector3(
		BASE_ROTATION.x + sin(_phase * 0.62) * SWAY_PITCH, 
		BASE_ROTATION.y + sin(_phase * 0.44 + 0.7) * SWAY_YAW, 
		BASE_ROTATION.z + sin(_phase * 0.51 + 1.4) * SWAY_ROLL)
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
	env.ambient_light_energy = 0.78
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 1.02
	var world_env: = WorldEnvironment.new()
	world_env.environment = env
	_viewport.add_child(world_env)

	var key: = DirectionalLight3D.new()
	key.light_color = Color(1.0, 0.94, 0.84, 1.0)
	key.light_energy = 1.45
	key.shadow_enabled = false
	key.rotation_degrees = Vector3(-34.0, -38.0, 0.0)
	_viewport.add_child(key)

	var rim: = DirectionalLight3D.new()
	rim.light_color = Color(1.0, 0.74, 0.28, 1.0)
	rim.light_energy = 1.0
	rim.shadow_enabled = false
	rim.rotation_degrees = Vector3(24.0, 152.0, 0.0)
	_viewport.add_child(rim)





func _rebuild() -> void :
	for child in _holder.get_children():
		_holder.remove_child(child)
		child.queue_free()
	if weapon_id == "":
		return


	var to_cam: = (_holder.basis.inverse() * Vector3(0.0, 0.0, 1.0)).normalized()
	var count: = 2 if PAIR_SKINS.has(skin_id) else 1
	for i in count:
		var pivot: = Node3D.new()
		_holder.add_child(pivot)
		if count > 1:


			pivot.basis = Basis(to_cam, deg_to_rad(PAIR_TILT * (1.0 if i == 0 else -1.0)))
			pivot.position = to_cam * PAIR_GAP * (0.5 if i == 0 else -0.5)
		var weapon: = WeaponBuilder.build(pivot, weapon_id, skin_id, false)
		if weapon == null:
			continue
		WeaponBuilder.apply_tint(weapon, tint)
		var local_box: = WeaponBuilder.model_aabb(weapon)
		weapon.position -= local_box.get_center()
	_framed = WeaponBuilder.model_aabb(_holder)
	_fit_camera(_framed)
	_request_render()





func _fit_camera(box: AABB) -> void :
	if _camera == null or box.size == Vector3.ZERO:
		return
	var w: = maxf(size.x, PREVIEW_SIZE.x)
	var h: = maxf(size.y, PREVIEW_SIZE.y)
	var half_fov: = deg_to_rad(PREVIEW_FOV) * 0.5
	var h_tan: = maxf(tan(half_fov) * (w / h), 0.01)
	var v_tan: = maxf(tan(half_fov), 0.01)
	var distance: = maxf(box.size.x * 0.5 / h_tan, box.size.y * 0.5 / v_tan)\
	* FIT_MARGIN
	distance = maxf(distance, 0.05)
	var center: = box.get_center()
	_camera.position = center + Vector3(0.0, 0.0, distance)
	_camera.look_at(center, Vector3.UP)
