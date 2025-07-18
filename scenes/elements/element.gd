extends Control
class_name Element
signal placed(cancelled:bool, element : Element)
@export var max_resources_stored : int = 1
var queued_resources : Array[GameResource]
var processed_resources : Array[GameResource]
enum DIRECTION{
	NORTH,
	EAST,
	SOUTH,
	WEST
}

@export_category("Objects")
@export var texture_rect : TextureRect
@export_category("Variables")
var sending_directions : Array[DIRECTION]
var recieving_directions : Array[DIRECTION]
@export var randomise_directions : bool
@export var sending_ports : int
@export var recieving_ports : int

@export_category("Resources")
@export var delete_button : Button
@export var north_facing_texture : Texture2D
@export var east_facing_texture : Texture2D
@export var south_facing_texture : Texture2D
@export var west_facing_texture : Texture2D

var parent_tile : Tile
var adjacent_tiles : Array[Tile]

func _ready() -> void:
	mouse_entered.connect(_show_delete_button)
	mouse_exited.connect(_hide_delete_button)
	if delete_button:
		delete_button.hide()
		delete_button.mouse_exited.connect(_hide_delete_button)
		delete_button.pressed.connect(delete_element)
	
	



func _show_delete_button():
	if delete_button and !is_in_placement_mode(): delete_button.show()
func _hide_delete_button():
	if delete_button and !delete_button.get_global_rect().has_point(get_global_mouse_position()) and !get_global_rect().has_point(get_global_mouse_position()): delete_button.hide()
func delete_element():
	parent_tile.clear_element()
	for resource in queued_resources + processed_resources:
		resource.queue_free()
	queue_free()

func change_direction():
	pass

func predict_direction(on_tile : Tile):
	pass

func reset_tile(tile : Tile):
	pass

func can_change_sending_direction() -> bool:
	return false

func reset_direction():
	if !previous_directions.is_empty():
		set_direction(previous_directions[0], previous_directions[1])
	else:
		set_direction()

func set_direction(in_sending_directions : Array[DIRECTION]= sending_directions, in_recieving_directions : Array[DIRECTION] = recieving_directions):
	if in_sending_directions.has(-1):
		in_sending_directions = sending_directions
	if in_recieving_directions.has(-1):
		in_recieving_directions = recieving_directions
	recieving_directions = in_recieving_directions
	sending_directions = in_sending_directions
	set_connectors()
	if in_sending_directions.is_empty() or !texture_rect:
		return
	match in_sending_directions[0]:
		DIRECTION.NORTH: 
			texture_rect.texture = north_facing_texture
		DIRECTION.EAST:
			texture_rect.texture = east_facing_texture
		DIRECTION.SOUTH:
			texture_rect.texture = south_facing_texture
		DIRECTION.WEST:
			texture_rect.texture = west_facing_texture
func set_connectors():
	if !is_instance_valid(%out_top):
		return
	
	%out_top.hide()
	%out_bottom.hide()
	%out_left.hide()
	%out_right.hide()
	%in_top.hide()
	%in_bottom.hide()
	%in_left.hide()
	%in_right.hide()
	for dir in sending_directions:
		match dir:
			DIRECTION.NORTH:
				%out_top.show()
			DIRECTION.EAST:
				%out_right.show()
			DIRECTION.SOUTH:
				%out_bottom.show()
			DIRECTION.WEST:
				%out_left.show()
	for dir in recieving_directions:
		match dir:
			DIRECTION.NORTH:
				%in_top.show()
			DIRECTION.EAST:
				%in_right.show()
			DIRECTION.SOUTH:
				%in_bottom.show()
			DIRECTION.WEST:
				%in_left.show()

func element_placed(on_tile : Tile):
	parent_tile = on_tile
	reparent(parent_tile)
	adjacent_tiles = Stage.get_main().get_adjacent_tiles(parent_tile)
	placement_mode = false
	if randomise_directions:
		var available_directions : Array[int]
		for i in adjacent_tiles.size():
			if adjacent_tiles[i]:
				available_directions.append(i)
		var remaining_sending_ports = sending_ports
		var remaining_recieving_ports = recieving_ports
		for i in available_directions.size():
			if remaining_sending_ports > 0 and remaining_recieving_ports > 0:
				if i % 2 == 0:
					sending_directions.append(available_directions[i])
					remaining_sending_ports -= 1
				else:
					recieving_directions.append(available_directions[i])
					remaining_recieving_ports -= 1
			elif remaining_sending_ports > 0:
					sending_directions.append(available_directions[i])
					remaining_sending_ports -= 1
			elif remaining_recieving_ports > 0:
					recieving_directions.append(available_directions[i])
					remaining_recieving_ports -= 1
				
		
	reset_direction()
	
	placed.emit(false, self)

func clear_placement_mode():
	placed.emit(true, self)
	placement_mode = false
	queue_free()


var closest_tile : Tile
func _input(event: InputEvent) -> void:
	# Check if we're in placement mode (you'll need to define this condition based on your game state)
	if is_in_placement_mode():
		# Snap to closest tile to mouse position
		if Input.is_action_just_pressed("ui_cancel"):
			clear_placement_mode()
		if closest_tile != get_closest_tile_to_mouse():
			reset_tile(closest_tile)
			closest_tile = get_closest_tile_to_mouse()
			if closest_tile:
				global_position = closest_tile.global_position + closest_tile.size/2 - size/2
				predict_direction(closest_tile)
		if event is InputEventMouseButton:
			var mouse_event = event as InputEventMouseButton
			
			# Left click - place element on tile
			if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
				if closest_tile:
					place_on_tile(closest_tile)
			
			# Right click - change direction
			elif mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
				if is_mouse_over_element():
					change_direction()
var placement_mode = true
func is_in_placement_mode() -> bool:
	return placement_mode

func get_closest_tile_to_mouse() -> Tile:
	return Stage.get_main().get_closest_tile_to_position(get_global_mouse_position())


func place_on_tile(tile: Tile) -> void:
	# Place the element on the specified tile
	if tile and !tile.element:
		tile.element = self
		element_placed(tile)
	
	for adj_tile in adjacent_tiles:
		if adj_tile and adj_tile.element:
			adj_tile.element.save_direction_state()
		

func is_mouse_over_element() -> bool:
	var mouse_pos = get_global_mouse_position()
	var rect = Rect2(global_position, size)
	return rect.has_point(mouse_pos)

var element_activating = false
func activate_element():
	element_activating = true
	if !queued_resources.is_empty():
		processed_resources.append(queued_resources.pop_back())
	element_activating = false
	
func _process(delta: float) -> void:

	
	if !processed_resources.is_empty():
		var send_to : Array[Tile] = get_send_to()
		
		
		for tile in send_to:
			if tile and tile.element and tile.element.can_recieve_resource(self, processed_resources.back()) and !processed_resources.is_empty():
				#if tile.element is not Arrow and self is not Arrow:
					#continue
				if tile.element.resource_sending:
					continue
				if !movement_tween or !movement_tween.is_running():
					var sending_resource = processed_resources.back()
					processed_resources.erase(sending_resource)
					await tile.element.send_resource(sending_resource)
	
	if _ready_to_activate():
		await activate_element()


func get_send_to() -> Array[Tile]:
	var send_to : Array[Tile]
	for facing_direction in sending_directions:
			match facing_direction:
				DIRECTION.NORTH:
					if adjacent_tiles[0] and adjacent_tiles[0].element and DIRECTION.SOUTH in adjacent_tiles[0].element.recieving_directions:
						send_to.append(adjacent_tiles[0])
				DIRECTION.EAST:
					if adjacent_tiles[1] and adjacent_tiles[1].element and DIRECTION.WEST in adjacent_tiles[1].element.recieving_directions:
						send_to.append(adjacent_tiles[1])
				DIRECTION.SOUTH:
					if adjacent_tiles[2] and adjacent_tiles[2].element and DIRECTION.NORTH in adjacent_tiles[2].element.recieving_directions:
						send_to.append(adjacent_tiles[2])
				DIRECTION.WEST:
					if adjacent_tiles[3] and adjacent_tiles[3].element and DIRECTION.EAST in adjacent_tiles[3].element.recieving_directions:
						send_to.append(adjacent_tiles[3])
	return send_to


func _ready_to_activate() -> bool:
	return !queued_resources.is_empty() and !element_activating
		

var movement_tween : Tween
var resource_sending : bool = false
func send_resource(sent_resource : GameResource, reactivate=true):
	resource_sending = true
	if movement_tween and movement_tween.is_running():
		movement_tween.kill()
	sent_resource.reparent(self)
	movement_tween = create_tween()
	movement_tween.tween_property(sent_resource, "global_position", global_position + size/2 - sent_resource.size/2, 0.3)
	queued_resources.append(sent_resource)
	await movement_tween.finished
	resource_sending = false

func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	if sending_element is not Arrow and self is not Arrow:
		return false
	
	var direction_correct = false
	for direction in recieving_directions:
		if sending_element.sending_directions.map(func(dir): return get_opposite_direction(dir)).has(direction):
			direction_correct = true
	return queued_resources.size() < max_resources_stored and processed_resources.size() < max_resources_stored and direction_correct


var previous_directions : Array[Array]
func save_direction_state():
	previous_directions = [sending_directions, recieving_directions]


func get_opposite_direction(from_direction : DIRECTION) -> DIRECTION:
	match from_direction:
		DIRECTION.NORTH:
			return DIRECTION.SOUTH
		DIRECTION.EAST:
			return DIRECTION.WEST
		DIRECTION.SOUTH:
			return DIRECTION.NORTH
		DIRECTION.WEST:
			return DIRECTION.EAST
		_:
			return 0

func get_clockwise_direction(from_direction : DIRECTION) -> DIRECTION:
	match from_direction:
		DIRECTION.NORTH:
			return DIRECTION.EAST
		DIRECTION.EAST:
			return DIRECTION.SOUTH
		DIRECTION.SOUTH:
			return DIRECTION.WEST
		DIRECTION.WEST:
			return DIRECTION.NORTH
		_:
			return 0
			
