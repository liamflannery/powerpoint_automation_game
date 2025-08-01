extends "res://scenes/clear_resources.gd"

func _pressed() -> void:
	"""Clear all resources, then delete all elements on the current page"""
	
	var visible_page
	var visible_page_found : bool = false
	#var do_not_clear = [Producer, Sender, Target]
	
	super()  # Clear all resources
	
	# Determine current page
	for pg in %PageParent.get_children():
		if pg.is_visible_in_tree():
			visible_page = pg
			visible_page_found = true
			break
	
	# Clear all tiles on current page
	if visible_page_found:
		for tile : Tile in visible_page.get_children():
			if tile.elements.front() is not Producer and tile.elements.front() is not Sender:
				tile.clear_element()
	else:
		print('Error - no visible page')
