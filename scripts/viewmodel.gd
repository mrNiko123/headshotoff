extends Node3D





const MeshKit = preload("res://scripts/mesh_kit.gd")
const WeaponBuilder = preload("res://scripts/weapon_builder.gd")
const WeaponData = preload("res://scripts/weapon_data.gd")
const ARM_SHADER = preload("res://shaders/arm_gradient.gdshader")

const AWP_POSITION: = Vector3(0.65, -0.405, -0.815)
const AWP_ROTATION: = Vector3(-2.0, 6.0, 1.0)
const AWP_SCALE: = 2.55



const AK_POSITION_OFFSET: = Vector3(0.32, -0.2, 0.0)
const KNIFE_POSITION: = Vector3(0.235, -0.14, -0.56)
const KNIFE_ROTATION: = Vector3(0.0, 0.0, 0.0)
const KNIFE_SCALE: = 1.02


const KNIFE_MODEL_SCALE: = 0.8



const BUTTERFLY_MODEL_SCALE: = 0.96



const BAYONET_MODEL_SCALE: = 1.2



const HAND_SCALE: = 1.2




const HAND_REF_SCALE: = 1.18


const KNIFE_HAND_SHIFT: = Vector3(0.022, 0.004, 0.0)



const BAYONET_GRIP_SHIFT: = 0.03


const BAYONET_HAND_SHIFT: = Vector3(-0.022, -0.022, 0.0)





const KNIFE_HOLD_ROTATION: = Vector3(8.0, 36.0, -22.0)




const BAYONET_HOLD_ROTATION: = Vector3(20.0, 90.0, -50.0)




const NOMAD_HOLD_ROTATION: = Vector3(22.0, 90.0, -44.0)


const NOMAD_MODEL_SCALE: = 1.08


const NOMAD_HAND_SHIFT: = Vector3(0.004, -0.032, 0.0)



const NOMAD_GRIP_SHIFT: = 0.02


const NOMAD_INSPECT_PUSH: = 0.05






const DAGGER_OFF_HOLD: = Basis(
	Vector3(0.854, -0.4103, -0.32), 
	Vector3(0.4106, 0.1536, 0.8988), 
	Vector3(-0.3196, -0.8989, 0.2996))



const DAGGER_OFF_ROLL: = 90.0




const DAGGER_OFF_VIEW_ROLL: = -40.0



const DAGGER_OFF_GRIP: = Vector3(-0.56, -0.165, 0.086)




const DAGGER_OFF_FOREARM: = Vector3(-0.42, -0.85, 0.1)



const DAGGER_OFF_THRUST: = Vector3(0.055, 0.014, -0.03)


const BUTTERFLY_HAND_SHIFT: = Vector3(0.025, 0.0, 0.0)





const BUTTERFLY_GRIP_FORWARD: = 0.03


const INSPECT_HANDOUT: = Vector3(-0.022, 0.04, 0.115)





const KARAMBIT_HOLD_ROTATION: = Vector3(0.0, -90.0, 0.0)
const KARAMBIT_FLAT_TILT: = 90.0



const KNIFE_GRIP: = Vector3(0.01, -0.06, 0.082)


const KNIFE_GRIP_DROP: = 0.05

const KNIFE_PIN_FORWARD: = 0.096


const KNIFE_FOREARM: = Vector3(0.3, -0.7, 0.3)




const SKELETON_MODEL_SCALE: = 1.0
const SKELETON_HAND_SHIFT: = Vector3(0.014, -0.046, 0.01)






const SKELETON_HOLD_ROTATION: = Vector3(34.0, 90.0, 102.0)




const SKELETON_INSPECT_HOLD_TILT: = Vector3(-14.0, -35.0, 0.0)









const BUTTERFLY_HANDLE_FAN: = Vector2(24.0, 86.0)



const BUTTERFLY_INSPECT_LIFT: = 0.065




const BUTTERFLY_INSPECT_ARM_PITCH: = 46.0




const BUTTERFLY_INSPECT_TILT: = 26.0





const KARAMBIT_INSPECT_PUSH: = 0.1



const SKELETON_INSPECT_PUSH: = 0.095




const INSPECT_RESTART_MIN: = 0.14




const INSPECT_RETRIGGER_BLEND: = 0.13


const CURVE_RELOAD: = [
	Vector2(0.0, 0.0), Vector2(0.16, 0.72), Vector2(0.36, 1.0), 
	Vector2(0.62, 0.94), Vector2(0.86, 0.24), Vector2(1.0, 0.0)
]
# Двухфазная перезарядка пистолета: отвести вниз (+наклон) и «вщёлкнуть» обратно
const CURVE_DEAGLE_RELOAD_WAVE: = [
	Vector2(0.0, 0.0), Vector2(0.14, 0.55), Vector2(0.3, 0.72), 
	Vector2(0.42, 0.55), Vector2(0.56, 0.95), Vector2(0.7, 1.0), 
	Vector2(0.85, 0.35), Vector2(1.0, 0.0)
]




const CURVE_BOLT_CYCLE: = [
	Vector2(0.0, 0.0), Vector2(0.12, 1.0), Vector2(0.7, 0.94), 
	Vector2(1.0, 0.0)
]

const CURVE_BOLT_PULL: = [
	Vector2(0.0, 0.0), Vector2(0.18, 0.0), Vector2(0.32, 1.0), 
	Vector2(0.42, 1.0), Vector2(0.58, 0.0), Vector2(1.0, 0.0)
]


const CURVE_BOLT_HAND: = [
	Vector2(0.0, 0.0), Vector2(0.1, 0.0), Vector2(0.18, 1.0), 
	Vector2(0.6, 1.0), Vector2(0.76, 0.0), Vector2(1.0, 0.0)
]






const CURVE_KNIFE_SPIN: = [
	Vector2(0.0, 0.0), Vector2(0.1, -16.0), Vector2(0.24, -34.0), 
	Vector2(0.4, -34.0), Vector2(0.48, 20.0), Vector2(0.56, 118.0), 
	Vector2(0.68, 118.0), Vector2(0.82, 30.0), Vector2(0.94, -6.0), 
	Vector2(1.0, 0.0)
]








const CURVE_KNIFE_DRAW_SPIN: = [
	Vector2(0.0, -118.0), Vector2(0.16, -58.0), Vector2(0.32, -8.0), 
	Vector2(0.48, 0.0), Vector2(1.0, 0.0)
]
const CURVE_KNIFE_WRIST_X: = [
	Vector2(0.0, 0.0), Vector2(0.12, 6.0), Vector2(0.28, -8.0), 
	Vector2(0.5, -4.0), Vector2(0.7, -8.0), Vector2(0.9, 3.0), 
	Vector2(1.0, 0.0)
]
const CURVE_KNIFE_WRIST_Z: = [
	Vector2(0.0, 0.0), Vector2(0.1, -10.0), Vector2(0.3, 8.0), 
	Vector2(0.56, 4.0), Vector2(0.72, 9.0), Vector2(0.92, -3.0), 
	Vector2(1.0, 0.0)
]


const CURVE_KNIFE_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.14, -4.0), Vector2(0.4, 7.0), 
	Vector2(0.62, 4.0), Vector2(0.8, -5.0), Vector2(0.94, 2.0), 
	Vector2(1.0, 0.0)
]
const CURVE_KNIFE_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.14, 4.0), Vector2(0.38, -6.0), 
	Vector2(0.6, -3.0), Vector2(0.78, 5.0), Vector2(0.94, -2.0), 
	Vector2(1.0, 0.0)
]
const CURVE_KNIFE_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.16, -4.0), Vector2(0.42, 6.0), 
	Vector2(0.64, -3.0), Vector2(0.84, 5.0), Vector2(0.94, -2.0), 
	Vector2(1.0, 0.0)
]
const CURVE_KNIFE_UP: = [
	Vector2(0.0, 0.0), Vector2(0.1, 0.02), Vector2(0.24, 0.098), 
	Vector2(0.55, 0.105), Vector2(0.72, 0.088), Vector2(0.88, 0.034), 
	Vector2(1.0, 0.0)
]
const CURVE_KNIFE_SIDE: = [
	Vector2(0.0, 0.0), Vector2(0.12, -0.018), Vector2(0.26, -0.07), 
	Vector2(0.56, -0.075), Vector2(0.74, -0.048), Vector2(0.9, -0.014), 
	Vector2(1.0, 0.0)
]
const CURVE_KNIFE_FORWARD: = [
	Vector2(0.0, 0.0), Vector2(0.12, 0.006), Vector2(0.28, 0.032), 
	Vector2(0.6, 0.035), Vector2(0.8, 0.014), Vector2(1.0, 0.0)
]










const CURVE_BFLY_INSPECT_SPIN: = [
	Vector2(0.0, 0.0), Vector2(0.08, 0.0), 
	Vector2(0.11, 15.0), Vector2(0.14, 50.0), Vector2(0.18, 120.0), 
	Vector2(0.22, 225.0), Vector2(0.26, 355.0), Vector2(0.3, 505.0), 
	Vector2(0.34, 665.0), Vector2(0.38, 825.0), Vector2(0.42, 975.0), 
	Vector2(0.46, 1115.0), Vector2(0.5, 1240.0), Vector2(0.54, 1345.0), 
	Vector2(0.58, 1415.0), Vector2(0.62, 1438.0), Vector2(0.68, 1440.0), 
	Vector2(0.8, 1440.0), Vector2(1.0, 1440.0)
]




const CURVE_BFLY_INSPECT_FLAT: = [
	Vector2(0.0, 0.0), Vector2(0.08, 1.0), Vector2(0.84, 1.0), 
	Vector2(1.0, 0.0)
]


const CURVE_BFLY_INSPECT_GRIP: = [
	Vector2(0.0, 0.0), Vector2(0.06, 1.0), Vector2(0.9, 1.0), 
	Vector2(1.0, 0.0)
]






const CURVE_BFLY_INSPECT_FOLD: = [
	Vector2(0.0, 1.0), Vector2(0.08, 1.0), Vector2(0.14, 0.92), 
	Vector2(0.2, 0.7), Vector2(0.26, 0.4), Vector2(0.32, 0.12), 
	Vector2(0.38, 0.0), Vector2(0.44, 0.12), Vector2(0.5, 0.4), 
	Vector2(0.56, 0.7), Vector2(0.62, 0.92), Vector2(0.68, 1.0), 
	Vector2(1.0, 1.0)
]





const CURVE_BFLY_INSPECT_WRIST_Z: = [
	Vector2(0.0, 0.0), Vector2(0.03, -30.0), Vector2(0.09, -55.0), 
	Vector2(0.18, -65.0), Vector2(0.42, -66.0), Vector2(0.6, -62.0), 
	Vector2(0.8, -66.0), Vector2(0.94, -28.0), Vector2(1.0, 0.0)
]

const CURVE_BFLY_INSPECT_WRIST_X: = [
	Vector2(0.0, 0.0), Vector2(0.1, 6.0), Vector2(0.24, -9.0), 
	Vector2(0.38, 5.0), Vector2(0.52, -7.0), Vector2(0.66, 8.0), 
	Vector2(0.8, -6.0), Vector2(0.92, 3.0), Vector2(1.0, 0.0)
]


const CURVE_BFLY_INSPECT_UP: = [
	Vector2(0.0, 0.0), Vector2(0.08, 0.03), Vector2(0.2, 0.108), 
	Vector2(0.4, 0.124), Vector2(0.6, 0.112), Vector2(0.8, 0.12), 
	Vector2(0.92, 0.052), Vector2(1.0, 0.0)
]
const CURVE_BFLY_INSPECT_SIDE: = [
	Vector2(0.0, 0.0), Vector2(0.1, -0.008), Vector2(0.26, -0.022), 
	Vector2(0.46, -0.018), Vector2(0.66, -0.024), Vector2(0.86, -0.01), 
	Vector2(1.0, 0.0)
]
const CURVE_BFLY_INSPECT_FORWARD: = [
	Vector2(0.0, 0.0), Vector2(0.1, 0.004), Vector2(0.26, 0.012), 
	Vector2(0.48, 0.01), Vector2(0.7, 0.012), Vector2(0.9, 0.004), 
	Vector2(1.0, 0.0)
]








const CURVE_BAYONET_INSPECT_ROLL: = [


	Vector2(0.0, 0.0), Vector2(0.1, 18.0), Vector2(0.22, 74.0), 
	Vector2(0.32, 96.0), Vector2(0.42, 104.0), Vector2(0.54, 168.0), 
	Vector2(0.64, 196.0), Vector2(0.74, 262.0), Vector2(0.84, 316.0), 
	Vector2(0.92, 346.0), Vector2(1.0, 360.0)
]


const CURVE_BAYONET_INSPECT_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.14, -5.0), Vector2(0.3, 4.0), 
	Vector2(0.46, 7.0), Vector2(0.62, -3.0), Vector2(0.78, -6.0), 
	Vector2(0.92, 2.0), Vector2(1.0, 0.0)
]
const CURVE_BAYONET_INSPECT_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.16, 3.0), Vector2(0.34, -4.0), 
	Vector2(0.52, -6.0), Vector2(0.7, -2.0), Vector2(0.86, 3.0), 
	Vector2(1.0, 0.0)
]
const CURVE_BAYONET_INSPECT_ROLL_BODY: = [
	Vector2(0.0, 0.0), Vector2(0.2, -2.0), Vector2(0.44, 3.0), 
	Vector2(0.66, -3.0), Vector2(0.86, 2.0), Vector2(1.0, 0.0)
]



const CURVE_BAYONET_INSPECT_UP: = [
	Vector2(0.0, 0.0), Vector2(0.12, 0.014), Vector2(0.26, 0.03), 
	Vector2(0.62, 0.032), Vector2(0.8, 0.024), Vector2(0.92, 0.009), 
	Vector2(1.0, 0.0)
]
const CURVE_BAYONET_INSPECT_SIDE: = [
	Vector2(0.0, 0.0), Vector2(0.14, -0.018), Vector2(0.3, -0.046), 
	Vector2(0.6, -0.048), Vector2(0.8, -0.026), Vector2(1.0, 0.0)
]
const CURVE_BAYONET_INSPECT_FORWARD: = [
	Vector2(0.0, 0.0), Vector2(0.14, 0.01), Vector2(0.3, 0.03), 
	Vector2(0.64, 0.032), Vector2(0.82, 0.022), Vector2(0.94, 0.007), 
	Vector2(1.0, 0.0)
]



const BAYONET_INSPECT_BASIS: = Basis(
	Vector3(0.0, 0.0, 1.0), Vector3(-1.0, 0.0, 0.0), Vector3(0.0, -1.0, 0.0))








const CURVE_BAYONET_SWING_SPIN: = [
	Vector2(0.0, 0.0), Vector2(0.14, -14.0), Vector2(0.22, -18.0), 
	Vector2(0.34, 22.0), Vector2(0.46, 30.0), Vector2(0.54, 36.0), 
	Vector2(0.7, 20.0), Vector2(0.86, 6.0), Vector2(1.0, 0.0)
]


const CURVE_BAYONET_SWING_BODY: = [
	Vector2(0.0, 0.0), Vector2(0.14, -3.0), Vector2(0.22, -4.0), 
	Vector2(0.34, 4.0), Vector2(0.46, 7.0), Vector2(0.54, 8.0), 
	Vector2(0.74, 3.0), Vector2(0.9, 1.0), Vector2(1.0, 0.0)
]
const CURVE_BAYONET_SWING_X: = [
	Vector2(0.0, 0.0), Vector2(0.14, 0.018), Vector2(0.22, 0.026), 
	Vector2(0.34, -0.07), Vector2(0.46, -0.105), Vector2(0.6, -0.078), 
	Vector2(0.8, -0.02), Vector2(1.0, 0.0)
]
const CURVE_BAYONET_SWING_Y: = [
	Vector2(0.0, 0.0), Vector2(0.14, 0.015), Vector2(0.22, 0.03), 
	Vector2(0.34, 0.08), Vector2(0.46, 0.1), Vector2(0.6, 0.085), 
	Vector2(0.8, 0.03), Vector2(1.0, 0.0)
]
const CURVE_BAYONET_SWING_Z: = [
	Vector2(0.0, 0.0), Vector2(0.14, 0.008), Vector2(0.22, 0.012), 
	Vector2(0.34, -0.03), Vector2(0.46, -0.048), Vector2(0.6, -0.03), 
	Vector2(0.8, -0.006), Vector2(1.0, 0.0)
]
const CURVE_BAYONET_SWING_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.14, 6.0), Vector2(0.22, 8.0), 
	Vector2(0.34, -1.0), Vector2(0.46, -4.0), Vector2(0.6, -2.0), 
	Vector2(0.82, 0.0), Vector2(1.0, 0.0)
]
const CURVE_BAYONET_SWING_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.14, 2.0), Vector2(0.22, 3.0), 
	Vector2(0.34, -1.0), Vector2(0.46, -2.0), Vector2(0.6, 0.0), 
	Vector2(1.0, 0.0)
]



const CURVE_NOMAD_INSPECT1_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.08, 16.0), Vector2(0.18, 58.0), 
	Vector2(0.3, 118.0), Vector2(0.42, 184.0), Vector2(0.54, 250.0), 
	Vector2(0.66, 304.0), Vector2(0.78, 340.0), Vector2(0.9, 358.0), 
	Vector2(1.0, 360.0)
]
const CURVE_NOMAD_INSPECT1_WRIST_X: = [
	Vector2(0.0, 0.0), Vector2(0.14, 5.0), Vector2(0.34, -5.0), 
	Vector2(0.56, 4.0), Vector2(0.78, -3.0), Vector2(0.94, 1.0), 
	Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT1_WRIST_Z: = [
	Vector2(0.0, 0.0), Vector2(0.1, -3.0), Vector2(0.3, 4.0), 
	Vector2(0.52, -4.0), Vector2(0.74, 3.0), Vector2(0.94, -1.0), 
	Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT1_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.16, -4.0), Vector2(0.36, 5.0), 
	Vector2(0.58, -3.0), Vector2(0.8, 4.0), Vector2(0.94, -1.0), 
	Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT1_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.18, 3.0), Vector2(0.4, -4.0), 
	Vector2(0.62, 3.0), Vector2(0.84, -2.0), Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT1_ROLL_BODY: = [
	Vector2(0.0, 0.0), Vector2(0.2, -2.0), Vector2(0.44, 2.5), 
	Vector2(0.68, -2.0), Vector2(0.88, 1.0), Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT1_UP: = [
	Vector2(0.0, 0.0), Vector2(0.1, 0.016), Vector2(0.26, 0.04), 
	Vector2(0.62, 0.044), Vector2(0.82, 0.03), Vector2(0.94, 0.01), 
	Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT1_SIDE: = [
	Vector2(0.0, 0.0), Vector2(0.14, -0.018), Vector2(0.32, -0.048), 
	Vector2(0.62, -0.05), Vector2(0.82, -0.028), Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT1_FORWARD: = [
	Vector2(0.0, 0.0), Vector2(0.12, 0.01), Vector2(0.28, 0.032), 
	Vector2(0.64, 0.034), Vector2(0.84, 0.022), Vector2(0.95, 0.007), 
	Vector2(1.0, 0.0)
]




const CURVE_NOMAD_INSPECT2_SPIN: = [
	Vector2(0.0, 0.0), Vector2(0.06, 18.0), Vector2(0.14, 92.0), 
	Vector2(0.24, 220.0), Vector2(0.34, 356.0), Vector2(0.44, 470.0), 
	Vector2(0.52, 560.0), Vector2(0.6, 640.0), Vector2(0.68, 700.0), 
	Vector2(0.74, 726.0), Vector2(0.8, 712.0), Vector2(0.88, 720.0), 
	Vector2(1.0, 720.0)
]


const CURVE_NOMAD_INSPECT2_GRIP: = [
	Vector2(0.0, 0.0), Vector2(0.1, 14.0), Vector2(0.22, -18.0), 
	Vector2(0.34, 12.0), Vector2(0.46, -10.0), Vector2(0.58, 8.0), 
	Vector2(0.72, -4.0), Vector2(0.86, 2.0), Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT2_WRIST_X: = [
	Vector2(0.0, 0.0), Vector2(0.1, 7.0), Vector2(0.28, -10.0), 
	Vector2(0.46, 9.0), Vector2(0.64, -7.0), Vector2(0.82, 4.0), 
	Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT2_WRIST_Z: = [
	Vector2(0.0, 0.0), Vector2(0.08, -5.0), Vector2(0.26, 8.0), 
	Vector2(0.44, -8.0), Vector2(0.62, 6.0), Vector2(0.8, -3.0), 
	Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT2_TUMBLE: = [
	Vector2(0.0, 0.0), Vector2(0.12, -6.0), Vector2(0.3, 5.0), 
	Vector2(0.48, -4.0), Vector2(0.66, 4.0), Vector2(0.84, -2.0), 
	Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT2_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.14, -4.0), Vector2(0.34, 5.0), 
	Vector2(0.56, -3.0), Vector2(0.78, 2.0), Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT2_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.12, 3.0), Vector2(0.32, -5.0), 
	Vector2(0.52, 3.0), Vector2(0.72, -3.0), Vector2(0.9, 1.0), 
	Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT2_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.16, -3.0), Vector2(0.38, 4.0), 
	Vector2(0.6, -3.0), Vector2(0.82, 2.0), Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT2_UP: = [
	Vector2(0.0, 0.0), Vector2(0.08, 0.02), Vector2(0.2, 0.058), 
	Vector2(0.42, 0.064), Vector2(0.64, 0.058), Vector2(0.82, 0.03), 
	Vector2(0.94, 0.008), Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT2_SIDE: = [
	Vector2(0.0, 0.0), Vector2(0.12, -0.02), Vector2(0.3, -0.052), 
	Vector2(0.52, -0.046), Vector2(0.72, -0.03), Vector2(0.9, -0.01), 
	Vector2(1.0, 0.0)
]
const CURVE_NOMAD_INSPECT2_FORWARD: = [
	Vector2(0.0, 0.0), Vector2(0.1, 0.008), Vector2(0.26, 0.03), 
	Vector2(0.48, 0.022), Vector2(0.64, 0.032), Vector2(0.82, 0.014), 
	Vector2(1.0, 0.0)
]




const CURVE_NOMAD_DRAW_SPIN_A: = [
	Vector2(0.0, -128.0), Vector2(0.16, -64.0), Vector2(0.34, -6.0), 
	Vector2(0.52, 0.0), Vector2(1.0, 0.0)
]
const CURVE_NOMAD_DRAW_SPIN_B: = [
	Vector2(0.0, 112.0), Vector2(0.18, 54.0), Vector2(0.36, 4.0), 
	Vector2(0.54, 0.0), Vector2(1.0, 0.0)
]




const CURVE_NOMAD_SWING_A_X: = [Vector2(0.0, 0.0), Vector2(0.1, 0.02), 
	Vector2(0.18, 0.03), Vector2(0.32, -0.05), Vector2(0.44, -0.07), 
	Vector2(0.58, -0.03), Vector2(0.78, -0.008), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_A_Y: = [Vector2(0.0, 0.0), Vector2(0.1, 0.012), 
	Vector2(0.18, 0.02), Vector2(0.32, -0.02), Vector2(0.44, -0.03), 
	Vector2(0.58, -0.012), Vector2(0.78, -0.003), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_A_Z: = [Vector2(0.0, 0.0), Vector2(0.1, 0.018), 
	Vector2(0.18, 0.028), Vector2(0.32, -0.045), Vector2(0.44, -0.062), 
	Vector2(0.58, -0.026), Vector2(0.78, -0.006), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_A_PITCH: = [Vector2(0.0, 0.0), Vector2(0.1, 14.0), 
	Vector2(0.18, 24.0), Vector2(0.32, -16.0), Vector2(0.42, -30.0), 
	Vector2(0.56, -10.0), Vector2(0.74, -2.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_A_YAW: = [Vector2(0.0, 0.0), Vector2(0.1, 20.0), 
	Vector2(0.18, 32.0), Vector2(0.32, 18.0), Vector2(0.42, 4.0), 
	Vector2(0.56, 2.0), Vector2(0.76, 0.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_A_ROLL: = [Vector2(0.0, 0.0), Vector2(0.1, -8.0), 
	Vector2(0.18, -14.0), Vector2(0.32, 34.0), Vector2(0.44, 46.0), 
	Vector2(0.58, 20.0), Vector2(0.76, 4.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_A_BODY: = [Vector2(0.0, 0.0), Vector2(0.12, 2.0), 
	Vector2(0.24, 3.0), Vector2(0.4, -3.0), Vector2(0.56, -4.0), 
	Vector2(0.76, -1.0), Vector2(1.0, 0.0)]



const CURVE_NOMAD_SWING_A_SPIN: = [Vector2(0.0, 0.0), Vector2(0.1, 6.0), 
	Vector2(0.18, 12.0), Vector2(0.32, -30.0), Vector2(0.44, -46.0), 
	Vector2(0.58, -18.0), Vector2(0.78, -4.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_B_SPIN: = [Vector2(0.0, 0.0), Vector2(0.1, -16.0), 
	Vector2(0.18, -26.0), Vector2(0.3, 26.0), Vector2(0.42, 42.0), 
	Vector2(0.56, 16.0), Vector2(0.78, 4.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_B_X: = [Vector2(0.0, 0.0), Vector2(0.1, -0.018), 
	Vector2(0.18, -0.028), Vector2(0.3, 0.04), Vector2(0.42, 0.058), 
	Vector2(0.56, 0.026), Vector2(0.76, 0.006), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_B_Y: = [Vector2(0.0, 0.0), Vector2(0.1, -0.01), 
	Vector2(0.18, -0.018), Vector2(0.3, 0.018), Vector2(0.42, 0.03), 
	Vector2(0.56, 0.012), Vector2(0.76, 0.003), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_B_Z: = [Vector2(0.0, 0.0), Vector2(0.1, 0.016), 
	Vector2(0.18, 0.024), Vector2(0.3, -0.04), Vector2(0.42, -0.058), 
	Vector2(0.56, -0.024), Vector2(0.76, -0.006), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_B_PITCH: = [Vector2(0.0, 0.0), Vector2(0.1, -24.0), 
	Vector2(0.18, -38.0), Vector2(0.3, 22.0), Vector2(0.42, 40.0), 
	Vector2(0.56, 14.0), Vector2(0.74, 2.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_B_YAW: = [Vector2(0.0, 0.0), Vector2(0.1, -32.0), 
	Vector2(0.18, -48.0), Vector2(0.3, -14.0), Vector2(0.42, 2.0), 
	Vector2(0.56, 2.0), Vector2(0.76, 0.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_B_ROLL: = [Vector2(0.0, 0.0), Vector2(0.1, 10.0), 
	Vector2(0.18, 18.0), Vector2(0.3, -36.0), Vector2(0.42, -50.0), 
	Vector2(0.56, -20.0), Vector2(0.76, -4.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_B_BODY: = [Vector2(0.0, 0.0), Vector2(0.12, -2.0), 
	Vector2(0.24, -3.0), Vector2(0.4, 3.0), Vector2(0.56, 4.0), 
	Vector2(0.76, 1.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_HEAVY_X: = [Vector2(0.0, 0.0), Vector2(0.12, -0.02), 
	Vector2(0.22, -0.03), Vector2(0.34, 0.05), Vector2(0.46, -0.02), 
	Vector2(0.58, -0.03), Vector2(0.78, -0.008), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_HEAVY_Y: = [Vector2(0.0, 0.0), Vector2(0.12, 0.02), 
	Vector2(0.22, 0.03), Vector2(0.34, -0.08), Vector2(0.46, -0.1), 
	Vector2(0.58, -0.04), Vector2(0.78, -0.01), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_HEAVY_Z: = [Vector2(0.0, 0.0), Vector2(0.12, 0.02), 
	Vector2(0.22, 0.03), Vector2(0.34, -0.1), Vector2(0.46, -0.14), 
	Vector2(0.58, -0.05), Vector2(0.78, -0.012), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_HEAVY_PITCH: = [Vector2(0.0, 0.0), Vector2(0.12, 28.0), 
	Vector2(0.22, 38.0), Vector2(0.3, 6.0), Vector2(0.42, -18.0), 
	Vector2(0.56, -6.0), Vector2(0.74, -2.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_HEAVY_YAW: = [Vector2(0.0, 0.0), Vector2(0.12, 14.0), 
	Vector2(0.22, 22.0), Vector2(0.34, 4.0), Vector2(0.46, -12.0), 
	Vector2(0.56, -4.0), Vector2(0.78, 0.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_HEAVY_ROLL: = [Vector2(0.0, 0.0), Vector2(0.12, -20.0), 
	Vector2(0.22, -30.0), Vector2(0.34, 30.0), Vector2(0.46, 50.0), 
	Vector2(0.58, 18.0), Vector2(0.78, 2.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_HEAVY_SPIN: = [Vector2(0.0, 0.0), Vector2(0.12, 10.0), 
	Vector2(0.22, 18.0), Vector2(0.34, -26.0), Vector2(0.46, -58.0), 
	Vector2(0.56, -40.0), Vector2(0.74, -8.0), Vector2(1.0, 0.0)]
const CURVE_NOMAD_SWING_HEAVY_BODY: = [Vector2(0.0, 0.0), Vector2(0.12, 4.0), 
	Vector2(0.22, 7.0), Vector2(0.34, -4.0), Vector2(0.46, -9.0), 
	Vector2(0.56, -5.0), Vector2(0.8, -1.0), Vector2(1.0, 0.0)]
const CURVE_KARAMBIT_INSPECT_SPIN: = [
	Vector2(0.0, 0.0), Vector2(0.05, 46.0), Vector2(0.12, 158.0), 
	Vector2(0.18, 182.0), Vector2(0.28, 176.0), Vector2(0.34, 300.0), 
	Vector2(0.42, 428.0), Vector2(0.5, 474.0), Vector2(0.58, 458.0), 
	Vector2(0.66, 560.0), Vector2(0.76, 706.0), Vector2(0.84, 728.0), 
	Vector2(0.92, 714.0), Vector2(1.0, 720.0)
]
const CURVE_KARAMBIT_INSPECT_WRIST_X: = [
	Vector2(0.0, 0.0), Vector2(0.06, 20.0), Vector2(0.16, -22.0), 
	Vector2(0.28, -10.0), Vector2(0.4, 18.0), Vector2(0.52, -20.0), 
	Vector2(0.64, 16.0), Vector2(0.78, -12.0), Vector2(0.9, 5.0), 
	Vector2(1.0, 0.0)
]
const CURVE_KARAMBIT_INSPECT_WRIST_Z: = [
	Vector2(0.0, 0.0), Vector2(0.08, -24.0), Vector2(0.2, 20.0), 
	Vector2(0.34, 26.0), Vector2(0.48, -20.0), Vector2(0.62, 24.0), 
	Vector2(0.76, -16.0), Vector2(0.9, 6.0), Vector2(1.0, 0.0)
]




const CURVE_KARAMBIT_INSPECT_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.1, -7.0), Vector2(0.24, 9.0), 
	Vector2(0.4, -4.0), Vector2(0.56, 10.0), Vector2(0.72, -6.0), 
	Vector2(0.88, 3.0), Vector2(1.0, 0.0)
]
const CURVE_KARAMBIT_INSPECT_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.12, 7.0), Vector2(0.3, -9.0), 
	Vector2(0.48, 6.0), Vector2(0.66, -7.0), Vector2(0.84, 3.0), 
	Vector2(1.0, 0.0)
]
const CURVE_KARAMBIT_INSPECT_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.08, -7.0), Vector2(0.22, 9.0), 
	Vector2(0.38, -5.0), Vector2(0.54, 10.0), Vector2(0.7, -8.0), 
	Vector2(0.86, 4.0), Vector2(1.0, 0.0)
]
const CURVE_KARAMBIT_INSPECT_UP: = [
	Vector2(0.0, 0.0), Vector2(0.06, 0.032), Vector2(0.16, 0.112), 
	Vector2(0.28, 0.138), Vector2(0.4, 0.116), Vector2(0.52, 0.142), 
	Vector2(0.64, 0.12), Vector2(0.78, 0.052), Vector2(0.9, 0.016), 
	Vector2(1.0, 0.0)
]
const CURVE_KARAMBIT_INSPECT_SIDE: = [
	Vector2(0.0, 0.0), Vector2(0.1, -0.03), Vector2(0.24, -0.076), 
	Vector2(0.42, -0.06), Vector2(0.58, -0.086), Vector2(0.76, -0.04), 
	Vector2(0.9, -0.01), Vector2(1.0, 0.0)
]
const CURVE_KARAMBIT_INSPECT_FORWARD: = [
	Vector2(0.0, 0.0), Vector2(0.1, 0.01), Vector2(0.26, 0.046), 
	Vector2(0.48, 0.03), Vector2(0.62, 0.05), Vector2(0.8, 0.02), 
	Vector2(1.0, 0.0)
]
const CURVE_SKELETON_INSPECT_SPIN: = [
	Vector2(0.0, 0.0), Vector2(0.08, -24.0), Vector2(0.2, 120.0), 
	Vector2(0.32, 300.0), Vector2(0.44, 360.0), Vector2(0.54, 360.0), 
	Vector2(0.66, 560.0), Vector2(0.8, 716.0), Vector2(0.9, 726.0), 
	Vector2(1.0, 720.0)
]



const CURVE_SKELETON_INSPECT_TUMBLE: = [
	Vector2(0.0, 0.0), Vector2(0.1, -16.0), Vector2(0.22, 14.0), 
	Vector2(0.36, -12.0), Vector2(0.5, 17.0), Vector2(0.64, -14.0), 
	Vector2(0.78, 11.0), Vector2(0.9, -5.0), Vector2(1.0, 0.0)
]
const CURVE_SKELETON_INSPECT_WRIST_X: = [
	Vector2(0.0, 0.0), Vector2(0.08, 14.0), Vector2(0.2, -18.0), 
	Vector2(0.34, 16.0), Vector2(0.48, -20.0), Vector2(0.62, 16.0), 
	Vector2(0.78, -11.0), Vector2(0.92, 4.0), Vector2(1.0, 0.0)
]
const CURVE_SKELETON_INSPECT_WRIST_Z: = [
	Vector2(0.0, 0.0), Vector2(0.06, -30.0), Vector2(0.18, 20.0), 
	Vector2(0.3, 24.0), Vector2(0.42, -18.0), Vector2(0.54, 22.0), 
	Vector2(0.68, -15.0), Vector2(0.82, 8.0), Vector2(1.0, 0.0)
]


const CURVE_SKELETON_INSPECT_UP: = [
	Vector2(0.0, 0.0), Vector2(0.08, 0.04), Vector2(0.2, 0.128), 
	Vector2(0.34, 0.146), Vector2(0.48, 0.12), Vector2(0.62, 0.15), 
	Vector2(0.76, 0.118), Vector2(0.9, 0.04), Vector2(1.0, 0.0)
]
const CURVE_SKELETON_INSPECT_SIDE: = [
	Vector2(0.0, 0.0), Vector2(0.1, -0.02), Vector2(0.24, -0.074), 
	Vector2(0.4, -0.058), Vector2(0.56, -0.082), Vector2(0.72, -0.052), 
	Vector2(0.88, -0.016), Vector2(1.0, 0.0)
]
const CURVE_SKELETON_INSPECT_FORWARD: = [
	Vector2(0.0, 0.0), Vector2(0.1, 0.014), Vector2(0.26, 0.052), 
	Vector2(0.44, 0.034), Vector2(0.62, 0.058), Vector2(0.8, 0.024), 
	Vector2(1.0, 0.0)
]




const SKELETON_IDLE_PERIOD: = 4.8
const SKELETON_IDLE_START: = 0.24
const SKELETON_IDLE_END: = 0.82
const CURVE_SKELETON_IDLE_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.1, 12.0), Vector2(0.3, 150.0), 
	Vector2(0.52, 264.0), Vector2(0.74, 338.0), Vector2(0.9, 358.0), 
	Vector2(1.0, 360.0)
]
const CURVE_SKELETON_IDLE_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.18, -16.0), Vector2(0.42, 12.0), 
	Vector2(0.66, -10.0), Vector2(0.86, 6.0), Vector2(1.0, 0.0)
]
const CURVE_SKELETON_IDLE_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.22, 18.0), Vector2(0.5, -12.0), 
	Vector2(0.78, 8.0), Vector2(1.0, 0.0)
]
const CURVE_DAGGER_INSPECT_SPIN: = [
	Vector2(0.0, 0.0), Vector2(0.1, -30.0), Vector2(0.24, 120.0), 
	Vector2(0.38, 250.0), Vector2(0.5, 360.0), Vector2(0.64, 360.0), 
	Vector2(0.78, 368.0), Vector2(0.92, 362.0), Vector2(1.0, 360.0)
]





const CURVE_DAGGER_OFF_INSPECT_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.08, -52.0), Vector2(0.18, 34.0), 
	Vector2(0.3, -96.0), Vector2(0.44, -218.0), Vector2(0.58, -330.0), 
	Vector2(0.66, -384.0), Vector2(0.8, -366.0), Vector2(0.92, -359.0), 
	Vector2(1.0, -360.0)
]




const CURVE_DAGGER_OFF_GUARD_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.16, -5.0), Vector2(0.34, -9.0), 
	Vector2(0.6, -5.0), Vector2(0.84, -1.0), Vector2(1.0, 0.0)
]
const CURVE_DAGGER_OFF_GUARD_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.14, 7.0), Vector2(0.32, 12.0), 
	Vector2(0.58, 6.0), Vector2(0.82, 1.5), Vector2(1.0, 0.0)
]
const CURVE_DAGGER_OFF_GUARD_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.12, -10.0), Vector2(0.3, -17.0), 
	Vector2(0.56, -9.0), Vector2(0.82, -2.0), Vector2(1.0, 0.0)
]
const CURVE_DAGGER_OFF_GUARD_BACK: = [
	Vector2(0.0, 0.0), Vector2(0.16, 0.02), Vector2(0.34, 0.034), 
	Vector2(0.6, 0.018), Vector2(0.84, 0.004), Vector2(1.0, 0.0)
]



const CURVE_DAGGER_OFF_THRUST: = [
	Vector2(0.0, 0.0), Vector2(0.1, -0.12), Vector2(0.24, 0.72), 
	Vector2(0.34, 1.0), Vector2(0.52, 0.46), Vector2(0.74, 0.12), 
	Vector2(1.0, 0.0)
]
const CURVE_DAGGER_OFF_GUARD_DOWN: = [
	Vector2(0.0, 0.0), Vector2(0.16, -0.008), Vector2(0.34, -0.014), 
	Vector2(0.6, -0.007), Vector2(0.84, -0.001), Vector2(1.0, 0.0)
]


const CURVE_DAGGER_RIGHT_GUARD_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.18, 9.0), Vector2(0.38, 13.0), 
	Vector2(0.64, 6.0), Vector2(0.86, 1.0), Vector2(1.0, 0.0)
]
const CURVE_GUN_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.12, -6.0), Vector2(0.34, 54.0), 
	Vector2(0.48, 54.0), Vector2(0.62, 16.0), Vector2(0.76, -24.0), 
	Vector2(0.9, -4.0), Vector2(1.0, 0.0)
]
const CURVE_GUN_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.14, -6.0), Vector2(0.36, -20.0), 
	Vector2(0.58, -10.0), Vector2(0.78, 7.0), Vector2(1.0, 0.0)
]
const CURVE_GUN_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.16, 12.0), Vector2(0.38, -28.0), 
	Vector2(0.6, -28.0), Vector2(0.82, 10.0), Vector2(1.0, 0.0)
]
# Осмотр дигла: поднести к лицу, наклонить и показать профиль затвора,
# покрутить и вернуть в исходную позицию
const CURVE_DEAGLE_INSPECT_YAW: = [
	Vector2(0.0, 0.0), Vector2(0.15, -10.0), Vector2(0.36, 30.0), 
	Vector2(0.58, 30.0), Vector2(0.74, 4.0), Vector2(0.88, -12.0), 
	Vector2(1.0, 0.0)
]
const CURVE_DEAGLE_INSPECT_PITCH: = [
	Vector2(0.0, 0.0), Vector2(0.16, -10.0), Vector2(0.4, -18.0), 
	Vector2(0.62, -8.0), Vector2(0.8, 6.0), Vector2(1.0, 0.0)
]
const CURVE_DEAGLE_INSPECT_ROLL: = [
	Vector2(0.0, 0.0), Vector2(0.18, 8.0), Vector2(0.4, -18.0), 
	Vector2(0.62, -18.0), Vector2(0.84, 4.0), Vector2(1.0, 0.0)
]
const CURVE_DEAGLE_INSPECT_UP: = [
	Vector2(0.0, 0.0), Vector2(0.2, 0.045), Vector2(0.6, 0.055), 
	Vector2(0.9, 0.0), Vector2(1.0, 0.0)
]
const CURVE_DEAGLE_INSPECT_SIDE: = [
	Vector2(0.0, 0.0), Vector2(0.2, -0.035), Vector2(0.6, -0.045), 
	Vector2(0.9, 0.0), Vector2(1.0, 0.0)
]
const CURVE_DEAGLE_INSPECT_FORWARD: = [
	Vector2(0.0, 0.0), Vector2(0.2, -0.12), Vector2(0.6, -0.14), 
	Vector2(0.9, 0.0), Vector2(1.0, 0.0)
]








const CURVE_SWING_A_X: = [Vector2(0.0, 0.0), Vector2(0.14, 0.028), 
	Vector2(0.3, -0.055), Vector2(0.46, -0.07), Vector2(0.64, -0.045), 
	Vector2(0.84, -0.01), Vector2(1.0, 0.0)]
const CURVE_SWING_A_Y: = [Vector2(0.0, 0.0), Vector2(0.14, 0.018), 
	Vector2(0.3, -0.018), Vector2(0.46, -0.028), Vector2(0.64, -0.02), 
	Vector2(0.84, -0.004), Vector2(1.0, 0.0)]
const CURVE_SWING_A_Z: = [Vector2(0.0, 0.0), Vector2(0.14, 0.02), 
	Vector2(0.3, -0.045), Vector2(0.46, -0.035), Vector2(0.64, -0.018), 
	Vector2(0.84, -0.004), Vector2(1.0, 0.0)]
const CURVE_SWING_A_PITCH: = [Vector2(0.0, 0.0), Vector2(0.14, 38.0), 
	Vector2(0.3, -18.0), Vector2(0.46, -8.0), Vector2(0.64, -2.0), 
	Vector2(1.0, 0.0)]
const CURVE_SWING_A_YAW: = [Vector2(0.0, 0.0), Vector2(0.14, 52.0), 
	Vector2(0.3, 24.0), Vector2(0.46, 12.0), Vector2(0.64, 4.0), 
	Vector2(1.0, 0.0)]
const CURVE_SWING_A_ROLL: = [Vector2(0.0, 0.0), Vector2(0.46, 0.0), 
	Vector2(0.52, 14.0), Vector2(0.68, -180.0), Vector2(0.86, -360.0), 
	Vector2(1.0, -360.0)]
const CURVE_SWING_B_X: = [Vector2(0.0, 0.0), Vector2(0.14, -0.02), 
	Vector2(0.3, 0.045), Vector2(0.46, 0.055), Vector2(0.64, 0.03), 
	Vector2(0.84, 0.006), Vector2(1.0, 0.0)]
const CURVE_SWING_B_Y: = [Vector2(0.0, 0.0), Vector2(0.14, -0.02), 
	Vector2(0.3, 0.012), Vector2(0.46, 0.02), Vector2(0.64, 0.012), 
	Vector2(0.84, 0.003), Vector2(1.0, 0.0)]
const CURVE_SWING_B_Z: = [Vector2(0.0, 0.0), Vector2(0.14, 0.014), 
	Vector2(0.3, -0.04), Vector2(0.46, -0.03), Vector2(0.64, -0.014), 
	Vector2(0.84, -0.003), Vector2(1.0, 0.0)]
const CURVE_SWING_B_PITCH: = [Vector2(0.0, 0.0), Vector2(0.14, -24.0), 
	Vector2(0.3, 30.0), Vector2(0.46, 14.0), Vector2(0.64, 4.0), 
	Vector2(1.0, 0.0)]
const CURVE_SWING_B_YAW: = [Vector2(0.0, 0.0), Vector2(0.14, 12.0), 
	Vector2(0.3, 46.0), Vector2(0.46, 30.0), Vector2(0.64, 10.0), 
	Vector2(1.0, 0.0)]
const CURVE_SWING_B_ROLL: = [Vector2(0.0, 0.0), Vector2(0.46, 0.0), 
	Vector2(0.52, -14.0), Vector2(0.68, 180.0), Vector2(0.86, 360.0), 
	Vector2(1.0, 360.0)]
const CURVE_SWING_C_X: = [Vector2(0.0, 0.0), Vector2(0.16, 0.018), 
	Vector2(0.34, -0.06), Vector2(0.5, -0.048), Vector2(0.64, -0.062), 
	Vector2(0.84, -0.012), Vector2(1.0, 0.0)]
const CURVE_SWING_C_Y: = [Vector2(0.0, 0.0), Vector2(0.16, 0.026), 
	Vector2(0.34, -0.03), Vector2(0.5, -0.022), Vector2(0.64, -0.035), 
	Vector2(0.84, -0.006), Vector2(1.0, 0.0)]
const CURVE_SWING_C_Z: = [Vector2(0.0, 0.0), Vector2(0.16, 0.022), 
	Vector2(0.34, -0.075), Vector2(0.52, -0.05), Vector2(0.64, -0.03), 
	Vector2(0.84, -0.006), Vector2(1.0, 0.0)]
const CURVE_SWING_C_PITCH: = [Vector2(0.0, 0.0), Vector2(0.16, 48.0), 
	Vector2(0.34, -22.0), Vector2(0.5, -8.0), Vector2(0.64, -2.0), 
	Vector2(1.0, 0.0)]
const CURVE_SWING_C_YAW: = [Vector2(0.0, 0.0), Vector2(0.16, 38.0), 
	Vector2(0.34, 12.0), Vector2(0.5, 18.0), Vector2(0.64, 6.0), 
	Vector2(1.0, 0.0)]
const CURVE_SWING_C_ROLL: = [Vector2(0.0, 0.0), Vector2(0.46, 0.0), 
	Vector2(0.54, 16.0), Vector2(0.72, -180.0), Vector2(0.9, -360.0), 
	Vector2(1.0, -360.0)]








const CURVE_BFLY_SWING_A_X: = [Vector2(0.0, 0.0), Vector2(0.1, 0.016), 
	Vector2(0.16, 0.026), Vector2(0.32, -0.034), Vector2(0.44, -0.044), 
	Vector2(0.58, -0.02), Vector2(0.78, -0.005), Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_A_Y: = [Vector2(0.0, 0.0), Vector2(0.1, 0.008), 
	Vector2(0.16, 0.012), Vector2(0.32, -0.018), Vector2(0.44, -0.026), 
	Vector2(0.58, -0.01), Vector2(0.78, -0.002), Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_A_Z: = [Vector2(0.0, 0.0), Vector2(0.1, 0.018), 
	Vector2(0.16, 0.026), Vector2(0.32, -0.036), Vector2(0.44, -0.052), 
	Vector2(0.58, -0.024), Vector2(0.78, -0.006), Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_A_PITCH: = [Vector2(0.0, 0.0), Vector2(0.1, 34.0), 
	Vector2(0.18, 52.0), Vector2(0.32, -18.0), Vector2(0.42, -34.0), 
	Vector2(0.56, -12.0), Vector2(0.74, -3.0), Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_A_YAW: = [Vector2(0.0, 0.0), Vector2(0.1, 46.0), 
	Vector2(0.18, 68.0), Vector2(0.32, 16.0), Vector2(0.42, 4.0), 
	Vector2(0.56, 8.0), Vector2(0.76, 3.0), Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_A_ROLL: = [Vector2(0.0, 0.0), Vector2(0.4, 0.0), 
	Vector2(0.46, -16.0), Vector2(0.6, -180.0), Vector2(0.72, -338.0), 
	Vector2(0.82, -372.0), Vector2(0.9, -360.0), Vector2(1.0, -360.0)]


const CURVE_BFLY_SWING_A_TUMBLE: = [Vector2(0.0, 0.0), Vector2(0.4, 0.0), 
	Vector2(0.5, 16.0), Vector2(0.6, -18.0), Vector2(0.7, 14.0), 
	Vector2(0.8, -9.0), Vector2(0.9, 3.0), Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_B_X: = [Vector2(0.0, 0.0), Vector2(0.1, -0.014), 
	Vector2(0.16, -0.022), Vector2(0.28, 0.024), Vector2(0.38, 0.04), 
	Vector2(0.48, 0.034), Vector2(0.6, 0.014), Vector2(0.76, 0.004), 
	Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_B_Y: = [Vector2(0.0, 0.0), Vector2(0.1, -0.006), 
	Vector2(0.16, -0.01), Vector2(0.28, 0.016), Vector2(0.38, 0.026), 
	Vector2(0.48, 0.022), Vector2(0.62, 0.008), Vector2(0.78, 0.002), 
	Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_B_Z: = [Vector2(0.0, 0.0), Vector2(0.1, 0.016), 
	Vector2(0.16, 0.024), Vector2(0.28, -0.024), Vector2(0.38, -0.044), 
	Vector2(0.48, -0.056), Vector2(0.62, -0.026), Vector2(0.8, -0.006), 
	Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_B_PITCH: = [Vector2(0.0, 0.0), Vector2(0.1, -26.0), 
	Vector2(0.16, -40.0), Vector2(0.28, 10.0), Vector2(0.38, 44.0), 
	Vector2(0.48, 56.0), Vector2(0.62, 20.0), Vector2(0.78, 4.0), 
	Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_B_YAW: = [Vector2(0.0, 0.0), Vector2(0.1, -20.0), 
	Vector2(0.16, -30.0), Vector2(0.28, 24.0), Vector2(0.38, 54.0), 
	Vector2(0.48, 68.0), Vector2(0.62, 28.0), Vector2(0.78, 6.0), 
	Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_B_ROLL: = [Vector2(0.0, 0.0), Vector2(0.4, 0.0), 
	Vector2(0.46, 16.0), Vector2(0.6, 180.0), Vector2(0.72, 338.0), 
	Vector2(0.82, 372.0), Vector2(0.9, 360.0), Vector2(1.0, 360.0)]
const CURVE_BFLY_SWING_B_TUMBLE: = [Vector2(0.0, 0.0), Vector2(0.4, 0.0), 
	Vector2(0.5, -16.0), Vector2(0.6, 18.0), Vector2(0.7, -14.0), 
	Vector2(0.8, 9.0), Vector2(0.9, -3.0), Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_C_X: = [Vector2(0.0, 0.0), Vector2(0.12, 0.012), 
	Vector2(0.18, 0.018), Vector2(0.32, -0.03), Vector2(0.42, -0.044), 
	Vector2(0.56, -0.022), Vector2(0.72, -0.008), Vector2(0.88, 0.003), 
	Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_C_Y: = [Vector2(0.0, 0.0), Vector2(0.12, 0.006), 
	Vector2(0.18, 0.01), Vector2(0.32, -0.022), Vector2(0.42, -0.034), 
	Vector2(0.58, -0.016), Vector2(0.76, -0.004), Vector2(1.0, 0.0)]


const CURVE_BFLY_SWING_C_Z: = [Vector2(0.0, 0.0), Vector2(0.12, 0.022), 
	Vector2(0.18, 0.034), Vector2(0.32, -0.038), Vector2(0.42, -0.062), 
	Vector2(0.52, -0.072), Vector2(0.66, -0.032), Vector2(0.82, -0.008), 
	Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_C_PITCH: = [Vector2(0.0, 0.0), Vector2(0.12, 36.0), 
	Vector2(0.18, 54.0), Vector2(0.32, -6.0), Vector2(0.42, -26.0), 
	Vector2(0.56, -12.0), Vector2(0.72, -3.0), Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_C_YAW: = [Vector2(0.0, 0.0), Vector2(0.12, 34.0), 
	Vector2(0.18, 52.0), Vector2(0.32, 20.0), Vector2(0.42, 10.0), 
	Vector2(0.56, 4.0), Vector2(0.74, 1.0), Vector2(1.0, 0.0)]
const CURVE_BFLY_SWING_C_ROLL: = [Vector2(0.0, 0.0), Vector2(0.44, 0.0), 
	Vector2(0.5, -16.0), Vector2(0.64, -180.0), Vector2(0.76, -338.0), 
	Vector2(0.86, -372.0), Vector2(0.94, -360.0), Vector2(1.0, -360.0)]
const CURVE_BFLY_SWING_C_TUMBLE: = [Vector2(0.0, 0.0), Vector2(0.44, 0.0), 
	Vector2(0.54, 14.0), Vector2(0.64, -16.0), Vector2(0.74, 12.0), 
	Vector2(0.84, -7.0), Vector2(0.92, 2.0), Vector2(1.0, 0.0)]



const SWING_DROP: = -0.04





const AWP_KICK_LIFT: = 0.06
const AWP_KICK_PITCH: = 0.15
const AWP_KICK_BACK: = 0.05
const AWP_KICK_LIFT_MAX: = 0.12
const AWP_KICK_PITCH_MAX: = 0.3
const AWP_KICK_BACK_MAX: = 0.11





const RIFLE_KICK_LIFT: = 0.015
const RIFLE_KICK_LIFT_MAX: = 0.04
const RIFLE_KICK_PITCH: = 0.032
const RIFLE_KICK_PITCH_MAX: = 0.075
const RIFLE_KICK_BACK: = 0.15
const RIFLE_KICK_BACK_MAX: = 0.27



const RIFLE_BACK_RIG_SHARE: = 0.85


const AWP_KICK_SETTLE: = 6.5

const PISTOL_KICK_LIFT: = 0.018
const PISTOL_KICK_LIFT_MAX: = 0.04
const PISTOL_KICK_PITCH: = 0.05
const PISTOL_KICK_PITCH_MAX: = 0.11
const PISTOL_KICK_BACK: = 0.022
const PISTOL_KICK_BACK_MAX: = 0.05



const BOLT_HAND_GRAB: = Vector3(0.062, 0.078, -0.025)




const BOLT_HAND_PULL: = Vector3(0.006, -0.004, 0.022)




const CURVE_KNIFE_STAB_L_X: = [Vector2(0.0, 0.0), Vector2(0.1, 0.018), 
	Vector2(0.22, -0.032), Vector2(0.34, -0.046), Vector2(0.52, -0.022), 
	Vector2(0.74, -0.008), Vector2(1.0, 0.0)]
const CURVE_KNIFE_STAB_L_Y: = [Vector2(0.0, 0.0), Vector2(0.1, 0.014), 
	Vector2(0.22, -0.018), Vector2(0.34, -0.026), Vector2(0.52, 0.014), 
	Vector2(0.72, 0.03), Vector2(0.9, 0.012), Vector2(1.0, 0.0)]
const CURVE_KNIFE_STAB_L_Z: = [Vector2(0.0, 0.0), Vector2(0.1, 0.024), 
	Vector2(0.24, -0.068), Vector2(0.34, -0.112), Vector2(0.5, -0.058), 
	Vector2(0.74, -0.018), Vector2(1.0, 0.0)]
const CURVE_KNIFE_STAB_L_PITCH: = [Vector2(0.0, 0.0), Vector2(0.1, -14.0), 
	Vector2(0.24, 6.0), Vector2(0.34, 11.0), Vector2(0.52, 5.0), 
	Vector2(0.74, 1.0), Vector2(1.0, 0.0)]
const CURVE_KNIFE_STAB_L_YAW: = [Vector2(0.0, 0.0), Vector2(0.1, 14.0), 
	Vector2(0.24, 6.0), Vector2(0.34, 2.0), Vector2(0.52, 1.0), 
	Vector2(1.0, 0.0)]
const CURVE_KNIFE_STAB_L_ROLL: = [Vector2(0.0, 0.0), Vector2(0.1, 10.0), 
	Vector2(0.26, -14.0), Vector2(0.42, -8.0), Vector2(0.64, 2.0), 
	Vector2(1.0, 0.0)]


const CURVE_DRAW: = [
	Vector2(0.0, 0.0), Vector2(0.44, 0.9), Vector2(0.72, 1.045), 
	Vector2(1.0, 1.0)
]




const CURVE_DRAW_KNIFE: = [
	Vector2(0.0, 0.0), Vector2(0.44, 0.9), Vector2(0.82, 1.0), 
	Vector2(1.0, 1.0)
]

var _rig: Node3D
var _weapon: Node3D
var _flash: Node3D
var _flash_light: OmniLight3D
var _seconds: = 0.0


var _sway_amount: = 1.0

var _weapon_id: = "awp"
var _skin_id: = "default"


var preview_mode: = false
var _melee: = false
var _base_position: = AWP_POSITION
var _base_rotation: = AWP_ROTATION
var _base_scale: = AWP_SCALE

var _arm_l: Node3D
var _arm_r: Node3D
var _arm_l_base: = Vector3.ZERO
var _arm_r_base: = Vector3.ZERO
var _arm_materials: Array[ShaderMaterial] = []

var _look: = Vector2.ZERO
var _look_vel: = Vector2.ZERO


var _arm_look: = Vector2.ZERO
var _sway: = Vector2.ZERO
var _bob_time: = 0.0
var _bob: = Vector3.ZERO
var _speed: = 0.0
var _on_floor: = true
var _air: = 0.0

var _kick_pitch: = 0.0
var _kick_back: = 0.0
var _kick_roll: = 0.0
var _kick_lift: = 0.0
var _hand_kick: = 0.0
var _reload_time: = 0.0
var _reload_duration: = 0.0




var _bolt_time: = 0.0
var _bolt_duration: = 0.0
var _bolt_hold: = 0.0
var _fov_scale: = 1.0
var _fov_spread: = 0.0

var _inspect_time: = 0.0
var _inspect_duration: = 0.0
var _inspect_dir: = 1.0


var _inspect_blend: = 0.0
var _inspect_blend_rig: = Transform3D()
var _inspect_blend_weapon: = Transform3D()
var _inspect_blend_offhand: = Transform3D()
var _inspect_blend_arm_l: = Transform3D()
var _inspect_blend_arm_r: = Transform3D()
var _inspect_blend_has_weapon: = false
var _inspect_blend_has_offhand: = false
var _inspect_blend_has_arms: = false
var _swing_time: = 0.0
var _swing_duration: = 0.0
var _swing_kind: = 0



var _nomad_inspect_variant: = 0
var _nomad_draw_variant: = 0

var _nomad_swing_variant: = 0


var _swing_heavy: = false


var _dual: = false
var _weapon_l: Node3D

var _swing_left: = false
var _draw_time: = 0.0
var _draw_duration: = 0.0


var _skeleton_idle_time: = 0.0


var _butterfly: = false
var _bf_blade: Node3D
var _bf_lever1: Node3D
var _bf_lever2: Node3D


var _bf_depth: = 0.0032




var _bf_axis: = Vector3.UP



var _bf_basis: = Basis.IDENTITY
var _fold: = 1.0
var _fold_from: = 1.0
var _fold_to: = 1.0
var _fold_time: = 0.0
var _fold_duration: = 0.0
var _fold_delay: = 0.0


var _draw_serial: = 0


var _knife_kind: = "butterfly"


var _grip_forward: = KNIFE_PIN_FORWARD


var _grip_drop: = KNIFE_GRIP_DROP


var _inspect_pivot: Node3D = null
var _inspect_pivot_base: = Vector3.ZERO
var _inspect_pivot_shift: = Vector3.ZERO

var _insp_spin: Array = CURVE_KNIFE_SPIN
var _insp_wrist_x: Array = CURVE_KNIFE_WRIST_X
var _insp_wrist_z: Array = CURVE_KNIFE_WRIST_Z
var _insp_yaw: Array = CURVE_KNIFE_YAW
var _insp_pitch: Array = CURVE_KNIFE_PITCH
var _insp_roll: Array = CURVE_KNIFE_ROLL
var _insp_up: Array = CURVE_KNIFE_UP
var _insp_side: Array = CURVE_KNIFE_SIDE
var _insp_forward: Array = CURVE_KNIFE_FORWARD

var _insp_tumble: Array = []



var _insp_flat: = 90.0


var _swing_spin_scale: = 1.0


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_INHERIT
	_sway_amount = Settings.vm_sway
	if not Settings.settings_changed.is_connected(_on_settings_changed):
		Settings.settings_changed.connect(_on_settings_changed)
	build_for(Settings.weapon_id, Settings.weapon_skin)


func build_for(weapon_id: String, skin_id: String) -> void :
	_weapon_id = weapon_id
	_skin_id = skin_id
	_melee = WeaponData.is_melee(weapon_id)
	_refresh_base_transform()
	build()
	if not preview_mode:
		play_draw()





func _refresh_base_transform() -> void :
	var weapon_position: = AWP_POSITION
	var weapon_rotation: = AWP_ROTATION
	var weapon_scale: = AWP_SCALE
	if _melee:
		weapon_position = KNIFE_POSITION
		weapon_rotation = KNIFE_ROTATION
		weapon_scale = KNIFE_SCALE
	elif _weapon_id == "ak47":
		weapon_position = AWP_POSITION + AK_POSITION_OFFSET
	_base_position = weapon_position + Settings.vm_offset
	_base_rotation = weapon_rotation + Settings.vm_rotation
	_base_scale = weapon_scale * Settings.vm_scale







func _base_transform() -> Transform3D:
	return Transform3D(
		Basis.from_euler(_base_rotation * (PI / 180.0)).scaled(
			Vector3.ONE * _base_scale), 
		_base_position)


func build() -> void :



	if not preview_mode:
		Sfx.stop_weapon_sounds()
	for child in get_children():
		child.queue_free()
	_weapon = null
	_weapon_l = null
	_inspect_pivot = null
	_inspect_pivot_base = Vector3.ZERO
	_inspect_pivot_shift = Vector3.ZERO
	_flash = null
	_flash_light = null
	_arm_l = null
	_arm_r = null
	_reload_time = 0.0
	_reload_duration = 0.0
	_bolt_time = 0.0
	_bolt_duration = 0.0
	_bolt_hold = 0.0
	_inspect_time = 0.0
	_inspect_duration = 0.0
	_inspect_blend = 0.0
	_inspect_blend_has_weapon = false
	_inspect_blend_has_offhand = false
	_inspect_blend_has_arms = false
	_swing_time = 0.0
	_swing_duration = 0.0
	_swing_left = false
	_skeleton_idle_time = 0.0
	_arm_materials.clear()
	_butterfly = false
	_knife_kind = ""
	_grip_forward = KNIFE_PIN_FORWARD
	_grip_drop = KNIFE_GRIP_DROP
	_swing_spin_scale = 0.0
	_bf_blade = null
	_bf_lever1 = null
	_bf_lever2 = null
	_fold = 1.0
	_fold_from = 1.0
	_fold_to = 1.0
	_fold_time = 0.0
	_fold_duration = 0.0
	_fold_delay = 0.0

	_rig = Node3D.new()
	_rig.name = "Rig"
	_rig.position = _base_position
	_rig.rotation_degrees = _base_rotation
	_rig.scale = Vector3.ONE * _base_scale
	add_child(_rig)

	_weapon = WeaponBuilder.build(_rig, _weapon_id, _skin_id, false)
	_apply_weapon_tint(_weapon)
	_knife_kind = str(_weapon.get_meta("knife_kind", "butterfly" if _melee else ""))


	_inspect_pivot = _weapon.get_node_or_null("KnifePivot") as Node3D
	_inspect_pivot_shift = _weapon.get_meta("knife_inspect_offset", Vector3.ZERO)
	if _inspect_pivot != null:
		_inspect_pivot_base = _inspect_pivot.position
	_butterfly = _melee and _knife_kind == "butterfly"
	_grip_forward = float(_weapon.get_meta("grip_forward", KNIFE_PIN_FORWARD))
	_grip_drop = float(_weapon.get_meta("grip_drop", KNIFE_GRIP_DROP))
	_swing_spin_scale = 1.0 if _butterfly else 0.0



	_dual = _melee and _knife_kind == "dagger"
	if _butterfly:
		_bf_blade = _weapon.get_meta("butterfly_blade", null)
		_bf_lever1 = _weapon.get_meta("butterfly_lever1", null)
		_bf_lever2 = _weapon.get_meta("butterfly_lever2", null)
		_bf_depth = float(_weapon.get_meta("butterfly_fold_depth", 0.0032))
		_bf_axis = _butterfly_inspect_axis()
		_bf_basis = _butterfly_inspect_basis()

		_fold = 0.0
		_apply_fold(0.0)
	if _melee:



		var hold: = Basis.from_euler(_hold_rotation() * (PI / 180.0))
		_weapon.basis = hold.scaled(Vector3.ONE * _knife_model_scale())
		_weapon.position = _knife_grip_position(Basis.IDENTITY, hold)
		if _dual:
			_weapon_l = WeaponBuilder.build(_rig, _weapon_id, _skin_id, false)
			_apply_weapon_tint(_weapon_l)
			_weapon_l.name = "WeaponOffhand"


			_update_offhand(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	_build_arms(_rig)
	if not _melee:
		_build_muzzle_fx()

	_apply_render_layer(self)
	_apply_fov()






func _build_arms(rig: Node3D) -> void :
	var arms: = Node3D.new()
	arms.name = "Arms"
	rig.add_child(arms)

	if _melee:




		var knife_r: = KNIFE_GRIP + Vector3(0.0, -0.025, 0.0)
		if (_knife_kind == "bayonet" or _knife_kind == "combat"\
		or _knife_kind == "nomad") and _weapon != null:





			var hand_shift: = BAYONET_HAND_SHIFT
			var grip_shift: = BAYONET_GRIP_SHIFT
			if _knife_kind == "nomad":
				hand_shift = NOMAD_HAND_SHIFT
				grip_shift = NOMAD_GRIP_SHIFT
			knife_r = _weapon.position - hand_shift\
			+ _weapon.basis * Vector3(0.0, 0.0, 
				- grip_shift / _knife_model_scale())
		_arm_r = _make_arm(arms, knife_r, 
			knife_r + Vector3(0.3, -0.7, 0.3), 0.115, 0.092, 0.2)
		if _dual:



			var knife_l: = DAGGER_OFF_GRIP + Vector3(0.0, -0.025, 0.0)
			_arm_l = _make_arm(arms, knife_l, knife_l + DAGGER_OFF_FOREARM, 
				0.115, 0.092, 0.2)
			return




		var rp: = rig.transform * knife_r
		var knife_l: Vector3 = rig.transform.affine_inverse()\
		* Vector3( - rp.x, rp.y, rp.z)
		_arm_l = _make_arm(arms, knife_l, 
			knife_l + Vector3(-0.3, -0.7, 0.3), 0.115, 0.092, 0.2)
		return






	var grip_shift: Vector3 = _weapon.get_meta("view_grip", Vector3.ZERO)
	var right_grip: = Vector3(-0.052, -0.064, 0.03) + grip_shift
	var left_grip: = Vector3(-0.018, -0.088, -0.545) + grip_shift




	if _weapon.has_meta("view_hand_right") and _weapon.has_meta("view_hand_left"):
		right_grip = _weapon.get_meta("view_hand_right")


		right_grip += Vector3(0.004, 0.048, 0.0)
		left_grip = _weapon.get_meta("view_hand_left")
		left_grip += Vector3(-0.006, -0.01, 0.0)
	_arm_r = _make_arm(arms, right_grip, 
		right_grip + Vector3(0.52, -0.9, 0.3), 0.14, 0.132, 0.32)




	_arm_l = _make_arm(arms, left_grip, 
		left_grip + Vector3(-0.56, -1.0, 0.12), 0.148, 0.138, 0.32)




func _make_arm(parent: Node3D, grip: Vector3, elbow: Vector3, width: float, 
		thickness: float, hand_span: float) -> Node3D:
	var hand_fix: = HAND_SCALE
	if not _melee:
		hand_fix *= HAND_REF_SCALE / AWP_SCALE
	width *= hand_fix
	thickness *= hand_fix
	hand_span *= hand_fix
	var arm: = Node3D.new()
	arm.position = grip
	parent.add_child(arm)

	var local_elbow: = elbow - grip
	var length: = maxf(local_elbow.length(), 0.001)
	var mat: = _arm_material(length * 0.5, hand_span, width * 0.5, thickness * 0.5)
	var mesh: = MeshKit.limb(arm, Vector3.ZERO, local_elbow, width, mat, 
		thickness / maxf(width, 0.001))
	mesh.name = "Arm"

	arm.set_meta("base_position", arm.position)
	return arm



func _arm_material(half_length: float, hand_span: float, half_width: float, 
		half_depth: float) -> ShaderMaterial:
	var mat: = ShaderMaterial.new()
	mat.shader = ARM_SHADER
	mat.set_shader_parameter("sleeve_color", Settings.arm_sleeve)
	mat.set_shader_parameter("glove_color", Settings.arm_glove)
	mat.set_shader_parameter("half_length", half_length)
	mat.set_shader_parameter("glove_span", hand_span)
	mat.set_shader_parameter("fade_span", 0.12)
	mat.set_shader_parameter("sharp_split", 1.0 if Settings.arm_sharp_split else 0.0)
	mat.set_shader_parameter("half_width", maxf(half_width, 0.001))
	mat.set_shader_parameter("half_depth", maxf(half_depth, 0.001))
	mat.set_shader_parameter("roughness_value", 0.7)
	mat.render_priority = 1
	_arm_materials.append(mat)
	return mat


func _apply_arm_colors() -> void :
	for mat in _arm_materials:
		if is_instance_valid(mat):
			mat.set_shader_parameter("sleeve_color", Settings.arm_sleeve)
			mat.set_shader_parameter("glove_color", Settings.arm_glove)
			mat.set_shader_parameter("sharp_split", 
				1.0 if Settings.arm_sharp_split else 0.0)


func _on_settings_changed() -> void :
	_sway_amount = Settings.vm_sway
	_apply_arm_colors()
	_apply_weapon_tint(_weapon)
	_apply_weapon_tint(_weapon_l)
	_refresh_base_transform()
	_apply_fov()






func _apply_weapon_tint(node: Node3D) -> void :
	if node == null:
		return
	var tint: = Settings.knife_tint_color() if _melee\
	else Settings.weapon_tint_color()
	WeaponBuilder.apply_tint(node, tint)



func _build_muzzle_fx() -> void :
	var muzzle: = _weapon.get_node_or_null("Muzzle") as Node3D
	if muzzle == null:
		return
	_flash = Node3D.new()
	_flash.name = "MuzzleFlash"
	_flash.visible = false
	muzzle.add_child(_flash)

	var mat: = MeshKit.additive(Color(1.0, 0.72, 0.32, 0.9))


	var flash_scale: = float(_weapon.get_meta("muzzle_flash_scale", 1.0))
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.19, 0.19) * flash_scale
	for i in 2:
		var inst: = MeshInstance3D.new()
		inst.mesh = quad
		inst.material_override = mat
		inst.rotation_degrees = Vector3(0.0, 0.0, 45.0 + i * 90.0)
		inst.position = Vector3(0.0, 0.0, -0.03 * flash_scale)
		_flash.add_child(inst)

	_flash_light = OmniLight3D.new()
	_flash_light.light_color = Color(1.0, 0.72, 0.36, 1.0)
	_flash_light.light_energy = 0.0
	_flash_light.omni_range = 3.2 * flash_scale
	_flash_light.shadow_enabled = false
	_flash_light.layers = 4
	_flash_light.light_cull_mask = 4
	_flash_light.visible = false
	muzzle.add_child(_flash_light)

	_apply_render_layer(_flash)


	_warm_muzzle_flash()


func _warm_muzzle_flash() -> void :
	if _flash == null:
		return
	var restored: Array[StandardMaterial3D] = []
	for child in _flash.get_children():
		var inst: = child as MeshInstance3D
		if inst == null:
			continue
		var mat: = inst.material_override as StandardMaterial3D
		if mat == null:
			continue
		restored.append(mat)
		mat.albedo_color.a = 0.0
	_flash.visible = true
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null:
		_flash.visible = false
		for mat in restored:
			mat.albedo_color.a = 0.9
		return
	await tree.process_frame
	await tree.process_frame
	if is_instance_valid(_flash):
		_flash.visible = false
	for mat in restored:
		if is_instance_valid(mat):
			mat.albedo_color.a = 0.9


func _apply_render_layer(node: Node) -> void :
	if node is MeshInstance3D:
		var mesh: = node as MeshInstance3D
		mesh.layers = 4




		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


		mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	for child in node.get_children():
		_apply_render_layer(child)


func _apply_fov() -> void :


	var ratio: = tan(deg_to_rad(Settings.fov) * 0.5) / tan(deg_to_rad(90.0) * 0.5)
	_fov_scale = clampf(pow(ratio, 0.3), 0.78, 1.42)
	_fov_spread = clampf((Settings.fov - 90.0) / 90.0, -0.6, 0.6)


	var sx: = - _fov_scale if Settings.left_hand else _fov_scale
	scale = Vector3(sx, _fov_scale, _fov_scale)


func set_fov(value: float) -> void :
	Settings.fov = value
	_apply_fov()


func play_draw(duration: = -1.0) -> void :
	if duration > 0.0:
		_draw_duration = duration
	else:
		_draw_duration = _knife_draw_duration() if _melee else 0.46
	_draw_time = 0.001
	if _melee:
		if _knife_kind == "nomad":
			_nomad_draw_variant = 1 - _nomad_draw_variant
		Sfx.play_knife_draw()
	if _butterfly:


		_fold_from = 0.0
		_fold_to = 1.0
		_fold = 0.0
		_fold_time = 0.0
		_fold_duration = 0.34
		_fold_delay = 0.2
		_apply_fold(0.0)


		_draw_serial += 1
		get_tree().create_timer(_fold_delay).timeout.connect(
			_on_butterfly_open_sound.bind(_draw_serial))




func _knife_draw_duration() -> float:
	match _knife_kind:
		"butterfly":
			return 0.78
		"karambit":
			return 0.64
		"skeleton":
			return 0.6
		"dagger":
			return 0.52
		"bayonet":
			return 0.56
		"nomad":


			return 0.66
		_:
			return 0.56


func _on_butterfly_open_sound(serial: int) -> void :
	if serial == _draw_serial and _butterfly:
		Sfx.play_butterfly_open()


func add_look(relative: Vector2) -> void :
	_look += relative
	_look.x = clampf(_look.x, -320.0, 320.0)
	_look.y = clampf(_look.y, -240.0, 240.0)
	_look_vel += relative


func update_motion(speed: float, on_floor: bool, delta: float) -> void :
	_speed = speed
	_on_floor = on_floor
	if on_floor and speed > 0.6:
		_bob_time += delta * (7.2 + speed * 0.4)
	else:
		_bob_time = lerpf(_bob_time, 0.0, 1.0 - exp(-6.0 * delta))






func kick(strength: = 1.0, from_shot: = false) -> void :
	if _melee:
		_kick_pitch = minf(_kick_pitch + 0.02 * strength, 0.1)
		_kick_back = minf(_kick_back + 0.012 * strength, 0.04)
		_kick_roll = clampf(_kick_roll + randf_range(-1.2, 1.2) * strength, -5.0, 5.0)
		_hand_kick = minf(_hand_kick + 0.02 * strength, 0.05)
		return
	if not from_shot:
		return



	if _weapon_id == "ak47" or _weapon_id == "m4a1":
		var rifle_scale: = 1.0 if _weapon_id == "ak47" else 0.75
		_kick_lift = minf(_kick_lift + RIFLE_KICK_LIFT * strength * rifle_scale, 
			RIFLE_KICK_LIFT_MAX * rifle_scale)
		_kick_pitch = minf(_kick_pitch + RIFLE_KICK_PITCH * strength * rifle_scale, 
			RIFLE_KICK_PITCH_MAX * rifle_scale)
		_kick_back = minf(_kick_back + RIFLE_KICK_BACK * strength * rifle_scale, 
			RIFLE_KICK_BACK_MAX * rifle_scale)
		_kick_roll = clampf(_kick_roll + randf_range(-1.8, 1.8) * strength
			* 0.65, -6.0, 6.0)
		_hand_kick = minf(_hand_kick + 0.04 * strength, 0.09)
		return



	if _weapon_id == "deagle":
		# у пистолетов свой кик: короткий щелчок запястья вместо
		# тяжёлого ашпишного подброса, иначе модель летит в камеру
		var pistol_scale: = 1.0
		_kick_lift = minf(_kick_lift + PISTOL_KICK_LIFT * strength * pistol_scale, 
			PISTOL_KICK_LIFT_MAX * pistol_scale)
		_kick_pitch = minf(_kick_pitch + PISTOL_KICK_PITCH * strength * pistol_scale, 
			PISTOL_KICK_PITCH_MAX * pistol_scale)
		_kick_back = minf(_kick_back + PISTOL_KICK_BACK * strength * pistol_scale, 
			PISTOL_KICK_BACK_MAX * pistol_scale)
		_kick_roll = clampf(_kick_roll + randf_range(-1.8, 1.8) * strength
			* 0.7, -6.0, 6.0)
		_hand_kick = minf(_hand_kick + 0.035 * strength, 0.08)
		return




	_kick_lift = minf(_kick_lift + AWP_KICK_LIFT * strength, AWP_KICK_LIFT_MAX)
	_kick_pitch = minf(_kick_pitch + AWP_KICK_PITCH * strength, 
		AWP_KICK_PITCH_MAX)
	_kick_back = minf(_kick_back + AWP_KICK_BACK * strength, 
		AWP_KICK_BACK_MAX)
	_kick_roll = clampf(_kick_roll + randf_range(-1.8, 1.8) * strength, 
		-6.0, 6.0)
	_hand_kick = minf(_hand_kick + 0.05 * strength, 0.1)


func play_reload(duration: float) -> void :
	_reload_duration = maxf(duration, 0.1)
	_reload_time = 0.0


	_bolt_time = _bolt_duration
	_bolt_hold = 0.0






func play_bolt_cycle(duration: float, delay: = 0.0) -> void :
	if _melee:
		return
	_bolt_hold = clampf(delay, 0.0, maxf(duration - 0.1, 0.0))
	_bolt_duration = maxf(duration - _bolt_hold, 0.1)
	_bolt_time = 0.0





func finish_reload_animation() -> void :
	_reload_time = _reload_duration
	_bolt_time = _bolt_duration
	_bolt_hold = 0.0


func play_inspect() -> void :



	var playing: = _inspect_time > 0.0 and _inspect_time < _inspect_duration
	if playing and _inspect_time < INSPECT_RESTART_MIN:
		return



	if playing:
		_capture_inspect_pose()


	if _melee and _knife_kind == "nomad":
		_nomad_inspect_variant = 1 - _nomad_inspect_variant
	_inspect_duration = _knife_inspect_duration() if _melee else 2.95
	_inspect_time = 0.001
	if _melee:

		_inspect_dir = - _inspect_dir
		_select_inspect_curves()
		Sfx.play_knife_flourish()





func _capture_inspect_pose() -> void :
	_inspect_blend = 1.0
	_inspect_blend_has_weapon = _weapon != null
	_inspect_blend_has_offhand = _weapon_l != null
	_inspect_blend_has_arms = _arm_r != null or _arm_l != null
	if _rig != null:
		_inspect_blend_rig = _rig.transform
	if _weapon != null:
		_inspect_blend_weapon = _weapon.transform
	if _weapon_l != null:
		_inspect_blend_offhand = _weapon_l.transform
	if _arm_r != null:
		_inspect_blend_arm_r = _arm_r.transform
	if _arm_l != null:
		_inspect_blend_arm_l = _arm_l.transform







func _blend_inspect_pose(delta: float) -> void :
	if _inspect_blend <= 0.0:
		return
	_inspect_blend = maxf(0.0, _inspect_blend - delta / INSPECT_RETRIGGER_BLEND)
	var w: = 1.0 - smoothstep(0.0, 1.0, _inspect_blend)
	if _rig != null:
		_rig.transform = _blend_transform(_inspect_blend_rig, _rig.transform, w)
	if _inspect_blend_has_weapon and _weapon != null:
		_weapon.transform = _blend_transform(_inspect_blend_weapon, 
			_weapon.transform, w)
	if _inspect_blend_has_offhand and _weapon_l != null:
		_weapon_l.transform = _blend_transform(_inspect_blend_offhand, 
			_weapon_l.transform, w)
	if _inspect_blend_has_arms:
		if _arm_r != null:
			_arm_r.transform = _blend_transform(_inspect_blend_arm_r, 
				_arm_r.transform, w)
		if _arm_l != null:
			_arm_l.transform = _blend_transform(_inspect_blend_arm_l, 
				_arm_l.transform, w)
	if w >= 1.0:
		_inspect_blend = 0.0





static func _blend_transform(from: Transform3D, to: Transform3D, w: float) -> Transform3D:
	if w <= 0.0:
		return from
	if w >= 1.0:
		return to
	var basis: = Basis(from.basis.get_rotation_quaternion().slerp(
		to.basis.get_rotation_quaternion(), w))
	basis = basis.scaled(from.basis.get_scale().lerp(to.basis.get_scale(), w))
	return Transform3D(basis, from.origin.lerp(to.origin, w))





func _select_inspect_curves() -> void :
	_insp_spin = CURVE_KNIFE_SPIN
	_insp_wrist_x = CURVE_KNIFE_WRIST_X
	_insp_wrist_z = CURVE_KNIFE_WRIST_Z
	_insp_yaw = CURVE_KNIFE_YAW
	_insp_pitch = CURVE_KNIFE_PITCH
	_insp_roll = CURVE_KNIFE_ROLL
	_insp_up = CURVE_KNIFE_UP
	_insp_side = CURVE_KNIFE_SIDE
	_insp_forward = CURVE_KNIFE_FORWARD
	_insp_tumble = []
	_insp_flat = 90.0
	match _knife_kind:
		"butterfly":


			_insp_spin = CURVE_BFLY_INSPECT_SPIN
			_bf_axis = _butterfly_inspect_axis()
			_bf_basis = _butterfly_inspect_basis()
			_insp_wrist_x = CURVE_BFLY_INSPECT_WRIST_X
			_insp_wrist_z = CURVE_BFLY_INSPECT_WRIST_Z


			_insp_tumble = []




			_insp_yaw = []
			_insp_pitch = []
			_insp_roll = []
			_insp_up = CURVE_BFLY_INSPECT_UP
			_insp_side = CURVE_BFLY_INSPECT_SIDE
			_insp_forward = CURVE_BFLY_INSPECT_FORWARD


			_insp_flat = 0.0
		"karambit":
			_insp_spin = CURVE_KARAMBIT_INSPECT_SPIN
			_insp_wrist_x = CURVE_KARAMBIT_INSPECT_WRIST_X
			_insp_wrist_z = CURVE_KARAMBIT_INSPECT_WRIST_Z
			_insp_yaw = CURVE_KARAMBIT_INSPECT_YAW
			_insp_pitch = CURVE_KARAMBIT_INSPECT_PITCH
			_insp_roll = CURVE_KARAMBIT_INSPECT_ROLL
			_insp_up = CURVE_KARAMBIT_INSPECT_UP
			_insp_side = CURVE_KARAMBIT_INSPECT_SIDE
			_insp_forward = CURVE_KARAMBIT_INSPECT_FORWARD


			_insp_flat = 0.0
		"skeleton":
			_insp_spin = CURVE_SKELETON_INSPECT_SPIN
			_insp_wrist_x = CURVE_SKELETON_INSPECT_WRIST_X
			_insp_wrist_z = CURVE_SKELETON_INSPECT_WRIST_Z
			_insp_tumble = CURVE_SKELETON_INSPECT_TUMBLE
			_insp_up = CURVE_SKELETON_INSPECT_UP
			_insp_side = CURVE_SKELETON_INSPECT_SIDE
			_insp_forward = CURVE_SKELETON_INSPECT_FORWARD



			_insp_flat = 90.0
		"dagger":
			_insp_spin = CURVE_DAGGER_INSPECT_SPIN
		"combat":




			_insp_flat = 0.0
		"bayonet":


			_insp_spin = []
			_insp_wrist_x = []
			_insp_wrist_z = []
			_insp_yaw = CURVE_BAYONET_INSPECT_YAW
			_insp_pitch = CURVE_BAYONET_INSPECT_PITCH
			_insp_roll = CURVE_BAYONET_INSPECT_ROLL_BODY
			_insp_up = CURVE_BAYONET_INSPECT_UP
			_insp_side = CURVE_BAYONET_INSPECT_SIDE
			_insp_forward = CURVE_BAYONET_INSPECT_FORWARD


			_insp_flat = 0.0
		"nomad":




			_insp_flat = 0.0
			if _nomad_inspect_variant == 0:
				_insp_spin = []
				_insp_wrist_x = CURVE_NOMAD_INSPECT1_WRIST_X
				_insp_wrist_z = CURVE_NOMAD_INSPECT1_WRIST_Z
				_insp_yaw = CURVE_NOMAD_INSPECT1_YAW
				_insp_pitch = CURVE_NOMAD_INSPECT1_PITCH
				_insp_roll = CURVE_NOMAD_INSPECT1_ROLL_BODY
				_insp_up = CURVE_NOMAD_INSPECT1_UP
				_insp_side = CURVE_NOMAD_INSPECT1_SIDE
				_insp_forward = CURVE_NOMAD_INSPECT1_FORWARD
				_insp_tumble = []
			else:
				_insp_spin = []
				_insp_wrist_x = CURVE_NOMAD_INSPECT2_WRIST_X
				_insp_wrist_z = CURVE_NOMAD_INSPECT2_WRIST_Z
				_insp_yaw = CURVE_NOMAD_INSPECT2_YAW
				_insp_pitch = CURVE_NOMAD_INSPECT2_PITCH
				_insp_roll = CURVE_NOMAD_INSPECT2_ROLL
				_insp_up = CURVE_NOMAD_INSPECT2_UP
				_insp_side = CURVE_NOMAD_INSPECT2_SIDE
				_insp_forward = CURVE_NOMAD_INSPECT2_FORWARD
				_insp_tumble = CURVE_NOMAD_INSPECT2_TUMBLE


func _knife_inspect_duration() -> float:
	match _knife_kind:
		"butterfly":

			return 3.2
		"karambit":
			return 3.35
		"skeleton":
			return 3.4
		"dagger":
			return 2.8
		"bayonet":
			return 3.4
		"nomad":


			return 3.6 if _nomad_inspect_variant == 0 else 3.2
		_:
			return 3.1




func has_heavy_attack() -> bool:
	return _melee and _knife_kind == "nomad"


func play_swing(heavy: = false) -> void :
	if not _melee:
		return
	_swing_heavy = heavy and _knife_kind == "nomad"


	if _knife_kind == "nomad":
		if _swing_heavy:
			_swing_kind = 2
			_swing_duration = 0.78
		else:
			_swing_kind = _nomad_swing_variant
			_nomad_swing_variant = 1 - _nomad_swing_variant
			_swing_duration = 0.46
		_swing_left = false
		_swing_time = 0.001
		return


	var kinds: = 1 if _knife_kind == "bayonet" else (4 if _dual else 3)
	_swing_kind = (_swing_kind + 1) % kinds
	_swing_left = _dual and _swing_kind == 3





	_swing_duration = 0.52 if _knife_kind == "bayonet" else 0.62
	_swing_time = 0.001


func flash_muzzle() -> void :
	if _flash == null or Settings.effects_quality <= 0:
		return
	var flash: = _flash
	flash.visible = true
	var tween: = flash.create_tween()
	tween.tween_interval(0.035)
	tween.tween_callback( func() -> void : flash.visible = false)

	if _flash_light != null and Settings.effects_quality >= 2:
		var light: = _flash_light
		light.light_energy = 4.0
		light.visible = true
		var light_tween: = light.create_tween()
		light_tween.tween_property(light, "light_energy", 0.0, 0.07)
		light_tween.tween_callback( func() -> void : light.visible = false)


func get_muzzle_position() -> Vector3:
	if _weapon == null:
		return global_position
	var muzzle: = _weapon.get_node_or_null("Muzzle") as Node3D
	if muzzle == null:
		return _weapon.global_position
	return muzzle.global_position


func _process(delta: float) -> void :
	_seconds += delta
	if _rig == null:
		return


	_look = _look.lerp(Vector2.ZERO, 1.0 - exp(-9.0 * delta))
	_look_vel = _look_vel.lerp(Vector2.ZERO, 1.0 - exp(-16.0 * delta))


	_arm_look = _arm_look.lerp(_look, 1.0 - exp(-4.5 * delta))
	var sway_target: = Vector2(
		clampf( - _look.x * 0.0007, -0.06, 0.06), 
		clampf(_look.y * 0.00045, -0.04, 0.04)
	) * _sway_amount
	_sway = _sway.lerp(sway_target, 1.0 - exp(-11.0 * delta))




	var lag_yaw: = clampf(_look.x * 0.02, -5.0, 5.0) * _sway_amount
	var lag_pitch: = clampf(_look.y * 0.016, -4.0, 4.0) * _sway_amount
	var lag_roll: = clampf( - _look_vel.x * 0.03, -3.0, 3.0) * _sway_amount


	_air = lerpf(_air, 0.0 if _on_floor else 1.0, 1.0 - exp(-6.0 * delta))
	var breathe: = sin(_seconds * 1.45) * 0.0026
	var bob_target: = Vector3.ZERO
	if _on_floor and _speed > 0.6:
		var amp: = clampf(_speed / 8.0, 0.35, 1.35)
		bob_target.x = sin(_bob_time) * 0.008 * amp
		bob_target.y = absf(cos(_bob_time)) * 0.01 * amp
	bob_target.y += breathe
	if not _on_floor:
		bob_target.y += sin(_seconds * 2.2) * 0.0016
	bob_target *= _sway_amount
	_bob = _bob.lerp(bob_target, 1.0 - exp(-15.0 * delta))

	if _melee:
		_kick_pitch = move_toward(_kick_pitch, 0.0, delta * 1.1)
		_kick_back = move_toward(_kick_back, 0.0, delta * 0.55)
		_kick_lift = move_toward(_kick_lift, 0.0, delta * 0.55)
		_kick_roll = move_toward(_kick_roll, 0.0, delta * 90.0)
		_hand_kick = move_toward(_hand_kick, 0.0, delta * 0.55)
	else:


		var settle: = 1.0 - exp( - AWP_KICK_SETTLE * delta)
		_kick_pitch = lerpf(_kick_pitch, 0.0, settle)
		_kick_back = lerpf(_kick_back, 0.0, settle)
		_kick_lift = lerpf(_kick_lift, 0.0, settle)
		_kick_roll = lerpf(_kick_roll, 0.0, settle)
		_hand_kick = lerpf(_hand_kick, 0.0, settle)


	var sprint: = clampf((_speed - 10.5) / 5.0, 0.0, 1.0)


	var reload_wave: = 0.0
	var reload_y: = 0.0
	var reload_z: = 0.0
	var reload_roll: = 0.0
	var bolt_wave: = 0.0
	if _reload_time < _reload_duration:
		_reload_time = minf(_reload_time + delta, _reload_duration)
		var t: = _reload_time / _reload_duration
		if _weapon_id == "deagle":
			# двухфазный жест: отводим пистолет и выбрасываем магазин,
			# потом «вщёлкиваем» обратно и снимаем затвор с задержки
			reload_wave = _curve(CURVE_DEAGLE_RELOAD_WAVE, t)
			reload_y = -0.085 * reload_wave
			reload_z = 0.062 * reload_wave
			reload_roll = -1.35 * reload_wave
		else:
			reload_wave = _curve(CURVE_RELOAD, t)
			reload_y = -0.135 * reload_wave
			reload_z = 0.055 * reload_wave
			reload_roll = 1.05 * reload_wave

		if not _melee:
			bolt_wave = _pulse(t, 0.84, 0.98) \
				if _weapon_id == "deagle" else _pulse(t, 0.72, 0.92)


	var bolt_cycle: = 0.0
	var bolt_pull: = 0.0
	var bolt_hand: = 0.0
	if not _melee and _bolt_time < _bolt_duration:
		var step: = delta
		if _bolt_hold > 0.0:




			var held: = minf(step, _bolt_hold)
			_bolt_hold -= held
			step -= held
		if step > 0.0:
			_bolt_time = minf(_bolt_time + step, _bolt_duration)
			var bt: = _bolt_time / _bolt_duration
			bolt_cycle = _curve(CURVE_BOLT_CYCLE, bt)
			bolt_pull = _curve(CURVE_BOLT_PULL, bt)
			bolt_hand = _curve(CURVE_BOLT_HAND, bt)


	var inspect_yaw: = 0.0
	var inspect_pitch: = 0.0
	var inspect_roll: = 0.0
	var inspect_up: = 0.0
	var inspect_side: = 0.0
	var inspect_forward: = 0.0
	var inspect_handout: = 0.0
	var inspect_wave: = 0.0
	var inspect_wrist: = Vector3.ZERO
	var inspect_tumble: = 0.0
	var weapon_spin: = 0.0


	var inspect_local_spin: = 0.0


	var inspect_bay_env: = 0.0



	var inspect_bf_env: = 0.0


	var inspect_bf_grip: = 0.0
	if _inspect_time < _inspect_duration:
		_inspect_time = minf(_inspect_time + delta, _inspect_duration)
		var t: = _inspect_time / _inspect_duration
		inspect_wave = sin(t * PI)
		if _melee:



			if _knife_kind == "butterfly":



				inspect_local_spin = _spline(_insp_spin, t) * _inspect_dir
				inspect_bf_env = _curve(CURVE_BFLY_INSPECT_FLAT, t)
				inspect_bf_grip = _curve(CURVE_BFLY_INSPECT_GRIP, t)
			elif _knife_kind == "bayonet":



				inspect_bay_env = _plateau(t, 0.16)
				inspect_local_spin = _curve(CURVE_BAYONET_INSPECT_ROLL, t)\
				* _inspect_dir
			elif _knife_kind == "nomad":





				var nomad_second: = _nomad_inspect_variant == 1
				inspect_bay_env = _plateau(t, 0.1 if nomad_second else 0.16)
				inspect_local_spin = _curve(
					CURVE_NOMAD_INSPECT2_SPIN if nomad_second\
					else CURVE_NOMAD_INSPECT1_ROLL, t) * _inspect_dir
				if nomad_second:



					weapon_spin = _curve(CURVE_NOMAD_INSPECT2_GRIP, t)\
					* _inspect_dir
					inspect_tumble = _curve(_insp_tumble, t) * _inspect_dir
			else:
				weapon_spin = _curve(_insp_spin, t) * _inspect_dir
			inspect_wrist.x = _curve(_insp_wrist_x, t)
			inspect_wrist.z = _curve(_insp_wrist_z, t) * _inspect_dir



			inspect_wrist.z -= _insp_flat * inspect_wave
			inspect_yaw = _curve(_insp_yaw, t)
			inspect_pitch = _curve(_insp_pitch, t)
			inspect_roll = _curve(_insp_roll, t)
			inspect_up = _curve(_insp_up, t)
			inspect_side = _curve(_insp_side, t)
			inspect_forward = _curve(_insp_forward, t)




			inspect_handout = 0.0 if _knife_kind == "butterfly" else inspect_wave
		else:
			if _weapon_id == "deagle":
				inspect_yaw = _curve(CURVE_DEAGLE_INSPECT_YAW, t)
				inspect_pitch = _curve(CURVE_DEAGLE_INSPECT_PITCH, t)
				inspect_roll = _curve(CURVE_DEAGLE_INSPECT_ROLL, t)
				inspect_up = _curve(CURVE_DEAGLE_INSPECT_UP, t)
				inspect_side = _curve(CURVE_DEAGLE_INSPECT_SIDE, t)
				inspect_forward = _curve(CURVE_DEAGLE_INSPECT_FORWARD, t)
			else:
				inspect_yaw = _curve(CURVE_GUN_YAW, t)
				inspect_pitch = _curve(CURVE_GUN_PITCH, t)
				inspect_roll = _curve(CURVE_GUN_ROLL, t)
				inspect_up = 0.095 * inspect_wave
				inspect_side = -0.05 * inspect_wave
				inspect_forward = -0.075 * inspect_wave


	var swing_x: = 0.0
	var swing_y: = 0.0
	var swing_z: = 0.0
	var swing_pitch: = 0.0
	var swing_yaw: = 0.0
	var swing_roll: = 0.0
	var swing_wave: = 0.0
	var swing_tumble: = 0.0


	var swing_bay_spin: = 0.0
	var swing_bay_body: = 0.0
	if _swing_time < _swing_duration:
		_swing_time = minf(_swing_time + delta, _swing_duration)
		var t: = _swing_time / _swing_duration

		var wing: = _knife_kind == "butterfly" and not _swing_left
		var bay: = _knife_kind == "bayonet" and not _swing_left
		var nomad: = _knife_kind == "nomad" and not _swing_left
		if nomad:



			if _swing_heavy:
				swing_x = _curve(CURVE_NOMAD_SWING_HEAVY_X, t)
				swing_y = _curve(CURVE_NOMAD_SWING_HEAVY_Y, t)
				swing_z = _curve(CURVE_NOMAD_SWING_HEAVY_Z, t)
				swing_pitch = _curve(CURVE_NOMAD_SWING_HEAVY_PITCH, t)
				swing_yaw = _curve(CURVE_NOMAD_SWING_HEAVY_YAW, t)
				swing_roll = _curve(CURVE_NOMAD_SWING_HEAVY_ROLL, t)
				swing_bay_spin = _curve(CURVE_NOMAD_SWING_HEAVY_SPIN, t)
				swing_bay_body = _curve(CURVE_NOMAD_SWING_HEAVY_BODY, t)
			elif _swing_kind == 0:
				swing_x = _curve(CURVE_NOMAD_SWING_A_X, t)
				swing_y = _curve(CURVE_NOMAD_SWING_A_Y, t)
				swing_z = _curve(CURVE_NOMAD_SWING_A_Z, t)
				swing_pitch = _curve(CURVE_NOMAD_SWING_A_PITCH, t)
				swing_yaw = _curve(CURVE_NOMAD_SWING_A_YAW, t)
				swing_roll = _curve(CURVE_NOMAD_SWING_A_ROLL, t)
				swing_bay_spin = _curve(CURVE_NOMAD_SWING_A_SPIN, t)
				swing_bay_body = _curve(CURVE_NOMAD_SWING_A_BODY, t)
			else:
				swing_x = _curve(CURVE_NOMAD_SWING_B_X, t)
				swing_y = _curve(CURVE_NOMAD_SWING_B_Y, t)
				swing_z = _curve(CURVE_NOMAD_SWING_B_Z, t)
				swing_pitch = _curve(CURVE_NOMAD_SWING_B_PITCH, t)
				swing_yaw = _curve(CURVE_NOMAD_SWING_B_YAW, t)
				swing_roll = _curve(CURVE_NOMAD_SWING_B_ROLL, t)
				swing_bay_spin = _curve(CURVE_NOMAD_SWING_B_SPIN, t)
				swing_bay_body = _curve(CURVE_NOMAD_SWING_B_BODY, t)
		elif bay:


			swing_x = _curve(CURVE_BAYONET_SWING_X, t)
			swing_y = _curve(CURVE_BAYONET_SWING_Y, t)
			swing_z = _curve(CURVE_BAYONET_SWING_Z, t)
			swing_pitch = _curve(CURVE_BAYONET_SWING_PITCH, t)
			swing_yaw = _curve(CURVE_BAYONET_SWING_YAW, t)
			swing_bay_spin = _curve(CURVE_BAYONET_SWING_SPIN, t)
			swing_bay_body = _curve(CURVE_BAYONET_SWING_BODY, t)
		elif _swing_left:

			swing_x = _curve(CURVE_KNIFE_STAB_L_X, t)
			swing_y = _curve(CURVE_KNIFE_STAB_L_Y, t)
			swing_z = _curve(CURVE_KNIFE_STAB_L_Z, t)
			swing_pitch = _curve(CURVE_KNIFE_STAB_L_PITCH, t)
			swing_yaw = _curve(CURVE_KNIFE_STAB_L_YAW, t)
			swing_roll = _curve(CURVE_KNIFE_STAB_L_ROLL, t)
		elif _swing_kind == 0:

			swing_x = _swing_value(wing, CURVE_BFLY_SWING_A_X, CURVE_SWING_A_X, t)
			swing_y = _swing_value(wing, CURVE_BFLY_SWING_A_Y, CURVE_SWING_A_Y, t)
			swing_z = _swing_value(wing, CURVE_BFLY_SWING_A_Z, CURVE_SWING_A_Z, t)
			swing_pitch = _swing_value(wing, CURVE_BFLY_SWING_A_PITCH, 
				CURVE_SWING_A_PITCH, t)
			swing_yaw = _swing_value(wing, CURVE_BFLY_SWING_A_YAW, 
				CURVE_SWING_A_YAW, t)
			swing_roll = _swing_value(wing, CURVE_BFLY_SWING_A_ROLL, 
				CURVE_SWING_A_ROLL, t)
			swing_tumble = _curve(CURVE_BFLY_SWING_A_TUMBLE, t) if wing else 0.0
		elif _swing_kind == 1:

			swing_x = _swing_value(wing, CURVE_BFLY_SWING_B_X, CURVE_SWING_B_X, t)
			swing_y = _swing_value(wing, CURVE_BFLY_SWING_B_Y, CURVE_SWING_B_Y, t)
			swing_z = _swing_value(wing, CURVE_BFLY_SWING_B_Z, CURVE_SWING_B_Z, t)
			swing_pitch = _swing_value(wing, CURVE_BFLY_SWING_B_PITCH, 
				CURVE_SWING_B_PITCH, t)
			swing_yaw = _swing_value(wing, CURVE_BFLY_SWING_B_YAW, 
				CURVE_SWING_B_YAW, t)
			swing_roll = _swing_value(wing, CURVE_BFLY_SWING_B_ROLL, 
				CURVE_SWING_B_ROLL, t)
			swing_tumble = _curve(CURVE_BFLY_SWING_B_TUMBLE, t) if wing else 0.0
		else:

			swing_x = _swing_value(wing, CURVE_BFLY_SWING_C_X, CURVE_SWING_C_X, t)
			swing_y = _swing_value(wing, CURVE_BFLY_SWING_C_Y, CURVE_SWING_C_Y, t)
			swing_z = _swing_value(wing, CURVE_BFLY_SWING_C_Z, CURVE_SWING_C_Z, t)
			swing_pitch = _swing_value(wing, CURVE_BFLY_SWING_C_PITCH, 
				CURVE_SWING_C_PITCH, t)
			swing_yaw = _swing_value(wing, CURVE_BFLY_SWING_C_YAW, 
				CURVE_SWING_C_YAW, t)
			swing_roll = _swing_value(wing, CURVE_BFLY_SWING_C_ROLL, 
				CURVE_SWING_C_ROLL, t)
			swing_tumble = _curve(CURVE_BFLY_SWING_C_TUMBLE, t) if wing else 0.0
		swing_wave = sin(t * PI)




		if not bay and not nomad:
			swing_y += swing_wave * SWING_DROP

		if t > 0.3 and t < 0.58:
			var impact: = 1.0 - (t - 0.3) / 0.28
			swing_x += sin(t * 150.0) * 0.006 * impact
			swing_y += sin(t * 190.0) * 0.005 * impact



	var draw_dip: = 0.0
	var draw_spin: = 0.0
	if _draw_time < _draw_duration:
		_draw_time = minf(_draw_time + delta, _draw_duration)
		var dt: = _draw_time / _draw_duration
		var settle: = _curve(CURVE_DRAW_KNIFE if _melee else CURVE_DRAW, dt)
		draw_dip = 1.0 - settle
		if _melee:
			if _knife_kind == "nomad":


				draw_spin = _curve(CURVE_NOMAD_DRAW_SPIN_A
					if _nomad_draw_variant == 0 else CURVE_NOMAD_DRAW_SPIN_B, dt)
			else:
				draw_spin = _curve(CURVE_KNIFE_DRAW_SPIN, dt)


	var idle_x: = sin(_seconds * 0.95) * 0.0032 * _sway_amount
	var idle_y: = sin(_seconds * 1.6 + 0.8) * 0.0024 * _sway_amount
	var idle_roll: = sin(_seconds * 0.8 + 0.3) * (0.9 if _melee else 0.35) * _sway_amount






	var skeleton_twirl: = _skeleton_idle_twirl(delta)


	var fov_shift: = Vector3(
		_fov_spread * 0.09, 
		- _fov_spread * 0.048, 
		_fov_spread * 0.025
	)







	var rifle_back_split: = not _melee\
	and (_weapon_id == "ak47" or _weapon_id == "m4a1")
	var rig_back: = _kick_back
	var weapon_slide: = 0.0
	if rifle_back_split:
		rig_back = _kick_back * _base_scale * RIFLE_BACK_RIG_SHARE
		weapon_slide = _kick_back * (1.0 - RIFLE_BACK_RIG_SHARE)
	_rig.position = _base_position + fov_shift + Vector3(
		_sway.x + _bob.x + swing_x * (-1.0 if _swing_left else 1.0)\
		+ inspect_side + idle_x - sprint * 0.006 - bolt_cycle * 0.01, 
		_sway.y + _bob.y + reload_y + inspect_up + swing_y + idle_y + _kick_lift\
		- bolt_cycle * 0.018\
		- draw_dip * (0.44 if _melee else 0.34) - sprint * 0.04, 
		rig_back + reload_z + inspect_forward + swing_z\
		+ bolt_cycle * 0.016 + bolt_pull * 0.012\
		+ draw_dip * (0.12 if _melee else 0.08) + sprint * 0.02
	)








	var kick_pitch_deg: = rad_to_deg(_kick_pitch) if not _melee\
	else - rad_to_deg(_kick_pitch)
	_rig.rotation_degrees = Vector3(
		_base_rotation.x + kick_pitch_deg + lag_pitch\
		+ reload_roll * 5.0 + inspect_pitch\
		- bolt_cycle * 2.2\
		- _air * 1.4\
		- draw_dip * (48.0 if _melee else 26.0) + sprint * 6.0, 
		_base_rotation.y + lag_yaw + inspect_yaw\
		- draw_dip * (12.0 if _melee else 8.0) + sprint * 5.0\
		+ bolt_wave * 14.0 + bolt_cycle * 3.0 + bolt_pull * 4.0, 
		_base_rotation.z + reload_roll * 34.0 + inspect_roll\
		+ sin(deg_to_rad(swing_roll)) * 4.0 * (-1.0 if _swing_left else 1.0)\
		+ swing_bay_body\
		+ lag_roll - _kick_roll\
		+ bolt_cycle * 22.0 - bolt_pull * 2.0\
		- draw_dip * (18.0 if _melee else 6.0) + idle_roll + sprint * 7.0\
		- bolt_wave * 9.0
	)
	_rig.scale = Vector3.ONE * _base_scale * _fov_scale * (1.0 - draw_dip * 0.1)





	var inspect_extra: = INSPECT_HANDOUT * inspect_handout
	var bf_push_env: = clampf(inspect_wave * 8.0, 0.0, 1.0)



	var display_push_env: = 0.0
	if (_knife_kind == "karambit" or _knife_kind == "skeleton"\
	or _knife_kind == "nomad")\
	and _inspect_time > 0.0 and _inspect_time < _inspect_duration:
		display_push_env = _plateau(
			_inspect_time / maxf(_inspect_duration, 0.001), 0.12)
	if _butterfly:


		inspect_extra += _bf_axis * (BUTTERFLY_INSPECT_LIFT * bf_push_env)
	elif _knife_kind == "karambit":
		inspect_extra += Vector3(0.0, 0.0, 
			KARAMBIT_INSPECT_PUSH * display_push_env)
	elif _knife_kind == "skeleton":
		inspect_extra += Vector3(0.0, 0.0, 
			SKELETON_INSPECT_PUSH * display_push_env)
	elif _knife_kind == "nomad":


		inspect_extra += Vector3(0.0, 0.0, 
			NOMAD_INSPECT_PUSH * display_push_env)



	if _weapon != null:
		if _melee:


			var swing_spin: = swing_roll * _swing_spin_scale + swing_bay_spin
			var hold_rot: = _hold_rotation()
			var hold_pitch: = hold_rot.x + inspect_wrist.x
			var hold_yaw: = hold_rot.y



			if _knife_kind == "skeleton":
				hold_pitch += SKELETON_INSPECT_HOLD_TILT.x * inspect_wave
				hold_yaw += SKELETON_INSPECT_HOLD_TILT.y * inspect_wave
			var hold: = Basis.from_euler(Vector3(
				hold_pitch, 
				hold_yaw, 
				hold_rot.z + draw_dip * 10.0 + inspect_wrist.z
			) * (PI / 180.0))



			if inspect_bay_env > 0.0001:
				hold = hold.slerp(BAYONET_INSPECT_BASIS, inspect_bay_env)


			if inspect_bf_env > 0.0001:
				hold = hold.slerp(_bf_basis, inspect_bf_env)



			if _knife_kind == "karambit":
				hold = Basis(Vector3(1.0, 0.0, 0.0), 
					deg_to_rad(KARAMBIT_FLAT_TILT)) * hold





			if _knife_kind == "combat" or _knife_kind == "nomad":
				hold = hold * Basis(Vector3(0.0, 0.0, 1.0), PI)




			var right_active: = not _swing_left
			var guard_r: = 0.0
			if _dual and not right_active and _swing_time < _swing_duration:
				guard_r = _curve(CURVE_DAGGER_RIGHT_GUARD_ROLL, 
					_swing_time / maxf(_swing_duration, 0.001))
			var rot_r: = _knife_rot_basis(
				weapon_spin + (swing_spin if right_active else guard_r), 
				(swing_yaw if right_active else 0.0) + draw_spin + inspect_tumble\
				+ skeleton_twirl.y + (swing_tumble if right_active else 0.0), 
				(swing_pitch if right_active else 0.0) + skeleton_twirl.z)


			var local_spin: = Basis.IDENTITY
			if _knife_kind == "skeleton" and absf(skeleton_twirl.x) > 0.01:
				local_spin = Basis(Vector3(0.0, 0.0, 1.0), 
					deg_to_rad(skeleton_twirl.x))
			elif (_knife_kind == "bayonet" or _knife_kind == "nomad")\
			and absf(inspect_local_spin) > 0.01:


				local_spin = Basis(Vector3(0.0, 0.0, 1.0), 
					deg_to_rad(inspect_local_spin))




			var grip_spin: = Basis.IDENTITY
			if _butterfly and absf(inspect_local_spin) > 0.01:
				grip_spin = Basis(_bf_axis, deg_to_rad(inspect_local_spin))
			var spin_rot: = grip_spin * rot_r
			_weapon.basis = (spin_rot * hold * local_spin).scaled(
				Vector3.ONE * _knife_model_scale())




			var grip_fwd: = _grip_forward
			if _butterfly and inspect_bf_grip > 0.0001:
				grip_fwd = lerpf(_grip_forward, BUTTERFLY_GRIP_FORWARD, 
					inspect_bf_grip)
			_weapon.position = _knife_grip_position(spin_rot, hold, 
				inspect_extra, grip_fwd)



			if _inspect_pivot != null\
			and _inspect_pivot_shift != Vector3.ZERO:
				_inspect_pivot.position = _inspect_pivot_base\
				+ _inspect_pivot_shift * inspect_bay_env
			if _weapon_l != null:
				_update_offhand(draw_dip, draw_spin, inspect_wave, 
					swing_pitch, swing_yaw, swing_wave)
		else:
			_weapon.rotation_degrees = Vector3.ZERO


			_weapon.position = Vector3(0.0, 0.0, weapon_slide)






	var follow_amp: = 18.0
	var follow_lead: = 0.0
	var follow_env: = 1.0
	var hand_roll: = 0.0
	var hand_pitch: = 0.0
	if _butterfly and _inspect_time > 0.0 and _inspect_time < _inspect_duration:






		follow_amp = 14.0
		follow_lead = 24.0
		follow_env = clampf(inspect_wave * 8.0, 0.0, 1.0)


		hand_roll = sin(deg_to_rad(inspect_local_spin + 30.0)) * 3.0 * follow_env
		hand_pitch = sin(deg_to_rad(inspect_local_spin + 32.0)) * 1.5 * follow_env
	elif _knife_kind == "skeleton" and absf(skeleton_twirl.x) > 0.01:


		hand_roll = sin(deg_to_rad(skeleton_twirl.x)) * 10.0
	elif (_knife_kind == "bayonet" or _knife_kind == "nomad")\
	and inspect_bay_env > 0.001:


		hand_roll = sin(deg_to_rad(inspect_local_spin)) * 9.0 * inspect_bay_env
	var spin_follow: = sin(deg_to_rad(weapon_spin + follow_lead))\
	* follow_amp * follow_env
	_animate_arms(reload_wave, inspect_wave, swing_wave, draw_dip, 
		spin_follow, Vector3(swing_pitch, swing_yaw, 
			swing_roll * _swing_spin_scale), hand_roll, hand_pitch, 
		bolt_hand, bolt_pull)
	_update_butterfly(delta)
	_blend_inspect_pose(delta)






func _hold_rotation() -> Vector3:
	if _knife_kind == "karambit":
		return KARAMBIT_HOLD_ROTATION
	if _knife_kind == "skeleton":
		return SKELETON_HOLD_ROTATION
	if _knife_kind == "bayonet" or _knife_kind == "combat":
		return BAYONET_HOLD_ROTATION
	if _knife_kind == "nomad":
		return NOMAD_HOLD_ROTATION
	return KNIFE_HOLD_ROTATION







func _butterfly_inspect_axis() -> Vector3:
	var tilt: = deg_to_rad(BUTTERFLY_INSPECT_TILT)
	return Vector3(0.0, sin(tilt), cos(tilt))






func _butterfly_inspect_basis() -> Basis:
	var normal: = _butterfly_inspect_axis()
	var u: = Vector3(1.0, 0.0, 0.0)
	var v: = normal.cross(u)
	var back: = (u + v).normalized()
	var side: = back.cross(normal)
	return Basis(normal, side, back)






func _knife_model_scale() -> float:
	if _knife_kind == "skeleton":
		return SKELETON_MODEL_SCALE
	if _knife_kind == "bayonet" or _knife_kind == "combat":
		return BAYONET_MODEL_SCALE
	if _knife_kind == "nomad":
		return NOMAD_MODEL_SCALE
	return BUTTERFLY_MODEL_SCALE if _butterfly else KNIFE_MODEL_SCALE






func _skeleton_idle_twirl(delta: float) -> Vector3:
	if _knife_kind != "skeleton":
		return Vector3.ZERO
	var busy: = _inspect_time < _inspect_duration\
	or _swing_time < _swing_duration or _draw_time < _draw_duration
	if busy:
		_skeleton_idle_time = 0.0
		return Vector3.ZERO
	_skeleton_idle_time += delta
	while _skeleton_idle_time > SKELETON_IDLE_PERIOD:
		_skeleton_idle_time -= SKELETON_IDLE_PERIOD
	var phase: = _skeleton_idle_time / SKELETON_IDLE_PERIOD
	if phase <= SKELETON_IDLE_START or phase >= SKELETON_IDLE_END:
		return Vector3.ZERO
	var t: = (phase - SKELETON_IDLE_START) / (SKELETON_IDLE_END - SKELETON_IDLE_START)
	return Vector3(
		_spline(CURVE_SKELETON_IDLE_ROLL, t), 
		_spline(CURVE_SKELETON_IDLE_YAW, t), 
		_spline(CURVE_SKELETON_IDLE_PITCH, t))




static func _knife_rot_basis(spin: float, yaw: float, pitch: float) -> Basis:
	return Basis(Vector3(0.0, 0.0, 1.0), deg_to_rad(spin))\
	* Basis(Vector3(0.0, 1.0, 0.0), deg_to_rad(yaw))\
	* Basis(Vector3(1.0, 0.0, 0.0), deg_to_rad(pitch))






func _update_offhand(draw_dip: float, draw_spin: float, inspect_wave: float, 
		swing_pitch: float, swing_yaw: float, swing_wave: float) -> void :
	if _weapon_l == null:
		return
	var sway: = _sway_amount


	var off: = Vector3(
		sin(_seconds * 1.35 + 0.9) * 1.8, 
		sin(_seconds * 0.72 + 2.4) * 2.6, 
		sin(_seconds * 1.05 + 1.2) * 2.0) * sway
	var pos: = Vector3(0.0, sin(_seconds * 0.95 + 1.8) * 0.0018, 0.0) * sway
	var local_spin: = Basis.IDENTITY



	off += Vector3(-8.0, 6.0, 14.0) * draw_dip
	pos.z += draw_dip * 0.02
	local_spin = Basis(Vector3(0.0, 0.0, 1.0), deg_to_rad( - draw_spin * 0.85))



	if _inspect_time > 0.0 and _inspect_time < _inspect_duration:
		var it: = _inspect_time / maxf(_inspect_duration, 0.001)
		local_spin = Basis(Vector3(0.0, 0.0, 1.0), 
			deg_to_rad(_curve(CURVE_DAGGER_OFF_INSPECT_ROLL, it)))
		off += Vector3(-4.0, 3.5, 0.0) * inspect_wave
		pos.y += 0.012 * inspect_wave




	var rot_a: = Basis.IDENTITY
	if _swing_time < _swing_duration:
		if _swing_left:



			rot_a = _knife_rot_basis(0.0, swing_yaw, swing_pitch)
			pos += DAGGER_OFF_THRUST * _offhand_thrust()\
			+ Vector3(-0.008, -0.006, 0.0) * swing_wave
		else:
			var t: = _swing_time / maxf(_swing_duration, 0.001)
			var amp: = 1.35 if _swing_kind == 2 else 1.0
			var dir: = -1.0 if _swing_kind == 1 else 1.0
			off += Vector3(
				_curve(CURVE_DAGGER_OFF_GUARD_PITCH, t), 
				_curve(CURVE_DAGGER_OFF_GUARD_YAW, t) * dir, 
				_curve(CURVE_DAGGER_OFF_GUARD_ROLL, t) * dir) * amp
			pos += Vector3(0.0, 
				_curve(CURVE_DAGGER_OFF_GUARD_DOWN, t), 
				_curve(CURVE_DAGGER_OFF_GUARD_BACK, t)) * amp

	var hold: = Basis(Vector3(0.0, 0.0, 1.0), deg_to_rad(DAGGER_OFF_VIEW_ROLL))\
	* Basis.from_euler(off * (PI / 180.0)) * DAGGER_OFF_HOLD\
	* Basis(Vector3(0.0, 0.0, 1.0), deg_to_rad(DAGGER_OFF_ROLL))
	_weapon_l.basis = (rot_a * hold * local_spin).scaled(
		Vector3.ONE * _knife_model_scale())
	_weapon_l.position = DAGGER_OFF_GRIP\
	+ rot_a * hold * Vector3(0.0, 0.0, - _grip_forward)\
	+ Vector3(0.0, - _grip_drop, 0.0) + pos




func _offhand_thrust() -> float:
	if not _dual or not _swing_left or _swing_time >= _swing_duration:
		return 0.0
	return _curve(CURVE_DAGGER_OFF_THRUST, 
		_swing_time / maxf(_swing_duration, 0.001))








func _knife_grip_position(rot: Basis, hold: Basis, extra: = Vector3.ZERO, 
		forward: = -1.0) -> Vector3:
	var grip_forward: = _grip_forward if forward < 0.0 else forward
	var pos: = KNIFE_GRIP + KNIFE_HAND_SHIFT\
	+ rot * hold * Vector3(0.0, 0.0, - grip_forward)\
	+ Vector3(0.0, - _grip_drop, 0.0) + extra
	if _butterfly:
		pos += BUTTERFLY_HAND_SHIFT
	elif _knife_kind == "skeleton":
		pos += SKELETON_HAND_SHIFT
	elif _knife_kind == "bayonet" or _knife_kind == "combat":




		pos += BAYONET_HAND_SHIFT
	elif _knife_kind == "nomad":
		pos += NOMAD_HAND_SHIFT
	return pos






func _update_butterfly(delta: float) -> void :
	if not _butterfly or _bf_blade == null:
		return
	var open: = _fold_to
	var folding: = _fold_delay > 0.0 or _fold_time < _fold_duration
	if _fold_delay > 0.0:
		_fold_delay = maxf(0.0, _fold_delay - delta)
		open = _fold_from
	elif _fold_time < _fold_duration:
		_fold_time = minf(_fold_time + delta, _fold_duration)
		var t: = _fold_time / maxf(_fold_duration, 0.001)
		open = lerpf(_fold_from, _fold_to, _snap(t))




	if not folding and _inspect_time > 0.0 and _inspect_time < _inspect_duration:
		var it: = _inspect_time / maxf(_inspect_duration, 0.001)
		var target: = _curve(CURVE_BFLY_INSPECT_FOLD, it)



		_fold = lerpf(_fold, target, 1.0 - exp(-24.0 * delta))
		_apply_fold(_fold, delta)
		return
	_fold = open
	_apply_fold(open, delta)









func _apply_fold(open: float, delta: = 0.0) -> void :
	if _bf_blade == null:
		return
	var closed: = clampf(1.0 - open, 0.0, 1.0)

	_bf_blade.rotation_degrees.z = 180.0 * closed



	var fan: = sin(closed * PI)
	if _bf_lever1 != null:
		_bf_lever1.rotation_degrees.z = - BUTTERFLY_HANDLE_FAN.x * fan
	if _bf_lever2 != null:
		_bf_lever2.rotation_degrees.z = BUTTERFLY_HANDLE_FAN.y * fan





	var lay: = _bf_depth * closed
	if delta > 0.0:
		lay = lerpf(_bf_lever1.position.z if _bf_lever1 != null else 0.0, lay, 
			1.0 - exp(-26.0 * delta))
	if _bf_lever1 != null:
		_bf_lever1.position.z = lay
	if _bf_lever2 != null:
		_bf_lever2.position.z = - lay




static func _snap(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	const C1: = 1.15
	const C3: = C1 + 1.0
	return 1.0 + C3 * pow(t - 1.0, 3.0) + C1 * pow(t - 1.0, 2.0)










func _animate_arms(reload_wave: float, inspect_wave: float, swing_wave: float, 
		draw_dip: float, wrist_follow: = 0.0, 
		swing_follow: = Vector3.ZERO, hand_roll: = 0.0, 
		hand_pitch: = 0.0, bolt_hand: = 0.0, bolt_pull: = 0.0) -> void :
	var arm_lag: = _arm_lag_rotation() if _melee else Vector3.ZERO
	if _arm_r != null:
		if _melee:





			var bf_pitch: = 0.0
			if _butterfly:
				bf_pitch = BUTTERFLY_INSPECT_ARM_PITCH\
				* clampf(inspect_wave * 8.0, 0.0, 1.0)




			var twist: = inspect_wave * 3.0 + hand_pitch


			var follow: Vector3 = - swing_follow * 0.2 if _swing_left\
			else swing_follow
			var arm_rot: = _arm_swing_rotation(
				twist, follow, draw_dip, wrist_follow) + arm_lag
			arm_rot.x += bf_pitch
			if absf(hand_roll) > 0.01:



				var arm_basis: = Basis.from_euler(arm_rot * (PI / 180.0))
				var axis: = (arm_basis * KNIFE_FOREARM.normalized()).normalized()
				_arm_r.basis = Basis(axis, deg_to_rad(hand_roll)) * arm_basis
			else:
				_arm_r.rotation_degrees = arm_rot
		else:




			var arm_r_base: Vector3 = _arm_r.get_meta("base_position", 
				_arm_r.position)
			_arm_r.position = arm_r_base + BOLT_HAND_GRAB * bolt_hand\
			+ BOLT_HAND_PULL * bolt_pull
			_arm_r.rotation_degrees = Vector3(
				- swing_wave * 2.0 - bolt_hand * 7.0, 
				bolt_hand * 5.0, 
				- swing_wave * 3.0 + draw_dip * 6.0 - bolt_hand * 12.0
			)

	if _arm_l != null:
		if _melee:
			if _dual:




				var arm_base: Vector3 = _arm_l.get_meta("base_position", 
					_arm_l.position)
				_arm_l.position = arm_base + DAGGER_OFF_THRUST * _offhand_thrust()
				var left_follow: Vector3 = swing_follow if _swing_left\
				else - swing_follow * 0.18
				var left_rot: = _arm_swing_rotation(
					inspect_wave * 2.0 + hand_pitch * 0.55, 
					left_follow, draw_dip * 1.1, wrist_follow * 0.6)
				if absf(hand_roll) > 0.01:
					var arm_basis: = Basis.from_euler(left_rot * (PI / 180.0))
					var axis: = (arm_basis * DAGGER_OFF_FOREARM.normalized())\
					.normalized()
					_arm_l.basis = Basis(axis, deg_to_rad( - hand_roll * 0.45))\
					* arm_basis
				else:
					_arm_l.rotation_degrees = left_rot + arm_lag
				return






			if _arm_r != null:
				var base: = _base_transform()
				var rp: Vector3 = base * _arm_r.position
				_arm_l.position = base.affine_inverse()\
				* Vector3( - rp.x, rp.y, rp.z)
			if _butterfly:



				_arm_l.rotation_degrees = arm_lag
				return
			var mirror_rot: = _arm_swing_rotation(
				inspect_wave * 3.0 + hand_pitch, 
				swing_follow if _swing_left else Vector3.ZERO, 
				draw_dip, wrist_follow)
			_arm_l.rotation_degrees = Vector3(
				mirror_rot.x, - mirror_rot.y, - mirror_rot.z) + arm_lag
			return
		var base_l: Vector3 = _arm_l.get_meta("base_position", _arm_l.position)
		var offset: = Vector3.ZERO
		var rot: = Vector3(
			- inspect_wave * 5.0 - swing_wave * 2.0, 
			0.0, 
			inspect_wave * 4.0 + swing_wave * 3.0 - draw_dip * 5.0
		)

		offset = Vector3(0.045, -0.035, 0.33) * reload_wave
		rot += Vector3(-24.0, 8.0, 10.0) * reload_wave
		_arm_l.position = base_l + offset
		_arm_l.rotation_degrees = rot





func _arm_lag_rotation() -> Vector3:
	return Vector3(
		clampf( - _arm_look.y * 0.016, -4.0, 4.0), 
		clampf( - _arm_look.x * 0.018, -6.0, 6.0), 
		clampf( - _look_vel.x * 0.016, -2.5, 2.5)) * _sway_amount






static func _arm_swing_rotation(twist: float, follow: Vector3, draw_dip: float, 
		wrist: float) -> Vector3:
	return Vector3(
		twist + clampf(follow.x * 0.22, -12.0, 12.0), 
		clampf(follow.y * 0.18, -10.0, 10.0), 
		twist * 1.2 + draw_dip * 5.0 + wrist + sin(deg_to_rad(follow.z)) * 8.0)


static func _pulse(t: float, start: float, end: float) -> float:
	if t <= start or t >= end:
		return 0.0
	var k: = (t - start) / maxf(end - start, 0.0001)
	return sin(k * PI)




static func _plateau(t: float, edge: float) -> float:
	var k: = clampf(minf(t / edge, (1.0 - t) / edge), 0.0, 1.0)
	return k * k * (3.0 - 2.0 * k)





func _swing_value(wing: bool, flying: Array, plain: Array, t: float) -> float:
	return _spline(flying, t) if wing else _curve(plain, t)


static func _curve(points: Array, t: float) -> float:

	if points.is_empty():
		return 0.0
	if t <= points[0].x:
		return points[0].y
	for i in range(1, points.size()):
		var p1: Vector2 = points[i]
		if t <= p1.x:
			var p0: Vector2 = points[i - 1]
			var span: = maxf(p1.x - p0.x, 0.0001)
			var k: = clampf((t - p0.x) / span, 0.0, 1.0)
			k = k * k * (3.0 - 2.0 * k)
			return lerpf(p0.y, p1.y, k)
	return points[points.size() - 1].y







static func _spline(points: Array, t: float) -> float:
	if points.is_empty():
		return 0.0
	var count: = points.size()
	if count == 1:
		return points[0].y
	if t <= points[0].x:
		return points[0].y
	if t >= points[count - 1].x:
		return points[count - 1].y
	var i: = 0
	for k in range(1, count):
		if t <= points[k].x:
			i = k - 1
			break
	var p0: Vector2 = points[maxi(i - 1, 0)]
	var p1: Vector2 = points[i]
	var p2: Vector2 = points[i + 1]
	var p3: Vector2 = points[mini(i + 2, count - 1)]
	var span: = maxf(p2.x - p1.x, 0.0001)
	var u: = clampf((t - p1.x) / span, 0.0, 1.0)
	var m1: = (p2.y - p0.y) / maxf(p2.x - p0.x, 0.0001) * span
	var m2: = (p3.y - p1.y) / maxf(p3.x - p1.x, 0.0001) * span
	if i == 0:
		m1 = 0.0
	if i + 2 >= count:
		m2 = 0.0
	var u2: = u * u
	var u3: = u2 * u
	return (2.0 * u3 - 3.0 * u2 + 1.0) * p1.y\
	+ (u3 - 2.0 * u2 + u) * m1\
	+ (-2.0 * u3 + 3.0 * u2) * p2.y\
	+ (u3 - u2) * m2
