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




func get_closest_tile_to_position(to_position : Vector2, include_full_tiles=false):
	var sorted_tiles = tiles.duplicate()
	if !include_full_tiles:
		sorted_tiles = sorted_tiles.filter(func(tile): return !tile.element)
	sorted_tiles.sort_custom(func(a,b): return to_position.distance_to(a.global_position + a.size/2) < to_position.distance_to(b.global_position + b.size/2))
	return sorted_tiles.front()
