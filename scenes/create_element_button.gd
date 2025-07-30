extends Button

@export var element_scene : PackedScene
@export var multi_place := false
func _ready() -> void:
	tooltip_text = element_scene.instantiate().tooltip_text

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

		
	disabled = false
	if multi_place and !cancelled: 
		_pressed()
	
func _process(delta: float) -> void:
	disabled = Stage.get_main().arrow_placement_mode
