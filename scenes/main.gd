extends Control
class_name Main

@export var tile_grid : GridContainer
var tiles : Array[Tile]

func _ready() -> void:
	for child in tile_grid.get_children():
		tiles.append(child)
	Stage.register_main(self)

func get_adjacent_tiles(to_tile : Tile) -> Array[Tile]:
	var adjacent_tiles : Array[Tile] = [null, null, null, null]
	var target_tile_index = tiles.find(to_tile)
	if target_tile_index == -1:
		return adjacent_tiles
	var grid_width = tile_grid.columns
	
	# North (up)
	if target_tile_index - grid_width >= 0:
		adjacent_tiles[0] = tiles[target_tile_index - grid_width]
	
	# East (right)
	if (target_tile_index + 1) % grid_width != 0:
		adjacent_tiles[1] = tiles[target_tile_index + 1]
	
	# South (down)
	if target_tile_index + grid_width < tiles.size():
		adjacent_tiles[2] = tiles[target_tile_index + grid_width]
	
	# West (left)
	if target_tile_index % grid_width != 0:
		adjacent_tiles[3] = tiles[target_tile_index - 1]
	
	return adjacent_tiles
