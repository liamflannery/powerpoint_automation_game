extends Element
class_name Sorter

@export var resource_delete_button : Button
var to_sort : GameResource

func get_send_to() -> Array[Tile]:
	if !to_sort:
		to_sort = processed_resources.pop_back()
		to_sort.reparent(self)
		to_sort.z_as_relative = true
		to_sort.z_index = 0
		move_child(resource_delete_button, -1)
		movement_tween.kill()
		resource_sending = false
		to_sort.position = %resource_icon_position.position - to_sort.size/2
		return []
	if !to_sort.resource_equal_to(processed_resources.back()):
		return [adjacent_tiles[get_opposite_direction(recieving_directions[0])]]
	else:
		return [adjacent_tiles[get_clockwise_direction(get_opposite_direction(recieving_directions[0]))]]

func activate_element():
	element_activating = true
	await get_tree().create_timer(2).timeout
	super()

func _show_delete_button():
	super()
	if to_sort and !Stage.get_main().arrow_placement_mode:
		resource_delete_button.show()

func _hide_delete_button():
	super()
	if !resource_delete_button.get_global_rect().has_point(get_global_mouse_position()):
		resource_delete_button.hide()


func _on_resource_delete_button_pressed() -> void:
	if to_sort:
		to_sort.queue_free()
		to_sort = null

func _ready_to_activate() -> bool:
	return super()

func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	return super(sending_element, sending_resource)
