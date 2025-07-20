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

	var to_direction = in_sending_directions.front()

	
	sending_directions = in_sending_directions
	recieving_directions = in_recieving_directions
	var adjacents = adjacent_tiles

	
	if to_direction and adjacents and adjacents[to_direction]: 
		if adjacents[to_direction].element is not Arrow or !adjacents[to_direction].element.recieving_directions.has(get_opposite_direction(to_direction)): 
				match to_direction:
					DIRECTION.NORTH:
						%arrow_north.show()
					DIRECTION.EAST:
						%arrow_east.show()
					DIRECTION.WEST:
						%arrow_west.show()
					DIRECTION.SOUTH:
						%arrow_south.show()



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
	


		
	
func can_change_sending_direction() -> bool:
	return true
		
