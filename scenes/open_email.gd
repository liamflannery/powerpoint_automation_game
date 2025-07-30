extends MoveableWindows
class_name OpenEmail

@export var subject_line : Label
@export var from : Label
@export var time : Label
@export var to : Label
@export var accept_button : Button
@export var reject_button : Button
@export var intro : Label
@export var level_box : HBoxContainer
@export var sign_off : Label

var content : Main.Email
func set_content(this_content : Main.Email):
	content = this_content
	subject_line.text = this_content.subject_line
	from.text = this_content.from
	time.text = this_content.time
	to.text = "Liam Flannery"
	var level_target = Stage.get_main().get_target(this_content.difficulty_level)
	level_box.add_child(level_target)
	
	level_target.z_as_relative = true
	for child in level_target.get_children(true):
		child.z_as_relative = true


	


func _on_quit_button_pressed() -> void:
	hide()


func _on_accept_button_pressed() -> void:
	Stage.get_main().target = level_box.get_child(0)
	Stage.get_main().current_contract = content
	hide()
