extends Node2D

@export var tilemap: TileMap

const UnitScene = preload("res://unit.tscn")
const unit_layer = 1
const unit_scene_collection = 1

const x_axis = {
	"N": Vector2i.UP,
	"S": Vector2i.DOWN
}
const y_axis = {
	"E": Vector2i.LEFT,
	"W": Vector2i.RIGHT
}

const diag1_axis = {
	"NW": Vector2i(-1, -1),
	"SE": Vector2i(1, 1)
}

const diag2_axis = {
	"NE": Vector2i(1, -1),
	"SW": Vector2i(-1, 1)
}

func _input(event):
	if event.is_action_pressed("LeftMouse"):
		var mouse_pos = get_global_mouse_position()
		create_unit_at_position(mouse_pos)

func create_unit_at_position(target_position):
	var target_position_map_local = tilemap.to_local(target_position) + Vector2(1, 2)
	var tile_cell = tilemap.local_to_map(target_position_map_local)
	
	var tile_cell_map_local = tilemap.map_to_local(tile_cell)
	
	if not are_close_enough(target_position_map_local, tile_cell_map_local) or \
		is_cell_occupied_by_units(tile_cell):
		return
	
	var unit_scene = UnitScene
	var unit_type = "Unit"
	instantiate_unit_at_tile_cell(unit_scene, tile_cell)
	check_for_connections(unit_type, tile_cell)

func instantiate_unit_at_tile_cell(unit_scene, tile_cell):
	var unit = unit_scene.instantiate()
	tilemap.add_child(unit)
	
	tilemap.set_cell(unit_layer, tile_cell, unit_scene_collection, Vector2i.ZERO, unit.get_index())
	unit.position = tilemap.map_to_local(tile_cell)

func get_unit_at_tile_cell(tile_cell):
	if tile_cell not in tilemap.get_used_cells(unit_layer):
		return null
	var child_index: int = tilemap.get_cell_alternative_tile(unit_layer, tile_cell)
	return tilemap.get_child(child_index)

func check_for_connections(unit_type, tile_cell):
	for axis in [x_axis, y_axis]:
		var units = get_same_units_on_axis(unit_type, tile_cell, axis)
		if len(units) >= 4:
			for unit in units:
				tilemap.erase_cell(unit_layer, unit["unit_cell"])
				tilemap.remove_child(unit["unit_instance"])
			return

func get_same_units_on_axis(unit_type, unit_cell, axis):
	var same_units = [{
		"unit_cell": unit_cell, 
		"unit_instance": get_unit_at_tile_cell(unit_cell)
	}]
	
	for i in axis:
		var direction = axis[i]
		var units = get_same_uits_in_direction(unit_type, unit_cell + direction, direction)
		same_units += units
	return same_units

func get_same_uits_in_direction(unit_type, unit_cell, direction):
	var unit_instance = get_unit_at_tile_cell(unit_cell)
	if unit_instance == null:
		return []
	
	var same_units = [{
		"unit_cell": unit_cell, 
		"unit_instance": unit_instance
	}]
	
	var neighbour_cell = unit_cell + direction
	var neighbour_instance = get_unit_at_tile_cell(neighbour_cell)
	if neighbour_instance != null and neighbour_instance.is_in_group(unit_type):
		return same_units + get_same_uits_in_direction(unit_type, neighbour_cell, direction)
	return same_units

func is_cell_occupied_by_units(cell):
	if cell in tilemap.get_used_cells(unit_layer):
		return true
	return false

func are_close_enough(pos1, pos2, max_distance_px=40):
	return pos1.distance_squared_to(pos2) < max_distance_px
