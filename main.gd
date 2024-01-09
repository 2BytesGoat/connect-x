extends Node2D

@export var tilemap: TileMap
const UnitScene = preload("res://unit.tscn")

var enemy_placed = true

func _input(event):
	if event.is_action_pressed("LeftMouse"):
		var mouse_pos = get_global_mouse_position()
		create_unit_at_position(mouse_pos, false)
	if event.is_action_pressed("RightMouse"):
		var mouse_pos = get_global_mouse_position()
		create_unit_at_position(mouse_pos, true)

func create_unit_at_position(target_position, is_enemy):
	# TODO: think of better way to differenciate
	var unit_type = "Enemy" if is_enemy else "Unit"
	
	var target_position_map_local = tilemap.to_local(target_position) + Vector2(1, 2)
	var tile_cell = tilemap.local_to_map(target_position_map_local)
	var tile_cell_map_local = tilemap.map_to_local(tile_cell)
	
	if not tilemap.are_close_enough(target_position_map_local, tile_cell_map_local) or \
		tilemap.is_cell_occupied_by_units(tile_cell):
		return
	
	var unit_scene = UnitScene
	tilemap.instantiate_unit_at_tile_cell(unit_scene, tile_cell, is_enemy)
	tilemap.check_for_connections(unit_type, tile_cell, is_enemy)

func _on_tile_map_connection_created(is_enemy):
	GameState.is_game_over = true
	%EndScreen.visible = true
	%WinnerLabel.text = "Winner Player " + ("2" if is_enemy else "1")

func _on_button_pressed():
	GameState.reset_game()
