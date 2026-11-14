extends Node3D














const MeshKit = preload("res://scripts/mesh_kit.gd")

const RAGDOLL_LAYER: = 4
const WORLD_MASK: = 1


const SETTLE_TIME: = 4.5


var palette: Dictionary = {}

var impulse_from: = Vector3.ZERO
var impulse_scale: = 1.0

var exclude: PhysicsBody3D

var _parts: Array[RigidBody3D] = []
var _thighs: Array[RigidBody3D] = []
var _hips: RigidBody3D
var _chest: RigidBody3D
var _head: RigidBody3D
var _physics: PhysicsMaterial
var _elapsed: = 0.0
var _settled: = false
var _joint_index: = 0


func _ready() -> void :
	_build()
	_kick.call_deferred()


func _process(delta: float) -> void :
	if _settled:
		return
	_elapsed += delta
	if _elapsed >= SETTLE_TIME:
		_settled = true
		for part in _parts:
			if is_instance_valid(part):


				part.freeze = true


func _build() -> void :
	_physics = PhysicsMaterial.new()
	_physics.friction = 0.92
	_physics.bounce = 0.04

	var torso: = _color("torso", Color(0.2, 0.24, 0.2))
	var shirt: = _color("shirt", Color(0.62, 0.3, 0.28))
	var pants: = _color("pants", Color(0.26, 0.3, 0.22))
	var pants_dark: = _color("pants_dark", Color(0.18, 0.21, 0.16))
	var boots: = _color("boots", Color(0.12, 0.12, 0.12))
	var skin: = _color("skin", Color(0.76, 0.56, 0.4))
	var glove: = _color("glove", Color(0.24, 0.24, 0.22))
	var helmet: = _color("helmet", Color(0.16, 0.2, 0.15))
	var accent: = _color("accent", Color(0.8, 0.68, 0.34))
	var eye: = _color("eye", Color(0.09, 0.09, 0.1))



	var hips: = _part("Hips", Vector3(0.3, 0.24, 0.22), 
		Vector3(0.0, 0.99, 0.0), pants, 6.0)
	_hips = hips
	_deco(hips, Vector3(0.32, 0.075, 0.235), Vector3(0.0, 0.075, 0.0), boots)

	var chest: = _part("Chest", Vector3(0.42, 0.46, 0.28), 
		Vector3(0.0, 1.32, 0.0), torso, 11.0)


	_deco(chest, Vector3(0.22, 0.32, 0.035), Vector3(0.0, -0.01, -0.148), shirt)
	_deco(chest, Vector3(0.5, 0.1, 0.295), Vector3(0.0, -0.19, 0.0), boots)
	_deco(chest, Vector3(0.14, 0.09, 0.045), Vector3(0.0, 0.13, -0.152), accent)
	_deco(chest, Vector3(0.15, 0.12, 0.15), Vector3(0.0, 0.27, 0.0), skin)
	_chest = chest

	var head: = _part("Head", Vector3(0.235, 0.24, 0.24), 
		Vector3(0.0, 1.7, 0.0), skin, 4.5)
	_deco(head, Vector3(0.25, 0.09, 0.255), Vector3(0.0, 0.1, 0.008), helmet)
	_deco(head, Vector3(0.225, 0.075, 0.225), Vector3(0.0, -0.085, -0.01), skin)
	_deco(head, Vector3(0.052, 0.028, 0.02), Vector3(-0.055, 0.02, -0.123), eye)
	_deco(head, Vector3(0.052, 0.028, 0.02), Vector3(0.055, 0.02, -0.123), eye)
	_deco(head, Vector3(0.04, 0.055, 0.045), Vector3(0.0, -0.02, -0.132), skin)
	_head = head

	var arm_r: = _arm("R", 1.0, shirt, torso, skin, glove)
	var arm_l: = _arm("L", -1.0, shirt, torso, skin, glove)
	var thigh_r: = _thigh("R", 1.0, pants, pants_dark, boots, accent)
	var thigh_l: = _thigh("L", -1.0, pants, pants_dark, boots, accent)
	var shin_r: = _shin("R", 1.0, pants_dark, boots)
	var shin_l: = _shin("L", -1.0, pants_dark, boots)
	var foot_r: = _foot("R", 1.0, boots)
	var foot_l: = _foot("L", -1.0, boots)


	_joint(hips, chest, Vector3(0.0, 1.105, 0.0), 
		Vector3(-0.32, -0.38, -0.3), Vector3(0.46, 0.38, 0.3))
	_joint(chest, head, Vector3(0.0, 1.555, 0.0), 
		Vector3(-0.58, -0.72, -0.46), Vector3(0.58, 0.72, 0.46))



	for side in [1.0, -1.0]:
		var arm: RigidBody3D = arm_r if side > 0.0 else arm_l
		var elbow: RigidBody3D = arm.get_meta("forearm") as RigidBody3D
		var thigh: RigidBody3D = thigh_r if side > 0.0 else thigh_l
		var shin: RigidBody3D = shin_r if side > 0.0 else shin_l
		var foot: RigidBody3D = foot_r if side > 0.0 else foot_l
		_joint(chest, arm, Vector3(0.28 * side, 1.47, 0.0), 
			Vector3(-1.45, -1.1, -1.55), Vector3(1.45, 1.1, 1.55))
		_joint(arm, elbow, Vector3(0.3 * side, 1.24, 0.0), 
			Vector3(-0.16, -0.16, -0.16), Vector3(1.85, 0.16, 0.16))
		_joint(hips, thigh, Vector3(0.11 * side, 0.93, 0.0), 
			Vector3(-1.15, -0.7, -1.3), Vector3(1.15, 0.7, 1.3))
		_joint(thigh, shin, Vector3(0.11 * side, 0.56, 0.0), 
			Vector3(-1.75, -0.13, -0.13), Vector3(0.12, 0.13, 0.13))
		_joint(shin, foot, Vector3(0.11 * side, 0.17, 0.0), 
			Vector3(-0.55, -0.2, -0.26), Vector3(0.55, 0.2, 0.26))


func _arm(suffix: String, side: float, sleeve: Color, shoulder: Color, 
		skin: Color, glove: Color) -> RigidBody3D:
	var arm: = _part("UpperArm" + suffix, Vector3(0.13, 0.3, 0.15), 
		Vector3(0.3 * side, 1.36, 0.0), sleeve, 2.6)
	_deco(arm, Vector3(0.175, 0.13, 0.185), Vector3(0.0, 0.115, 0.0), shoulder)
	_deco(arm, Vector3(0.125, 0.07, 0.135), Vector3(0.0, -0.155, 0.0), skin)
	var fore: = _part("Forearm" + suffix, Vector3(0.115, 0.3, 0.13), 
		Vector3(0.3 * side, 1.09, 0.0), sleeve, 2.0)
	_deco(fore, Vector3(0.12, 0.1, 0.14), Vector3(0.0, -0.115, 0.0), glove)
	arm.set_meta("forearm", fore)
	return arm


func _thigh(suffix: String, side: float, pants: Color, pants_dark: Color, 
		boots: Color, accent: Color) -> RigidBody3D:
	var thigh: = _part("Thigh" + suffix, Vector3(0.155, 0.38, 0.19), 
		Vector3(0.11 * side, 0.75, 0.0), pants, 6.0)
	_deco(thigh, Vector3(0.12, 0.12, 0.025), Vector3(0.0, -0.04, -0.098), accent)
	_deco(thigh, Vector3(0.145, 0.14, 0.185), Vector3(0.0, -0.2, 0.0), pants_dark)
	_deco(thigh, Vector3(0.12, 0.09, 0.2), Vector3(0.0, -0.335, -0.01), boots)
	_thighs.append(thigh)
	return thigh


func _shin(suffix: String, side: float, pants: Color, 
		boots: Color) -> RigidBody3D:
	var shin: = _part("Shin" + suffix, Vector3(0.135, 0.4, 0.17), 
		Vector3(0.11 * side, 0.37, 0.0), pants, 3.5)
	_deco(shin, Vector3(0.155, 0.14, 0.205), Vector3(0.0, -0.12, -0.03), boots)
	return shin


func _foot(suffix: String, side: float, boots: Color) -> RigidBody3D:
	var foot: = _part("Foot" + suffix, Vector3(0.15, 0.12, 0.3), 
		Vector3(0.11 * side, 0.1, -0.06), boots, 1.8)
	_deco(foot, Vector3(0.155, 0.045, 0.31), Vector3(0.0, -0.045, 0.0), 
		_color("sole", boots.darkened(0.35)))
	return foot



func _part(node_name: String, size: Vector3, pos: Vector3, color: Color, 
		mass: float) -> RigidBody3D:
	var body: = RigidBody3D.new()
	body.name = node_name
	body.position = pos
	body.mass = mass
	body.collision_layer = RAGDOLL_LAYER
	body.collision_mask = WORLD_MASK
	body.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	body.linear_damp = 1.6
	body.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	body.angular_damp = 3.4
	body.can_sleep = true


	body.continuous_cd = false
	body.physics_material_override = _physics
	var shape: = BoxShape3D.new()
	shape.size = size
	var collider: = CollisionShape3D.new()
	collider.shape = shape
	body.add_child(collider)
	var mesh: = MeshKit.block(body, size, Vector3.ZERO, 
		MeshKit.material(color, 0.93))
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(body)
	if exclude != null:
		body.add_collision_exception_with(exclude)
	_parts.append(body)
	return body



func _deco(parent: RigidBody3D, size: Vector3, offset: Vector3, 
		color: Color) -> void :
	var mesh: = MeshKit.block(parent, size, offset, 
		MeshKit.material(color, 0.92))


	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED




func _joint(a: RigidBody3D, b: RigidBody3D, at: Vector3, 
		low: Vector3, high: Vector3) -> void :
	var joint: = Generic6DOFJoint3D.new()
	_joint_index += 1
	joint.name = "Joint%d" % _joint_index
	joint.position = at
	joint.node_a = NodePath("../%s" % a.name)
	joint.node_b = NodePath("../%s" % b.name)

	for axis in 3:
		_set_linear_lock(joint, axis)
		_set_angular_limit(joint, axis, low[axis], high[axis])
	add_child(joint)


func _set_linear_lock(joint: Generic6DOFJoint3D, axis: int) -> void :
	var flag: = Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT
	if axis == 0:
		joint.set_flag_x(flag, true)
		joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
		joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
	elif axis == 1:
		joint.set_flag_y(flag, true)
		joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
		joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
	else:
		joint.set_flag_z(flag, true)
		joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
		joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)


func _set_angular_limit(joint: Generic6DOFJoint3D, axis: int, low: float, 
		high: float) -> void :
	var flag: = Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT
	var lower: = Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT
	var upper: = Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT
	if axis == 0:
		joint.set_flag_x(flag, true)
		joint.set_param_x(lower, low)
		joint.set_param_x(upper, high)
	elif axis == 1:
		joint.set_flag_y(flag, true)
		joint.set_param_y(lower, low)
		joint.set_param_y(upper, high)
	else:
		joint.set_flag_z(flag, true)
		joint.set_param_z(lower, low)
		joint.set_param_z(upper, high)





func _kick() -> void :
	if not is_inside_tree() or _chest == null:
		return
	var dir: = global_position - impulse_from
	dir.y = 0.0
	if dir.length_squared() < 0.01:
		dir = global_transform.basis.z
	dir = dir.normalized()
	var axis: = Vector3(dir.z, 0.0, - dir.x)
	_chest.linear_velocity = (dir * 1.6 + Vector3.UP * 0.35) * impulse_scale
	_chest.angular_velocity = axis * 3.2 * impulse_scale
	if _hips != null:
		_hips.linear_velocity = dir * 1.0 * impulse_scale
		_hips.angular_velocity = axis * 2.0 * impulse_scale
	if _head != null:
		_head.linear_velocity = (dir * 1.9 + Vector3.UP * 0.25) * impulse_scale
		_head.angular_velocity = axis * 4.2 * impulse_scale


	for thigh in _thighs:
		if is_instance_valid(thigh):
			thigh.angular_velocity = Vector3(randf_range(0.35, 0.65), 0.0, 0.0)\
			* impulse_scale


func _color(key: String, fallback: Color) -> Color:
	var value: Variant = palette.get(key)
	if value is Color:
		return value as Color
	return fallback
