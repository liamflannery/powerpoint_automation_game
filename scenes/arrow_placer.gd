extends Button

@export var element_scene : PackedScene
var arrow_placement_mode : bool = false
func _ready() -> void:
	Stage.mouse_entered_tile.connect(mouse_moved_to_tile)

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
	element = element_scene.instantiate()
	Stage.get_main().add_child(element)
	arrow_placement_mode = false
	
	
	for tile : Tile in Stage.get_main().get_tiles():
		tile.texture = load("res://assets/tile_no_outline.png")
		if tile.element:
			if !is_instance_valid(placed_element) or !placed_element.adjacent_tiles.has(tile): 
				tile.element.reset_direction()
		
	disabled = false
	if  !cancelled: 
		
		_pressed()

func mouse_moved_to_tile(to_tile : Tile):
	pass
