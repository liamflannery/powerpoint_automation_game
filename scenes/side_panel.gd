extends PanelContainer

func _ready() -> void:
	show_child(0)
	for preview in %PreviewsParent.get_children():
		var button : Button = preview.get_child(0)
		button.pressed.connect(show_child.bind(preview.get_index()))


func hide_all_pages():
	for child in %PageParent.get_children():
		child.hide()
	for preview : PanelContainer in %PreviewsParent.get_children():
		preview.theme_type_variation = "Sheet"
	
func show_child(index = 0):
	if %PageParent.get_child_count() - 1 < index:
		return
	hide_all_pages()
	%PageParent.get_child(index).show()
	%PreviewsParent.get_child(index).theme_type_variation = "SheetHighlighted"
	
