extends Node
class_name Map

enum CollapseStepStatus {
	Ok,
	FellBack,
	Finished,
}

onready var tile_manager  = $"/root/TileManager"
onready var connection_manager = $"/root/ConnectionsManager"

export (Vector2) var map_size = Vector2(10, 5)
const tile_size = 1
var map = []
var collapse_map = []
class CollapseTile:
	var possible_tile_keys = {}

	func _init(possible_tile_keys_: Array):
		for key in possible_tile_keys_:
			possible_tile_keys[key] = true

var fallback_key = "filled"
var tile_spec_arr = [
	TileSpec.new(fallback_key, [ImagePixelFilter.AlwayTrue.new()], Color(50,0,0)),

	TileSpec.new("empty", []),

	TileSpec.new("center_square", [ImagePixelFilter.IsInCenterSquare.new()]),
	TileSpec.new("vertical_line", [ImagePixelFilter.IsOnVerticalLine.new()]),
	TileSpec.new("horizontal_line", [ImagePixelFilter.IsOnHorizontalLine.new()]),

	TileSpec.new("upper_vertical_line", [ImagePixelFilter.IsOnUpperVerticalLine.new()]),
	TileSpec.new("lower_vertical_line", [ImagePixelFilter.IsOnLoverVerticalLine.new()]),
	TileSpec.new("left_horizontal_line", [ImagePixelFilter.IsOnLeftHorizontalLine.new()]),
	TileSpec.new("right_horizontal_line", [ImagePixelFilter.IsOnRightHorizontalLine.new()]),

	TileSpec.new("cross", [ImagePixelFilter.IsOnVerticalLine.new(), ImagePixelFilter.IsOnHorizontalLine.new()]),
	TileSpec.new("up_right_turn", [ImagePixelFilter.IsOnUpperVerticalLine.new(), ImagePixelFilter.IsOnRightHorizontalLine.new()]),
	TileSpec.new("up_left_turn", [ImagePixelFilter.IsOnUpperVerticalLine.new(), ImagePixelFilter.IsOnLeftHorizontalLine.new()]),
	TileSpec.new("down_right_turn", [ImagePixelFilter.IsOnLoverVerticalLine.new(), ImagePixelFilter.IsOnRightHorizontalLine.new()]),
	TileSpec.new("down_left_turn", [ImagePixelFilter.IsOnLoverVerticalLine.new(), ImagePixelFilter.IsOnLeftHorizontalLine.new()]),
]

var tile_connections = [
	# empty
	Connection.new("center_square", "empty", Connection.ALL_DIRECTIONS),
	Connection.new("vertical_line", "empty", Connection.HORIZONTAL_DIRECTIONS),
	Connection.new("horizontal_line", "empty", Connection.VERTICAL_DIRECTIONS),
	Connection.new("upper_vertical_line", "empty", Connection.HORIZONTAL_DIRECTIONS + [Connection.Direction.DOWN]),
	Connection.new("lower_vertical_line", "empty", Connection.HORIZONTAL_DIRECTIONS + [Connection.Direction.UP]),
	Connection.new("left_horizontal_line", "empty", Connection.VERTICAL_DIRECTIONS + [Connection.Direction.RIGHT]),
	Connection.new("right_horizontal_line", "empty", Connection.VERTICAL_DIRECTIONS + [Connection.Direction.LEFT]),
	Connection.new("up_right_turn", "empty", [Connection.Direction.DOWN, Connection.Direction.LEFT]),
	Connection.new("up_left_turn", "empty", [Connection.Direction.DOWN, Connection.Direction.RIGHT]),
	Connection.new("down_right_turn", "empty", [Connection.Direction.UP, Connection.Direction.LEFT]),
	Connection.new("down_left_turn", "empty", [Connection.Direction.UP, Connection.Direction.RIGHT]),

	# center square
	Connection.new("vertical_line", "center_square", Connection.HORIZONTAL_DIRECTIONS),
	Connection.new("horizontal_line", "center_square", Connection.VERTICAL_DIRECTIONS),
	Connection.new("upper_vertical_line", "center_square", Connection.HORIZONTAL_DIRECTIONS + [Connection.Direction.DOWN]),
	Connection.new("lower_vertical_line", "center_square", Connection.HORIZONTAL_DIRECTIONS + [Connection.Direction.UP]),
	Connection.new("left_horizontal_line", "center_square", Connection.VERTICAL_DIRECTIONS + [Connection.Direction.RIGHT]),
	Connection.new("right_horizontal_line", "center_square", Connection.VERTICAL_DIRECTIONS + [Connection.Direction.LEFT]),
	Connection.new("up_right_turn", "center_square", [Connection.Direction.DOWN, Connection.Direction.LEFT]),
	Connection.new("up_left_turn", "center_square", [Connection.Direction.DOWN, Connection.Direction.RIGHT]),
	Connection.new("down_right_turn", "center_square", [Connection.Direction.UP, Connection.Direction.LEFT]),
	Connection.new("down_left_turn", "center_square", [Connection.Direction.UP, Connection.Direction.RIGHT]),

	# vertical_line
	Connection.new("upper_vertical_line", "vertical_line", [Connection.Direction.UP]),
	Connection.new("lower_vertical_line", "vertical_line", [Connection.Direction.DOWN]),
	Connection.new("cross", "vertical_line", Connection.VERTICAL_DIRECTIONS),
	Connection.new("up_right_turn", "vertical_line", [Connection.Direction.UP]),
	Connection.new("up_left_turn", "vertical_line", [Connection.Direction.UP]),
	Connection.new("down_right_turn", "vertical_line", [Connection.Direction.DOWN]),
	Connection.new("down_left_turn", "vertical_line", [Connection.Direction.DOWN]),

	# horizontal line
	Connection.new("left_horizontal_line", "horizontal_line", [Connection.Direction.LEFT]),
	Connection.new("right_horizontal_line", "horizontal_line", [Connection.Direction.RIGHT]),
	Connection.new("cross", "horizontal_line", Connection.HORIZONTAL_DIRECTIONS),
	Connection.new("up_right_turn", "horizontal_line", [Connection.Direction.RIGHT]),
	Connection.new("up_left_turn", "horizontal_line", [Connection.Direction.LEFT]),
	Connection.new("down_right_turn", "horizontal_line", [Connection.Direction.RIGHT]),
	Connection.new("down_left_turn", "horizontal_line", [Connection.Direction.LEFT]),

	# upper vertical
	Connection.new("lower_vertical_line", "upper_vertical_line", [Connection.Direction.DOWN]),
	Connection.new("cross", "upper_vertical_line", [Connection.Direction.DOWN]),
	Connection.new("down_right_turn", "upper_vertical_line", [Connection.Direction.DOWN]),
	Connection.new("down_left_turn", "upper_vertical_line", [Connection.Direction.DOWN]),

	# lower vertical
	Connection.new("cross", "lower_vertical_line", [Connection.Direction.UP]),
	Connection.new("up_right_turn", "lower_vertical_line", [Connection.Direction.UP]),
	Connection.new("up_left_turn", "lower_vertical_line", [Connection.Direction.UP]),

	# left horizontal
	Connection.new("right_horizontal_line", "left_horizontal_line", [Connection.Direction.RIGHT]),
	Connection.new("cross", "left_horizontal_line", [Connection.Direction.RIGHT]),
	Connection.new("up_right_turn", "left_horizontal_line", [Connection.Direction.RIGHT]),
	Connection.new("down_right_turn", "left_horizontal_line", [Connection.Direction.RIGHT]),

	# right_horizontal_line
	Connection.new("cross", "right_horizontal_line", [Connection.Direction.LEFT]),
	Connection.new("up_left_turn", "right_horizontal_line", [Connection.Direction.LEFT]),
	Connection.new("down_left_turn", "right_horizontal_line", [Connection.Direction.LEFT]),

	# cross
	Connection.new("up_right_turn", "cross", [Connection.Direction.UP, Connection.Direction.RIGHT]),
	Connection.new("up_left_turn", "cross", [Connection.Direction.UP, Connection.Direction.LEFT]),
	Connection.new("down_right_turn", "cross", [Connection.Direction.DOWN, Connection.Direction.RIGHT]),
	Connection.new("down_left_turn", "cross", [Connection.Direction.DOWN, Connection.Direction.LEFT]),

	# up_right_turn
	Connection.new("up_left_turn", "up_right_turn", [Connection.Direction.LEFT]),
	Connection.new("down_left_turn", "up_right_turn", [Connection.Direction.LEFT]),

	# up_left_turn
	Connection.new("down_right_turn", "up_left_turn", [Connection.Direction.RIGHT]),

	# down_right_turn
	Connection.new("down_left_turn", "down_right_turn", [Connection.Direction.LEFT]),
]

func _ready():
	randomize()
	for spec in tile_spec_arr:
		tile_manager.add_tile_spec(spec)
	# for connection in tile_connections:
	# 	connection_manager.add_connection(connection)
	connection_manager.generate_connections(tile_spec_arr)

func draw_single_tile(tile_key: String):
	initialize_map(Vector2(1,1))
	var tile = tile_manager.create_tile_from_key(tile_key)
	map[0][0] = tile
	add_child(tile)

	set_camera_to_map()

func draw_all_tile_connections(center_tile_key: String):
	var connections = connection_manager.get_possible_connections_all_directions(center_tile_key)
	var map_size = Vector2(connections.size()*3 + connections.size()-1, 3)
	initialize_map(map_size)

	var center_x = 1
	for connection in connections:
		var center_tile_coordinates = Vector2(center_x, 1)
		var center_tile = create_tile_at_map_coordinatesv(center_tile_key, center_tile_coordinates)
		center_tile.get_node("Mesh").get_surface_material(0).albedo_color = Color(100,0,0)
		add_child(center_tile)

		var connection_tile_key = connection.key_other
		for offset in connection.directions_to_offsets():
			var tile = create_tile_at_map_coordinatesv(connection_tile_key, center_tile_coordinates + offset)
			add_child(tile)

		center_x += 4

	set_camera_to_map()
		

func clear_map():
	for column in map:
		for tile in column:
			if tile:
				tile.queue_free()
	map = []

func map_to_world_coordinatesv(map_coordinates: Vector2) -> Vector3:
	return map_to_world_coordinates(map_coordinates.x, map_coordinates.y)

func map_to_world_coordinates(x: int, y: int) -> Vector3:
	return Vector3(x * tile_size, 0, y * tile_size)

func get_map_tilev(map: Array, coordinates: Vector2):
	if coordinates.x < 0 || map.size() <= coordinates.x:
		return null
		
	var column = map[coordinates.x]
	if coordinates.y < 0 || column.size() <= coordinates.y:
		return null

	return column[coordinates.y]

func set_map_tilev(map: Array, coordinates: Vector2, new_tile):
	map[coordinates.x][coordinates.y] = new_tile

func initialize_map(size = null):
	if size == null:
		size = map_size

	clear_map()
	map.resize(size.x)
	for x in map.size():
		map[x] = []
		map[x].resize(size.y)

func initialize_collapse():
	initialize_map()
	var tile_keys = tile_manager.tile_spec_dict.keys()

	collapse_map = []
	collapse_map.resize(map_size.x)
	for x in range(collapse_map.size()):
		collapse_map[x] = []
		collapse_map[x].resize(map_size.y)
		for y in range(collapse_map[x].size()):
			collapse_map[x][y] = CollapseTile.new(tile_keys)

	set_camera_to_map()
	
func play_out_collapse():
	$CollapseTimer.start()
	
func _on_CollapseTimer_timeout():
	var step_status = collapse_step()
	if step_status == CollapseStepStatus.Finished:
		$CollapseTimer.stop()

# return true if wave function collapse is done
func collapse_step() -> int:
	print_debug('starting debug step')
	var least_available_variations_tile_coordinates = null
	var least_available_variations_tile_variations = tile_manager.tile_spec_dict.size() + 1
	for x in range(collapse_map.size()):
		var column = collapse_map[x]
		for y in range(column.size()):
			var collapse_tile : CollapseTile = collapse_map[x][y]
			if collapse_tile == null:
				continue

			var available_variations = collapse_tile.possible_tile_keys.size()
			if available_variations < least_available_variations_tile_variations:
				least_available_variations_tile_coordinates = Vector2(x, y)
				least_available_variations_tile_variations = available_variations

	print_debug('finished looking into which tile has the smallest entropy')
	print_debug(least_available_variations_tile_coordinates)

	if least_available_variations_tile_coordinates == null:
		return CollapseStepStatus.Finished

	# collapse a tile
	var collapse_tile : CollapseTile = get_map_tilev(collapse_map, least_available_variations_tile_coordinates)
	var possible_key_amount = collapse_tile.possible_tile_keys.size()
	var collapsed_key: String = fallback_key
	var fell_back = true
	if collapse_tile.possible_tile_keys.size() > 0:
		collapsed_key = collapse_tile.possible_tile_keys.keys()[randi() % collapse_tile.possible_tile_keys.size()]
		fell_back = false

	var tile : Spatial = tile_manager.create_tile(tile_manager.tile_spec_dict[collapsed_key])
	set_map_tilev(map, least_available_variations_tile_coordinates, tile)
	set_map_tilev(collapse_map, least_available_variations_tile_coordinates, null)
	tile.translation = map_to_world_coordinatesv(least_available_variations_tile_coordinates)
	add_child(tile)
	print_debug('created and added a tile with key %s', collapsed_key)

	if fell_back:
		return CollapseStepStatus.FellBack

	# update adjacent collapse tiles
	var directions = Connection.ALL_DIRECTIONS
	var neighbour_tile_coordinates_directions = []
	for direction in directions:
		neighbour_tile_coordinates_directions.append(
			[
				least_available_variations_tile_coordinates + Connection.direction_to_offset_dict[direction],
				direction
			]
		)
	
	print_debug(neighbour_tile_coordinates_directions)

	for neighbour in neighbour_tile_coordinates_directions:
		update_tile_after_neighbour_collapse(neighbour[0], collapsed_key, neighbour[1])

	return CollapseStepStatus.Ok

func update_tile_after_neighbour_collapse(tile_coordinates: Vector2, collapsed_neighbour_key: String, direction_from_neighbour: int):
	var tile : CollapseTile = get_map_tilev(collapse_map, tile_coordinates)
	if not tile:
		return

	var possible_connections_from_neighbour = connection_manager.get_possible_connections(
		collapsed_neighbour_key, direction_from_neighbour)
		
	print_debug('lowering entropy for tile at %s' % str(tile_coordinates))
	print_debug('possible connections before: %s' % str(tile.possible_tile_keys))
	print_debug('possible connections to neighbour: %s' % str(possible_connections_from_neighbour))

	for connection in tile.possible_tile_keys.keys():
		if not (connection in possible_connections_from_neighbour):
			tile.possible_tile_keys.erase(connection)

func fill_map():
	var spec = tile_manager.tile_spec_dict["center_square"]
	for x in range(map_size.x):
		for y in range(map_size.y):
			spec = tile_spec_arr[(x+y) % tile_spec_arr.size()]
			var tile = tile_manager.create_tile(spec)
			tile.scale *= 0.95
			tile.translation = map_to_world_coordinates(x, y)
			map[x][y] = tile
			add_child(tile)

func set_camera_to_map():
	var map_size = Vector2(map.size(), 0)
	if map.size() > 0:
		map_size.y = map[0].size()

	$Camera.size = max(map_size.x, map_size.y)
	$Camera.translation.x = tile_size * (map_size.x - 1) / 2
	$Camera.translation.z = tile_size * (map_size.y - 1) / 2

func visualize_arr_of_all_tiles():
	var i = 0
	for spec in tile_manager.tile_spec_dict.values():
		var tile = tile_manager.create_tile(spec)
		tile.translation = Vector3(i, 0, 0)
		add_child(tile)
		i += 1
	
	var camera_size = i * 0.7
	$Camera.size = camera_size
	$Camera.translation.x = i / 2

func create_tile_at_map_coordinatesv(tile_key: String, map_coordinates: Vector2) -> Spatial:
	var tile = tile_manager.create_tile_from_key(tile_key)
	tile.translation = map_to_world_coordinatesv(map_coordinates)
	set_map_tilev(map, map_coordinates, tile)
	return tile
