extends Element
class_name Colourer

func activate_element():
	if !resources.is_empty():
		resources.front().set_colour(Color.BLUE)
	super()
