extends Button

@export var element_scene : PackedScene
@export var multi_place := false
func _pressed() -> void:
	if !element_scene:
		return
	var element : Element = element_scene.instantiate()
	Stage.get_main().add_child(element)
	disabled = true
	for tile : Tile in Stage.get_main().get_tiles():
		tile.texture = load("res://assets/tile_outline.png")
	var placed_signal = await element.placed
	var cancelled = placed_signal[0]
	var placed_element = placed_signal[1]
	if !cancelled:
		await Stage.mouse_exited_tile
	for tile : Tile in Stage.get_main().get_tiles():
		tile.texture = load("res://assets/tile_no_outline.png")
		if tile.element:
			if !is_instance_valid(placed_element) or !placed_element.adjacent_tiles.has(tile): 
				tile.element.reset_direction()
		
	disabled = false
	if multi_place and !cancelled: 
		_pressed()
	
