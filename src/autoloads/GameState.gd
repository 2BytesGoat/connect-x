extends Node

var is_game_over = false

func reset_game():
	is_game_over = false
	get_tree().reload_current_scene()
