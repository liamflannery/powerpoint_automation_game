extends Element
class_name Bin

func activate_element():

	element_activating = true
	await get_tree().create_timer(2).timeout
	var to_delete = queued_resources.pop_front()
	to_delete.queue_free()
	
	super()
