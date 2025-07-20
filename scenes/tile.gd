extends Control
class_name Tile
@export var highlighted_tile_texture : Texture
var original_texture : Texture
@export var starting_element : PackedScene
var element : Element :
	get():
		if !is_instance_valid(element):
			return null
		else:
			return element
var placeholder_element : Element 
		

func _ready() -> void:
	original_texture = self.texture
	await Stage.main_registered
	mouse_entered.connect(Stage.mouse_just_entered_tile.bind(self))
	mouse_exited.connect(Stage.mouse_just_exited_tile.bind(self))
	for child in get_children():
		if child is Element:
			element = child
			child.element_placed(self)
	if starting_element:
		set_element(starting_element)
	

	
func set_element(element_packed_scene : PackedScene):
	var element_scene : Element = element_packed_scene.instantiate()
	add_child(element_scene)
	element = element_scene
	element.element_placed(self)

func clear_element():
	if element in get_children():
		remove_child(element)
	element = null

	
func highlight_tile():
	self.texture = highlighted_tile_texture	

func reset_tile():
	self.texture = original_texture
	
#var timer : float
#func _process(delta: float) -> void:
	#timer += delta + randf() * 0.001
	#if timer >= 1:
		#timer = 0
		#if element:
			#element.activate_element()
