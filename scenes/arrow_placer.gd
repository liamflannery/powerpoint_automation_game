extends Button

func _pressed() -> void:
	Stage.get_main().arrow_placement_mode = !Stage.get_main().arrow_placement_mode
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Stage.get_main().arrow_placement_mode:
			Stage.get_main().arrow_placement_mode = false
	icon = load("res://assets/arrow_button_icon.png") if !Stage.get_main().arrow_placement_mode else load("res://assets/cross.png")
	disabled = Stage.get_main().movement_mode
