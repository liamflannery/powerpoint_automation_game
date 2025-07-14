extends Element
class_name Arrow

@export_category("Resources")
@export var up_down_texture : Texture2D
@export var left_right_texture : Texture2D



func _ready() -> void:
	set_direction(facing_direction)

func set_direction(value : DIRECTION):
	facing_direction = value
	match facing_direction:
		DIRECTION.NORTH, DIRECTION.SOUTH:
			texture_rect.texture = up_down_texture
		DIRECTION.EAST, DIRECTION.WEST:
			texture_rect.texture = left_right_texture
