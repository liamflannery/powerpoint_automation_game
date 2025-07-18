extends Control
class_name GameResource

@export var can_set_data : bool = true
@export var can_set_colour : bool = true
@export var can_set_type : bool = true

@export var shape : bool = false

@export var resource_colour : Color = Color.WHITE
@export var type_image : TextureRect
@export var data_label : Label
var this_type : Texture
@export var data : String

func _ready() -> void:
	set_colour(resource_colour)
	set_data(data)
	set_type(this_type)

func set_colour(colour : Color):
	if !can_set_colour: return
	self_modulate = colour
	resource_colour = colour

func set_type(new_type : Texture):
	if !can_set_type: return
	this_type = new_type
	if type_image: type_image.texture = this_type

func set_data(new_data : String):
	if !can_set_data: return
	data = new_data
	if data_label: data_label.text = data

func resource_equal_to(target_resource : GameResource) -> bool:
	return target_resource.resource_colour == resource_colour and target_resource.this_type == this_type and target_resource.data == data
