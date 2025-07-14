extends Control
class_name Element

enum DIRECTION{
	NORTH,
	EAST,
	SOUTH,
	WEST
}

@export_category("Objects")
@export var texture_rect : TextureRect
@export_category("Variables")
@export var facing_direction : DIRECTION
