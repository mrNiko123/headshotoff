extends Area3D
## ПИКАП ЛУТА БАТЛ РОЯЛЯ: аптечка / патроны / оружие / пачка материалов.
## Собирается касанием игрока, покачивается над землёй.

const MeshKit = preload("res://scripts/mesh_kit.gd")

signal collected(kind: String, payload)

const KIND_COLORS: = {
	"health": Color(0.3, 1.0, 0.45, 1.0), 
	"ammo": Color(1.0, 0.8, 0.25, 1.0), 
	"weapon": Color(0.35, 0.75, 1.0, 1.0), 
	"mats": Color(0.76, 0.6, 0.38, 1.0), 
}
const KIND_ICONS: = {
	"health": "+", 
	"ammo": "≡", 
	"weapon": "⌐", 
	"mats": "▤", 
}

var kind: = "health"
var payload = null
var target: Node3D
var _label: Label3D
var _time: = 0.0
var _base_y: = 0.0
var _taken: = false


func setup(kind_id: String, payload_value, pos: Vector3) -> void :
	kind = kind_id
	payload = payload_value
	position = pos
	_base_y = pos.y


func _ready() -> void :
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	var shape: = CollisionShape3D.new()
	var capsule: = SphereShape3D.new()
	capsule.radius = 1.15
	shape.shape = capsule
	add_child(shape)

	var color: Color = KIND_COLORS.get(kind, Color.WHITE)
	var mesh: = MeshInstance3D.new()
	mesh.mesh = MeshKit.box_mesh(Vector3(0.55, 0.55, 0.55))
	var mat: = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 0.7
	mesh.material_override = mat
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh)

	_label = Label3D.new()
	_label.text = str(KIND_ICONS.get(kind, "?"))
	_label.font_size = 92
	_label.modulate = color
	_label.outline_size = 10
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = false
	_label.position = Vector3(0.0, 0.75, 0.0)
	add_child(_label)

	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void :
	_time += delta
	position.y = _base_y + sin(_time * 2.4) * 0.12
	rotate_y(delta * 1.2)


func _on_body_entered(body: Node3D) -> void :
	if _taken or not (body is CharacterBody3D):
		return
	if target != null and body != target:
		return
	_taken = true
	collected.emit(kind, payload)
	queue_free()
