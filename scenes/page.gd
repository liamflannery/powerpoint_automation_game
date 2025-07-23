extends GridContainer
class_name Page

var sender_scene : PackedScene = load("res://scenes/elements/sender.tscn")

var next_page_sender : Sender
var next_page_reciever : Sender
var previous_page_sender : Sender
var previous_page_reciever : Sender


func _ready() -> void:
	if get_previous_page():
		previous_page_sender = sender_scene.instantiate()
		previous_page_reciever = sender_scene.instantiate()
		previous_page_reciever.east_port = Element.PORT_STATUS.SENDING
		previous_page_sender.east_port = Element.PORT_STATUS.RECEIVING
		get_child(get_child_count() - columns).add_child(previous_page_sender)
		get_child(get_child_count() - columns * 2).add_child(previous_page_reciever)
		previous_page_sender.set_parent_page(self)
		previous_page_reciever.set_parent_page(self)
	if get_next_page():
		next_page_sender = sender_scene.instantiate()
		next_page_reciever = sender_scene.instantiate()
		next_page_sender.to_page = Sender.MODE.NEXT
		next_page_reciever = sender_scene.instantiate()
		next_page_reciever.to_page = Sender.MODE.NEXT
		next_page_reciever.west_port = Element.PORT_STATUS.SENDING
		next_page_sender.west_port = Element.PORT_STATUS.RECEIVING
		get_child(get_child_count() - 1).add_child(next_page_sender)
		get_child(get_child_count() - columns - 1).add_child(next_page_reciever)
		
		next_page_sender.set_parent_page(self)
		next_page_reciever.set_parent_page(self)

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
