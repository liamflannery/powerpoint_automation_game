extends Element
class_name TypeSetter
@export var type_image : Texture
func activate_element():
	element_activating = true
	await get_tree().create_timer(2).timeout
	if !queued_resources.is_empty(): queued_resources.back().set_type(type_image)
	super()

func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	if !sending_resource:
		return false
	if !sending_resource.can_set_type:
		return false
	return super(sending_element, sending_resource)
