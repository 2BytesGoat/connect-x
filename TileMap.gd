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

var cell_contents = {}

signal connection_created(is_enemy)


func _ready():
	_on_viewport_size_changed()
	get_tree().root.connect("size_changed", _on_viewport_size_changed)

func _on_viewport_size_changed():
	var screen_size = get_viewport().size
	var map_size = get_used_rect().size * tile_set.tile_size
	position = (screen_size - map_size) / 2

func instantiate_unit_at_tile_cell(unit_scene, tile_cell):
	var unit = unit_scene.instantiate()
	add_child(unit)
	set_cell(unit_layer, tile_cell, unit_scene_collection, Vector2i.ZERO)
	
	cell_contents[tile_cell] = {
		"unit_id": unit.get_instance_id()
	}
	unit.position = map_to_local(tile_cell)
	
	var unit_type = unit.get_groups()[0]
	check_for_connections(unit_type, tile_cell)

func get_unit_at_tile_cell(tile_cell):
	if tile_cell not in cell_contents:
		return null
	var unit_id = cell_contents[tile_cell]["unit_id"]
	return instance_from_id(unit_id)

func check_for_connections(unit_type, tile_cell):
	for axis in [x_axis, y_axis, diag1_axis, diag2_axis]:
		var units = get_same_units_on_axis(unit_type, tile_cell, axis)
		if len(units) >= GameState.min_connection:
			remove_units(units)
			emit_signal("connection_created", unit_type)
			return

func remove_units(units):
	for unit in units:
		remove_unit(unit)

func remove_unit(unit):
	cell_contents.erase(unit["unit_cell"])
	erase_cell(unit_layer, unit["unit_cell"])
	unit["unit_instance"].celebrate()

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
	if unit_instance == null or not unit_instance.is_in_group(unit_type):
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
