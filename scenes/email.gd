extends MoveableWindows
class_name EmailInbox

func recieve_email(mail : Main.Email):
	var new_entry : EmailEntry = load("res://scenes/email_entry.tscn").instantiate()
	new_entry.set_content(mail)
	%emails_parent.add_child(new_entry)
