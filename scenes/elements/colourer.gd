extends Element
class_name Colourer

func activate_element():
	element_activating = true
	await get_tree().create_timer(2).timeout
	if !queued_resources.is_empty(): queued_resources.back().set_colour(Color.BLUE)
	super()
