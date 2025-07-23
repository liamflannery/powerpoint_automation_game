extends Node
var save_paths : Dictionary
var current_path : String :
	set(value):
		current_path = value
var current_save_name : String
signal loaded
var has_loaded = false
func _ready():
	if !DirAccess.dir_exists_absolute("user://saves/"):
		DirAccess.make_dir_absolute("user://saves/")
		
	var dir = DirAccess.open("user://saves/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name!= "":
			var save_name = get_path_save_name("user://saves/" + str(file_name))
			if save_name:
				save_paths[save_name] = "user://saves/" + str(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	SaveSystem._load_persistent()


func new_save(save_name : String, seed=""):
	create_new_save_file(save_name)
	SaveSystem.clear_all_data = true

func create_new_save_file(save_name : String):
	current_path =  SaveSystem.default_file_path
	current_save_name = save_name
	save_paths[save_name] = current_path
	


func get_persistent_path() -> String:
	return "user://persistent_save_data.save"
func get_current_save_name() -> String:
	if current_save_name == "":
		if save_paths.is_empty():
			#new_save("Untitled")
			return ""
		else:
			#set_current_path(save_paths.values()[0])
			return ""
	return current_save_name

func quit():
	get_tree().quit()

func get_current_path() -> String:
	return SaveSystem.default_file_path

func get_saves() -> Dictionary:
	return save_paths
	
func load_save():

	has_loaded = false
	#await SceneLoader.scene_loaded
	for node in get_tree().get_nodes_in_group("persist"):
		if node.has_method("load_node") and (node.get_parent() == node.get_tree().root and self != node.get_tree().current_scene):
			node.load_node()
	for node in get_tree().get_nodes_in_group("persist"):
		if node.has_method("load_node") and not (node.get_parent() == node.get_tree().root and self != node.get_tree().current_scene):
			await node.load_node()
	has_loaded = true
	loaded.emit()


func set_current_path(path : String):
	current_path = path
	current_save_name = get_path_save_name(current_path)

func delete_save(path : String):
	SaveSystem.delete(path)
	DirAccess.remove_absolute(path)
	save_paths.erase(save_paths.find_key(path))

func get_path_save_name(path : String) -> String:
	var path_name =  SaveSystem.get_var_from_save(path, "save_name")
	if path_name:
		return path_name
	return ""


func save_game(bypass_no_save=false):
	print("Saving...")
	for node in get_tree().get_nodes_in_group("persist"):
		if node.has_method("save"):
			node.save()
	if SaveSystem.save():
		print("Game Saved")
	else:
		print("Failed to save")
