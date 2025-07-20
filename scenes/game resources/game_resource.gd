extends Control
class_name GameResource

enum RESOURCE_TYPE{SLIDE, PROPERTY, TRANSITION}
enum CONTENT_TYPE{NUMBER, QUOTE, TITLE, GRAPH}
enum PROPERTY_TYPE{COLOUR, CONTENT}
enum TRANSITION_TYPE{STAR_WIPE, FADE}

func _ready() -> void:
	z_as_relative = false
	z_index = 1



func set_property(property : GameResource):
	pass
			
func can_set_property(property : GameResource) -> bool:
	return false
		

func resource_equal_to(target_resource : GameResource) -> bool:
	return false
