extends CharacterBody3D




signal shot_fired(hit: Dictionary)



signal noise_made(kind: String, position: Vector3, loudness: float)
signal melee_hit(hit: Dictionary)
signal ammo_changed(ammo: int, magazine: int, reloading: bool)
signal weapon_changed(ammo: Dictionary)
signal spawned_mannequin_requested
signal landed(impact_speed: float)
signal wall_jumped
signal bounced(strength: float)
signal slide_boosted(strength: float)
signal scope_changed(active: bool)
signal health_changed(health: float, max_health: float)
signal damaged(amount: float, from_position: Vector3)
signal died

const WeaponData = preload("res://scripts/weapon_data.gd")
const MeshKit = preload("res://scripts/mesh_kit.gd")
const BulletHoleShader = preload("res://shaders/bullet_hole.gdshader")

const RUN_SPEED: = 9.6
const CROUCH_SPEED: = 4.2
const GROUND_ACCEL: = 10.0
const AIR_ACCEL: = 12.0


const AIR_WISH_CAP: = 0.96
const AIR_LEAN: = 2.4
const AIR_LEAN_SPEED: = 7.0
const FRICTION: = 6.0
const STOP_SPEED: = 2.0
const GRAVITY: = 23.5
const JUMP_VELOCITY: = 6.4
const MAX_SPEED: = 18.0



const MAX_SPEED_CAP: = 1000000000.0
const BHOP_STEP: = 0.8
const BHOP_KICK: = 0.2
const BHOP_CHAIN_WINDOW: = 0.16
const SLIDE_MIN_SPEED: = 6.0
const SLIDE_SLOPE_MIN: = 0.03
const SLIDE_GAIN: = 2.6
const EYE_HEIGHT: = 1.62
const CROUCH_EYE_HEIGHT: = 1.05
const CROUCH_LERP: = 12.0
const MOUSE_BASE: = 0.00205



const GYRO_BASE_GAIN: = 1.15

const GYRO_DEADZONE_MIN: = 0.028
const GYRO_DEADZONE_NOISE: = 2.5
const GYRO_CALIBRATE_TIME: = 0.75
const GYRO_BIAS_TRACK: = 0.65


const GYRO_REST_TIME: = 0.9
const GYRO_REST_LINEAR: = 0.55
const GYRO_REST_RATE: = 0.28

const GYRO_MAX_RATE: = 9.0
const GYRO_AXIS_LERP: = 0.22
const COYOTE_TIME: = 0.1

const MAX_HEALTH: = 100.0



const JUMP_BUFFER_TIME: = 0.14
const MAX_HEIGHT: = 2.4


const DEFAULT_SCOPE_FOV: = 22.0
const SCOPE_ZOOM_IN_SPEED: = 30.0
const SCOPE_MOVE_SCALE: = 0.42
const SCOPE_SPREAD_SCALE: = 0.16
const SCOPE_SENS_MIN: = 0.22

const SLOT_PRIMARY: = 0
const SLOT_SECONDARY: = 1
const SLOT_MELEE: = 2




const AWP_BOLT_DELAY: = 0.22

const WALL_JUMP_PUSH: = 8.6
const WALL_JUMP_LIFT: = 8.4



const WALL_JUMP_LIFT_MAX: = 14.0
const WALL_JUMP_PUSH_MAX: = 11.6
const WALL_JUMP_RUNUP_REF: = RUN_SPEED
const WALL_JUMP_COOLDOWN: = 0.18





const TRACER_POOL: = 8
const SPARK_POOL: = 10
const IMPACT_LIGHT_POOL: = 4


const BULLET_HOLE_POOL: = 64
const BULLET_HOLE_SIZE: = 0.075

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head / Camera3D
@onready var viewmodel = $Head / Camera3D / Viewmodel
@onready var collision: CollisionShape3D = $CollisionShape3D

var _vm_viewport: SubViewport
var _vm_container: SubViewportContainer
var _vm_camera: Camera3D




var _audio_listener: AudioListener3D


var _vm_environment: Environment

var active: = true:
	set(value):
		if active == value:
			return
		active = value
		if not value:
			_jump_buffer = 0.0


			_touch_fire = false
			_touch_fire_latch = false
		if is_node_ready():


			_set_viewmodel_updating(value and viewmodel != null and viewmodel.visible)

var _pitch: = 0.0
var _recoil_pitch: = 0.0


var _gyro_ready: = false
var _gyro_bias: = Vector2.ZERO
var _gyro_calibrate: = 0.0
var _gyro_cal_sum: = Vector2.ZERO
var _gyro_cal_samples: = 0
var _gyro_cal_max: = 0.0
var _gyro_noise: = GYRO_DEADZONE_MIN



var _gyro_up: = Vector2(0.0, 1.0)
var _gyro_right: = Vector2(1.0, 0.0)
var _gyro_rest: = 0.0
var _was_on_floor: = true
var _coyote: = 0.0
var _ground_time: = 0.0
var _jump_cooldown: = 0.0


var _jump_buffer: = 0.0
var _has_jumped: = false
var _bhop_chain: = 0
var _speed_cap: = MAX_SPEED
var _wall_jump_cooldown: = 0.0



var _wall_runup: = 0.0
var _slide_boost_cooldown: = 0.0

var _slot: = SLOT_PRIMARY
var _primary_id: = "awp"
var _primary_skin: = "default"
var _pistol_id: = "deagle"
var _pistol_skin: = "chrome"
var _melee_skin: = "forest"



var _duel_weapon_locked: = false
var _weapon_id: = "awp"
var _weapon: Dictionary = {}
var _is_melee: = false
var _automatic: = false
var _fire_interval: = 1.3
var _spread: = 0.0012
var _shot_bloom: = 0.0
var _recoil: = 0.06


var _recoil_recovery: = 9.0

var _recoil_limit: = 0.157
var _melee_range: = 2.4

var _fire_cooldown: = 0.0


var _melee_cooldown: = 0.0


var _touch_fire: = false


var _touch_fire_latch: = false
var _ammo: = 5
var _magazine: = 5
var _primary_ammo: = -1
var _secondary_ammo: = -1
var _reloading: = false
var _reload_time: = 0.0
var _reload_duration: = 2.5



var _reload_magazine: = 0

var _bob_time: = 0.0
var _bob: = Vector2.ZERO
var _land_dip: = 0.0
var _step_timer: = 0.0
var _speed: = 0.0

var _scoped: = false


var _can_scope: = true


var _crouch_latched: = false
var _aim_latched: = false
var _scope_fov: = DEFAULT_SCOPE_FOV

var _crouched: = false
var _crouch_visual: = 0.0
var _strafe_lean: = 0.0
var _stand_height: = 1.8
var _crouch_height: = 1.12
var _stand_shape_y: = 0.9

var _spawn_position: = Vector3.ZERO
var _spawn_yaw: = 0.0



var health: = MAX_HEALTH
var _alive: = true

var _tracers: Array[MeshInstance3D] = []
var _tracer_mats: Array[StandardMaterial3D] = []
var _sparks: Array[MeshInstance3D] = []
var _spark_mats: Array[StandardMaterial3D] = []
var _impact_lights: Array[OmniLight3D] = []
var _bullet_holes: Array[MeshInstance3D] = []
var _tracer_index: = 0
var _spark_index: = 0
var _impact_light_index: = 0
var _bullet_hole_index: = 0



var _ray_query: PhysicsRayQueryParameters3D


func _ready() -> void :
	add_to_group("player")
	_spawn_position = global_position
	_spawn_yaw = rotation.y
	_pitch = head.rotation.x
	_setup_crouch_shape()
	_primary_id = Settings.weapon_id
	_primary_skin = Settings.weapon_skin
	_pistol_id = Settings.pistol_id
	_pistol_skin = Settings.pistol_skin
	_melee_skin = Settings.knife_skin
	_slot = SLOT_PRIMARY
	_apply_weapon(false)
	camera.fov = Settings.fov
	camera.far = Settings.draw_distance
	viewmodel.set_fov(Settings.fov)
	head.position = Vector3(0.0, EYE_HEIGHT, 0.0)
	Settings.settings_changed.connect(_on_settings_changed)
	Settings.render_scale_changed.connect(_on_render_scale_changed)
	Settings.gyro_calibration_requested.connect(_reset_gyro_calibration)
	_setup_viewmodel_layer()
	_setup_audio_listener()
	_build_effect_pools()




func _setup_audio_listener() -> void :
	_audio_listener = AudioListener3D.new()
	_audio_listener.name = "AudioListener"
	camera.add_child(_audio_listener)
	_audio_listener.make_current()




func _emit_noise(kind: String, loudness: float, height: = 0.15) -> void :
	noise_made.emit(kind, global_position + Vector3.UP * height, 
		clampf(loudness, 0.0, 1.0))





func _setup_viewmodel_layer() -> void :
	var layer: = CanvasLayer.new()
	layer.name = "ViewmodelLayer"
	layer.layer = 0
	add_child(layer)

	var container: = SubViewportContainer.new()
	container.name = "ViewmodelView"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.stretch = true



	container.stretch_shrink = 1
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(container)
	_vm_container = container
	_apply_viewmodel_brightness()

	_vm_viewport = SubViewport.new()


	_vm_viewport.own_world_3d = true
	_vm_viewport.transparent_bg = true
	_vm_viewport.msaa_3d = Settings.msaa_level



	_vm_viewport.scaling_3d_scale = Settings.get_effective_render_scale()
	_vm_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_vm_viewport.handle_input_locally = false
	container.add_child(_vm_viewport)

	_vm_camera = Camera3D.new()
	_vm_camera.name = "ViewmodelCamera"
	_vm_camera.current = true
	_vm_camera.cull_mask = 4
	_vm_camera.near = 0.01


	_vm_camera.far = 5.0
	_vm_viewport.add_child(_vm_camera)
	_build_viewmodel_environment()



	viewmodel.reparent(_vm_camera, false)


	camera.cull_mask = camera.cull_mask & ~ 4
	_sync_viewmodel_camera()





func _build_viewmodel_environment() -> void :
	var env: = Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.66, 0.72, 0.84, 1.0)






	env.ambient_light_energy = 0.34
	env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED




	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 0.98
	_vm_environment = env

	var world: = WorldEnvironment.new()
	world.name = "ViewmodelEnvironment"
	world.environment = env
	_vm_viewport.add_child(world)








	var key: = DirectionalLight3D.new()
	key.name = "ViewmodelKey"





	key.layers = 4
	key.light_cull_mask = 4
	key.light_color = Color(1.0, 0.95, 0.88, 1.0)




	key.light_energy = 0.82


	key.light_specular = 0.5
	key.shadow_enabled = false
	key.rotation_degrees = Vector3(-38.0, -30.0, 0.0)
	_vm_camera.add_child(key)










	var fill: = DirectionalLight3D.new()
	fill.name = "ViewmodelFill"
	fill.layers = 4
	fill.light_cull_mask = 4
	fill.light_color = Color(1.0, 0.96, 0.9, 1.0)
	fill.light_energy = 0.55


	fill.light_specular = 0.0
	fill.shadow_enabled = false


	fill.rotation_degrees = Vector3(10.0, -18.0, 0.0)
	_vm_camera.add_child(fill)


func _sync_viewmodel_camera() -> void :
	if _vm_camera == null:
		return
	_vm_camera.global_transform = camera.global_transform
	_vm_camera.fov = camera.fov
	_vm_camera.keep_aspect = camera.keep_aspect
	_vm_camera.h_offset = camera.h_offset
	_vm_camera.v_offset = camera.v_offset






func _set_viewmodel_updating(on: bool) -> void :
	if _vm_viewport == null:
		return
	var mode: = SubViewport.UPDATE_ALWAYS if on else SubViewport.UPDATE_DISABLED
	if _vm_viewport.render_target_update_mode != mode:
		_vm_viewport.render_target_update_mode = mode


func _set_viewmodel_visible(on: bool) -> void :
	if viewmodel.visible != on:
		viewmodel.visible = on


	if viewmodel.is_processing() != on:
		viewmodel.set_process(on)
	if _vm_container != null and _vm_container.visible != on:
		_vm_container.visible = on
	_set_viewmodel_updating(on)





func _apply_viewmodel_brightness() -> void :
	if _vm_container == null:
		return
	var value: = clampf(Settings.brightness, 0.1, 2.0)
	_vm_container.self_modulate = Color(value, value, value, 1.0)


func _unhandled_input(event: InputEvent) -> void :
	if not active:
		return





	if event is InputEventMouseMotion and not Settings.is_touch_device()\
	and (Settings.is_mobile() or Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		var relative: Vector2 = event.screen_relative
		if relative == Vector2.ZERO:
			relative = event.relative
		apply_look(relative)

	if event.is_action_pressed("jump"):
		_jump_cooldown = 0.0


		_jump_buffer = JUMP_BUFFER_TIME




func _jump_bound_to_wheel() -> bool:
	return Settings.is_wheel_bind("jump")





func apply_look(relative: Vector2) -> void :
	if relative == Vector2.ZERO:
		return
	var sensitivity: = MOUSE_BASE * Settings.mouse_sensitivity * _scope_sensitivity()
	rotate_y( - relative.x * sensitivity)
	_pitch = clampf(_pitch - relative.y * sensitivity, 
		deg_to_rad(-88.5), deg_to_rad(88.5))
	head.rotation.x = _pitch + _recoil_pitch
	viewmodel.add_look(relative)








func _apply_gyro(delta: float) -> void :
	if not Settings.gyro_enabled or not Settings.is_touch_device():
		_gyro_ready = false
		_gyro_rest = 0.0
		return
	var rate: = Input.get_gyroscope()
	var sensor: = Vector2(rate.x, rate.y)
	_update_gyro_axes()
	if not _gyro_ready:

		_gyro_bias = sensor
		_gyro_calibrate = GYRO_CALIBRATE_TIME
		_gyro_cal_sum = Vector2.ZERO
		_gyro_cal_samples = 0
		_gyro_cal_max = 0.0
		_gyro_noise = GYRO_DEADZONE_MIN
		_gyro_rest = 0.0
		_gyro_ready = true
		return
	if _gyro_calibrate > 0.0:


		_gyro_calibrate -= delta
		_gyro_cal_sum += sensor
		_gyro_cal_samples += 1
		_gyro_bias = _gyro_cal_sum / float(maxi(_gyro_cal_samples, 1))
		_gyro_cal_max = maxf(_gyro_cal_max, 
			(sensor - _gyro_bias).length())
		if _gyro_calibrate <= 0.0:


			_gyro_noise = clampf(_gyro_cal_max, GYRO_DEADZONE_MIN, 0.12)
		return
	_track_gyro_rest(sensor, delta)
	var motion: = sensor - _gyro_bias
	var deadzone: = maxf(GYRO_DEADZONE_MIN, _gyro_noise * GYRO_DEADZONE_NOISE)
	var length: = motion.length()
	if length <= deadzone:
		return


	motion *= smoothstep(deadzone, deadzone * 2.0, length)
	if motion.length() > GYRO_MAX_RATE:
		motion = motion.normalized() * GYRO_MAX_RATE
	var scale: = MOUSE_BASE * Settings.mouse_sensitivity
	if scale < 0.0001:
		return
	var gain: = GYRO_BASE_GAIN * Settings.gyro_sensitivity * delta / scale


	var yaw: = - motion.dot(_gyro_up)
	var pitch: = - motion.dot(_gyro_right)
	apply_look(Vector2(yaw, pitch) * gain)






func _update_gyro_axes() -> void :
	var gravity: = Input.get_gravity()
	if gravity.length() < 0.5:
		gravity = Input.get_accelerometer()
	var planar: = Vector2(gravity.x, gravity.y)
	if planar.length() < 0.8:
		return
	var target: = - planar.normalized()
	var blended: = _gyro_up.lerp(target, GYRO_AXIS_LERP)
	if blended.length() < 0.15:
		blended = target
	_gyro_up = blended.normalized()
	_gyro_right = Vector2(_gyro_up.y, - _gyro_up.x)






func _track_gyro_rest(sensor: Vector2, delta: float) -> void :
	var accel: = Input.get_accelerometer()
	var gravity: = Input.get_gravity()
	if accel.length() < 0.5:
		accel = gravity
	if accel.length() < 0.5:
		_gyro_rest = 0.0
		return
	var linear: = (accel - gravity).length()
	if linear < GYRO_REST_LINEAR and sensor.length() < GYRO_REST_RATE:
		_gyro_rest += delta
		if _gyro_rest >= GYRO_REST_TIME:
			_gyro_bias = _gyro_bias.lerp(sensor, 
				minf(1.0, delta * GYRO_BIAS_TRACK))
	else:
		_gyro_rest = 0.0




func _reset_gyro_calibration() -> void :
	_gyro_ready = false
	_gyro_calibrate = 0.0
	_gyro_rest = 0.0


func _notification(what: int) -> void :
	if what == NOTIFICATION_APPLICATION_FOCUS_IN\
	or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_reset_gyro_calibration()




func set_touch_fire(on: bool) -> void :
	if on and not _touch_fire:
		_touch_fire_latch = true
	_touch_fire = on


func _process(delta: float) -> void :
	if not active:
		return

	_fire_cooldown = maxf(0.0, _fire_cooldown - delta)
	_melee_cooldown = maxf(0.0, _melee_cooldown - delta)
	_recoil_pitch = lerpf(_recoil_pitch, 0.0, 
		1.0 - exp( - _recoil_recovery * delta))
	head.rotation.x = _pitch + _recoil_pitch
	if _shot_bloom > 0.0:
		_shot_bloom = maxf(0.0, _shot_bloom - 
			_shot_bloom * float(_weapon.get("bloom_decay", 6.0)) * delta)


	if Input.is_action_just_pressed("reload"):
		_start_reload()
	if Input.is_action_just_pressed("inspect"):
		viewmodel.play_inspect()
	# В режиме стройки BR слоты 1-3 выбирают материал, огонь подавлен.
	if not has_meta("br_build"):
		if Input.is_action_just_pressed("slot_primary"):
			_switch_slot(SLOT_PRIMARY)
		if Input.is_action_just_pressed("slot_secondary"):
			_switch_slot(SLOT_SECONDARY)
		if Input.is_action_just_pressed("slot_melee"):
			_switch_slot(SLOT_MELEE)
	if Input.is_action_just_pressed("spawn_mannequin"):
		spawned_mannequin_requested.emit()

	if Input.is_action_just_pressed("toggle_left_hand"):
		Settings.set_left_hand( not Settings.left_hand)

	if _reloading:
		_reload_time -= delta
		if _reload_time <= 0.0:
			_reloading = false
			_reload_time = 0.0
			var loaded: = _reload_magazine if _reload_magazine > 0 else _magazine
			if _slot == SLOT_SECONDARY:
				_secondary_ammo = loaded
			else:
				_primary_ammo = loaded
			if _is_melee:


				weapon_changed.emit(get_ammo_state())
			else:
				_ammo = loaded
				ammo_changed.emit(_ammo, _magazine, false)

	if _is_melee:
		var fire_held: = Input.is_action_pressed("shoot")
		var fire_just: = Input.is_action_just_pressed("shoot")
		if Settings.is_mobile():


			fire_held = _touch_fire
			fire_just = _touch_fire_latch
			_touch_fire_latch = false
		if has_meta("br_build"):
			pass
		elif fire_just:
			_try_slash()
		elif Input.is_action_just_pressed("aim") and viewmodel.has_heavy_attack():


			_try_slash(true)
	else:
		var wants_fire: = Input.is_action_pressed("shoot")
		var wants_fire_just: = Input.is_action_just_pressed("shoot")
		if Settings.is_mobile():
			wants_fire = _touch_fire
			wants_fire_just = _touch_fire_latch
			_touch_fire_latch = false
		if has_meta("br_build"):
			pass
		elif _automatic:
			if wants_fire:
				_try_fire()
		elif wants_fire_just:
			_try_fire()

	_speed = Vector2(velocity.x, velocity.z).length()
	_update_camera(delta)
	_apply_gyro(delta)
	_update_scope(delta)
	_sync_viewmodel_camera()
	viewmodel.update_motion(_speed, is_on_floor(), delta)
	_update_steps(delta)
	_fall_guard()


func _physics_process(delta: float) -> void :
	if not active:
		velocity = Vector3.ZERO
		return

	_jump_cooldown = maxf(0.0, _jump_cooldown - delta)
	_jump_buffer = maxf(0.0, _jump_buffer - delta)
	_wall_jump_cooldown = maxf(0.0, _wall_jump_cooldown - delta)
	_slide_boost_cooldown = maxf(0.0, _slide_boost_cooldown - delta)

	var input_dir: = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_direction: = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y))
	wish_direction.y = 0.0
	if wish_direction.length_squared() > 1.0:
		wish_direction = wish_direction.normalized()

	_update_crouch()
	var wish_speed: = CROUCH_SPEED if _crouched else RUN_SPEED
	if _scoped:
		wish_speed *= SCOPE_MOVE_SCALE

	var on_floor: = is_on_floor()



	var jump_held: = _jump_buffer > 0.0
	if not _jump_bound_to_wheel():
		jump_held = jump_held or Input.is_action_pressed("jump")

	if on_floor:
		_coyote = COYOTE_TIME
		_ground_time += delta
	else:
		_coyote = maxf(0.0, _coyote - delta)
		velocity.y -= GRAVITY * delta


	var jumped: = false
	if jump_held and on_floor and _jump_cooldown <= 0.0:
		velocity.y = JUMP_VELOCITY
		_coyote = 0.0
		_jump_cooldown = 0.1
		jumped = true
		_on_jump()
		_jump_buffer = 0.0
		_ground_time = 0.0



	if on_floor and not jumped:
		_apply_friction(delta)
		if wish_direction.length_squared() > 0.001:
			_accelerate(wish_direction, wish_speed, GROUND_ACCEL, delta)
	elif not on_floor:
		_air_accelerate(wish_direction, wish_speed, delta)

	_clamp_horizontal()
	var fall_speed: = maxf(0.0, - velocity.y)

	var runup_speed: = Vector2(velocity.x, velocity.z).length()
	if on_floor:
		_wall_runup = runup_speed
	else:
		_wall_runup = maxf(_wall_runup, runup_speed)
	move_and_slide()

	var now_floor: = is_on_floor()
	if now_floor and not _was_on_floor:
		_on_land(fall_speed)


	# отскоки от стен и блоков убраны: об стену теперь просто скользишь

	if now_floor and _ground_time > 0.45:
		_bhop_chain = 0
		_speed_cap = MAX_SPEED
	_was_on_floor = now_floor


func _accelerate(direction: Vector3, speed: float, accel: float, delta: float) -> void :
	var current: = velocity.x * direction.x + velocity.z * direction.z
	var add: = speed - current
	if add <= 0.0:
		return
	var accel_speed: = minf(accel * speed * delta, add)
	velocity.x += direction.x * accel_speed
	velocity.z += direction.z * accel_speed


func _air_accelerate(direction: Vector3, wish_speed: float, delta: float) -> void :
	var current: = velocity.x * direction.x + velocity.z * direction.z
	var add: = AIR_WISH_CAP - current
	if add <= 0.0:
		return
	var accel_speed: = minf(AIR_ACCEL * wish_speed * delta, add)
	velocity.x += direction.x * accel_speed
	velocity.z += direction.z * accel_speed


func _apply_friction(delta: float) -> void :
	var horizontal: = Vector2(velocity.x, velocity.z)
	var speed: = horizontal.length()
	if speed < 0.05:
		velocity.x = 0.0
		velocity.z = 0.0
		return


	var drop: = maxf(speed, STOP_SPEED) * FRICTION * delta
	var new_speed: = maxf(0.0, speed - drop)
	var scale: = new_speed / speed
	velocity.x *= scale
	velocity.z *= scale


func _clamp_horizontal() -> void :
	var horizontal: = Vector2(velocity.x, velocity.z)
	var speed: = horizontal.length()
	if speed > _speed_cap:
		horizontal = horizontal.normalized() * _speed_cap
		velocity.x = horizontal.x
		velocity.z = horizontal.y


func _try_wall_jump(intent: Vector3, runup_speed: = 0.0) -> void :
	# отскоки от стен отключены (заглушка для совместимости)
	return
	var best_normal: = Vector3.ZERO
	for i in get_slide_collision_count():
		var collision: = get_slide_collision(i)
		var normal: = collision.get_normal()
		if absf(normal.y) > 0.55:
			continue

		var pressing: = intent.length_squared() > 0.01 and intent.dot(normal) < -0.15
		if not pressing and velocity.dot(normal) > 0.2:
			continue
		if best_normal == Vector3.ZERO or normal.dot(Vector3.UP) > best_normal.dot(Vector3.UP):
			best_normal = normal
	if best_normal == Vector3.ZERO:
		return



	var runup: = clampf(runup_speed / WALL_JUMP_RUNUP_REF, 0.0, 1.0)
	var charge: = smoothstep(0.0, 1.0, runup)
	var push: = lerpf(WALL_JUMP_PUSH, WALL_JUMP_PUSH_MAX, charge)
	var lift: = lerpf(WALL_JUMP_LIFT, WALL_JUMP_LIFT_MAX, charge)

	velocity = best_normal.normalized() * push + Vector3.UP * lift
	_wall_jump_cooldown = WALL_JUMP_COOLDOWN
	_jump_cooldown = 0.12
	_coyote = 0.0
	_jump_buffer = 0.0
	_bhop_chain += 1
	_speed_cap = minf(_speed_cap + 0.5, MAX_SPEED_CAP)
	_recoil_pitch -= deg_to_rad(1.0 + charge * 1.6)
	viewmodel.kick(0.55 + charge * 0.55)
	Sfx.play_jump()
	_emit_noise("wall_jump", 0.95, 0.35)
	wall_jumped.emit()


func bounce(strength: = 15.0) -> void :
	velocity.y = strength
	_coyote = 0.0
	_jump_cooldown = 0.16
	_wall_jump_cooldown = 0.18
	_bhop_chain += 1
	_speed_cap = minf(_speed_cap + 0.5, MAX_SPEED_CAP)
	viewmodel.kick(0.9)
	Sfx.play_jump()
	_emit_noise("bounce", 1.0, 0.35)
	bounced.emit(strength)


func _on_jump() -> void :
	if _has_jumped and _ground_time <= BHOP_CHAIN_WINDOW:
		_bhop_chain += 1
		_apply_bhop_boost()
	else:
		_bhop_chain = 1
		_speed_cap = MAX_SPEED
	_has_jumped = true
	_recoil_pitch -= deg_to_rad(0.6)
	viewmodel.kick(0.35)
	Sfx.play_jump()
	_emit_noise("jump", 0.7, 0.15)



func _apply_bhop_boost() -> void :
	_speed_cap = minf(MAX_SPEED + float(_bhop_chain - 1) * BHOP_STEP, MAX_SPEED_CAP)
	var horizontal: = Vector2(velocity.x, velocity.z)
	var speed: = horizontal.length()
	if speed > 0.4:
		var dir: = horizontal / speed
		var kick: = BHOP_KICK + minf(float(_bhop_chain) * 0.035, 0.45)
		velocity.x += dir.x * kick
		velocity.z += dir.y * kick


func _on_land(impact_speed: float) -> void :
	_land_dip = clampf(impact_speed * 0.006, 0.012, 0.085)
	viewmodel.kick(clampf(impact_speed * 0.1, 0.3, 1.4))
	Sfx.play_land()
	_emit_noise("land", clampf(impact_speed / 14.0, 0.4, 1.0))
	_try_slide_boost()
	landed.emit(impact_speed)




func _try_slide_boost() -> void :
	if _slide_boost_cooldown > 0.0:
		return
	var normal: = get_floor_normal()
	var slope: = clampf(1.0 - normal.y, 0.0, 0.7)
	var horizontal: = Vector2(velocity.x, velocity.z)
	var speed: = horizontal.length()
	if slope < SLIDE_SLOPE_MIN or speed < SLIDE_MIN_SPEED:
		return

	var gain: = clampf(speed * slope * SLIDE_GAIN, 0.0, 15.0)
	velocity.y = maxf(velocity.y, gain)
	var downhill: = Vector3(normal.x, 0.0, normal.z)
	if downhill.length_squared() > 0.0001:
		downhill = downhill.normalized()
		velocity.x += downhill.x * gain * 0.45
		velocity.z += downhill.z * gain * 0.45
	_speed_cap = minf(_speed_cap + gain * 0.12, MAX_SPEED_CAP)
	_slide_boost_cooldown = 0.22
	viewmodel.kick(0.9)
	Sfx.play_jump()
	_emit_noise("slide", clampf(gain / 15.0, 0.4, 1.0))
	slide_boosted.emit(gain)


func _update_camera(delta: float) -> void :
	_crouch_visual = lerpf(_crouch_visual, 1.0 if _crouched else 0.0, 
		1.0 - exp( - CROUCH_LERP * delta))
	var horizontal_speed: = Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and horizontal_speed > 0.6:
		_bob_time += delta * (5.5 + horizontal_speed * 0.75)
	else:
		_bob_time = lerpf(_bob_time, 0.0, 1.0 - exp(-7.0 * delta))

	var amplitude: = clampf(horizontal_speed / 8.0, 0.25, 1.25)
	var target: = Vector2(
		sin(_bob_time) * 0.011 * amplitude, 
		absf(cos(_bob_time)) * 0.016 * amplitude
	) * lerpf(1.0, 0.55, _crouch_visual)
	if not is_on_floor():
		target = Vector2.ZERO
	if _scoped:
		target = Vector2.ZERO
	_bob = _bob.lerp(target, 1.0 - exp(-16.0 * delta))
	_land_dip = lerpf(_land_dip, 0.0, 1.0 - exp(-9.0 * delta))

	var eye_height: = lerpf(EYE_HEIGHT, CROUCH_EYE_HEIGHT, _crouch_visual)
	head.position = Vector3(_bob.x, eye_height - _land_dip + _bob.y, 0.0)



	var strafe_axis: = Input.get_axis("move_left", "move_right")
	var lean_target: = 0.0
	if not is_on_floor():
		lean_target = - strafe_axis * AIR_LEAN
	_strafe_lean = lerpf(_strafe_lean, lean_target, 
		1.0 - exp( - AIR_LEAN_SPEED * delta))
	camera.rotation.z = deg_to_rad(_strafe_lean)





func _update_crouch() -> void :
	var wants_crouch: bool
	if Settings.tap_crouch_aim:
		if Input.is_action_just_pressed("crouch"):
			_crouch_latched = not _crouch_latched
		wants_crouch = _crouch_latched
	else:
		_crouch_latched = false
		wants_crouch = Input.is_action_pressed("crouch")
	if _crouched:
		if not wants_crouch and _can_stand():
			_set_crouched(false)
	elif wants_crouch:
		_set_crouched(true)


func _set_crouched(value: bool) -> void :
	if _crouched == value:
		return
	_crouched = value
	var capsule: CapsuleShape3D = null
	if collision != null:
		capsule = collision.shape as CapsuleShape3D
	if capsule == null:
		return
	var height: = _crouch_height if value else _stand_height
	capsule.height = height

	collision.position.y = _stand_shape_y * (height / maxf(_stand_height, 0.01))


func _can_stand() -> bool:
	if not _crouched:
		return true
	var rise: = _stand_height - _crouch_height
	return rise <= 0.0 or not test_move(global_transform, Vector3.UP * rise)


func _setup_crouch_shape() -> void :
	if collision == null or collision.shape == null:
		return
	if not (collision.shape is CapsuleShape3D):
		return
	collision.shape = collision.shape.duplicate()
	var capsule: = collision.shape as CapsuleShape3D
	_stand_height = capsule.height
	_crouch_height = maxf(capsule.radius * 2.0 + 0.05, _stand_height * 0.62)
	_stand_shape_y = collision.position.y





func _update_scope(delta: float) -> void :
	var blocked: = _is_melee or _reloading or not _can_scope
	var wanted: = false
	if Settings.tap_crouch_aim:
		if blocked:
			_aim_latched = false
		elif Input.is_action_just_pressed("aim"):
			_aim_latched = not _aim_latched
		wanted = _aim_latched and not blocked
	else:
		_aim_latched = false
		wanted = not blocked and Input.is_action_pressed("aim")
	_set_scope(wanted)

	var target_fov: = _scope_fov if _scoped else Settings.fov
	if _scoped:
		camera.fov = lerpf(camera.fov, target_fov, 1.0 - exp( - SCOPE_ZOOM_IN_SPEED * delta))
		if absf(camera.fov - target_fov) < 0.02:
			camera.fov = target_fov
	else:

		camera.fov = target_fov


	if not _scoped:
		_set_viewmodel_visible(camera.fov > Settings.fov - 3.0)


func _set_scope(active: bool) -> void :
	if _scoped == active:
		return
	_scoped = active
	if not active:


		_aim_latched = false
	if active:
		_set_viewmodel_visible(false)
		Sfx.play_scope_in()
	else:
		Sfx.play_scope_out()
	_emit_noise("scope", 0.5, 1.2)
	scope_changed.emit(active)




func _scope_sensitivity() -> float:
	if not _scoped:
		return 1.0
	var base: = deg_to_rad(Settings.fov * 0.5)
	if base < 0.001:
		return 1.0
	var zoomed: = deg_to_rad(camera.fov * 0.5)
	return clampf(tan(zoomed) / tan(base), SCOPE_SENS_MIN, 1.0)


func _update_steps(delta: float) -> void :
	if not is_on_floor() or _speed < 1.2:
		_step_timer = 0.0
		return
	_step_timer -= delta
	if _step_timer <= 0.0:
		_step_timer = clampf(3.5 / maxf(_speed, 1.0), 0.27, 0.48)
		Sfx.play_step()
		_emit_noise("step", clampf(_speed / RUN_SPEED, 0.35, 1.0))


func _fall_guard() -> void :
	if global_position.y < -8.0:
		respawn()


func respawn() -> void :
	global_position = _spawn_position
	rotation.y = _spawn_yaw
	_pitch = 0.0
	head.rotation.x = 0.0
	velocity = Vector3.ZERO
	_jump_buffer = 0.0
	_bhop_chain = 0
	_speed_cap = MAX_SPEED
	_slide_boost_cooldown = 0.0
	_set_scope(false)
	_set_crouched(false)
	_crouch_latched = false
	_aim_latched = false
	_crouch_visual = 0.0
	_strafe_lean = 0.0
	camera.rotation.z = 0.0




func set_spawn(point: Vector3, yaw: = 0.0) -> void :
	_spawn_position = point
	_spawn_yaw = yaw
	global_position = point
	rotation.y = yaw
	_pitch = 0.0
	head.rotation.x = 0.0
	velocity = Vector3.ZERO


func reset_health() -> void :
	health = MAX_HEALTH
	_alive = true
	health_changed.emit(health, MAX_HEALTH)





func reset_round_state() -> void :
	_alive = true
	respawn()
	reset_health()
	_reloading = false
	_reload_time = 0.0
	_reload_magazine = 0
	_fire_cooldown = 0.0
	_melee_cooldown = 0.0

	Sfx.stop_weapon_sounds()




	var was_melee: = _is_melee
	var primary_magazine: = int(WeaponData.get_weapon(_primary_id).get("magazine", 5))
	var pistol_magazine: = int(WeaponData.get_weapon(_pistol_id).get("magazine", 5))
	_slot = SLOT_PRIMARY
	_is_melee = false
	_weapon_id = _primary_id
	_weapon = WeaponData.get_weapon(_primary_id)
	_automatic = bool(_weapon.get("automatic", false))
	_fire_interval = float(_weapon.get("fire_rate", 1.3))
	_spread = float(_weapon.get("spread", 0.0012))
	_shot_bloom = 0.0
	_recoil = float(_weapon.get("recoil", 0.06))
	_recoil_recovery = float(_weapon.get("recoil_recovery", 9.0))
	_recoil_limit = deg_to_rad(float(_weapon.get("recoil_limit", 9.0)))
	_magazine = primary_magazine
	_reload_duration = float(_weapon.get("reload_time", 2.5))
	_scope_fov = float(_weapon.get("zoom_fov", DEFAULT_SCOPE_FOV))
	_primary_ammo = primary_magazine
	_secondary_ammo = pistol_magazine
	_ammo = primary_magazine
	if viewmodel != null and viewmodel.has_method("finish_reload_animation"):
		viewmodel.call("finish_reload_animation")



	if was_melee and viewmodel != null:
		viewmodel.build_for(_weapon_id, get_weapon_skin())
	set_combat_visible(true)
	ammo_changed.emit(_ammo, _magazine, false)
	weapon_changed.emit(get_ammo_state())





func set_duel_weapon(weapon_id: String, skin_id: String) -> void :
	if not WeaponData.WEAPONS.has(weapon_id):
		return
	_duel_weapon_locked = true
	_primary_id = weapon_id
	_primary_skin = skin_id
	_primary_ammo = -1
	_secondary_ammo = -1
	_reloading = false
	_reload_time = 0.0
	_reload_magazine = 0
	_slot = SLOT_PRIMARY
	_is_melee = false
	_apply_weapon(true)


func get_health() -> float:
	return health


func is_alive() -> bool:
	return _alive




func take_damage(amount: float, from_position: = Vector3.ZERO) -> void :
	if not _alive or amount <= 0.0:
		return
	health = maxf(0.0, health - amount)
	_recoil_pitch -= deg_to_rad(randf_range(0.8, 2.2))
	viewmodel.kick(0.75)
	damaged.emit(amount, from_position)
	health_changed.emit(health, MAX_HEALTH)
	if health <= 0.0:
		_alive = false
		active = false
		exit_scope()
		died.emit()





func pad_launch(lift: float, push: Vector3) -> void :
	if not _alive or not active:
		return
	velocity.y = maxf(velocity.y, lift)
	velocity.x = push.x
	velocity.z = push.z
	_jump_buffer = 0.0
	_jump_cooldown = 0.18
	Sfx.play_jump()


func exit_scope() -> void :
	_set_scope(false)



	if camera != null:
		camera.fov = Settings.fov
		_sync_viewmodel_camera()
	_set_viewmodel_visible(true)



func set_combat_visible(on: bool) -> void :
	_set_viewmodel_visible(on)




func _ensure_ray_query() -> PhysicsRayQueryParameters3D:
	if _ray_query == null:
		_ray_query = PhysicsRayQueryParameters3D.new()
		_ray_query.collision_mask = 1 | 2
		_ray_query.collide_with_areas = true
		_ray_query.collide_with_bodies = true
		_ray_query.exclude = [get_rid()]
	return _ray_query




func _damage_for_zone(zone: String) -> float:
	var damage: = float(_weapon.get("damage_body", 100.0))
	match zone:
		"head":
			damage = float(_weapon.get("damage_head", damage))
		"legs":
			damage = float(_weapon.get("damage_legs", damage))
	return damage


func _try_fire() -> void :
	if _fire_cooldown > 0.0 or _reloading:
		return
	if _ammo <= 0:
		Sfx.play_empty()
		_start_reload()
		return

	_fire_cooldown = _fire_interval
	_ammo -= 1
	if _slot == SLOT_SECONDARY:
		_secondary_ammo = _ammo
	else:
		_primary_ammo = _ammo
	ammo_changed.emit(_ammo, _magazine, false)

	var speed_factor: = clampf(_speed / MAX_SPEED, 0.0, 1.0)
	var move_penalty: = 1.0 + speed_factor * 3.2
	if not is_on_floor():
		move_penalty += 1.8
	var cone: = (_spread + _shot_bloom) * move_penalty
	if _scoped:
		cone *= SCOPE_SPREAD_SCALE

	var space: = get_world_3d().direct_space_state
	var camera_basis: = camera.global_transform.basis
	var forward: = - camera_basis.z
	var right: = camera_basis.x
	var up: = camera_basis.y
	var offset: = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	if offset.length_squared() > 1.0:
		offset = offset.normalized()
	var direction: = (forward + right * offset.x * cone + up * offset.y * cone).normalized()
	var origin: = camera.global_position
	var query: = _ensure_ray_query()
	query.from = origin
	query.to = origin + direction * 140.0
	var result: = space.intersect_ray(query)

	var end_position: = origin + direction * 140.0
	var normal: = - direction
	var collider: Object = null
	var zone: = ""
	var is_mannequin: = false
	if not result.is_empty():
		end_position = result.get("position", end_position)
		normal = result.get("normal", normal)
		collider = result.get("collider")
		if collider != null and collider.is_in_group("mannequin_hitboxes"):
			is_mannequin = true
			zone = str(collider.call("get_zone"))

	_recoil_pitch = minf(_recoil_pitch + _recoil, _recoil_limit)

	# Накопление разброса от частой стрельбы (дигл «уводит» ствол).
	var bloom: = float(_weapon.get("spread_bloom", 0.0))
	if bloom > 0.0:
		var bloom_cap: = bloom * 1.6
		_shot_bloom = minf(_shot_bloom + bloom, bloom_cap)

	var side: = float(_weapon.get("recoil_side", 0.0018))
	rotate_y(randf_range( - side, side) * (0.35 if _scoped else 1.0))
	viewmodel.kick(1.0, true)
	viewmodel.flash_muzzle()
	Sfx.play_shot()



	if _weapon_id == "awp":
		viewmodel.play_bolt_cycle(_fire_interval, AWP_BOLT_DELAY)
		Sfx.play_bolt(AWP_BOLT_DELAY)

	var muzzle: Vector3 = viewmodel.get_muzzle_position()
	_spawn_tracer(muzzle, end_position)
	if not is_mannequin:
		_spawn_impact(end_position, normal)


		if not result.is_empty():
			_spawn_bullet_hole(end_position, normal)

	shot_fired.emit({


		"origin": origin, 
		"position": end_position, 
		"normal": normal, 
		"collider": collider, 
		"zone": zone, 
		"headshot": zone == "head", 
		"mannequin": is_mannequin, 


		"damage": _damage_for_zone(zone), 
		"distance": origin.distance_to(end_position), 
		"melee": false, 

		"weapon": _weapon_id, 
		"scoped": _scoped, 
		"noscope": _weapon_id == "awp" and not _scoped, 
		"airborne": not is_on_floor(), 
	})




func _try_slash(heavy: = false) -> void :
	if _melee_cooldown > 0.0:
		return
	_melee_cooldown = _fire_interval * (1.6 if heavy else 1.0)
	viewmodel.play_swing(heavy)
	viewmodel.kick(1.4 if heavy else 1.0)
	Sfx.play_knife()
	_emit_noise("knife", 0.8 if heavy else 0.65, 1.0)

	var space: = get_world_3d().direct_space_state
	var camera_basis: = camera.global_transform.basis
	var forward: = - camera_basis.z
	var right: = camera_basis.x
	var up: = camera_basis.y
	var origin: = camera.global_position
	var reach: = _melee_range * (1.15 if heavy else 1.0)

	var best_hit: Dictionary = {}
	var fallback: Dictionary = {}
	var airborne: = not is_on_floor()
	var angles: = [
		Vector2.ZERO, 
		Vector2(0.055, 0.055), Vector2(-0.055, 0.055), 
		Vector2(0.055, -0.055), Vector2(-0.055, -0.055), 
		Vector2(0.1, 0.0), Vector2(-0.1, 0.0), 
	]
	var query: = _ensure_ray_query()
	query.from = origin
	for offset: Vector2 in angles:
		var direction: Vector3 = (forward + right * offset.x + up * offset.y).normalized()
		query.to = origin + direction * reach
		var result: = space.intersect_ray(query)
		if result.is_empty():
			continue
		var collider: Object = result.get("collider")
		var is_mannequin: bool = collider != null and collider.is_in_group("mannequin_hitboxes")
		var info: = {
			"position": result.get("position", origin + direction * reach), 
			"normal": result.get("normal", - direction), 
			"collider": collider, 
			"zone": str(collider.call("get_zone")) if is_mannequin else "", 
			"headshot": false, 
			"mannequin": is_mannequin, 


			"damage": 999.0, 
			"distance": reach, 
			"melee": true, 

			"weapon": "knife", 
			"scoped": false, 
			"noscope": false, 
			"airborne": airborne, 
		}
		if is_mannequin:
			best_hit = info
			break
		if fallback.is_empty():
			fallback = info

	if not best_hit.is_empty():
		best_hit["headshot"] = str(best_hit.get("zone", "")) == "head"
		_recoil_pitch = minf(_recoil_pitch + _recoil, deg_to_rad(5.0))
		melee_hit.emit(best_hit)
	elif not fallback.is_empty():
		var hit_position: Vector3 = fallback.get("position", origin)
		var hit_normal: Vector3 = fallback.get("normal", - forward)
		_spawn_impact(hit_position, hit_normal)
		# удар по миру (добыча материалов в БАТЛ РОЯЛЕ)
		fallback["headshot"] = false
		melee_hit.emit(fallback)
	else:
		Sfx.play_miss()


func _start_reload() -> void :
	if _is_melee or _reloading or _ammo >= _magazine:
		return
	_set_scope(false)
	_reloading = true
	_reload_time = _reload_duration
	_reload_magazine = _magazine
	viewmodel.play_reload(_reload_duration)
	Sfx.play_reload()
	_emit_noise("reload", 0.9, 1.0)
	ammo_changed.emit(_ammo, _magazine, true)


func _build_effect_pools() -> void :


	call_deferred("_create_effect_pools")


func _create_effect_pools() -> void :
	var parent: = get_parent()
	if parent == null:
		return

	for i in TRACER_POOL:
		var mat: = MeshKit.additive(Color(1.0, 0.78, 0.42, 0.0))
		var inst: = MeshInstance3D.new()
		inst.name = "TracerPool%d" % i
		inst.mesh = ImmediateMesh.new()
		inst.material_override = mat
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		inst.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		parent.add_child(inst)
		_tracers.append(inst)
		_tracer_mats.append(mat)

	for i in SPARK_POOL:
		var mat: = MeshKit.additive(Color(1.0, 0.72, 0.34, 0.0))
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mat.no_depth_test = true
		var quad: = QuadMesh.new()
		quad.size = Vector2(0.075, 0.075)
		var inst: = MeshInstance3D.new()
		inst.name = "SparkPool%d" % i
		inst.mesh = quad
		inst.material_override = mat
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		inst.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		parent.add_child(inst)
		_sparks.append(inst)
		_spark_mats.append(mat)



	for i in BULLET_HOLE_POOL:
		var hole_mat: = ShaderMaterial.new()
		hole_mat.shader = BulletHoleShader
		var hole_quad: = QuadMesh.new()
		hole_quad.size = Vector2(BULLET_HOLE_SIZE, BULLET_HOLE_SIZE)
		var hole: = MeshInstance3D.new()
		hole.name = "BulletHolePool%d" % i
		hole.mesh = hole_quad
		hole.material_override = hole_mat
		hole.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hole.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		hole.visible = false
		parent.add_child(hole)
		_bullet_holes.append(hole)

	for i in IMPACT_LIGHT_POOL:
		var light: = OmniLight3D.new()
		light.name = "ImpactLightPool%d" % i
		light.light_color = Color(1.0, 0.62, 0.28, 1.0)
		light.light_energy = 0.0
		light.omni_range = 1.6
		light.shadow_enabled = false


		light.visible = false
		parent.add_child(light)
		_impact_lights.append(light)



	if Settings.effects_quality > 0:
		_warm_tracers()




func _warm_tracers() -> void :
	if _tracers.is_empty():
		return


	var slot: = _tracers[_tracers.size() - 1]
	var immediate: = slot.mesh as ImmediateMesh
	if immediate == null:
		return
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate.surface_add_vertex(Vector3.ZERO)
	immediate.surface_add_vertex(Vector3.UP * 0.02)
	immediate.surface_end()
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	await tree.process_frame
	await tree.process_frame
	if is_instance_valid(immediate):
		immediate.clear_surfaces()




static func _fade_tween(node: Node) -> Tween:
	if node.has_meta("fade"):
		var old: Tween = node.get_meta("fade")
		if old != null and old.is_valid():
			old.kill()
	var tween: = node.create_tween()
	node.set_meta("fade", tween)
	return tween


func _spawn_tracer(from: Vector3, to: Vector3) -> void :
	if Settings.effects_quality <= 0 or _tracers.is_empty():
		return
	var index: = _tracer_index
	_tracer_index = (_tracer_index + 1) % _tracers.size()
	var inst: = _tracers[index]
	var mat: = _tracer_mats[index]
	var immediate: = inst.mesh as ImmediateMesh
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate.surface_add_vertex(from)
	immediate.surface_add_vertex(to)
	immediate.surface_end()
	mat.albedo_color.a = 0.9
	_fade_tween(inst).tween_property(mat, "albedo_color:a", 0.0, 0.07)


func _spawn_impact(position: Vector3, normal: Vector3) -> void :
	if Settings.effects_quality <= 0:
		return
	if Settings.effects_quality >= 2 and not _impact_lights.is_empty():
		var light: = _impact_lights[_impact_light_index]
		_impact_light_index = (_impact_light_index + 1) % _impact_lights.size()
		light.global_position = position + normal * 0.05
		light.light_color = Color(1.0, 0.62, 0.28, 1.0)
		light.light_energy = 2.2
		light.visible = true
		var light_tween: = _fade_tween(light)
		light_tween.tween_property(light, "light_energy", 0.0, 0.12)
		light_tween.tween_callback( func() -> void : light.visible = false)

	if _sparks.is_empty():
		return
	var index: = _spark_index
	_spark_index = (_spark_index + 1) % _sparks.size()
	var spark: = _sparks[index]
	var mat: = _spark_mats[index]
	spark.global_position = position + normal * 0.015
	spark.scale = Vector3.ONE
	mat.albedo_color.a = 0.95
	var spark_tween: = _fade_tween(spark)
	spark_tween.set_parallel(true)
	spark_tween.tween_property(spark, "scale", Vector3.ONE * 0.15, 0.14)
	spark_tween.tween_property(mat, "albedo_color:a", 0.0, 0.14)






func _spawn_bullet_hole(position: Vector3, normal: Vector3) -> void :
	if _bullet_holes.is_empty():
		return
	var dir: = normal.normalized()
	if dir.length_squared() < 0.001:
		return
	var index: = _bullet_hole_index
	_bullet_hole_index = (_bullet_hole_index + 1) % _bullet_holes.size()
	var hole: = _bullet_holes[index]



	var up_hint: = Vector3.UP
	if absf(dir.dot(Vector3.UP)) > 0.95:
		up_hint = Vector3.RIGHT
	var basis: = Basis.looking_at( - dir, up_hint)
	basis = Basis(dir, randf_range(0.0, TAU)) * basis
	var grow: = randf_range(0.85, 1.25)
	hole.global_transform = Transform3D(
		basis.scaled(Vector3(grow, grow, 1.0)), 
		position + dir * 0.006)
	hole.visible = true


func _switch_slot(slot: int) -> void :
	if slot == _slot:
		return
	_set_scope(false)



	Sfx.stop_weapon_sounds()
	_slot = slot
	_apply_weapon(true)
	Sfx.play_ui()


func _apply_weapon(rebuild_viewmodel: bool) -> void :


	if _slot == SLOT_MELEE:
		_weapon_id = "knife"
		_weapon = WeaponData.get_weapon("knife")
		_is_melee = true
		_automatic = false
		_can_scope = false
		_fire_interval = float(_weapon.get("fire_rate", 0.55))
		_spread = 0.0
		_shot_bloom = 0.0
		_recoil = float(_weapon.get("recoil", 0.012))
		_recoil_recovery = 9.0
		_recoil_limit = deg_to_rad(9.0)
		_melee_range = float(_weapon.get("melee_range", 2.4))
		_magazine = 0
		_ammo = 0
	else:
		var ammo_store: int = _secondary_ammo if _slot == SLOT_SECONDARY\
			else _primary_ammo
		_weapon_id = _pistol_id if _slot == SLOT_SECONDARY else _primary_id
		_weapon = WeaponData.get_weapon(_weapon_id)
		_is_melee = false
		_automatic = bool(_weapon.get("automatic", false))
		_fire_interval = float(_weapon.get("fire_rate", 1.3))
		_spread = float(_weapon.get("spread", 0.0012))
		_recoil = float(_weapon.get("recoil", 0.06))


		_recoil_recovery = float(_weapon.get("recoil_recovery", 9.0))
		_recoil_limit = deg_to_rad(float(_weapon.get("recoil_limit", 9.0)))
		_magazine = int(_weapon.get("magazine", 5))
		_reload_duration = float(_weapon.get("reload_time", 2.5))


		var zoom: = float(_weapon.get("zoom_fov", 0.0))
		_can_scope = zoom > 0.0
		_scope_fov = zoom if _can_scope else DEFAULT_SCOPE_FOV
		if not _can_scope:
			_set_scope(false)
		if ammo_store < 0:
			ammo_store = _magazine
		_ammo = clampi(ammo_store, 0, _magazine)
		if _slot == SLOT_SECONDARY:
			_secondary_ammo = _ammo
		else:
			_primary_ammo = _ammo




	if rebuild_viewmodel:
		viewmodel.build_for(_weapon_id, get_weapon_skin())
		if not _is_melee and _reloading:


			viewmodel.play_reload(maxf(_reload_time, 0.1))
	if not _is_melee:
		ammo_changed.emit(_ammo, _magazine, _reloading)
	weapon_changed.emit(get_ammo_state())


func _on_render_scale_changed(value: float) -> void :
	if _vm_viewport != null:
		_vm_viewport.scaling_3d_scale = value


func _on_settings_changed() -> void :
	if not _scoped:
		camera.fov = Settings.fov
	camera.far = Settings.draw_distance
	viewmodel.set_fov(Settings.fov)
	if _vm_viewport != null:
		_vm_viewport.msaa_3d = Settings.msaa_level
	if _vm_environment != null:


		_apply_viewmodel_brightness()
	_sync_viewmodel_camera()



	if _duel_weapon_locked:
		return
	var primary_changed: = Settings.weapon_id != _primary_id or Settings.weapon_skin != _primary_skin
	var pistol_changed: = Settings.pistol_id != _pistol_id or Settings.pistol_skin != _pistol_skin
	var melee_changed: = Settings.knife_skin != _melee_skin
	_primary_id = Settings.weapon_id
	_primary_skin = Settings.weapon_skin
	_pistol_id = Settings.pistol_id
	_pistol_skin = Settings.pistol_skin
	_melee_skin = Settings.knife_skin
	if primary_changed:


		_primary_ammo = -1
		_reloading = false
		_reload_time = 0.0
		_reload_magazine = 0
		if _slot == SLOT_PRIMARY:
			_apply_weapon(true)
	elif pistol_changed:
		_secondary_ammo = -1
		_reloading = false
		_reload_time = 0.0
		_reload_magazine = 0
		if _slot == SLOT_SECONDARY:
			_apply_weapon(true)
	elif _slot == SLOT_MELEE and melee_changed:
		_apply_weapon(true)


func get_speed() -> float:
	return _speed


func get_bhop_chain() -> int:
	return _bhop_chain


func get_spread_scale() -> float:
	if _is_melee:
		return 1.0
	var factor: = 1.0 + clampf(_speed / MAX_SPEED, 0.0, 1.0) * 2.4
	if not is_on_floor():
		factor += 1.1
	return factor


func get_weapon_skin() -> String:
	if _slot == SLOT_MELEE:
		return _melee_skin
	if _slot == SLOT_SECONDARY:
		return _pistol_skin
	return _primary_skin


func get_ammo_state() -> Dictionary:
	return {
		"ammo": _ammo, 
		"magazine": _magazine, 
		"reloading": _reloading, 
		"melee": _is_melee, 

		"weapon": _weapon_id, 
		"slot": _slot, 
	}




func get_reload_progress() -> float:
	if not _reloading or _reload_duration <= 0.0:
		return 0.0
	return clampf(1.0 - _reload_time / _reload_duration, 0.0, 1.0)




func get_reload_remaining() -> float:
	if not _reloading or _reload_time <= 0.0:
		return 0.0
	return _reload_time


func is_melee() -> bool:
	return _is_melee
