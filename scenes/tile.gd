extends Control
class_name Tile

@export var starting_element : PackedScene
var element : Element

func _ready() -> void:
	if starting_element:
		set_element(starting_element)

func set_element(element_packed_scene : PackedScene):
	var element_scene : Element = element_packed_scene.instantiate()
	add_child(element_scene)
	element = element_scene
