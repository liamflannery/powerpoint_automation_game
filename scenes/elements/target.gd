extends Element
class_name Target


func activate_element():
	element_activating = true
	var all_resources = processed_resources + queued_resources
	if movement_tween.is_running():
		await movement_tween.finished
	if !all_resources.is_empty():
		for resource in all_resources:
			if !resource:
				continue
			if Stage.get_main().target and Stage.get_main().target.resource_equal_to(resource):
				Stage.get_main().produced_resources += 1
			all_resources.pop_back().queue_free()
			processed_resources.erase(resource)
			queued_resources.erase(resource)
			all_resources.erase(resource)
	element_activating = false
