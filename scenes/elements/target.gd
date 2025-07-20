extends Element
class_name Target
@export var resource_counter : Label

var target_resource : GameResource

func _ready() -> void:
	#target_resource = load("res://scenes/game resources/diamond.tscn").instantiate()
	#add_child(target_resource)
	#target_resource.pivot_offset = target_resource.size/2
	#target_resource.scale *= 0.8
	#target_resource.set_colour(Color("#006FC1"))
	#target_resource.set_data("123")
	#target_resource.set_type(load("res://assets/graph_icon.png"))
	super()




func activate_element():
	element_activating = true
	var all_resources = processed_resources + queued_resources
	if movement_tween.is_running():
		await movement_tween.finished
	if !all_resources.is_empty():
		for resource in all_resources:
			if !resource:
				continue
			all_resources.pop_back().queue_free()
			processed_resources.erase(resource)
			queued_resources.erase(resource)
			all_resources.erase(resource)
	element_activating = false
