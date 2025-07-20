extends Element
class_name Target
@export var resource_counter : Label

var target_resource : GameResource
var counter : int = 0:
	set(value):
		counter = value
		resource_counter.text = str(value)
func _ready() -> void:
	#target_resource = load("res://scenes/game resources/diamond.tscn").instantiate()
	#add_child(target_resource)
	#target_resource.pivot_offset = target_resource.size/2
	#target_resource.scale *= 0.8
	#target_resource.set_colour(Color("#006FC1"))
	#target_resource.set_data("123")
	#target_resource.set_type(load("res://assets/graph_icon.png"))
	super()


func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	if !sending_element or !sending_resource:
		return false
	if !sending_resource.resource_equal_to(target_resource):
		return false
	return super(sending_element, sending_resource)

func activate_element():
	element_activating = true
	var all_resources = processed_resources + queued_resources
	if movement_tween.is_running():
		await movement_tween.finished
	if !all_resources.is_empty():
		for resource in all_resources:
			if !resource:
				continue
			if resource.resource_equal_to(target_resource):
				all_resources.pop_back().queue_free()
				processed_resources.erase(resource)
				queued_resources.erase(resource)
				all_resources.erase(resource)
				counter += 1
	element_activating = false
