extends GameResource
class_name SlideGroup
@export var slides_parent : HBoxContainer
var slides : Array[GameResource]

func add_resource(new_resource : GameResource):
	slides.append(new_resource)
	if !new_resource.is_inside_tree():
		slides_parent.add_child(new_resource)
	else:
		new_resource.reparent(slides_parent)

func resource_equal_to(target_resource : GameResource) -> bool:
	if target_resource is not SlideGroup:
		return false
	for i in target_resource.slides.size():
		if !slides[i].resource_equal_to(target_resource.slides[i]):
			return false
	return true
