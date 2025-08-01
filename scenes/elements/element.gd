extends Control
class_name Element
signal placed(cancelled:bool, element : Element)
@export var max_queued_resources : int = 1
@export var max_processed_resources : int = 1
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
enum PORT_STATUS{SENDING, RECEIVING, BLOCKED}
@export var north_port : PORT_STATUS
@export var east_port : PORT_STATUS
@export var south_port : PORT_STATUS
@export var west_port : PORT_STATUS
var sending_directions : Array[DIRECTION]
var recieving_directions : Array[DIRECTION]


@export_category("Resources")
@export var delete_button : Button


var parent_tile : Tile
var adjacent_tiles : Array[Tile]

func _ready() -> void:
	mouse_entered.connect(_show_delete_button)
	mouse_exited.connect(_hide_delete_button)
	if delete_button:
		delete_button.hide()
		delete_button.mouse_exited.connect(_hide_delete_button)
		delete_button.pressed.connect(delete_element)
	_initialise_ports()
	if self is not Arrow:
		z_as_relative = false
		z_index = 1

func _initialise_ports():
	sending_directions.clear()
	recieving_directions.clear()
	if north_port == PORT_STATUS.SENDING:
		sending_directions.append(0)
	if north_port == PORT_STATUS.RECEIVING:
		recieving_directions.append(0)
	if east_port == PORT_STATUS.SENDING:
		sending_directions.append(1)
	if east_port == PORT_STATUS.RECEIVING:
		recieving_directions.append(1)
	if south_port == PORT_STATUS.SENDING:
		sending_directions.append(2)
	if south_port == PORT_STATUS.RECEIVING:
		recieving_directions.append(2)
	if west_port == PORT_STATUS.SENDING:
		sending_directions.append(3)
	if west_port == PORT_STATUS.RECEIVING:
		recieving_directions.append(3)
	set_direction()
	
func _show_delete_button():
	if delete_button and !Stage.get_main().arrow_placement_mode and !is_in_placement_mode(): delete_button.show()

func _hide_delete_button():
	if delete_button and !delete_button.get_global_rect().has_point(get_global_mouse_position()) and !get_global_rect().has_point(get_global_mouse_position()): delete_button.hide()

func delete_element():
	for adj in adjacent_tiles:
		if !adj: continue
		for element in adj.elements:
			if element and element.recieving_queue.keys().has(self):
				element.recieving_queue.erase(self)
	parent_tile.elements.erase(self)
	for resource in queued_resources + processed_resources:
		resource.queue_free()
	
	queue_free()

func change_direction():
	for i in sending_directions.size():
		sending_directions[i] = get_clockwise_direction(sending_directions[i])
	for i in recieving_directions.size():
		recieving_directions[i] = get_clockwise_direction(recieving_directions[i])
	set_direction()
	
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
	if !adjacent_tiles.is_empty():
		for dir in sending_directions.duplicate():
			if !adjacent_tiles[dir]: sending_directions.erase(dir)
		for dir in recieving_directions.duplicate():
			if !adjacent_tiles[dir]: recieving_directions.erase(dir)
	set_connectors()
	if in_sending_directions.is_empty() or !texture_rect:
		return

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

func element_connected() -> bool:
	for sending_dir in sending_directions:
		if adjacent_tiles[sending_dir] and !adjacent_tiles[sending_dir].elements.is_empty():
			for element in adjacent_tiles[sending_dir].elements: 
				if element.recieving_directions.has(get_opposite_direction(sending_dir)):
					return true
	for recieving_dir in sending_directions:
		if adjacent_tiles[recieving_dir] and !adjacent_tiles[recieving_dir].elements.is_empty():
			for element in adjacent_tiles[recieving_dir].elements: 
				if element.sending_directions.has(get_opposite_direction(recieving_dir)):
					return true
	return false

func element_placed(on_tile : Tile):
	parent_tile = on_tile
	reparent(parent_tile)
	adjacent_tiles = Stage.get_main().get_adjacent_tiles(parent_tile)
	placement_mode = false
	
				
		

	
	placed.emit(false, self)
	set_direction()
	
func clear_placement_mode():
	placed.emit(true, self)
	placement_mode = false
	queue_free()


var closest_tile : Tile

func _input(event: InputEvent) -> void:
	# Check if we're in placement mode (you'll need to define this condition based on your game state)
	if !Stage.get_main():
		return
	#if !Stage.get_main().is_window_focused(self):
		#return
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
	if tile and !tile.elements.has(self):
		if self is Arrow: tile.elements.append(self)
		else: 
			tile.clear_element()
			tile.elements.append(self)
		element_placed(tile)

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

var previously_sent : Array[Tile]

func tick_element():
	if !processed_resources.is_empty() and !element_activating:
		if self is Producer and self.producing_resource == load("res://scenes/game resources/slide.tscn"):
			pass
		var send_to : Array[Tile] = get_send_to()
		if previously_sent.size() >= 4:
			previously_sent.clear()
		if previously_sent:
			send_to.sort_custom(func(a,b): 
				if !previously_sent.has(a):
					return true
				if !previously_sent.has(b):
					return false
				return previously_sent.find(a) < previously_sent.find(b)
				)
		processed_resources = processed_resources.filter(func(resource): return is_instance_valid(resource))
		if processed_resources.is_empty():
			return
		
		for tile in send_to:
			if tile and !tile.elements.is_empty(): 
				for element in tile.elements:
					if !processed_resources.is_empty():
						var direction_correct = false
						if self is Sender: 
							direction_correct = true
						for sending_dir in sending_directions:
							if element.recieving_directions.has(get_opposite_direction(sending_dir)):
								direction_correct = true
						if !direction_correct:
							continue
						
						if !element.resource_sending and !resource_sending:
							element.request_send(self, processed_resources.back())
							await get_tree().create_timer(0.1).timeout
		

	
	if !recieving_queue.keys().is_empty() and !resource_sending and !element_activating:
		var recieving_elements = recieving_queue.keys().duplicate()
		if previously_recieved_from.size() >= 4: previously_recieved_from.clear()
		recieving_elements.sort_custom(func(a,b): 
			if !previously_recieved_from.has(a):
				return true
			if !previously_recieved_from.has(b):
				return false
			return previously_recieved_from.find(a) < previously_recieved_from.find(b)
			)
		for element : Element in recieving_elements:
			if !recieving_queue.keys().has(element):
				continue
			var resource : GameResource = recieving_queue[element]
			if !resource:
				continue
			if resource.get_parent() != element:
				recieving_queue.erase(element)
				continue
			if !element.processed_resources.has(resource):
				recieving_queue.erase(element)
				continue
			if !can_recieve_resource(element, resource):
				continue
			if resource_sending:
				continue
			if !previously_recieved_from.has(element):
				previously_recieved_from.append(element)
			else:
				previously_recieved_from.erase(element)
				previously_recieved_from.append(element)
			await send_resource(resource, element)
			await get_tree().create_timer(0.1).timeout
			if is_instance_valid(element):
				element.processed_resources.erase(resource)
				if recieving_queue and !recieving_queue.is_empty(): recieving_queue.erase(element)
	
	if _ready_to_activate():
		await activate_element()	

var previously_recieved_from : Array[Element]
var recieving_queue : Dictionary[Element, GameResource] = {}

func request_send(from_tile : Element, with_resource : GameResource):
	if recieving_queue.keys().has(from_tile):
		return 
	recieving_queue[from_tile] = with_resource

func get_send_to() -> Array[Tile]:
	var send_to : Array[Tile]
	for facing_direction in sending_directions:
			match facing_direction:
				DIRECTION.NORTH:
					if adjacent_tiles[0] and !adjacent_tiles[0].elements.is_empty():
						for element in adjacent_tiles[0].elements: 
							if DIRECTION.SOUTH in element.recieving_directions:
								send_to.append(adjacent_tiles[0])
				DIRECTION.EAST:
					if adjacent_tiles[1] and !adjacent_tiles[1].elements.is_empty():
						for element in adjacent_tiles[1].elements: 
							if DIRECTION.WEST in element.recieving_directions:
								send_to.append(adjacent_tiles[1])
				DIRECTION.SOUTH:
					if adjacent_tiles[2] and !adjacent_tiles[2].elements.is_empty():
						for element in adjacent_tiles[2].elements: 
							if DIRECTION.NORTH in element.recieving_directions:
								send_to.append(adjacent_tiles[2])
				DIRECTION.WEST:
					if adjacent_tiles[3] and !adjacent_tiles[3].elements.is_empty():
						for element in adjacent_tiles[3].elements: 
							if DIRECTION.EAST in element.recieving_directions:
								send_to.append(adjacent_tiles[3])

	return send_to

func _ready_to_activate() -> bool:
	return !queued_resources.is_empty() and !element_activating
		
var movement_tween : Tween
var resource_sending : bool = false :
	set(value):
		resource_sending = value
		if self is Sender:
			pass

func send_resource(sent_resource : GameResource, sending_element : Element):
	resource_sending = true
	if movement_tween and movement_tween.is_running():
		movement_tween.kill()
	if !sending_element.previously_sent.has(parent_tile): 
		sending_element.previously_sent.append(parent_tile)
	else:
		sending_element.previously_sent.erase(parent_tile)
		sending_element.previously_sent.append(parent_tile)
	sent_resource.reparent(self)
	movement_tween = create_tween()
	movement_tween.tween_property(sent_resource, "global_position", global_position + size/2 - sent_resource.size/2, 0.3)
	queued_resources.append(sent_resource)
	sending_element.processed_resources.erase(sent_resource)
	await movement_tween.finished
	resource_sending = false

func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	var direction_correct = false
	for direction in recieving_directions:
		if sending_element.sending_directions.map(func(dir): return get_opposite_direction(dir)).has(direction):
			direction_correct = true
	return queued_resources.size() < max_queued_resources and processed_resources.size() < max_processed_resources and direction_correct

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

func get_save_dict() -> Dictionary:
	var save_dict = {}
	save_dict["sending_directions"] = sending_directions
	save_dict["recieving_directions"] = recieving_directions
	return save_dict

func load_from_save_dict(dict : Dictionary):
	if dict.has("sending_directions") and dict.has("recieving_directions"):
		sending_directions.clear()
		recieving_directions.clear()
		for i in dict["sending_directions"]:
			sending_directions.append(int(i))
		for i in dict["recieving_directions"]:
			recieving_directions.append(int(i))
		set_direction()
