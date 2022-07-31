extends Node

onready var tile_manager  = $"/root/TileManager"
onready var connection_manager = $"/root/ConnectionsManager"

export (Vector2) var map_size = Vector2(10, 5)
const tile_size = 1
var map = []

var tile_spec_arr = [
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
	Connection.new("upper_vertical", "empty", Connection.HORIZONTAL_DIRECTIONS + [Connection.Direction.DOWN]),
	Connection.new("lower_vertical", "empty", Connection.HORIZONTAL_DIRECTIONS + [Connection.Direction.UP]),
	Connection.new("left_horizontal_line", "empty", Connection.VERTICAL_DIRECTIONS + [Connection.Direction.RIGHT]),
	Connection.new("right_horizontal_line", "empty", Connection.VERTICAL_DIRECTIONS + [Connection.Direction.LEFT]),
	Connection.new("up_right_turn", "empty", [Connection.Direction.DOWN, Connection.Direction.LEFT]),
	Connection.new("up_left_turn", "empty", [Connection.Direction.DOWN, Connection.Direction.RIGHT]),
	Connection.new("down_right_turn", "empty", [Connection.Direction.UP, Connection.Direction.LEFT]),
	Connection.new("down_left_turn", "empty", [Connection.Direction.UP, Connection.Direction.RIGHT]),

	# center square
	Connection.new("vertical_line", "center_square", Connection.HORIZONTAL_DIRECTIONS),
	Connection.new("horizontal_line", "center_square", Connection.VERTICAL_DIRECTIONS),
	Connection.new("upper_vertical", "center_square", Connection.HORIZONTAL_DIRECTIONS + [Connection.Direction.DOWN]),
	Connection.new("lower_vertical", "center_square", Connection.HORIZONTAL_DIRECTIONS + [Connection.Direction.UP]),
	Connection.new("left_horizontal_line", "center_square", Connection.VERTICAL_DIRECTIONS + [Connection.Direction.RIGHT]),
	Connection.new("right_horizontal_line", "center_square", Connection.VERTICAL_DIRECTIONS + [Connection.Direction.LEFT]),
	Connection.new("up_right_turn", "center_square", [Connection.Direction.DOWN, Connection.Direction.LEFT]),
	Connection.new("up_left_turn", "center_square", [Connection.Direction.DOWN, Connection.Direction.RIGHT]),
	Connection.new("down_right_turn", "center_square", [Connection.Direction.UP, Connection.Direction.LEFT]),
	Connection.new("down_left_turn", "center_square", [Connection.Direction.UP, Connection.Direction.RIGHT]),

	# vertical_line
	Connection.new("upper_vertical", "vertical_line", [Connection.Direction.UP]),
	Connection.new("lower_vertical", "vertical_line", [Connection.Direction.DOWN]),
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
	for spec in tile_spec_arr:
		tile_manager.add_tile_spec(spec)

	initialize_map()
	fill_map()
	set_camera_to_map()

func map_to_world_coordinatesv(map_coordinates: Vector2) -> Vector3:
	return map_to_world_coordinates(map_coordinates.x, map_coordinates.y)

func map_to_world_coordinates(x: int, y: int) -> Vector3:
	return Vector3(x * tile_size, 0, y * tile_size)

func initialize_map():
	map.resize(map_size.x)
	for element in map:
		element = []
		element.resize(map_size.y)

func fill_map():
	var spec = tile_manager.tile_spec_dict["center_square"]
	for x in range(map_size.x):
		for y in range(map_size.y):
			spec = tile_spec_arr[(x+y) % tile_spec_arr.size()]
			var tile = tile_manager.create_tile(spec)
			tile.scale *= 0.95
			tile.translation = map_to_world_coordinates(x, y)
			add_child(tile)

func set_camera_to_map():
	$Camera.size = max(map_size.x, map_size.y) * 0.7
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
