extends TileMap

const unit_layer = 1
const unit_scene_collection = 1

# TODO: Move axis to constants
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

signal connection_created(is_enemy)

func instantiate_unit_at_tile_cell(unit_scene, tile_cell, is_enemy):
	var unit = unit_scene.instantiate()
	add_child(unit)
	
	set_cell(unit_layer, tile_cell, unit_scene_collection, Vector2i.ZERO, unit.get_index())
	unit.is_enemy = is_enemy
	unit.position = map_to_local(tile_cell)

func get_unit_at_tile_cell(tile_cell):
	if tile_cell not in get_used_cells(unit_layer):
		return null
	var child_index: int = get_cell_alternative_tile(unit_layer, tile_cell)
	return get_child(child_index)

func check_for_connections(unit_type, tile_cell, is_enemy):
	for axis in [x_axis, y_axis, diag1_axis, diag2_axis]:
		var units = get_same_units_on_axis(unit_type, tile_cell, axis)
		if len(units) >= 5:
			emit_signal("connection_created", is_enemy)
			return

func remove_unit(unit):
	erase_cell(unit_layer, unit["unit_cell"])
	remove_child(unit["unit_instance"])

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
	if cell in get_used_cells(unit_layer):
		return true
	return false

func are_close_enough(pos1, pos2, max_distance_px=40):
	return pos1.distance_squared_to(pos2) < max_distance_px
