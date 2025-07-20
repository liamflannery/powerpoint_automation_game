extends Element
class_name Arrow

@export var up_down_texture : Texture2D
@export var left_right_texture : Texture2D
@export var corner_texture_left_up : Texture2D
@export var corner_texture_right_up : Texture2D
@export var corner_texture_left_down : Texture2D
@export var corner_texture_right_down : Texture2D

func _ready() -> void:
	super()




func set_direction(in_sending_directions : Array[DIRECTION]= sending_directions, in_recieving_directions : Array[DIRECTION] = recieving_directions):
	if in_sending_directions.is_empty() or in_recieving_directions.is_empty():
		return
	if Input.is_action_pressed("ui_accept"):
		pass
	if in_sending_directions.has(-1):
		in_sending_directions = sending_directions
	if in_recieving_directions.has(-1):
		in_recieving_directions = recieving_directions

	var to_direction = in_sending_directions.front()
	recieving_directions.clear()
	
	sending_directions = in_sending_directions
	recieving_directions = in_recieving_directions
	%arrow_north.hide()
	%arrow_east.hide()
	%arrow_south.hide()
	%arrow_west.hide()
	var adjacents = adjacent_prediction if adjacent_tiles.is_empty() else adjacent_tiles
	if adjacents:
		for dir in DIRECTION.values():
			if dir != to_direction and adjacents[dir] and adjacents[dir].element and adjacents[dir].element.sending_directions.has(get_opposite_direction(dir)):
				recieving_directions.append(dir)
	
	if adjacents and adjacents[to_direction]: 
		if adjacents[to_direction].element is not Arrow: 
			if !is_instance_valid(adjacents[to_direction].placeholder_element) or adjacents[to_direction].placeholder_element is not Arrow:
				match to_direction:
					DIRECTION.NORTH:
						%arrow_north.show()
					DIRECTION.EAST:
						%arrow_east.show()
					DIRECTION.WEST:
						%arrow_west.show()
					DIRECTION.SOUTH:
						%arrow_south.show()


	%top_body.hide()
	%bottom_body.hide()
	%right_body.hide()
	%left_body.hide()
	for dir in recieving_directions + sending_directions:
		match dir:
			DIRECTION.NORTH:
				%top_body.show()
			DIRECTION.EAST:
				%right_body.show()
			DIRECTION.SOUTH:
				%bottom_body.show()
			DIRECTION.WEST:
				%left_body.show()
	

func change_direction():
	super()
	if placement_mode:
		predict_direction(closest_tile, false)

var adjacent_prediction : Array[Tile]
var combo_index = 0
var previous_tile : Tile
func predict_direction(on_tile : Tile, initial = true):
	if Input.is_action_pressed("ui_accept"):
		pass
	
	if previous_tile != on_tile:
		combo_index = 0
		if previous_tile: previous_tile.placeholder_element = null
		previous_tile = on_tile
		on_tile.placeholder_element = self
	if !initial:
		combo_index += 1
	for i in adjacent_prediction.size():
			if adjacent_prediction[i] and adjacent_prediction[i].element and adjacent_prediction[i].element.can_change_sending_direction():
					if sending_directions.front() == i: continue
					adjacent_prediction[i].element.reset_direction()
	adjacent_prediction = Stage.get_main().get_adjacent_tiles(on_tile)

	var tiles_feeding_into_this_tile : Array[Tile]
	var tiles_recieving_from_this_tile : Array[Tile]
	var blank_tiles : Array[int]
	var combos_dict : Array[Array] #[[sending to, recieving from, [[tile direction, sending to, recieving from ]]
	for i in adjacent_prediction.size():
			if adjacent_prediction[i] and adjacent_prediction[i].element:
				if adjacent_prediction[i].element.sending_directions.has(get_opposite_direction(i)):
					tiles_feeding_into_this_tile.append(adjacent_prediction[i])
				if adjacent_prediction[i].element.recieving_directions.has(get_opposite_direction(i)):
					tiles_recieving_from_this_tile.append(adjacent_prediction[i])
			elif adjacent_prediction[i]:
				blank_tiles.append(i)
					#
	#if !tiles_feeding_into_this_tile.is_empty() and !tiles_recieving_from_this_tile.is_empty():
		#for receiving_from : Tile in tiles_feeding_into_this_tile:
			#for sending_to : Tile in tiles_recieving_from_this_tile:
				#var recieving_index = adjacent_prediction.find(receiving_from)
				#var sending_index = adjacent_prediction.find(sending_to)
				#if recieving_index < 0 or sending_index < 0 or recieving_index == sending_index:
					#continue
				#combos_dict.append([sending_index, recieving_index])
	#if !tiles_feeding_into_this_tile.is_empty():
		#for receiving_from : Tile in tiles_feeding_into_this_tile:
			#var recieving_index = adjacent_prediction.find(receiving_from)
			#if recieving_index < 0:
				#continue
			#var other_directions = adjacent_prediction.duplicate()
			#other_directions.erase(receiving_from)
			#var sending_directions = [0,1,2,3]
			#sending_directions.erase(recieving_index)
			#for dir in sending_directions.duplicate():
				#if !adjacent_prediction[dir] or (adjacent_prediction[dir].element and !adjacent_prediction[dir].element.recieving_directions.has(get_opposite_direction(dir))):
					#sending_directions.erase(dir)
			#for to_send in sending_directions:
				#combos_dict.append([to_send,recieving_index])
	#if !tiles_recieving_from_this_tile.is_empty():
		#for sending_to : Tile in tiles_recieving_from_this_tile:
			#var sending_index = adjacent_prediction.find(sending_to)
			#if sending_index < 0:
				#continue
			#var other_directions = adjacent_prediction.duplicate()
			#other_directions.erase(sending_to)
			#var recieving_directions = [0,1,2,3]
			#recieving_directions.erase(sending_index)
			#for dir in recieving_directions.duplicate():
				#if !adjacent_prediction[dir] or (adjacent_prediction[dir].element and !adjacent_prediction[dir].element.sending_directions.has(get_opposite_direction(dir))):
					#recieving_directions.erase(dir)
			#for to_recieve in recieving_directions:
				#combos_dict.append([sending_index, to_recieve])
	#
	for i in adjacent_prediction.size():
		if adjacent_prediction[i]: 
			if (!adjacent_prediction[i].element) or (adjacent_prediction[i].element and adjacent_prediction[i].element.recieving_directions.has(get_opposite_direction(i))):
				combos_dict.append([i,1])
	var changeable_tiles : Array[Tile]
	for i in adjacent_prediction.size():
		var tile = adjacent_prediction[i]
		if tile and tile.element and tile.element.can_change_sending_direction() and get_opposite_direction(i) not in tile.element.sending_directions:
			changeable_tiles.append(tile)
	
	for tile in changeable_tiles:
		var instruction = [[adjacent_prediction.find(tile), get_opposite_direction(adjacent_prediction.find(tile)), -1]]
		combos_dict.append([get_opposite_direction(adjacent_prediction.find(tile)), adjacent_prediction.find(tile), instruction])
	
	for a in blank_tiles:
		for b in blank_tiles:
			if a != b:
				combos_dict.append([a,b])

	
	if !combos_dict.is_empty():

		for combo in combos_dict.duplicate():
			if combo.size() >= 3:
				if adjacent_prediction[combo[2][0][0]].element.element_connected():
					combos_dict.erase(combo)
					combos_dict.push_back(combo)
		
		if combos_dict.size() <= combo_index:
			combo_index = 0
		var combo = combos_dict[combo_index]	
		set_direction([combos_dict[combo_index][0]], [combos_dict[combo_index][1]])
		if combo.size() >= 3:
			var movmement_instructions = combo[2]
			for instruction in movmement_instructions:
				var tile_index = instruction[0]
				var new_send_to = instruction[1]
				var new_recieve_from = instruction[2]
				if adjacent_prediction[tile_index] and adjacent_prediction[tile_index].element:
					adjacent_prediction[tile_index].element.save_direction_state()
					adjacent_prediction[tile_index].element.set_direction([new_send_to])


		
	
func can_change_sending_direction() -> bool:
	return true
		
func reset_tile(tile : Tile):
	reset_direction()
	var adjacent_prediction : Array[Tile] = Stage.get_main().get_adjacent_tiles(tile)
	for i in adjacent_prediction.size():
		if adjacent_prediction[i] and adjacent_prediction[i].element:
			adjacent_prediction[i].element.reset_direction()
