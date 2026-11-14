extends RefCounted





const WeaponData = preload("res://scripts/weapon_data.gd")
const MeshKit = preload("res://scripts/mesh_kit.gd")




const AWP_SCENE: = preload("res://models/AWP.obj")

const AWP_TEXTURE: = preload("res://models/textures/RC4qv11Y.png")
const AWP_SKIN_SHADER: = preload("res://shaders/awp_skin.gdshader")

const AWP_MODEL_SCALE: = 0.127

const AWP_MODEL_YAW: = -90.0


const AWP_MODEL_OFFSET: = Vector3(0.0, -0.033, -0.333)

const AWP_MUZZLE: = Vector3(0.0, 0.0, -1.04)





const AK_MESH: = preload("res://knife/ak7finished.obj")
const AK_MODEL_YAW: = 90.0
const AK_SURFACE_COLORS: = [
	Color(0.33, 0.17, 0.07, 1.0), 
	Color(0.045, 0.045, 0.05, 1.0), 
	Color(0.11, 0.11, 0.12, 1.0), 
	Color(0.2, 0.2, 0.21, 1.0), 
	Color(0.06, 0.06, 0.07, 1.0), 
]



const DEAGLE_MESH: = preload(
	"res://assets/models/deagle/chrome/deagle_chrome.obj")
const USP_MESH: = preload("res://assets/models/usp/usp_s.obj")



const M4_SCENE: = preload("res://knife/M4A1s.gltf")
const M4_TEXTURE: = preload("res://knife/M4A1s_0.png")

const RIFLE_SHADER: = preload("res://shaders/rifle_skin.gdshader")



const RIFLE_LENGTH: = 1.45





const RIFLE_VIEW_SHIFT: = 0.2





const RIFLE_VIEW_DROP: = 0.11




const BUTTERFLY_SCENE: = preload("res://knife/Butterfly.obj")
const BUTTERFLY_SCALE: = 0.105













const KNIFE_MODELS: = {
	"bayonet": {
		"scene": preload("res://knife/Bayonet.obj"), 
		"texture": preload("res://knife/Bayonet_knife_Color.png"), 





		"length": 0.52, "roughness": 0.34, "metallic": 0.42, 
		"grip": 0.07, 
	}, 
	"karambit": {
		"scene": preload("res://knife/Karambit.obj"), 
		"texture": preload("res://knife/Krambit_knife_Color.png"), 
		"length": 0.38, "roughness": 0.36, "metallic": 0.4, 
		"grip": 0.22, "grip_y": 0.82, 
	}, 
	"skeleton": {
		"scene": preload("res://knife/Skeleton.obj"), 
		"texture": preload("res://knife/Skeleton_knife_color.png"), 
		"length": 0.46, "roughness": 0.32, "metallic": 0.46, 
	}, 
	"dagger": {
		"scene": preload("res://knife/Dagger.obj"), 
		"texture": preload("res://knife/Tdagger_color.png"), 
		"length": 0.46, "roughness": 0.38, "metallic": 0.38, "grip": 0.68, 
	}, 




	"combat": {
		"scene": preload("res://knife/CombatKnife.obj"), 
		"texture": preload("res://models/Combat_knife_Color.png"), 
		"length": 0.44, "roughness": 0.4, "metallic": 0.34, 
		"grip": 0.42, "grip_y": 0.55, 
	}, 











	"nomad": {
		"scene": preload("res://knife/Nomad.obj"), 
		"texture": preload("res://knife/Nomad_knife_Color (2).png"), 
		"length": 0.5, "roughness": 0.34, "metallic": 0.42, 
		"albedo_gain": 1.7, "detail_grain": true, "cull_back": true, 
		"grip": 0.05, "inspect_grip": 0.5, 
	}, 
}


static func build(parent: Node3D, weapon_id: String, skin_id: String, overlay: = false) -> Node3D:
	var weapon: Dictionary = WeaponData.get_weapon(weapon_id)
	var skin: Dictionary = WeaponData.get_skin(weapon_id, skin_id)

	var root: = Node3D.new()
	root.name = "Weapon"
	parent.add_child(root)

	var muzzle: = Node3D.new()
	muzzle.name = "Muzzle"

	if str(weapon.get("type", "")) == "knife":
		var model_id: = str(skin.get("model", ""))
		if model_id != "" and KNIFE_MODELS.has(model_id):
			_build_imported_knife(root, skin, overlay, model_id)
		else:
			_build_butterfly(root, skin, overlay)

		muzzle.position = Vector3(0.0, 0.0, -0.26)
	elif weapon_id == "ak47":
		muzzle.position = _build_ak(root, skin, overlay)
	elif weapon_id == "m4a1":
		muzzle.position = _build_m4(root, skin, overlay)
	elif weapon_id == "deagle":
		muzzle.position = _build_deagle(root, skin, overlay)
	elif weapon_id == "usp":
		muzzle.position = _build_usp(root, skin, overlay)
	else:
		_build_awp(root, skin, overlay)
		muzzle.position = AWP_MUZZLE

	root.add_child(muzzle)
	return root


static func display_scale(weapon_id: String) -> float:
	return 3.05 if WeaponData.is_melee(weapon_id) else 0.86







static func apply_tint(root: Node3D, color: Color) -> void :
	if root == null:
		return
	var amount: = clampf(color.a, 0.0, 1.0)
	var paint: = Color(color.r, color.g, color.b, 1.0)
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh: = node as MeshInstance3D
		_tint_material(mesh.material_override, paint, amount)
		var resource: = mesh.mesh
		if resource == null:
			continue
		for i in resource.get_surface_count():
			_tint_material(resource.surface_get_material(i), paint, amount)


static func _tint_material(mat: Material, paint: Color, amount: float) -> void :
	if mat == null:
		return
	if mat.has_meta("no_tint"):
		return
	if mat is ShaderMaterial:
		var shader_mat: = mat as ShaderMaterial
		var shader: = shader_mat.shader
		if shader == AWP_SKIN_SHADER or shader == RIFLE_SHADER:
			shader_mat.set_shader_parameter("paint_color", paint)
			shader_mat.set_shader_parameter("paint_amount", amount)
	elif mat is StandardMaterial3D:
		if not mat.has_meta("base_albedo"):
			return
		var base: Color = mat.get_meta("base_albedo")
		var standard: = mat as StandardMaterial3D
		var target: = paint



		if mat.has_meta("tint_darken"):
			target = paint.darkened(float(mat.get_meta("tint_darken")))
		standard.albedo_color = base.lerp(target, amount)




static func model_aabb(root: Node3D) -> AABB:
	return _model_aabb(root)







static func _awp_material(skin: Dictionary, overlay: bool) -> ShaderMaterial:
	var mat: = ShaderMaterial.new()
	mat.shader = AWP_SKIN_SHADER
	mat.set_shader_parameter("albedo_tex", AWP_TEXTURE)
	mat.set_shader_parameter("hue_shift", float(skin.get("hue", 0.0)))
	mat.set_shader_parameter("saturation_value", float(skin.get("saturation", 1.0)))
	mat.set_shader_parameter("value_scale", float(skin.get("value", 1.0)))
	if overlay:
		mat.render_priority = 2
	return mat


# OBJ-модели импортируются как Mesh (а не как сцена) — общий помощник.
static func _mesh_node(mesh: Mesh) -> Node3D:
	var node: = MeshInstance3D.new()
	node.mesh = mesh
	return node


static func _build_awp(root: Node3D, skin: Dictionary, overlay: bool) -> void :
	var model: = _mesh_node(AWP_SCENE)
	var pivot: = Node3D.new()
	pivot.name = "AwpModel"
	pivot.rotation_degrees = Vector3(0.0, AWP_MODEL_YAW, 0.0)
	pivot.scale = Vector3.ONE * AWP_MODEL_SCALE
	pivot.position = AWP_MODEL_OFFSET
	root.add_child(pivot)
	pivot.add_child(model)




	var mat: = _awp_material(skin, overlay)
	var body: MeshInstance3D = null
	for child in model.find_children("*", "MeshInstance3D", true, false):
		var mesh: = child as MeshInstance3D
		mesh.material_override = mat
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		if body == null:
			body = mesh
	if body != null:
		_add_awp_hole_plugs(body)


	_merge_static_meshes(model)








static func _add_awp_hole_plugs(body: MeshInstance3D) -> void :
	var plug_mat: = StandardMaterial3D.new()



	plug_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	plug_mat.albedo_color = Color(0.155, 0.165, 0.17, 1.0)
	plug_mat.disable_receive_shadows = true


	plug_mat.set_meta("base_albedo", plug_mat.albedo_color)
	plug_mat.set_meta("tint_darken", 0.72)


	var plugs: = [
		[Vector3(0.0355, 0.0, -0.0041), Vector3(0.0072, 0.003, 0.006)], 
		[Vector3(0.0261, 0.0, -0.0037), Vector3(0.006, 0.003, 0.004)], 
		[Vector3(0.0177, 0.0, 0.0053), Vector3(0.0068, 0.006, 0.0032)], 
	]
	for i in range(plugs.size()):
		var spec: Array = plugs[i]
		var plug: = MeshInstance3D.new()
		plug.name = "HolePlug%d" % i
		var box: = BoxMesh.new()
		box.size = spec[1]
		plug.mesh = box
		plug.position = spec[0]
		plug.material_override = plug_mat
		plug.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		plug.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		body.add_child(plug)







static func _build_ak(root: Node3D, skin: Dictionary, overlay: bool) -> Vector3:
	var model: = Node3D.new()
	model.name = "AkModel"
	var body: Color = skin.get("body", Color(0.31, 0.33, 0.36, 1.0))
	var accent: Color = skin.get("accent", Color(0.52, 0.27, 0.1, 1.0))

	var mesh: = MeshInstance3D.new()
	mesh.name = "AkMesh"




	var mesh_resource: = AK_MESH.duplicate() as ArrayMesh
	mesh.mesh = mesh_resource
	model.add_child(mesh)

	for i in mesh_resource.get_surface_count():
		var base: Color = AK_SURFACE_COLORS[i] if i < AK_SURFACE_COLORS.size()\
		else Color(0.12, 0.12, 0.13, 1.0)


		var tinted: = base.lerp(accent, 0.62) if i == 0 else base.lerp(body, 0.42)
		var mat: = _rifle_material(tinted, overlay, 
			0.72 if i == 0 else 0.46, 0.05 if i == 0 else 0.18)
		mesh_resource.surface_set_material(i, mat)



	return _place_rifle(root, model, AK_MODEL_YAW, 0.58, 0.5, 0.6, 0.285, 
		RIFLE_VIEW_DROP)




static func _build_m4(root: Node3D, skin: Dictionary, overlay: bool) -> Vector3:
	var model: = M4_SCENE.instantiate() as Node3D
	if model == null:
		return Vector3.ZERO
	var tint: Color = skin.get("body", Color(0.27, 0.3, 0.35, 1.0))
	var mat: = _rifle_texture_material(M4_TEXTURE, tint, overlay, 0.42, 0.2)
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh: = node as MeshInstance3D
		mesh.material_override = mat

	_merge_static_meshes(model)
	return _place_rifle(root, model, 0.0, 0.58, 0.5, 0.6, 0.285, 
		RIFLE_VIEW_DROP)










static func _build_deagle(root: Node3D, skin: Dictionary, overlay: bool) -> Vector3:
	var model: = Node3D.new()
	model.name = "DeagleModel"

	# Импортированная OBJ-модель: морда в +Z, в вьюмодели вперёд это -Z,
	# поэтому разворачиваем на 180°.
	var holder: = Node3D.new()
	holder.name = "DeagleHolder"
	holder.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	model.add_child(holder)

	var mesh: = MeshInstance3D.new()
	mesh.name = "DeagleMesh"
	var mesh_resource: = DEAGLE_MESH.duplicate() as ArrayMesh
	mesh.mesh = mesh_resource
	holder.add_child(mesh)

	var metal_color: Color = skin.get("metal", Color(0.8, 0.83, 0.88, 1.0))
	var frame_color: Color = skin.get("frame", Color(0.42, 0.45, 0.5, 1.0))
	_paint_pistol_mesh(mesh_resource, metal_color, frame_color, 0.92, 0.18)

	return _place_rifle(root, model, 0.0, 0.64, 0.38, 0.78, 0.32, 
		RIFLE_VIEW_DROP, Vector3(0.0, -12.0, 4.0), 
		Vector3(0.12, -0.02, -0.1), 0.62)


static func _paint_pistol_mesh(mesh_resource: ArrayMesh, metal_color: Color, 
		frame_color: Color, metal_gloss: float, metal_rough: float) -> void :
	# Раскраска импортированного OBJ по светлоте материалов из .mtl:
	# яркие поверхности - полированный металл скина, средние - рамка,
	# тёмные - чёрные детали (щёчки рукояти, канал дула).
	var dark: = Color(0.075, 0.075, 0.085, 1.0)
	for i in mesh_resource.get_surface_count():
		var lum: = 0.5
		var src: = mesh_resource.surface_get_material(i) as StandardMaterial3D
		if src != null:
			lum = src.albedo_color.get_luminance()
		var mat: = StandardMaterial3D.new()
		if lum >= 0.6:
			mat.albedo_color = metal_color
			mat.metallic = metal_gloss
			mat.roughness = metal_rough
			mat.metallic_specular = 0.7
		elif lum >= 0.25:
			mat.albedo_color = frame_color
			mat.metallic = metal_gloss * 0.9
			mat.roughness = metal_rough + 0.14
		else:
			mat.albedo_color = dark
			mat.metallic = 0.55
			mat.roughness = 0.5
		mat.set_meta("no_tint", true)
		mesh_resource.surface_set_material(i, mat)


static func _build_deagle_blocks(root: Node3D, skin: Dictionary, overlay: bool) -> Vector3:
	var model: = Node3D.new()
	model.name = "DeagleModel"

	# Процедурная модель Desert Eagle: морда в +Z, в вьюмодели оружие
	# вперёд это -Z, поэтому разворачиваем на 180°.
	var holder: = Node3D.new()
	holder.name = "DeagleHolder"
	holder.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	model.add_child(holder)

	# Палитра из скина: polished chrome / steel / тёмные детали.
	var metal_color: Color = skin.get("metal", Color(0.8, 0.83, 0.88, 1.0))
	var frame_color: Color = skin.get("frame", Color(0.42, 0.45, 0.5, 1.0))
	var metal: = StandardMaterial3D.new()
	metal.albedo_color = metal_color
	metal.metallic = 0.92
	metal.roughness = 0.18
	metal.metallic_specular = 0.7
	metal.set_meta("no_tint", true)
	var steel: = StandardMaterial3D.new()
	steel.albedo_color = frame_color
	steel.metallic = 0.85
	steel.roughness = 0.32
	steel.set_meta("no_tint", true)
	var dark: = StandardMaterial3D.new()
	dark.albedo_color = Color(0.08, 0.08, 0.095, 1.0)
	dark.metallic = 0.55
	dark.roughness = 0.5
	dark.set_meta("no_tint", true)

	# --- затвор (слайд) с треугольным верхом, как у deagle ---
	MeshKit.block(holder, Vector3(0.056, 0.074, 0.29), 
		Vector3(0.0, 0.064, -0.02), metal)
	# верхняя площадка затвора
	MeshKit.block(holder, Vector3(0.03, 0.018, 0.28), 
		Vector3(0.0, 0.108, -0.02), metal)
	# вент-рёбро сверху затвора (три продольных ребра)
	for rib in [-1.0, 0.0, 1.0]:
		MeshKit.block(holder, Vector3(0.006, 0.012, 0.2), 
			Vector3(rib * 0.011, 0.122, -0.06), metal)
	# вент-пазы в рёбре (светлые вырезы)
	for slot in 3:
		MeshKit.block(holder, Vector3(0.032, 0.012, 0.014), 
			Vector3(0.0, 0.122, -0.11 + float(slot) * 0.045), dark)
	# передний скос затвора
	MeshKit.block(holder, Vector3(0.056, 0.048, 0.03), 
		Vector3(0.0, 0.052, 0.135), metal)

	# --- насечки на затворе: ряды тонких вертикальных полос ---
	for side in [-1.0, 1.0]:
		for i in 7:
			var x: float = side * (0.0295)
			MeshKit.block(holder, Vector3(0.004, 0.055, 0.008), 
				Vector3(x, 0.062, -0.155 + float(i) * 0.014), dark)
		# передние насечки
		for i in 4:
			var x2: float = side * (0.0295)
			MeshKit.block(holder, Vector3(0.004, 0.05, 0.007), 
				Vector3(x2, 0.06, 0.075 + float(i) * 0.013), dark)
	# окно выброса гильз на правой стороне затвора
	MeshKit.block(holder, Vector3(0.006, 0.038, 0.075), 
		Vector3(0.0285, 0.07, 0.03), dark)

	# --- рамка (frame) ---
	MeshKit.block(holder, Vector3(0.05, 0.052, 0.235), 
		Vector3(0.0, 0.002, -0.045), steel)
	MeshKit.block(holder, Vector3(0.046, 0.03, 0.07), 
		Vector3(0.0, -0.022, -0.135), steel)

	# --- ствол: выступающий массивный блок deagle с каналом ---
	MeshKit.block(holder, Vector3(0.048, 0.054, 0.065), 
		Vector3(0.0, 0.06, 0.155), steel)
	MeshKit.block(holder, Vector3(0.03, 0.03, 0.012), 
		Vector3(0.0, 0.064, 0.187), dark)
	# кольцо дула
	MeshKit.block(holder, Vector3(0.056, 0.058, 0.012), 
		Vector3(0.0, 0.06, 0.186), metal)
	# мушка
	MeshKit.block(holder, Vector3(0.009, 0.02, 0.012), 
		Vector3(0.0, 0.096, 0.175), dark)
	# целик
	MeshKit.block(holder, Vector3(0.026, 0.018, 0.014), 
		Vector3(0.0, 0.126, -0.155), dark)

	# --- рукоять: наклон назад, чёрные щёчки ---
	var grip: = MeshKit.block(holder, Vector3(0.048, 0.135, 0.06), 
		Vector3(0.0, -0.075, -0.17), steel, Vector3(17.0, 0.0, 0.0))
	grip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for side in [-1.0, 1.0]:
		MeshKit.block(holder, Vector3(0.012, 0.1, 0.044), 
			Vector3(side * 0.028, -0.078, -0.163), dark, 
			Vector3(17.0, 0.0, 0.0))
	# заглушка магазина
	MeshKit.block(holder, Vector3(0.044, 0.014, 0.056), 
		Vector3(0.0, -0.146, -0.128), dark, Vector3(17.0, 0.0, 0.0))

	# --- скоба спускового крючка ---
	MeshKit.block(holder, Vector3(0.014, 0.008, 0.06), 
		Vector3(0.0, -0.056, -0.098), steel)
	MeshKit.block(holder, Vector3(0.014, 0.008, 0.03), 
		Vector3(0.0, -0.04, -0.075), steel)
	MeshKit.block(holder, Vector3(0.011, 0.028, 0.008), 
		Vector3(0.0, -0.032, -0.1), dark)

	# курок и флажок предохранителя
	MeshKit.block(holder, Vector3(0.014, 0.03, 0.012), 
		Vector3(0.0, 0.048, -0.168), steel, Vector3(-14.0, 0.0, 0.0))
	MeshKit.block(holder, Vector3(0.007, 0.016, 0.008), 
		Vector3(-0.032, 0.0, -0.13), dark)

	return _place_rifle(root, model, 0.0, 0.64, 0.38, 0.78, 0.32, 
		RIFLE_VIEW_DROP, Vector3.ZERO, Vector3(0.0, 0.0, 0.06), 0.74)


static func _build_usp(root: Node3D, skin: Dictionary, overlay: bool) -> Vector3:
	var model: = Node3D.new()
	model.name = "UspModel"

	# Импортированная OBJ-модель USP-S: морда в +Z, глушитель на месте.
	var holder: = Node3D.new()
	holder.name = "UspHolder"
	holder.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	model.add_child(holder)

	var mesh: = MeshInstance3D.new()
	mesh.name = "UspMesh"
	var mesh_resource: = USP_MESH.duplicate() as ArrayMesh
	mesh.mesh = mesh_resource
	holder.add_child(mesh)

	var metal_color: Color = skin.get("metal", Color(0.1, 0.1, 0.11, 1.0))
	var frame_color: Color = skin.get("frame", Color(0.15, 0.15, 0.16, 1.0))
	_paint_pistol_mesh(mesh_resource, metal_color, frame_color, 0.6, 0.3)

	return _place_rifle(root, model, 0.0, 0.64, 0.38, 0.78, 0.32, 
		RIFLE_VIEW_DROP, Vector3(0.0, -12.0, 4.0), 
		Vector3(0.12, -0.02, -0.1), 0.62)


static func _build_usp_blocks(root: Node3D, skin: Dictionary, overlay: bool) -> Vector3:
	var model: = Node3D.new()
	model.name = "UspModel"

	# Процедурная модель USP-S: морда в +Z; глушитель-труба, чёрный матовый.
	var holder: = Node3D.new()
	holder.name = "UspHolder"
	holder.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	model.add_child(holder)

	var metal_color: Color = skin.get("metal", Color(0.1, 0.1, 0.11, 1.0))
	var frame_color: Color = skin.get("frame", Color(0.15, 0.15, 0.16, 1.0))
	var slide_mat: = StandardMaterial3D.new()
	slide_mat.albedo_color = metal_color
	slide_mat.metallic = 0.6
	slide_mat.roughness = 0.42
	slide_mat.set_meta("no_tint", true)
	var frame_mat: = StandardMaterial3D.new()
	frame_mat.albedo_color = frame_color
	frame_mat.metallic = 0.3
	frame_mat.roughness = 0.6
	frame_mat.set_meta("no_tint", true)
	var dark: = StandardMaterial3D.new()
	dark.albedo_color = Color(0.055, 0.055, 0.06, 1.0)
	dark.metallic = 0.4
	dark.roughness = 0.55
	dark.set_meta("no_tint", true)

	# --- затвор: компактный, скошенный перед ---
	MeshKit.block(holder, Vector3(0.048, 0.062, 0.24), 
		Vector3(0.0, 0.06, -0.02), slide_mat)
	MeshKit.block(holder, Vector3(0.048, 0.04, 0.025), 
		Vector3(0.0, 0.05, 0.115), slide_mat)
	# насечки сзади затвора
	for side in [-1.0, 1.0]:
		for i in 6:
			MeshKit.block(holder, Vector3(0.004, 0.045, 0.007), 
				Vector3(side * 0.0255, 0.058, -0.15 + float(i) * 0.012), dark)
	# окно выброса
	MeshKit.block(holder, Vector3(0.006, 0.03, 0.06), 
		Vector3(0.0245, 0.068, 0.02), dark)

	# --- рамка и направляющая возвратной пружины ---
	MeshKit.block(holder, Vector3(0.042, 0.05, 0.2), 
		Vector3(0.0, 0.0, -0.03), frame_mat)
	MeshKit.block(holder, Vector3(0.038, 0.032, 0.05), 
		Vector3(0.0, -0.014, 0.085), frame_mat)

	# --- глушитель: труба перед дулом (морда в +Z) ---
	MeshKit.block(holder, Vector3(0.036, 0.036, 0.17), 
		Vector3(0.0, 0.062, 0.235), dark)
	# фаски глушителя (кольца)
	for ring in 3:
		MeshKit.block(holder, Vector3(0.04, 0.04, 0.012), 
			Vector3(0.0, 0.062, 0.185 + float(ring) * 0.075), dark)
	# дуло глушителя (тёмный канал)
	MeshKit.block(holder, Vector3(0.018, 0.018, 0.01), 
		Vector3(0.0, 0.062, 0.32), dark)
	# мушка и целик
	MeshKit.block(holder, Vector3(0.008, 0.016, 0.01), 
		Vector3(0.0, 0.096, -0.13), dark)
	MeshKit.block(holder, Vector3(0.022, 0.014, 0.012), 
		Vector3(0.0, 0.096, 0.1), dark)

	# --- рукоять: круче, чем у deagle, чёрная ---
	var grip: = MeshKit.block(holder, Vector3(0.044, 0.14, 0.055), 
		Vector3(0.0, -0.08, -0.15), frame_mat, Vector3(22.0, 0.0, 0.0))
	grip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for side in [-1.0, 1.0]:
		MeshKit.block(holder, Vector3(0.01, 0.105, 0.04), 
			Vector3(side * 0.026, -0.082, -0.145), dark, 
			Vector3(22.0, 0.0, 0.0))
	MeshKit.block(holder, Vector3(0.04, 0.014, 0.052), 
		Vector3(0.0, -0.152, -0.105), dark, Vector3(22.0, 0.0, 0.0))

	# --- скоба и спусковой крючок ---
	MeshKit.block(holder, Vector3(0.012, 0.007, 0.055), 
		Vector3(0.0, -0.052, -0.085), frame_mat)
	MeshKit.block(holder, Vector3(0.012, 0.007, 0.028), 
		Vector3(0.0, -0.036, -0.065), frame_mat)
	MeshKit.block(holder, Vector3(0.01, 0.026, 0.007), 
		Vector3(0.0, -0.03, -0.088), dark)
	# флажок предохранителя
	MeshKit.block(holder, Vector3(0.006, 0.014, 0.008), 
		Vector3(-0.028, 0.008, -0.115), dark)

	return _place_rifle(root, model, 0.0, 0.64, 0.38, 0.78, 0.32, 
		RIFLE_VIEW_DROP, Vector3.ZERO, Vector3(0.0, 0.0, 0.06), 0.74)

static func _place_rifle(root: Node3D, model: Node3D, yaw: float, 
	grip_frac: float, grip_y_frac: float, 
		hand_right_frac: float, hand_left_frac: float, 
		view_drop: float, view_rotation: = Vector3.ZERO, 
		view_offset: = Vector3.ZERO, 
		fit_length: = -1.0) -> Vector3:
	var box: = _model_aabb(model)


	var long_axis: = 0 if box.size.x >= box.size.z else 2
	var span: = maxf(box.size[long_axis], 0.0001)
	var length: = fit_length if fit_length > 0.0 else RIFLE_LENGTH
	var fit: = length / span

	var pivot: = Node3D.new()
	pivot.name = "RiflePivot"


	pivot.rotation_degrees = Vector3(view_rotation.x, yaw + view_rotation.y, 
		view_rotation.z)
	pivot.scale = Vector3.ONE * fit
	root.add_child(pivot)
	pivot.add_child(model)



	var placed: = _model_aabb(pivot)
	var grip: = Vector3(
		placed.get_center().x, 
		placed.position.y + placed.size.y * grip_y_frac, 
		placed.position.z + placed.size.z * grip_frac)
	model.position += pivot.basis.inverse() * ( - grip)






	pivot.position = Vector3(view_offset.x, - view_drop + view_offset.y, 
		- RIFLE_VIEW_SHIFT + view_offset.z)
	root.set_meta("view_grip", pivot.position)

	placed = _model_aabb(pivot)
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh: = node as MeshInstance3D
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED







	var right_z: = placed.position.z + placed.size.z * hand_right_frac
	var left_z: = placed.position.z + placed.size.z * hand_left_frac
	var right_low: = _profile_low_point(pivot, right_z, 0.045)
	var left_low: = _profile_low_point(pivot, left_z, 0.045)
	root.set_meta("view_hand_right", Vector3(right_low.x, right_low.y, right_z))
	root.set_meta("view_hand_left", Vector3(left_low.x, left_low.y, left_z))



	root.set_meta("muzzle_flash_scale", 0.62)
	return Vector3(
		placed.get_center().x, 
		placed.position.y + placed.size.y * 0.58, 
		placed.position.z - 0.01)





static func _profile_low_point(node: Node3D, z_center: float, 
		z_half: float) -> Vector2:
	var low: = INF
	var sum_x: = 0.0
	var count: = 0
	var stack: Array = [[node, Transform3D.IDENTITY]]
	while not stack.is_empty():
		var entry: Array = stack.pop_back()
		var current: = entry[0] as Node3D
		var xf: Transform3D = entry[1] * current.transform
		if current is MeshInstance3D:
			var mesh: = (current as MeshInstance3D).mesh
			if mesh != null:
				for s in mesh.get_surface_count():
					var arrays: = mesh.surface_get_arrays(s)
					var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
					for v in verts:
						var p: = xf * v
						if absf(p.z - z_center) > z_half:
							continue
						if p.y < low - 0.0001:
							low = p.y
							sum_x = p.x
							count = 1
						elif absf(p.y - low) <= 0.0001:
							sum_x += p.x
							count += 1
		for child in current.get_children():
			if child is Node3D:
				stack.append([child, xf])
	if count == 0:
		return Vector2.ZERO
	return Vector2(sum_x / float(count), low)


static func _rifle_material(color: Color, overlay: bool, roughness: float, 
		metallic: float) -> ShaderMaterial:
	var mat: = ShaderMaterial.new()
	mat.shader = RIFLE_SHADER
	mat.set_shader_parameter("albedo_color", color)
	mat.set_shader_parameter("use_texture", false)
	mat.set_shader_parameter("roughness_value", roughness)
	mat.set_shader_parameter("metallic_value", metallic)
	mat.set_shader_parameter("albedo_gain", 1.0)
	if overlay:
		mat.render_priority = 2
	return mat


static func _rifle_texture_material(tex: Texture2D, tint: Color, overlay: bool, 
		roughness: float, metallic: float) -> ShaderMaterial:
	var mat: = ShaderMaterial.new()
	mat.shader = RIFLE_SHADER
	mat.set_shader_parameter("albedo_tex", tex)
	mat.set_shader_parameter("use_texture", true)



	mat.set_shader_parameter("albedo_gain", 3.0)
	mat.set_shader_parameter("albedo_color", tint)
	mat.set_shader_parameter("roughness_value", roughness)
	mat.set_shader_parameter("metallic_value", metallic)
	if overlay:
		mat.render_priority = 2
	return mat








const BUTTERFLY_PIN: = Vector3(-0.003295, 0.000124, 0.0)






const BUTTERFLY_FOLD_DEPTH: = 0.0032


static func _build_butterfly(root: Node3D, skin: Dictionary, overlay: bool) -> void :
	var tint: Color = skin.get("tint", Color.WHITE)





	var blade_mat: = _knife_material(tint.lerp(Color(0.92, 0.94, 0.97, 1.0), 0.62), 
		overlay, 0.2, 0.66)
	var handle_mat: = _knife_material(tint.darkened(0.52), overlay, 0.52, 0.4)
	var grain: Texture2D = _knife_grain_texture()
	var skin_tex_path: = str(skin.get("texture", ""))
	if skin_tex_path != "":
		var skin_tex: = load(skin_tex_path) as Texture2D
		if skin_tex != null:
			blade_mat = _knife_texture_material(skin_tex, tint, 
				overlay, 0.2, 0.5)
			handle_mat = _knife_texture_material(skin_tex, 
				tint.darkened(0.5), overlay, 0.55, 0.35)
			blade_mat.albedo_texture = skin_tex
			handle_mat.albedo_texture = skin_tex
			blade_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			handle_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	elif bool(skin.get("lava", false)):
		blade_mat = _knife_texture_material(_lava_texture(), 
			Color(1.0, 0.88, 0.72, 1.0), overlay, 0.2, 0.5)
		blade_mat.emission_enabled = true
		blade_mat.emission = Color(1.0, 0.38, 0.06, 1.0)
		blade_mat.emission_energy_multiplier = 0.55
		handle_mat = _knife_texture_material(_lava_texture(), 
			Color(0.22, 0.15, 0.14, 1.0), overlay, 0.6, 0.3)
	else:
		blade_mat.albedo_texture = grain
		blade_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		handle_mat.albedo_texture = grain
		handle_mat.uv1_scale = Vector3(2.0, 2.0, 2.0)
		handle_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	var model: = _mesh_node(BUTTERFLY_SCENE)
	# OBJ запёк поворот корня FBX (-90°X) — ставим модель обратно вертикально.
	model.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	var pivot: = Node3D.new()
	pivot.name = "KnifePivot"

	pivot.rotation_degrees = Vector3(0.0, -90.0, 0.0)
	pivot.scale = Vector3.ONE * BUTTERFLY_SCALE
	pivot.position = Vector3(0.0, 0.0, -0.03)
	root.add_child(pivot)
	pivot.add_child(model)



	var body: = model.get_child(0) as Node3D
	if body != null:
		body.rotation = Vector3.ZERO

	var blade: = model.find_child("Blade", true, false) as MeshInstance3D
	var lever1: = model.find_child("Lever1", true, false) as MeshInstance3D
	var lever2: = model.find_child("Lever2", true, false) as MeshInstance3D

	_apply_knife_material(model, handle_mat)
	if blade != null:
		blade.material_override = blade_mat

	var rig: = Node3D.new()
	rig.name = "FoldRig"
	rig.position = BUTTERFLY_PIN
	var swapped: = false
	if body != null:
		body.add_child(rig)
		swapped = true


	var blade_arm: Node3D = null
	var lever1_arm: Node3D = null
	var lever2_arm: Node3D = null
	if swapped:
		blade_arm = _attach_to_rig(rig, body, blade)
		lever1_arm = _attach_to_rig(rig, body, lever1)
		lever2_arm = _attach_to_rig(rig, body, lever2)


	root.set_meta("knife_kind", "butterfly")
	root.set_meta("butterfly_blade", blade_arm)
	root.set_meta("butterfly_lever1", lever1_arm)
	root.set_meta("butterfly_lever2", lever2_arm)
	root.set_meta("butterfly_fold_depth", BUTTERFLY_FOLD_DEPTH)





static func _attach_to_rig(rig: Node3D, body: Node3D, node: Node3D) -> Node3D:
	if node == null:
		return null
	var arm: = Node3D.new()
	arm.name = node.name + "Arm"
	rig.add_child(arm)
	var part: = node
	var local: = rig.transform.affine_inverse() * _transform_to(node, body)
	part.get_parent().remove_child(part)
	arm.add_child(part)
	part.transform = local
	return arm


static func _transform_to(node: Node3D, ancestor: Node3D) -> Transform3D:
	var t: = Transform3D.IDENTITY
	var cur: Node = node
	while cur != null and cur != ancestor:
		var n3: = cur as Node3D
		if n3 == null:
			break
		t = n3.transform * t
		cur = cur.get_parent()
	return t











static func _merge_static_meshes(root: Node3D) -> void :
	var groups: Dictionary = {}
	var meshes: Array[MeshInstance3D] = []
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var inst: = node as MeshInstance3D
		if inst.mesh == null or inst.material_override == null:
			continue
		var key: = inst.material_override.get_instance_id()
		if not groups.has(key):
			groups[key] = {"material": inst.material_override, "meshes": []}
		(groups[key]["meshes"] as Array).append(inst)
		meshes.append(inst)
	if meshes.is_empty():
		return
	var merged_nodes: Array[MeshInstance3D] = []
	for key in groups:
		var entry: Dictionary = groups[key]
		var group: Array = entry["meshes"]
		if group.size() < 2:
			continue
		var st: = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var supported: = true
		for item in group:
			var inst: = item as MeshInstance3D
			var mesh: Mesh = inst.mesh
			var xform: = _transform_to(inst, root)
			for surface in mesh.get_surface_count():
				st.append_from(mesh, surface, xform)
			if not supported:
				break
		if not supported:
			continue
		var merged: = MeshInstance3D.new()
		merged.name = "MergedMesh"
		merged.mesh = st.commit()
		merged.material_override = entry["material"]
		merged.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		merged.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		merged_nodes.append(merged)
		for item in group:
			var inst: = item as MeshInstance3D
			var parent: Node = inst.get_parent()
			if parent != null:
				parent.remove_child(inst)
			inst.queue_free()
	for merged in merged_nodes:
		root.add_child(merged)


static func _knife_material(tint: Color, overlay: bool, roughness: float, 
		metallic: float) -> StandardMaterial3D:
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.roughness = roughness
	mat.metallic = metallic
	mat.metallic_specular = 0.55
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED


	mat.set_meta("base_albedo", mat.albedo_color)
	if overlay:
		mat.no_depth_test = true
		mat.disable_fog = true
		mat.render_priority = 2
	return mat







static var _knife_grain: ImageTexture = null


static func _knife_grain_texture() -> ImageTexture:
	if _knife_grain != null:
		return _knife_grain
	const SIZE: = 256
	var noise: = FastNoiseLite.new()
	noise.seed = 57095
	noise.frequency = 0.06
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	var img: = Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	for y in SIZE:
		for x in SIZE:

			var fine: = noise.get_noise_2d(float(x), float(y) * 5.0)

			var broad: = noise.get_noise_2d(float(x) * 0.25, 
				float(y) * 0.25)
			var v: = clampf(0.92 + fine * 0.14 + broad * 0.07, 0.68, 1.0)
			img.set_pixel(x, y, Color(v, v, v))
	img.generate_mipmaps()
	_knife_grain = ImageTexture.create_from_image(img)
	return _knife_grain


static var _lava_tex: ImageTexture = null


static func _lava_texture() -> ImageTexture:
	if _lava_tex != null:
		return _lava_tex
	const SIZE: = 128
	var hot_noise: = FastNoiseLite.new()
	hot_noise.seed = 4211
	hot_noise.frequency = 0.055
	hot_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	hot_noise.fractal_octaves = 4
	var tone_noise: = FastNoiseLite.new()
	tone_noise.seed = 9077
	tone_noise.frequency = 0.028
	tone_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	tone_noise.fractal_octaves = 2
	var img: = Image.create(SIZE, SIZE, false, Image.FORMAT_RGB8)
	for y in SIZE:
		for x in SIZE:
			var h: = hot_noise.get_noise_2d(float(x), float(y))
			var band: = absf(h)
			var veins: = clampf((0.16 - band) / 0.16, 0.0, 1.0)
			veins = veins * veins
			var tone: = 0.5 + 0.5 * tone_noise.get_noise_2d(float(x), float(y))
			var rock: = Color(0.075 + 0.09 * tone, 0.05 + 0.065 * tone, 
				0.048 + 0.05 * tone)
			var lava: = Color(1.0, 0.36 + 0.4 * tone, 0.05 + 0.1 * tone)
			img.set_pixel(x, y, rock.lerp(lava, veins))
	img.generate_mipmaps()
	_lava_tex = ImageTexture.create_from_image(img)
	return _lava_tex


static func _apply_knife_material(node: Node, mat: Material) -> void :
	if node is MeshInstance3D:
		var mesh: = node as MeshInstance3D
		mesh.material_override = mat
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	for child in node.get_children():
		_apply_knife_material(child, mat)








static func _build_imported_knife(root: Node3D, skin: Dictionary, overlay: bool, 
		model_id: String) -> void :
	var info: Dictionary = KNIFE_MODELS[model_id]
	var mesh: Mesh = info["scene"] as Mesh
	var model: = _mesh_node(mesh)
	# OBJ запёк поворот корня FBX (-90°X) — ставим модель обратно вертикально.
	model.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	if model == null:
		return

	_cancel_import_pitch(model)

	if absf(model.rotation_degrees.x + 90.0) < 1.0:
		model.rotation = Vector3.ZERO

	var box: = _model_aabb(model)
	var span: = maxf(maxf(box.size.x, box.size.y), box.size.z)
	var target: = float(info.get("length", 0.44))
	var fit: = target / maxf(span, 0.0001)

	var pivot: = Node3D.new()
	pivot.name = "KnifePivot"

	pivot.rotation_degrees = Vector3(0.0, -90.0, 0.0)
	pivot.scale = Vector3.ONE * fit
	root.add_child(pivot)
	pivot.add_child(model)




	var grip_frac: = clampf(float(info.get("grip", 0.5)), 0.05, 0.95)
	var grip_height: = clampf(float(info.get("grip_y", 0.5)), 0.0, 1.0)
	var handle_center: = Vector3(
		box.end.x * grip_frac, 
		box.position.y + box.size.y * grip_height, 
		box.get_center().z)
	model.position -= handle_center





	var inspect_grip: = clampf(float(info.get("inspect_grip", grip_frac)), 
		0.05, 0.95)
	root.set_meta("knife_inspect_offset", Vector3(0.0, 0.0, 
		(grip_frac - inspect_grip) * box.end.x * fit))

	var tint: Color = skin.get("tint", Color.WHITE)
	var tex: Texture2D = info["texture"]
	var tex_path: = str(skin.get("texture", ""))
	if tex_path != "":
		var loaded_tex: = load(tex_path) as Texture2D
		if loaded_tex != null:
			tex = loaded_tex
	var mat: = _knife_texture_material(tex, tint, overlay, 
		float(info.get("roughness", 0.36)), float(info.get("metallic", 0.42)), 
		float(info.get("albedo_gain", 1.0)), 
		bool(info.get("detail_grain", false)), 
		bool(info.get("cull_back", false)))
	_apply_knife_material(model, mat)

	root.set_meta("knife_kind", model_id)



	root.set_meta("grip_forward", 0.0)
	root.set_meta("grip_drop", 0.03)




static func _cancel_import_pitch(node: Node) -> void :
	for child in node.get_children():
		if child is Node3D:
			var part: = child as Node3D
			if absf(part.rotation_degrees.x + 90.0) < 1.0:
				part.rotation = Vector3.ZERO
			_cancel_import_pitch(part)



static func _model_aabb(node: Node3D) -> AABB:
	var box: = AABB()
	var found: = false
	var stack: Array = [[node, Transform3D.IDENTITY]]
	while not stack.is_empty():
		var entry: Array = stack.pop_back()
		var current: = entry[0] as Node3D
		var parent_xf: Transform3D = entry[1]
		var xf: = parent_xf * current.transform
		if current is MeshInstance3D:
			var mesh: = current as MeshInstance3D
			if mesh.mesh != null:
				var part: = xf * mesh.mesh.get_aabb()
				if found:
					box = box.merge(part)
				else:
					box = part
					found = true
		for child in current.get_children():
			if child is Node3D:
				stack.append([child, xf])
	return box


static func _knife_texture_material(tex: Texture2D, tint: Color, overlay: bool, 
		roughness: float, metallic: float, 
		albedo_gain: = 1.0, detail_grain: = false, 
		cull_back: = false) -> StandardMaterial3D:
	var mat: = StandardMaterial3D.new()
	mat.albedo_texture = tex


	mat.albedo_color = Color(tint.r * albedo_gain, tint.g * albedo_gain, 
		tint.b * albedo_gain, tint.a)


	mat.set_meta("base_albedo", mat.albedo_color)
	mat.roughness = roughness
	mat.metallic = metallic
	mat.metallic_specular = 0.5



	mat.cull_mode = BaseMaterial3D.CULL_BACK if cull_back\
	else BaseMaterial3D.CULL_DISABLED

	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	if detail_grain:


		mat.detail_enabled = true
		mat.detail_albedo = _knife_grain_texture()
		mat.detail_blend_mode = BaseMaterial3D.BLEND_MODE_MUL
	if overlay:
		mat.no_depth_test = true
		mat.disable_fog = true
		mat.render_priority = 2
	return mat
