extends GameResource
class_name IndividualResource


@export var this_type : RESOURCE_TYPE
@export var property_type : PROPERTY_TYPE
@export var content_type : CONTENT_TYPE
@export var transition_type : TRANSITION_TYPE
@export var content_parent : HBoxContainer
enum RESOURCE_COLOUR{WHITE, BLUE, PINK}
@export var resource_colour : RESOURCE_COLOUR 
var content : Array[CONTENT_TYPE]



func _ready() -> void:
	z_as_relative = false
	z_index = 1
	if content_parent:
		for child in content_parent.get_children():
			child.hide()

func _set_colour(this_colour : RESOURCE_COLOUR):
	resource_colour = this_colour
	match this_colour:
		RESOURCE_COLOUR.BLUE:
			self_modulate = Color("#64BDF0")
		RESOURCE_COLOUR.PINK:
			self_modulate = Color("#F0A8F0")


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
	if target_resource is not IndividualResource:
		return false
	var content_passed : bool = true
	if !content_parent and !target_resource.content_parent:
		content_passed = true
	elif !content_parent or !target_resource.content_parent:
		return false
	else:
		if content_parent.get_children().size() != target_resource.content_parent.get_children().size():
			content_passed = false
			return false
		if target_resource.content.size() != content.size():
			return false
		for i in content.size():
			if target_resource.content[i] != content[i]:
				return false
			
	var colour_passed : bool = target_resource.resource_colour == resource_colour
	var type_passed : bool = target_resource.this_type == this_type
	var property_type_passed : bool = target_resource.property_type == property_type
	var transition_type_passed : bool = target_resource.transition_type == transition_type
	var content_type_passed : bool = target_resource.content_type == content_type
	return content_passed and colour_passed and type_passed and property_type_passed and transition_type_passed and content_type_passed 

func get_save_dict() -> Dictionary:
	var save_dict = super()
	save_dict["this_type"] = this_type
	save_dict["property_type"] = property_type
	save_dict["this_colour"] = resource_colour
	save_dict["content_type"] = content_type
	save_dict["transition_type"] = transition_type
	save_dict["content"] = content
	return save_dict
func load_from_save_dict(dict : Dictionary):
	if dict.has("this_type"):
		this_type = int(dict["this_type"])
	if dict.has("property_type"):
		property_type = int(dict["property_type"])
	if dict.has("this_colour"):
		_set_colour(int(dict["this_colour"]))
	if dict.has("content_type"):
		content_type = int(dict["content_type"])
	if dict.has("transition_type"):
		transition_type = int(dict["transition_type"])
	if dict.has("content"):
		for i in dict.get("content"):
			_set_content(i)
	super(dict)
	
