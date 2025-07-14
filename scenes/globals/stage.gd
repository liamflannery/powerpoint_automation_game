extends Node
signal main_registered
var main : Main

func register_main(value : Main):
	main = value
	main_registered.emit()

func get_main() -> Main:
	return main
