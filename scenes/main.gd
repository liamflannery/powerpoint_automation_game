extends Control
class_name Main

var page_tiles : Array[Array]
var arrow_placement_mode := false :
	set(value):
		arrow_placement_mode = value
		if !arrow_placement_mode: %ArrowButton.release_focus()
var produced_resources : int = 0 :
	set(value):
		produced_resources = value
		%produced_label.text = str(value) + "/" + str(target_resources)
		if produced_resources >= target_resources:
			go_to_next_target()
func _ready() -> void:
	for child in %PageParent.get_children():
		var tiles : Array[Tile]
		for tile in child.get_children():
			tiles.append(tile)
			tile.texture = load("res://assets/tile_no_outline.png")
		page_tiles.append(tiles)
	Stage.register_main(self)
	await get_tree().create_timer(0.1).timeout
	level = 1
	set_target(level)
	
	

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

func get_page(to_tile : Tile) -> Page:
	for page in %PageParent.get_children():
		if page.get_children().has(to_tile):
			return page
	return null

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
		sorted_tiles = sorted_tiles.filter(func(tile): return tile.elements.is_empty())
	sorted_tiles.sort_custom(func(a,b): return to_position.distance_to(a.global_position + a.size/2) < to_position.distance_to(b.global_position + b.size/2))
	return sorted_tiles.front()
	
var counter = 0

var highlighted_tiles : Array
var direction : Element.DIRECTION 
func _process(delta: float) -> void:
	for page in %PageParent.get_children():
		var tiles = page.get_children()
		for tile in tiles:
			for element in tile.elements:
				element.tick_element()
	
	
	if !arrow_placement_mode:
		return
	if Input.is_action_just_pressed("mouse_left"):
		if %PageParent.get_global_rect().has_point(get_global_mouse_position()):
			drag_started()
	if Input.is_action_just_released("mouse_left"):
		if %PageParent.get_global_rect().has_point(get_global_mouse_position()):
			drag_ended()
		else:
			drag_cancelled()
	if is_dragging:

		var end_tile = get_closest_tile_to_position(get_global_mouse_position(), true)
		var current_tile_number = get_tiles().find(end_tile)
		var starting_tile_number = get_tiles().find(drag_start_tile)
		
		var num_columns = get_page(end_tile).columns
		var num_tiles = get_tiles().size()
		
		# Calculate row and column positions for both tiles
		var current_row = current_tile_number / num_columns
		var current_col = current_tile_number % num_columns
		var starting_row = starting_tile_number / num_columns
		var starting_col = starting_tile_number % num_columns

		# Calculate relative differences
		var num_tiles_across = current_col - starting_col
		var num_tiles_up = starting_row - current_row
		
		
		if abs(num_tiles_across) > abs(num_tiles_up):
			if num_tiles_across > 0:
				direction = Element.DIRECTION.EAST
			else:
				direction = Element.DIRECTION.WEST
		else:
			if num_tiles_up < 0:
				direction = Element.DIRECTION.SOUTH
			else:
				direction = Element.DIRECTION.NORTH



		var current_tile = drag_start_tile
		highlighted_tiles = [drag_start_tile]
		match direction:
			Element.DIRECTION.NORTH:
				for i in num_tiles_up:
					if get_adjacent_tiles(current_tile)[0]:
						highlighted_tiles.append(get_adjacent_tiles(current_tile)[0])
						current_tile = get_adjacent_tiles(current_tile)[0]
			Element.DIRECTION.EAST:
				for i in num_tiles_across:
					if get_adjacent_tiles(current_tile)[1]:
						highlighted_tiles.append(get_adjacent_tiles(current_tile)[1])
						current_tile = get_adjacent_tiles(current_tile)[1]
			Element.DIRECTION.WEST:
				for i in abs(num_tiles_across):
					if get_adjacent_tiles(current_tile)[3]:
						highlighted_tiles.append(get_adjacent_tiles(current_tile)[3])
						current_tile = get_adjacent_tiles(current_tile)[3]
			Element.DIRECTION.SOUTH:
				for i in abs(num_tiles_up):
					if get_adjacent_tiles(current_tile)[2]:
						highlighted_tiles.append(get_adjacent_tiles(current_tile)[2])
						current_tile = get_adjacent_tiles(current_tile)[2]
		for tile in highlighted_tiles:
			tile.highlight_tile()
	
		for tile in get_tiles():
			if !highlighted_tiles.has(tile):
				tile.reset_tile()


var target : GameResource

func get_target() -> GameResource:
	return target



var is_dragging : bool = false
var drag_start_tile : Tile
func drag_started():
	is_dragging = true
	drag_start_tile = get_closest_tile_to_position(get_global_mouse_position(), true)
func drag_cancelled():
	is_dragging = false
	for tile in get_tiles():
		tile.reset_tile()
	highlighted_tiles.clear()
	#arrow_placement_mode = false
func drag_ended():
	is_dragging = false
	for tile in get_tiles():
		tile.reset_tile()
	if highlighted_tiles.is_empty():
		return
	for i in highlighted_tiles.size():
		var tile : Tile = highlighted_tiles[i]
		if !tile.elements.is_empty() and tile.elements[0] is not Arrow:
			continue

		var setting_arrow
		if tile.elements.size() > 1:
			var second_arrow : Arrow = tile.elements.back()
			second_arrow.delete_element()
		if tile.elements.is_empty():
			tile.set_element(load("res://scenes/elements/arrow.tscn"))
		else:
			var existing_arrow = tile.elements[0]
			if existing_arrow.sending_directions.size() == 1 and existing_arrow.recieving_directions.size() == 1 and i > 0 and i != highlighted_tiles.size() - 1:
				if (existing_arrow.sending_directions[0] + existing_arrow.recieving_directions[0]) % 2 == 0 and direction not in [existing_arrow.sending_directions[0]]:
					tile.set_element(load("res://scenes/elements/arrow.tscn"))
					
		setting_arrow = tile.elements.back()
		var recieving : Array[Element.DIRECTION] = setting_arrow.recieving_directions
		var sending : Array[Element.DIRECTION] = [direction]
		if i > 0: recieving.append(setting_arrow.get_opposite_direction(direction))
		setting_arrow.set_direction(sending, recieving)
	for tile in highlighted_tiles:
		for element in tile.elements:
			element.set_direction()
	
	arrow_placement_mode = false
	
var level = 1 : 
	set(value):
		level = value
		%level_text.text = "Level: " + str(level)
var target_resources 
func go_to_next_target():
	level += 1
	produced_resources = 0
	set_target(level)

func set_target(level : int):
	if target: target.queue_free()
	match level:
		1:
			target_resources = 10
			target = load("res://scenes/game resources/slide.tscn").instantiate()
			%target2.add_child(target)
		2: 
			target_resources = 20
			target = load("res://scenes/game resources/slide.tscn").instantiate()
			%target2.add_child(target)
			target._set_content(IndividualResource.CONTENT_TYPE.TITLE)
		3: 
			target_resources = 50
			target = load("res://scenes/game resources/slide.tscn").instantiate()
			%target2.add_child(target)
			target._set_content(IndividualResource.CONTENT_TYPE.TITLE)
			target._set_colour(IndividualResource.RESOURCE_COLOUR.BLUE)
		4:
			target_resources = 50
			target = load("res://scenes/game resources/slide_group.tscn").instantiate()
			%target2.add_child(target)
			var slide_1 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			var slide_2 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			

			add_child(slide_1)
			add_child(slide_2)

			slide_1._set_content(IndividualResource.CONTENT_TYPE.TITLE)
			slide_1._set_colour(IndividualResource.RESOURCE_COLOUR.BLUE)
			slide_2._set_content(IndividualResource.CONTENT_TYPE.QUOTE)

			
			target.slides_parent.add_theme_constant_override("separation", 10)
			target.add_resource(slide_1)
			target.add_resource(load("res://scenes/game resources/star_wipe.tscn").instantiate())
			target.add_resource(slide_2)
		5:
			target_resources = 50
			target = load("res://scenes/game resources/slide_group.tscn").instantiate()
			var slide_1 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			var slide_2 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			var slide_3 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			%target2.add_child(target)
			add_child(slide_1)
			add_child(slide_2)
			add_child(slide_3)
			slide_1._set_content(IndividualResource.CONTENT_TYPE.TITLE)
			slide_1._set_colour(IndividualResource.RESOURCE_COLOUR.BLUE)
			slide_2._set_content(IndividualResource.CONTENT_TYPE.QUOTE)
			slide_3._set_content(IndividualResource.CONTENT_TYPE.GRAPH)
			slide_3._set_content(IndividualResource.CONTENT_TYPE.NUMBER)
			slide_3._set_colour(IndividualResource.RESOURCE_COLOUR.PINK)
			
			target.slides_parent.add_theme_constant_override("separation", 10)
			target.add_resource(slide_1)
			target.add_resource(load("res://scenes/game resources/star_wipe.tscn").instantiate())
			target.add_resource(slide_2)
			target.add_resource(load("res://scenes/game resources/fade.tscn").instantiate())
			target.add_resource(slide_3)
		_:
			target_resources = 1000
			target = load("res://scenes/game resources/slide_group.tscn").instantiate()
			var slide_1 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			var slide_2 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			var slide_3 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			%target2.add_child(target)
			add_child(slide_1)
			add_child(slide_2)
			add_child(slide_3)
			slide_1._set_content(IndividualResource.CONTENT_TYPE.values().pick_random())
			slide_1._set_content(IndividualResource.CONTENT_TYPE.values().pick_random())
			slide_1._set_colour([IndividualResource.RESOURCE_COLOUR.BLUE, IndividualResource.RESOURCE_COLOUR.PINK].pick_random())
			slide_2._set_content(IndividualResource.CONTENT_TYPE.values().pick_random())
			slide_2._set_content(IndividualResource.CONTENT_TYPE.values().pick_random())
			slide_2._set_colour([IndividualResource.RESOURCE_COLOUR.BLUE, IndividualResource.RESOURCE_COLOUR.PINK].pick_random())
			slide_3._set_content(IndividualResource.CONTENT_TYPE.values().pick_random())
			slide_3._set_content(IndividualResource.CONTENT_TYPE.values().pick_random())
			slide_3._set_colour([IndividualResource.RESOURCE_COLOUR.BLUE, IndividualResource.RESOURCE_COLOUR.PINK].pick_random())

			
			target.slides_parent.add_theme_constant_override("separation", 10)
			target.add_resource(slide_1)
			target.add_resource(load(["res://scenes/game resources/star_wipe.tscn", "res://scenes/game resources/fade.tscn"].pick_random()).instantiate())
			target.add_resource(slide_2)
			target.add_resource(load(["res://scenes/game resources/star_wipe.tscn", "res://scenes/game resources/fade.tscn"].pick_random()).instantiate())
			target.add_resource(slide_3)
	target.z_as_relative = true
	target.z_index = 0
	produced_resources = 0
	
	target.position = %target2.position + %target2.size/2 - target.size/2
