extends Control
class_name Tile
@export var highlighted_tile_texture : Texture
var original_texture : Texture
@export var starting_element : PackedScene
var elements : Array[Element] 
var placeholder_element : Element 
		

func _ready() -> void:
	original_texture = self.texture
	await Stage.main_registered
	mouse_entered.connect(Stage.mouse_just_entered_tile.bind(self))
	mouse_exited.connect(Stage.mouse_just_exited_tile.bind(self))
	for child in get_children():
		if child is Element:
			elements.append(child)
			child.element_placed(self)
			child.set_direction()
	if starting_element:
		set_element(starting_element)
	

	
func set_element(element_packed_scene : PackedScene):
	var element_scene : Element = element_packed_scene.instantiate()
	add_child(element_scene)
	elements.append(element_scene)
	element_scene.element_placed(self)

func clear_element():
	for element in elements:
		if element in get_children():
			remove_child(element)
	elements.clear()

	
func highlight_tile():
	self.texture = highlighted_tile_texture	

func reset_tile():
	self.texture = original_texture
	
func save():
	var elements_dict : Dictionary
	for element in elements:
		elements_dict[element.get_index()] = [element.scene_file_path, element.get_save_dict()]
	SaveSystem.set_var(name+"/"+Stage.get_main().get_page(self).name, elements_dict)
func load_node():
	clear_element()
	if SaveSystem.has(name+"/"+Stage.get_main().get_page(self).name):
		var dict = SaveSystem.get_var(name+"/"+Stage.get_main().get_page(self).name)
		for key in dict.keys():
			set_element(load(dict[key][0]))
			elements.back().load_from_save_dict(dict[key][1])
			
		
