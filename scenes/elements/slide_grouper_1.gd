extends Element
class_name SlideGrouper

func activate_element():
	if queued_resources.size() < 3:
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
	# If queue is empty, only accept transitions, slides, or slide groups
	if queued_resources.is_empty() and (sending_resource is SlideGroup or sending_resource.this_type in [GameResource.RESOURCE_TYPE.SLIDE, GameResource.RESOURCE_TYPE.TRANSITION]):
		return super(sending_element, sending_resource)
	
	# If queue has 1 element
	if queued_resources.size() == 1:
		var first_resource = queued_resources[0]
		
		if first_resource is IndividualResource and first_resource.this_type == GameResource.RESOURCE_TYPE.TRANSITION:
			return sending_resource is SlideGroup or sending_resource.this_type == GameResource.RESOURCE_TYPE.SLIDE
		return sending_resource is SlideGroup or sending_resource.this_type in [GameResource.RESOURCE_TYPE.SLIDE, GameResource.RESOURCE_TYPE.TRANSITION]

	
	# If queue has 2 elements
	if queued_resources.size() == 2:
		var has_transition = false
		var slide_count = 0
		
		# Count existing resources
		for resource in queued_resources:
			if resource is SlideGroup or resource.this_type == GameResource.RESOURCE_TYPE.SLIDE:
				slide_count += 1
			elif resource.this_type == GameResource.RESOURCE_TYPE.TRANSITION:
				has_transition = true
		
		# If we have transition and 1 slide/slide_group, accept another slide/slide_group
		if has_transition and slide_count == 1:
			return sending_resource is SlideGroup or sending_resource.this_type == GameResource.RESOURCE_TYPE.SLIDE
		
		# If we have 2 slides/slide_groups, accept transition
		elif slide_count == 2:
			return sending_resource is IndividualResource and sending_resource.this_type == GameResource.RESOURCE_TYPE.TRANSITION
		
		return false
	
	# If queue is full (3 elements), reject everything
	return false
