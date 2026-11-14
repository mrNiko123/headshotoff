extends Control





const WeaponBuilder = preload("res://scripts/weapon_builder.gd")
const WeaponData = preload("res://scripts/weapon_data.gd")
const OutlineShader = preload("res://shaders/hud_icon_outline.gdshader")

const ICON_SIZE: = Vector2(208.0, 66.0)


const RENDER_SCALE: = 2.0
const PREVIEW_FOV: = 34.0



const FIT_WIDTH: = 0.56


const FIT_HEIGHT_LIMIT: = 0.9




const SILHOUETTE_RIGHT: = 0.98




const BASE_ROTATION: = Vector3(0.0, -74.0, 0.0)

var kind: = "awp":
	set(value):
		if kind == value:
			return
		kind = value
		if _built:
			_rebuild()



var tint: = Color(0.945, 0.95, 0.96, 1.0):
	set(value):
		tint = value
		if _material != null:
			_material.set_shader_parameter("outline_color", value)
			_material.set_shader_parameter("fill_color", 
				Color(value.r, value.g, value.b, 0.3))



var compact: = false

var _viewport: SubViewport
var _camera: Camera3D
var _holder: Node3D
var _material: ShaderMaterial
var _solid: StandardMaterial3D


var _built: = false



static var _model_cache: Dictionary = {}


static var _points_cache: Dictionary = {}
static var _fit_cache: Dictionary = {}
var _current_key: = ""


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = ICON_SIZE
	_build_viewport()
	_build_scene()
	_build_texture()
	_rebuild()
	_built = true


	resized.connect(_fit_to_control)


func _build_viewport() -> void :
	_viewport = SubViewport.new()
	_viewport.name = "Icon3D"

	_viewport.own_world_3d = true
	_viewport.transparent_bg = true
	_viewport.size = Vector2i(ICON_SIZE * RENDER_SCALE)


	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_viewport.msaa_3d = Viewport.MSAA_4X
	add_child(_viewport)


func _build_scene() -> void :
	_camera = Camera3D.new()
	_camera.fov = PREVIEW_FOV
	_camera.near = 0.01
	_camera.far = 12.0
	_camera.current = true
	_viewport.add_child(_camera)

	_holder = Node3D.new()
	_holder.rotation_degrees = BASE_ROTATION
	_viewport.add_child(_holder)



	_solid = StandardMaterial3D.new()
	_solid.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_solid.albedo_color = Color.WHITE
	_solid.cull_mode = BaseMaterial3D.CULL_DISABLED
	_solid.disable_fog = true


func _build_texture() -> void :
	var rect: = TextureRect.new()
	rect.name = "Icon"
	rect.texture = _viewport.get_texture()
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_material = ShaderMaterial.new()
	_material.shader = OutlineShader
	_material.set_shader_parameter("outline_color", tint)
	_material.set_shader_parameter("fill_color", Color(tint.r, tint.g, tint.b, 0.3))



	_material.set_shader_parameter("outline_width", 1.7 if compact else 2.8)


	_material.set_shader_parameter("halo_color", Color(0.0, 0.0, 0.0, 0.62))
	_material.set_shader_parameter("icon_tex", _viewport.get_texture())
	rect.material = _material
	add_child(rect)




func _fit_to_control() -> void :
	if _viewport == null or size.x < 1.0 or size.y < 1.0:
		return
	var target: = Vector2i(maxi(int(round(size.x * RENDER_SCALE)), 16), 
		maxi(int(round(size.y * RENDER_SCALE)), 16))
	if _viewport.size == target:
		return
	_viewport.size = target
	_fit_camera()
	_request_render()






func _rebuild() -> void :
	for child in _holder.get_children():
		_holder.remove_child(child)
		child.queue_free()
	var weapon_id: = "awp"
	var skin_id: = "default"
	if kind == "knife":
		weapon_id = "knife"
		skin_id = "bayonet"
	elif WeaponData.WEAPONS.has(kind):
		weapon_id = kind
		var skins: Dictionary = WeaponData.get_weapon(kind).get("skins", {})
		if not skins.is_empty():
			skin_id = str(skins.keys()[0])
	_current_key = "%s|%s" % [weapon_id, skin_id]
	var weapon: Node3D
	var cached: Dictionary = _model_cache.get(_current_key, {})
	if not cached.is_empty():
		weapon = (cached["scene"] as PackedScene).instantiate() as Node3D
		if weapon == null:
			return
		_holder.add_child(weapon)
		weapon.position -= cached["center"]
	else:
		weapon = WeaponBuilder.build(_holder, weapon_id, skin_id, false)
		if weapon == null:
			return
		var local: = WeaponBuilder.model_aabb(weapon)
		var center: = local.get_center()


		var packed: = PackedScene.new()
		if packed.pack(weapon) == OK:
			_model_cache[_current_key] = {"scene": packed, "center": center}
		weapon.position -= center
	for node in weapon.find_children("*", "MeshInstance3D", true, false):
		var mesh: = node as MeshInstance3D
		mesh.material_override = _solid
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	_fit_camera()
	_request_render()



func _request_render() -> void :
	if _viewport != null:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE








func _fit_camera() -> void :
	if _camera == null or _viewport == null or _current_key.is_empty():
		return
	var fit_key: = "%s|%d|%d|%s" % [_current_key, _viewport.size.x, 
		_viewport.size.y, "1" if compact else "0"]
	var fit: Dictionary = _fit_cache.get(fit_key, {})
	if not fit.is_empty():
		_aim(fit["center"], fit["distance"])
		return
	var points: = _model_points()
	if points.is_empty():
		return
	var center: = _points_center(points)
	var half_fov: = deg_to_rad(PREVIEW_FOV) * 0.5
	var v_tan: = tan(half_fov)
	var view: = Vector2(_viewport.size)
	var fit_width: = 0.94 if compact else FIT_WIDTH
	var target: = Vector2(view.x * fit_width, view.y * FIT_HEIGHT_LIMIT)
	var radius: = 0.0
	for point in points:
		radius = maxf(radius, point.distance_to(center))
	var distance: = maxf(radius / sin(half_fov), 0.05)


	for _i in 3:
		_aim(center, distance)
		var rect: = _projected_rect(points)
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			break
		distance = maxf(distance * maxf(rect.size.x / target.x, 
			rect.size.y / target.y), 0.05)
	_aim(center, distance)




	var units_per_pixel: = 2.0 * distance * v_tan / view.y
	for _i in 3:
		var rect: = _projected_rect(points)
		var target_center: = Vector2(view.x * 0.5, view.y * 0.5)
		if not compact:
			target_center.x = view.x * SILHOUETTE_RIGHT - rect.size.x * 0.5
		var offset: = rect.get_center() - target_center
		if offset.length_squared() < 0.25:
			break
		center += Vector3(offset.x * units_per_pixel, - offset.y * units_per_pixel, 0.0)
		_aim(center, distance)
	_fit_cache[fit_key] = {"center": center, "distance": distance}


func _aim(center: Vector3, distance: float) -> void :
	_camera.position = center + Vector3(0.0, 0.0, distance)
	_camera.look_at(center, Vector3.UP)


func _model_points() -> PackedVector3Array:
	var cached: PackedVector3Array = _points_cache.get(_current_key, 
		PackedVector3Array())
	if not cached.is_empty():
		return cached
	var points: = PackedVector3Array()
	for node in _holder.find_children("*", "MeshInstance3D", true, false):
		var mesh: = node as MeshInstance3D
		if mesh.mesh == null:
			continue
		var xf: = mesh.global_transform
		for vertex in mesh.mesh.get_faces():
			points.append(xf * vertex)
	if not points.is_empty():
		_points_cache[_current_key] = points
	return points


func _points_center(points: PackedVector3Array) -> Vector3:
	var box: = AABB(points[0], Vector3.ZERO)
	for point in points:
		box = box.expand(point)
	return box.get_center()


func _projected_rect(points: PackedVector3Array) -> Rect2:
	var lo: = Vector2(INF, INF)
	var hi: = Vector2( - INF, - INF)
	for point in points:
		var p: = _camera.unproject_position(point)
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	return Rect2(lo, hi - lo)
