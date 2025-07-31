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
		%target_text.text = str(value) + "/" + str(target_resources)
		if produced_resources >= target_resources:
			target = null
			if current_contract:
				create_email(current_contract.difficulty_level + 1)

func _ready() -> void:
	for child in %PageParent.get_children():
		var tiles : Array[Tile]
		for tile in child.get_children():
			tiles.append(tile)
			tile.texture = load("res://assets/tile_no_outline.png")
		page_tiles.append(tiles)
	Stage.register_main(self)
	await get_tree().create_timer(2).timeout
	create_email(5)

var current_contract : Email
var funny_subject_lines = [
	"no subject",
	"RE: please send me a harder challenge",
	"FW: can you send this to that dumbass that makes slides",
	"struggle to make slides with this ONE WEIRD TRICK",
	"hot slides in your area",
	"CONGRATULATIONS you've won another slide challenge",
	
]
func create_email(this_level : int):
	var subject 
	match this_level:
		1:
			subject = "First task"
		2: 
			subject = "Second task"
		3:
			subject = "Damn okay see if you can do this"
		4:
			subject = "I've cooked on this one"
		5:
			subject = "The brain destroyer"
		_:
			subject = funny_subject_lines.pop_at(randi_range(0, funny_subject_lines.size() -1))
			if !subject or subject == "":
				subject = "Ive run out of subject line ideas"
	var email = Email.new(subject, "Liam Flannery", this_level, %time.get_time())
	%email_inbox.recieve_email(email)
	
	

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


func is_window_focused(node : Control) -> bool:
	var window_of_node
	var current_node = node
	while !window_of_node:
		if current_node.is_in_group("window"):
			window_of_node = current_node
		elif current_node.get_parent():
			current_node = current_node.get_parent()
		else:
			return false
	var windows = get_children().filter(func(child): return child.is_in_group("window") and child.visible)
	return window_of_node == windows.back()

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


var target : GameResource :
	set(value):
		target = value
		var sub_view = target.duplicate()
		%target_parent.add_child(sub_view)
		%target_parent.move_child(sub_view, 0)
		await get_tree().process_frame
		sub_view.pivot_offset = sub_view.size/2
		sub_view.scale *= 0.9
		produced_resources = 0





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
	

	
var level = 1 : 
	set(value):
		level = value
		%level_text.text = "Level " + str(level) + ", produce the following:"
var target_resources = 20




class Email:
	var subject_line : String
	var from : String
	var time : String
	var difficulty_level : int
	func _init(subject : String, from_text : String, level : int, current_time : String) -> void:
		subject_line = subject
		from = from_text
		difficulty_level = level
		time = current_time

func get_target(level : int) -> GameResource:
	var target : GameResource
	match level:
		1:

			target = load("res://scenes/game resources/slide.tscn").instantiate()
		2: 
	
			target = load("res://scenes/game resources/slide.tscn").instantiate()
			target._set_content(IndividualResource.CONTENT_TYPE.TITLE)
		3: 

			target = load("res://scenes/game resources/slide.tscn").instantiate()
			target._set_content(IndividualResource.CONTENT_TYPE.TITLE)
			target._set_colour(IndividualResource.RESOURCE_COLOUR.BLUE)
		4:
		
			target = load("res://scenes/game resources/slide_group.tscn").instantiate()
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

			target = load("res://scenes/game resources/slide_group.tscn").instantiate()
			var slide_1 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			var slide_2 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			var slide_3 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
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
	
			target = load("res://scenes/game resources/slide_group.tscn").instantiate()
			var slide_1 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			var slide_2 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
			var slide_3 : IndividualResource = load("res://scenes/game resources/slide.tscn").instantiate()
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
	for child in target.get_children():
		child.z_as_relative = true
		child.z_index = 1

	return target

func get_email_inbox() -> EmailInbox:
	return %email_inbox
