extends Node

var min_connection = 5 # move this to constants
var is_game_over = false

func reset_game():
	is_game_over = false
	get_tree().reload_current_scene()
