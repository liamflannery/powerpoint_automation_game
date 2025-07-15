extends Element
class_name Arrow

@export var up_down_texture : Texture2D
@export var left_right_texture : Texture2D
@export var corner_texture_left_up : Texture2D
@export var corner_texture_right_up : Texture2D
@export var corner_texture_left_down : Texture2D
@export var corner_texture_right_down : Texture2D



func set_direction(in_sending_directions : Array[DIRECTION]= sending_directions, in_recieving_directions : Array[DIRECTION] = recieving_directions):
	if sending_directions.is_empty() or recieving_directions.is_empty():
		return
	
	var from_direction = in_recieving_directions.front()
	var to_direction = in_sending_directions.front()
	if from_direction == to_direction:
		return
	sending_directions = in_sending_directions
	recieving_directions = in_recieving_directions
	%north_rect.hide()
	%east_rect.hide()
	%south_rect.hide()
	%west_rect.hide()
	match from_direction:
		DIRECTION.NORTH:
			%north_rect.show()
			%north_rect.color = Color.RED
		DIRECTION.EAST:
			%east_rect.show()
			%east_rect.color = Color.RED
		DIRECTION.WEST:
			%west_rect.show()
			%west_rect.color = Color.RED
		DIRECTION.SOUTH:
			%south_rect.show()
			%south_rect.color = Color.RED
	match to_direction:
		DIRECTION.NORTH:
			%north_rect.show()
			%north_rect.color = Color.GREEN
		DIRECTION.EAST:
			%east_rect.show()
			%east_rect.color = Color.GREEN
		DIRECTION.WEST:
			%west_rect.show()
			%west_rect.color = Color.GREEN
		DIRECTION.SOUTH:
			%south_rect.show()
			%south_rect.color = Color.GREEN
	
	if from_direction == get_opposite_direction(to_direction):
		if from_direction == DIRECTION.EAST or from_direction == DIRECTION.WEST:
			texture_rect.texture = left_right_texture
		else:
			texture_rect.texture = up_down_texture
	else:
		if DIRECTION.NORTH in [to_direction, from_direction]:
			if DIRECTION.EAST in [to_direction, from_direction]:
				texture_rect.texture = corner_texture_right_up
			else:
				texture_rect.texture = corner_texture_left_up
		if DIRECTION.SOUTH in [to_direction, from_direction]:
			if DIRECTION.EAST in [to_direction, from_direction]:
				texture_rect.texture = corner_texture_right_down
			else:
				texture_rect.texture = corner_texture_left_down

func change_direction():
	var next_sending = get_clockwise_direction(sending_directions.front())
	set_direction([next_sending], [get_opposite_direction(next_sending)])
	if placement_mode:
		predict_direction(closest_tile, false)


func predict_direction(on_tile : Tile, initial = true, direction_preference : DIRECTION = -1):
	if Input.is_action_pressed("ui_accept"):
		pass
	var adjacent_prediction : Array[Tile] = Stage.get_main().get_adjacent_tiles(on_tile)
	if !initial:
		for i in adjacent_prediction.size():
				if adjacent_prediction[i] and adjacent_prediction[i].element and adjacent_prediction[i].element is Arrow:
						if sending_directions.front() == i: continue
						adjacent_prediction[i].element.reset_direction()
	if direction_preference > -1:
		if adjacent_prediction[direction_preference] and adjacent_prediction[direction_preference].element and adjacent_prediction[direction_preference].element is Arrow:
				if sending_directions.front() != direction_preference:
					if initial: adjacent_prediction[direction_preference].element.save_direction_state()
					adjacent_prediction[direction_preference].element.set_direction([get_opposite_direction(direction_preference)])
					set_direction(sending_directions, [direction_preference])
	else:
		var tiles_feeding_into_this_tile : Array[Tile]
		var tiles_recieving_from_this_tile : Array[Tile]
		for i in adjacent_prediction.size():
				if adjacent_prediction[i] and adjacent_prediction[i].element:
					if adjacent_prediction[i].element.sending_directions.front() == get_opposite_direction(i):
						tiles_feeding_into_this_tile.append(adjacent_prediction[i])
		for i in adjacent_prediction.size():
				if adjacent_prediction[i] and adjacent_prediction[i].element:
					if adjacent_prediction[i].element.recieving_directions.front() == get_opposite_direction(i):
						tiles_recieving_from_this_tile.append(adjacent_prediction[i])
						
		if !tiles_feeding_into_this_tile.is_empty() and !tiles_recieving_from_this_tile.is_empty():
			var recieving_from = tiles_feeding_into_this_tile.front()
			var sending_to = tiles_recieving_from_this_tile.front()
			set_direction([adjacent_prediction.find(sending_to)], [adjacent_prediction.find(recieving_from)])
		elif !tiles_feeding_into_this_tile.is_empty():
			var recieving_from = tiles_feeding_into_this_tile.front()
			set_direction(sending_directions, [adjacent_prediction.find(recieving_from)])
		elif !tiles_recieving_from_this_tile.is_empty():
			var sending_to = tiles_recieving_from_this_tile.front()
			set_direction([adjacent_prediction.find(sending_to)])
		else:
			set_direction()

		
func reset_tile(tile : Tile):
	reset_direction()
	var adjacent_prediction : Array[Tile] = Stage.get_main().get_adjacent_tiles(tile)
	for i in adjacent_prediction.size():
		if adjacent_prediction[i] and adjacent_prediction[i].element:
			adjacent_prediction[i].element.reset_direction()
