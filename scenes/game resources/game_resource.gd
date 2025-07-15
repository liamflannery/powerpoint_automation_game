extends Control
class_name GameResource

var resource_colour : Color



func set_colour(colour : Color):
	modulate = colour
	self_modulate = colour
	resource_colour = colour

func resource_equal_to(target_resource : GameResource) -> bool:
	return target_resource.resource_colour == resource_colour
