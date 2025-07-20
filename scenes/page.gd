extends GridContainer
class_name Page

var sender_scene : PackedScene = load("res://scenes/elements/sender.tscn")

var next_page_sender : Sender
var previous_page_sender : Sender


func _ready() -> void:
	if get_previous_page():
		previous_page_sender = sender_scene.instantiate()
		get_child(get_child_count() - columns).add_child(previous_page_sender)
		previous_page_sender.set_parent_page(self)
	if get_next_page():
		next_page_sender = sender_scene.instantiate()
		next_page_sender.to_page = Sender.MODE.NEXT
		get_child(get_child_count() - 1).add_child(next_page_sender)
		next_page_sender.set_parent_page(self)

func set_next(new_next : Element): 
	next_page_sender = new_next
func set_previous(new_previous : Element): 
	previous_page_sender = new_previous
	
func get_next_page() -> Page:
	if self == get_parent().get_children().back():
		return null
	return get_parent().get_child(get_index() + 1)

func get_previous_page() -> Page:
	if self == get_parent().get_children().front():
		return null
	return get_parent().get_child(get_index() - 1)
