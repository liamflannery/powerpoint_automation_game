extends Button

func _pressed() -> void:
	for page : Page in %PageParent.get_children():
		for tile : Tile in page.get_children():
			for element in tile.elements:
				if !element:
					continue
				element.recieving_queue.clear()
				if element.movement_tween and element.movement_tween.is_running():
					element.movement_tween.kill()
				for resource in element.queued_resources + element.processed_resources:
					if is_instance_valid(resource): resource.queue_free()
				element.queued_resources.clear()
				element.processed_resources.clear()
				
				element.resource_sending = false
