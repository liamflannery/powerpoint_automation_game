extends Element
class_name Sender

enum MODE{PREVIOUS, NEXT}
@export var to_page : MODE
var parent_page : Page
@export var tile_text : Label

## var slide_change_button = Button.new()


func set_parent_page(this_page : Page):
	if to_page == MODE.PREVIOUS:
		texture_rect.texture = load("res://assets/previous_slide.png")
		parent_page = this_page
	else:
		texture_rect.texture = load("res://assets/next_slide.png")
		parent_page = this_page

func send_resource(sent_resource : GameResource, sending_element : Element):
	if sending_element is Sender:
		resource_sending = true
		if movement_tween and movement_tween.is_running():
			movement_tween.kill()
		sent_resource.reparent(self)
		sent_resource.global_position = global_position + size/2 - sent_resource.size/2
		queued_resources.append(sent_resource)
		resource_sending = false
	else:
		await super(sent_resource, sending_element)

func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	return queued_resources.size() < max_queued_resources and processed_resources.size() < max_processed_resources

func get_send_to() -> Array[Tile]:
	var normal_send_to : Array[Tile] = super()
	if to_page == MODE.PREVIOUS and !recieving_directions.is_empty():
		if parent_page.get_previous_page():
			normal_send_to.append_array([parent_page.get_previous_page().next_page_reciever.parent_tile])
	if to_page == MODE.NEXT and !recieving_directions.is_empty():
		if parent_page.get_next_page():
			normal_send_to.append_array([parent_page.get_next_page().previous_page_reciever.parent_tile])
	return normal_send_to

func get_save_dict() -> Dictionary:
	var save_dict = super()
	save_dict["to_page"] = to_page
	return save_dict

func load_from_save_dict(dict : Dictionary):
	if dict.has("to_page"):
		to_page = int(dict["to_page"])
		_ready()
		set_parent_page(Stage.get_main().get_page(parent_tile))
	super(dict)
