extends Element
class_name Merger

func activate_element():
	if queued_resources.size() < 2:
		return
	element_activating = true
	await get_tree().create_timer(2).timeout
	var diamond = queued_resources[queued_resources.find_custom(func(a): return a.shape)]
	var other = queued_resources[queued_resources.find_custom(func(a): return !a.shape)]
	diamond.set_data(other.data)
	queued_resources.erase(other)
	other.queue_free()
	
	super()

func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	for resource : GameResource in queued_resources:
		if resource.shape and resource.data != "":
			return false
		if resource.resource_equal_to(sending_resource):
			return false
	return super(sending_element, sending_resource)
