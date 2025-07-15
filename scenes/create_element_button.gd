extends Button

@export var element_scene : PackedScene

func _pressed() -> void:
	if !element_scene:
		return
	var element : Element = element_scene.instantiate()
	Stage.get_main().add_child(element)
	disabled = true
	await element.placed
	disabled = false
	#_pressed()
