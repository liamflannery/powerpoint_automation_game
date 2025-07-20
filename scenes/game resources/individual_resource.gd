extends GameResource
class_name IndividualResource


@export var this_type : RESOURCE_TYPE
@export var property_type : PROPERTY_TYPE
@export var content_type : CONTENT_TYPE
@export var transition_type : TRANSITION_TYPE
@export var content_parent : HBoxContainer
@export var resource_colour : Color = Color.WHITE 
var content : Array[CONTENT_TYPE]



func _ready() -> void:
	z_as_relative = false
	z_index = 1
	if content_parent:
		for child in content_parent.get_children():
			child.hide()

func _set_colour(this_colour : Color):
	resource_colour = this_colour
	self_modulate = this_colour


func _set_content(new_content : CONTENT_TYPE):
	content.append(new_content)
	var content_texture : Texture
	match new_content:
		CONTENT_TYPE.NUMBER:
			content_texture = load("res://assets/number_property_icon.png")
		CONTENT_TYPE.GRAPH:
			content_texture = load("res://assets/chart_icon.png")
		CONTENT_TYPE.TITLE:
			content_texture = load("res://assets/title_property_icon.png")
		CONTENT_TYPE.QUOTE:
			content_texture = load("res://assets/quote_icon.png")
	var content_image : TextureRect = content_parent.get_child(content.size() - 1)	
	content_image.show()
	content_image.texture = content_texture	
	
	if content.size() == 1:
		content_image.custom_minimum_size.x = 30
	else:
		for child in content_parent.get_children():
			child.custom_minimum_size.x = 20
	

func set_property(property : GameResource):
	match property.property_type:
		PROPERTY_TYPE.COLOUR:
			_set_colour(property.resource_colour)
		PROPERTY_TYPE.CONTENT:
			if content.size() < 2:
				_set_content(property.content_type)
			
			

func can_set_property(property : GameResource) -> bool:
	if property.this_type != RESOURCE_TYPE.PROPERTY:
		return false
	if property.property_type == PROPERTY_TYPE.CONTENT:
		if content.size() >= 2:
			return false
	return true
		

func resource_equal_to(target_resource : GameResource) -> bool:
	var content_passed : bool = true
	if !content_parent and !target_resource.content_parent:
		content_passed = true
	elif !content_parent:
		return false
	else:
		for i in content_parent.get_children().size():
			if !target_resource.content_parent:
				content_passed = false
				break
			if content_parent.get_children()[i].texture != target_resource.content_parent.get_children()[i].texture:
				content_passed = false
	var colour_passed : bool = target_resource.resource_colour == resource_colour
	var type_passed : bool = target_resource.this_type == this_type
	var property_type_passed : bool = target_resource.property_type == property_type
	var transition_type_passed : bool = target_resource.transition_type == transition_type
	var content_type_passed : bool = target_resource.content_type == content_type
	return content_passed and colour_passed and type_passed and property_type_passed and transition_type_passed and content_type_passed 
	
	
