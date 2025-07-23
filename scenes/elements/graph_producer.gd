extends Element
class_name Producer
@export var producing_resource : PackedScene
@export var resource_icon : TextureRect

func _ready() -> void:
	await super()
	set_element_texture()
	activate_element()

func set_element_texture():
	resource_icon.texture = producing_resource.instantiate().texture

func set_direction(in_sending_directions : Array[DIRECTION]= sending_directions, in_recieving_directions : Array[DIRECTION] = recieving_directions):
	set_connectors()

func activate_element():
	element_activating = true
	await get_tree().create_timer(1).timeout
	if !producing_resource: return
	if queued_resources.size() < max_queued_resources:
		var new_resource : GameResource = producing_resource.instantiate()
		add_child(new_resource)
		queued_resources.append(new_resource)
	super()

func _ready_to_activate() -> bool:
	return !element_activating and queued_resources.is_empty() and processed_resources.is_empty()

func get_save_dict() -> Dictionary:
	var save_dict = super()
	save_dict["producing_resource"] = producing_resource.resource_path
	return save_dict
func load_from_save_dict(dict : Dictionary):
	if dict.has("producing_resource"):
		producing_resource = load(dict["producing_resource"])
		set_element_texture()
	super(dict)
