extends Node2D

@export var tilemap: TileMap
const PlayerScene = preload("res://unit.tscn")
const EnemyScene = preload("res://enemy_unit.tscn")

var player1_hp = 3
var player2_hp = 3

func _ready():
	update_player_hp_counter()

func _input(event):
	if event.is_action_pressed("LeftMouse"):
		var mouse_pos = get_global_mouse_position()
		create_unit_at_position(mouse_pos, PlayerScene)
	if event.is_action_pressed("RightMouse"):
		var mouse_pos = get_global_mouse_position()
		create_unit_at_position(mouse_pos, EnemyScene)

func create_unit_at_position(target_position, unit_scene):
	var target_position_map_local = tilemap.to_local(target_position) + Vector2(1, 2)
	var tile_cell = tilemap.local_to_map(target_position_map_local)
	var tile_cell_map_local = tilemap.map_to_local(tile_cell)
	
	if not tilemap.are_close_enough(target_position_map_local, tile_cell_map_local) or \
		tilemap.is_cell_occupied_by_units(tile_cell):
		return
	
	tilemap.instantiate_unit_at_tile_cell(unit_scene, tile_cell)

func _on_player_hp_0():
	GameState.is_game_over = true
	%EndScreen.visible = true
	%WinnerLabel.text = "Winner Player " + ("2" if player1_hp == 0 else "1")

func _on_tile_map_connection_created(unit_type):
	if unit_type == "Enemy":
		player1_hp -= 1
	else:
		player2_hp -= 1
	
	update_player_hp_counter()
	
	if player1_hp == 0 or player2_hp == 0:
		_on_player_hp_0()

func _on_button_pressed():
	GameState.reset_game()

func update_player_hp_counter():
	%Player1HPLabel.text = str(player1_hp)
	%Player2HPLabel.text = str(player2_hp)
