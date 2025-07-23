extends Element
class_name Merger

func activate_element():
	if queued_resources.size() < 2:
		return
	element_activating = true
	await get_tree().create_timer(0.1).timeout
	var slide = queued_resources[queued_resources.find_custom(func(a): return a.this_type == GameResource.RESOURCE_TYPE.SLIDE)]
	var property = queued_resources[queued_resources.find_custom(func(a): return a.this_type == GameResource.RESOURCE_TYPE.PROPERTY)]
	slide.set_property(property)
	queued_resources.erase(property)
	property.queue_free()
	
	super()

func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	if queued_resources.is_empty() and sending_resource.this_type in [GameResource.RESOURCE_TYPE.SLIDE, GameResource.RESOURCE_TYPE.PROPERTY]:
		return super(sending_element, sending_resource)
	if queued_resources.size() == 1:
		var current_resource : GameResource = queued_resources.front()
		if current_resource.this_type == GameResource.RESOURCE_TYPE.SLIDE:
			if sending_resource.this_type == GameResource.RESOURCE_TYPE.PROPERTY:
				if current_resource.can_set_property(sending_resource):
					return super(sending_element, sending_resource)
		elif current_resource.this_type == GameResource.RESOURCE_TYPE.PROPERTY:
			if sending_resource.this_type == GameResource.RESOURCE_TYPE.SLIDE:
				if sending_resource.can_set_property(current_resource):
					return super(sending_element, sending_resource)
	return false
