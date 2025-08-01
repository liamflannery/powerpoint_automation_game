extends "res://scenes/clear_resources.gd"

func _pressed() -> void:
	"""Clear all resources, then delete all elements on the current page"""
	
	var visible_page
	#var do_not_clear = [Producer, Sender, Target]
	
	super()  # Clear all resources
	
	# Determine current page
	visible_page = Stage.get_main().get_current_page()
	
	# Clear all tiles on current page
	if visible_page:
		for tile : Tile in visible_page.get_children():
			if !tile.elements.is_empty() and !tile.elements.front().locked:
				tile.clear_element()
	else:
		print('Error - no visible page')
