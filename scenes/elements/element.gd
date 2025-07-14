extends Control
class_name Element

@export var max_resources_stored : int = 1
var resources : Array[GameResource]

enum DIRECTION{
	NORTH,
	EAST,
	SOUTH,
	WEST
}

@export_category("Objects")
@export var texture_rect : TextureRect
@export_category("Variables")
@export var sending_directions : Array[DIRECTION]
@export var recieving_directions : Array[DIRECTION]

@export_category("Resources")
@export var north_facing_texture : Texture2D
@export var east_facing_texture : Texture2D
@export var south_facing_texture : Texture2D
@export var west_facing_texture : Texture2D

var parent_tile : Tile
var adjacent_tiles : Array[Tile]

func _ready() -> void:
	set_direction(sending_directions)

func set_direction(value : Array[DIRECTION]):
	sending_directions = value
	if sending_directions.is_empty():
		return
	match sending_directions[0]:
		DIRECTION.NORTH: 
			texture_rect.texture = north_facing_texture
		DIRECTION.EAST:
			texture_rect.texture = east_facing_texture
		DIRECTION.SOUTH:
			texture_rect.texture = south_facing_texture
		DIRECTION.WEST:
			texture_rect.texture = west_facing_texture

func element_placed(on_tile : Tile):
	parent_tile = on_tile
	adjacent_tiles = Stage.get_main().get_adjacent_tiles(parent_tile)

func activate_element():
	var send_to : Array[Tile]
	for facing_direction in sending_directions:
		match facing_direction:
			DIRECTION.NORTH:
				if adjacent_tiles[0] and adjacent_tiles[0].element:
					send_to.append(adjacent_tiles[0])
			DIRECTION.EAST:
				if adjacent_tiles[1] and adjacent_tiles[1].element:
					send_to.append(adjacent_tiles[1])
			DIRECTION.SOUTH:
				if adjacent_tiles[2] and adjacent_tiles[2].element:
					send_to.append(adjacent_tiles[2])
			DIRECTION.WEST:
				if adjacent_tiles[3] and adjacent_tiles[3].element:
					send_to.append(adjacent_tiles[3])
	for tile in send_to:
		if tile and tile.element and tile.element.can_recieve_resource(self) and !resources.is_empty():
			tile.element.send_resource(resources.pop_back())


func send_resource(sent_resource : GameResource):
	var movement_tween : Tween
	sent_resource.reparent(self)
	resources.append(sent_resource)
	movement_tween = create_tween()
	movement_tween.tween_property(sent_resource, "global_position", global_position + size/2, 0.3)

func can_recieve_resource(sending_element : Element) -> bool:
	var direction_correct = false
	for direction in recieving_directions:
		if sending_element.sending_directions.map(func(dir): return get_opposite_direction(dir)).has(direction):
			direction_correct = true
	return resources.size() < max_resources_stored and direction_correct


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
