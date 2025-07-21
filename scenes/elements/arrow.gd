extends Element
class_name Arrow



func _ready() -> void:
	super()
	placement_mode = false




func set_direction(in_sending_directions : Array[DIRECTION]= sending_directions, in_recieving_directions : Array[DIRECTION] = recieving_directions):
	if Input.is_action_pressed("ui_accept"):
		pass
	if in_sending_directions.has(-1):
		in_sending_directions = sending_directions
	if in_recieving_directions.has(-1):
		in_recieving_directions = recieving_directions

	%arrow_north.hide()
	%arrow_east.hide()
	%arrow_south.hide()
	%arrow_west.hide()
	%top_body.hide()
	%bottom_body.hide()
	%right_body.hide()
	%left_body.hide()
	%bridge_left_right.hide()
	%bridge_up_down.hide()
	

	var to_direction = in_sending_directions.front()

	
	sending_directions = in_sending_directions
	recieving_directions = in_recieving_directions
	
	for dir in sending_directions.duplicate():
		while sending_directions.count(dir) > 1:
			sending_directions.erase(dir)
	for dir in recieving_directions.duplicate():
		while recieving_directions.count(dir) > 1:
			recieving_directions.erase(dir)
	
	var adjacents = adjacent_tiles

	
	if to_direction and adjacents and adjacents[to_direction]: 
		if adjacents[to_direction].elements.is_empty():
			match to_direction:
				DIRECTION.NORTH:
					%arrow_north.show()
				DIRECTION.EAST:
					%arrow_east.show()
				DIRECTION.WEST:
					%arrow_west.show()
				DIRECTION.SOUTH:
					%arrow_south.show()
			
		for element in adjacents[to_direction].elements:
			if element is not Arrow or !element.recieving_directions.has(get_opposite_direction(to_direction)): 
					match to_direction:
						DIRECTION.NORTH:
							%arrow_north.show()
						DIRECTION.EAST:
							%arrow_east.show()
						DIRECTION.WEST:
							%arrow_west.show()
						DIRECTION.SOUTH:
							%arrow_south.show()


	if !parent_tile or self == parent_tile.elements.front():
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
	else:
		if to_direction in [DIRECTION.NORTH, DIRECTION.SOUTH]:
			%bridge_up_down.show()
		else:
			%bridge_left_right.show()
	


		
	
func can_change_sending_direction() -> bool:
	return true
		
