extends Element
class_name SlideGrouper

func activate_element():
	if queued_resources.size() < 3 or !queued_resources.filter(func(entry): return !is_instance_valid(entry) or !entry).is_empty():
		return
	element_activating = true
	await get_tree().create_timer(0.1).timeout
	var transition = queued_resources.pop_at(queued_resources.find_custom(func(a): return a is IndividualResource and a.this_type == GameResource.RESOURCE_TYPE.TRANSITION))
	var other_elements = queued_resources
	var new_group : SlideGroup = load("res://scenes/game resources/slide_group.tscn").instantiate()
	add_child(new_group)
	new_group.add_resource(other_elements[0])
	new_group.add_resource(transition)
	new_group.add_resource(other_elements[1])
	queued_resources.clear()
	queued_resources.append(new_group)
	super()

func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	queued_resources.resize(3)
	if sending_element in adjacent_tiles[3].elements and !is_instance_valid(queued_resources[0]):
		if !((sending_resource is IndividualResource and sending_resource.this_type == IndividualResource.RESOURCE_TYPE.SLIDE) or sending_resource is SlideGroup):
			return false
		queued_resources[0] = sending_resource
		return true
	if sending_element in adjacent_tiles[1].elements and !is_instance_valid(queued_resources[2]):
		if !((sending_resource is IndividualResource and sending_resource.this_type == IndividualResource.RESOURCE_TYPE.SLIDE) or sending_resource is SlideGroup):
			return false
		queued_resources[2] = sending_resource
		return true
	if sending_element in adjacent_tiles[2].elements and !is_instance_valid(queued_resources[1]):
		if sending_resource is IndividualResource and sending_resource.this_type == IndividualResource.RESOURCE_TYPE.TRANSITION:
			queued_resources[1] = sending_resource
			return true
	return false
		
