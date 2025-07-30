extends PanelContainer
class_name MoveableWindows
@export var top_bar_button : Button
@export var tool_bar_button : Button
func _ready() -> void:
	if top_bar_button:
		top_bar_button.button_down.connect(started_hold)
		top_bar_button.button_up.connect(ended_hold)
	if tool_bar_button:
		tool_bar_button.button_pressed = visible
	tool_bar_button.toggled.connect(toggle_window)
var held : bool = false
var offset : Vector2
func started_hold():
	move_to_front()
	held = true
	offset = global_position - get_global_mouse_position()
func ended_hold():
	held = false

func _process(delta: float) -> void:
	if held:
		global_position = get_global_mouse_position() + offset

func toggle_window(value : bool):
	visible = value
	if tool_bar_button:
		tool_bar_button.set_pressed_no_signal(value)
	
func quit_button_pressed():
	toggle_window(false)
