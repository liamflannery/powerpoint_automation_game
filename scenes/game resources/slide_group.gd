extends GameResource
class_name SlideGroup
@export var slides_parent : HBoxContainer
var slides : Array[GameResource]

func add_resource(new_resource : GameResource):
	slides.append(new_resource)
	new_resource.reparent(slides_parent)
