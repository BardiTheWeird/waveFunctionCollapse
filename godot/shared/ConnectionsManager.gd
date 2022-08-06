extends Node

onready var texture_manager = $"/root/TextureManager"

# center_key -> [Connection]
var connections_dict = {}

func get_possible_connections_all_directions(key_center: String) -> Array:
	if not (key_center in connections_dict):
		return []
	return connections_dict[key_center]

func get_possible_connections(key_center: String, direction: int) -> Array:
	if not (key_center in connections_dict.keys()):
		return []
	var possible_connections = []
	for connection in connections_dict[key_center]:
		if direction in connection.directions:
			possible_connections.append(connection.key_other)
	return possible_connections

func add_connection(connection: Connection):
	if not (connection.key_center in connections_dict):
		connections_dict[connection.key_center] = [connection]
	else:
		connections_dict[connection.key_center].append(connection)

	if connection.key_center == connection.key_other:
		return

	connection = connection.flipped()	
	if not (connection.key_center in connections_dict):
		connections_dict[connection.key_center] = [connection]
	else:
		connections_dict[connection.key_center].append(connection)

func generate_connections(tile_specs: Array):
	for i in range(tile_specs.size()):
		var spec_center = tile_specs[i]
		var image_center : Image = texture_manager.generate_texture(spec_center).get_data()
		for j in range(i, tile_specs.size()):
			var spec_other = tile_specs[j]
			var image_other : Image = texture_manager.generate_texture(spec_other).get_data()

			var possible_directions = []
			for direction in Connection.ALL_DIRECTIONS:
				var image_side_center = get_image_side(image_center, direction)
				var image_side_other = get_image_side(image_other, Connection.get_direction_flipped(direction))

				if image_sides_equal(image_side_center, image_side_other):
					possible_directions.append(direction)

			if possible_directions.size() > 0:
				add_connection(Connection.new(spec_center.key, spec_other.key, possible_directions))


func get_image_side(image: Image, direction: int) -> Array:
	image.lock()
	
	var size = image.get_size()
	var side = []

	if direction in Connection.VERTICAL_DIRECTIONS:
		side.resize(size.x)
		var y_pos = 0
		if direction == Connection.Direction.DOWN:
			y_pos = size.y - 1
		for x in range(size.x):
			side[x] = image.get_pixel(x, y_pos)
	else:
		side.resize(size.y)
		var x_pos = 0
		if direction == Connection.Direction.RIGHT:
			x_pos = size.x - 1
		for y in range(size.y):
			side[y] = image.get_pixel(x_pos, y)
	
	image.unlock()
	return side

func image_sides_equal(side_a: Array, side_b: Array) -> bool:
	if side_a.size() != side_b.size():
		return false

	for i in range(side_a.size()):
		if side_a[i] != side_b[i]:
			return false

	return true
