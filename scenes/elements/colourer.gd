extends Element
class_name Colourer

func activate_element():
	element_activating = true
	await get_tree().create_timer(0.1).timeout
	if !queued_resources.is_empty(): queued_resources.back().set_colour(Color("#006FC1"))
	super()

func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	if !sending_resource:
		return false
	if !sending_resource.can_set_colour:
		return false
	return super(sending_element, sending_resource)
