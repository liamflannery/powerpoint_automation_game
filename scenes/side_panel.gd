extends PanelContainer

func _ready() -> void:
	show_child(0)
	for preview in %PreviewsParent.get_children():
		var button : Button = preview.get_child(0)
		button.pressed.connect(show_child.bind(preview.get_index()))
	add_to_group('sender_group')  # Enables access by other scenes
	
func hide_all_pages():
	for child in %PageParent.get_children():
		child.hide()
	for preview : TextureRect in %PreviewsParent.get_children():
		preview.texture = load("res://assets/slide_icon_side.png")
	
func show_child(index = 0):
	# Swaps slides
	if %PageParent.get_child_count() - 1 < index:
		return
	hide_all_pages()
	%PageParent.get_child(index).show()
	%PreviewsParent.get_child(index).texture = load("res://assets/slide_icon_side_highlighted.png")
	
