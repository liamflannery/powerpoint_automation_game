extends Node
signal main_registered
var main : Main

func register_main(value : Main):
	main = value
	main_registered.emit()

func get_main() -> Main:
	return main

signal mouse_entered_tile(tile : Tile)
signal mouse_exited_tile(tile : Tile)

func mouse_just_entered_tile(tile : Tile):
	mouse_entered_tile.emit(tile)
func mouse_just_exited_tile(tile : Tile):
	mouse_exited_tile.emit(tile)
