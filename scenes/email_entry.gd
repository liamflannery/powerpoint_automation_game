extends PanelContainer
class_name EmailEntry
@export var this_button : Button
@export var text_parent : HBoxContainer
@export var from_text : Label
@export var subject_line : Label
@export var sent_time : Label
@export var open_close_icon : TextureRect
var selected : bool = false
func _ready() -> void:
	this_button.pressed.connect(email_selected)
	
var this_content : Main.Email
func set_content(content: Main.Email):
	from_text.text = content.from
	subject_line.text = content.subject_line
	sent_time.text = content.time
	this_content = content 

func email_selected():
	selected = true
	for child in get_parent().get_children():
		if child != self and child.has_method("email_unselected"):
			child.email_unselected()
	theme_type_variation = "HighlightedPanel"
	for child in text_parent.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", Color.WHITE)

func email_unselected():
	selected = false
	theme_type_variation = "InvisiblePanel"
	for child in text_parent.get_children():
		if child is Label:
			child.add_theme_color_override("font_color", Color.BLACK)

func _input(event: InputEvent) -> void:
	if !Stage.get_main():
		return
	if !Stage.get_main().is_window_focused(self):
		return
	if event is InputEventMouseButton:
		if event.double_click and selected:
			open_email()
	if Input.is_action_just_pressed("ui_up") and selected:
		await get_tree().create_timer(0.1).timeout
		get_parent().get_child(get_index() - 1).email_selected()
	if Input.is_action_just_pressed("ui_down") and selected:
		await get_tree().create_timer(0.1).timeout
		get_parent().get_child(get_index() + 1 if self != get_parent().get_children().back() else 0).email_selected()
	if Input.is_action_just_pressed("ui_accept") and selected:
		open_email()

var expanded_email : OpenEmail
func open_email():
	if expanded_email:
		expanded_email.show()
		expanded_email.move_to_front()
		return
	expanded_email = load("res://scenes/open_email.tscn").instantiate()
	Stage.get_main().add_child(expanded_email)
	expanded_email.set_content(this_content)
	expanded_email.global_position += Vector2(50,50)
	
