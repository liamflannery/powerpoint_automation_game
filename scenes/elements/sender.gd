extends Element
class_name Sender
@export var connected_sender : Sender


func can_recieve_resource(sending_element : Element, sending_resource : GameResource=null) -> bool:
	return queued_resources.size() < max_resources_stored and processed_resources.size() < max_resources_stored

func get_send_to() -> Array[Tile]:
	if !connected_sender:
		return super()
	return [connected_sender.parent_tile]
