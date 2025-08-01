extends GridContainer
class_name Page

var sender_scene : PackedScene = load("res://scenes/elements/sender.tscn")

var next_page_sender : Sender
var next_page_reciever : Sender
var previous_page_sender : Sender
var previous_page_reciever : Sender
var sender_button_idx = 0

func call_show_page(index):
	# Access function to switch between slides
	get_tree().call_group('sender_group', 'show_child', index)

func _ready() -> void:
	if get_previous_page():
		# Previous Page Reciever (top left)
		previous_page_reciever = sender_scene.instantiate()
		previous_page_reciever.set_parent_page(self)
		previous_page_reciever.east_port = Element.PORT_STATUS.SENDING
		previous_page_reciever.south_port = Element.PORT_STATUS.SENDING
		previous_page_reciever.tile_text.text = "Recieve from previous slide"
		previous_page_reciever.tooltip_text = "Recieve resources from the previous slide"
		get_child(0).add_child(previous_page_reciever)
		# Connect button to slide panel change function
		previous_page_reciever.get_child(sender_button_idx).pressed.connect(call_show_page.bind(self.get_index()-1))

		# Previous Page Sender (top right)
		previous_page_sender = sender_scene.instantiate()
		previous_page_sender.set_parent_page(self)
		previous_page_sender.west_port = Element.PORT_STATUS.RECEIVING
		previous_page_sender.south_port = Element.PORT_STATUS.RECEIVING
		previous_page_sender.tile_text.text = "Send to previous slide"
		previous_page_sender.tooltip_text = "Send resources to the previous slide"
		get_child(columns - 1).add_child(previous_page_sender)
		# Connect button to slide panel change function
		previous_page_sender.get_child(sender_button_idx).pressed.connect(call_show_page.bind(self.get_index()-1))
		
	if get_next_page():
		# Next Page Sender (bottom left)
		next_page_sender = sender_scene.instantiate()
		next_page_sender.to_page = Sender.MODE.NEXT
		next_page_sender.set_parent_page(self)
		next_page_sender.north_port = Element.PORT_STATUS.RECEIVING
		next_page_sender.east_port = Element.PORT_STATUS.RECEIVING
		next_page_sender.tooltip_text = "Recieve resources from the next slide"
		next_page_sender.tile_text.text = "Send to next slide"
		get_child(get_child_count() - columns).add_child(next_page_sender)
		# Connect button to slide panel change function
		next_page_sender.get_child(sender_button_idx).pressed.connect(call_show_page.bind(self.get_index()+1))

		# Next Page Reciever (bottom right)
		next_page_reciever = sender_scene.instantiate()
		next_page_reciever.to_page = Sender.MODE.NEXT
		next_page_reciever.set_parent_page(self)
		next_page_reciever.west_port = Element.PORT_STATUS.SENDING
		next_page_reciever.north_port = Element.PORT_STATUS.SENDING
		next_page_reciever.tooltip_text = "Send resources to the next slide"
		next_page_reciever.tile_text.text = "Recieve from next slide"
		get_child(get_child_count() - 1).add_child(next_page_reciever)
		# Connect button to slide panel change function
		next_page_reciever.get_child(sender_button_idx).pressed.connect(call_show_page.bind(self.get_index()+1))

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
