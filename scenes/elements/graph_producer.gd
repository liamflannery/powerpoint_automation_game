extends Element
class_name Producer
@export var producing_resource : PackedScene


func activate_element():
	if !producing_resource: return
	if resources.size() < max_resources_stored:
		var new_resource : GameResource = producing_resource.instantiate()
		add_child(new_resource)
		resources.append(new_resource)
	super()
