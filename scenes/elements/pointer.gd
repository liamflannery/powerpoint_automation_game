extends Element
class_name Pointer


#func get_send_to() -> Array[Tile]:
	#var normal_send_to = super()
	#for i in processed_resources.size():
		#if !is_instance_valid(processed_resources[i]):
			#processed_resources.remove_at(i)
	#if processed_resources.is_empty():
		#return []
	#if normal_send_to.has(adjacent_tiles[0]) and adjacent_tiles[0].elements[0].can_recieve_resource(self, processed_resources.back()):
		#return [adjacent_tiles[0]]
	#return super()
