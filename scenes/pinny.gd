extends VBoxContainer
class_name Pinny

@export var left_button : Button
@export var center_button : Button
@export var right_button : Button
@export var diaglogue_box : Label


func _on_button_pressed() -> void:
	left_button.hide()
	right_button.hide()
	diaglogue_box.text = "Unlucky"
	await get_tree().create_timer(2).timeout
	hide()


func _on_button_2_pressed() -> void:
	left_button.hide()
	right_button.hide()
	diaglogue_box.text = "I guess Ill go kill myself then"
	await get_tree().create_timer(2).timeout
	hide()
