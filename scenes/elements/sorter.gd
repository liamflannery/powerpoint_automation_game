extends Element
class_name Sorter

@export var resource_delete_button : Button
var to_sort : GameResource

func get_send_to() -> Array[Tile]:
	if !to_sort:
		return []
	if !to_sort.resource_equal_to(processed_resources.back()):
		return [adjacent_tiles[get_opposite_direction(recieving_directions[0])]]
	else:
		return [adjacent_tiles[get_clockwise_direction(get_opposite_direction(recieving_directions[0]))]]

func place_on_tile(tile: Tile) -> void:
	if to_sort:
		super(tile)
		return
	for element in tile.elements:
		if element is Arrow:
			for resource in element.processed_resources + element.queued_resources:
				set_to_sort(resource)
				break
	super(tile)

func activate_element():
	element_activating = true
	if !to_sort and !queued_resources.is_empty():
		var new_to_sort = queued_resources.pop_back()
		for tile in adjacent_tiles:
			if !tile: continue
			for element in tile.elements:
				if element.processed_resources.has(new_to_sort):
					element.processed_resources.erase(new_to_sort)
		if movement_tween: movement_tween.kill()
		set_to_sort(new_to_sort)
	
		for key in recieving_queue.keys():
			if recieving_queue[key] == to_sort:
				recieving_queue.erase(key)
				
		resource_sending = false
		
		element_activating = false
		super()
		return
	if to_sort: await get_tree().create_timer(0.1).timeout
	super()

func set_to_sort(with_resource : GameResource):
	to_sort = with_resource
	to_sort.reparent(self) if to_sort.is_inside_tree() else add_child(to_sort)
	to_sort.z_as_relative = true
	to_sort.z_index = 0
	move_child(resource_delete_button, -1)
	to_sort.position = %resource_icon_position.position - to_sort.size/2
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
	for resource in processed_resources:
		resource.queue_free()
	for resource in queued_resources:
		resource.queue_free()
	processed_resources.clear()
	queued_resources.clear()
	recieving_queue.clear()


func get_save_dict() -> Dictionary:
	var save_dict = super()
	save_dict["filtering_resource"] =[to_sort.scene_file_path, to_sort.get_save_dict()]
	return save_dict
func load_from_save_dict(dict : Dictionary):
	if dict.has("filtering_resource"):
		var new_to_sort = load(dict["filtering_resource"][0]).instantiate()
		set_to_sort(new_to_sort)
		new_to_sort.load_from_save_dict(dict["filtering_resource"][1])
	super(dict)
