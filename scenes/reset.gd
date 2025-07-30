extends Button

func _pressed() -> void:
	for page : Page in %PageParent.get_children():
		for tile : Tile in page.get_children():
			if tile.elements.front() is not Producer or tile.elements.front() is not Sender:
				tile.clear_element()
				
	Stage.get_main().produced_resources = 0
	Stage.get_main().level = 1
	Stage.get_main().set_target(1)
	%Pinny.show()
	
