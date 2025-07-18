extends Control
class_name Main

var page_tiles : Array[Array]

func _ready() -> void:
	for child in %PageParent.get_children():
		var tiles : Array[Tile]
		for tile in child.get_children():
			tiles.append(tile)
			tile.texture = load("res://assets/tile_no_outline.png")
		page_tiles.append(tiles)
	Stage.register_main(self)

func get_adjacent_tiles(to_tile : Tile) -> Array[Tile]:
	var tiles : Array[Tile]
	for group in page_tiles:
		if group.has(to_tile):
			tiles = group
			break
	if tiles.is_empty():
		print("failed to find tile grid")
		return []
	var adjacent_tiles : Array[Tile] = [null, null, null, null]
	var target_tile_index = tiles.find(to_tile)
	if target_tile_index == -1:
		return adjacent_tiles
	var grid_width = %PageParent.get_child(0).columns
	
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



func get_tiles() -> Array[Tile]:
	var tiles : Array[Tile]
	for group in %PageParent.get_children():
		if group.visible:
			for child in group.get_children():
				tiles.append(child)
	return tiles


func get_closest_tile_to_position(to_position : Vector2, include_full_tiles=false):
	var tiles : Array[Tile]
	for group in %PageParent.get_children():
		if group.visible:
			for child in group.get_children():
				tiles.append(child)
	if tiles.is_empty():
		print("failed to find closest tile grid")
		return 
		
	var sorted_tiles = tiles.duplicate()
	if !include_full_tiles:
		sorted_tiles = sorted_tiles.filter(func(tile): return !tile.element)
	sorted_tiles.sort_custom(func(a,b): return to_position.distance_to(a.global_position + a.size/2) < to_position.distance_to(b.global_position + b.size/2))
	return sorted_tiles.front()
