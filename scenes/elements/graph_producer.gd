extends Element
class_name Producer
@export var producing_resource : PackedScene

func _ready() -> void:
	activate_element()

func activate_element():
	element_activating = true
	if !producing_resource: return
	if queued_resources.size() < max_resources_stored:
		var new_resource : GameResource = producing_resource.instantiate()
		add_child(new_resource)
		queued_resources.append(new_resource)
	super()

func _ready_to_activate() -> bool:
	return !element_activating and queued_resources.is_empty() and processed_resources.is_empty()
