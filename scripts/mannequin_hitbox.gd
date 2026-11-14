extends Area3D



@export var zone: = "body"
var mannequin: Node3D


func _ready() -> void :
	add_to_group("mannequin_hitboxes")
	collision_layer = 2
	collision_mask = 0
	monitoring = false


func get_zone() -> String:
	return zone
