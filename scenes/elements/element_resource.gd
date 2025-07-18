extends Resource
class_name ElementResource


@export var element_texture : Texture

func set_direction(element_ui : Element, in_sending_directions : Array[Element.DIRECTION], in_recieving_directions : Array[Element.DIRECTION]):
	pass

func activate_element(element_ui : Element):
	pass

func _ready_to_activate(element_ui : Element) -> bool:
	return true
