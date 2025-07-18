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
	var cancelled = await element.placed
	for tile : Tile in Stage.get_main().get_tiles():
		tile.texture = load("res://assets/tile_no_outline.png")
		if tile.element: tile.element.reset_direction()
		
	disabled = false
	if multi_place and !cancelled: _pressed()
	
