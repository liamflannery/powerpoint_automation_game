extends MoveableWindows
class_name EmailInbox

func recieve_email(mail : Main.Email):
	var new_entry : EmailEntry = load("res://scenes/email_entry.tscn").instantiate()
	new_entry.set_content(mail)
	%emails_parent.add_child(new_entry)
	%emails_parent.move_child(new_entry, 0)
	new_entry.mail_opened.connect(test_notification_icon)
	set_icons_to_notification()

func set_icons_to_notification():
	%mail_app_icon_window.texture = load("res://assets/mail_app_icon_notification.png")
	%email_app_toolbar_button.icon = load("res://assets/mail_app_icon_notification.png")

func set_icons_to_default():
	%mail_app_icon_window.texture = load("res://assets/mail_app_icon_no_notification.png")
	%email_app_toolbar_button.icon = load("res://assets/mail_app_icon_no_notification.png")

func test_notification_icon():
	for entry in %emails_parent.get_children():
		if !entry.opened:
			set_icons_to_notification()
			return
	set_icons_to_default()


func _on_target_button_pressed() -> void:
	if target_email:
		target_email.show()
	else:
		show()

var target_email : OpenEmail
func set_target_email(email : OpenEmail):
	target_email = email
