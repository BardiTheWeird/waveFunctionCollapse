extends Node

# center_key -> [Connection]
var connections_dict = {}

func get_possible_connections(key_center: String, direction: int) -> Array:
	if not (key_center in connections_dict.keys()):
		return []
	var possible_connections = []
	for connection in connections_dict[key_center]:
		if direction in connection.directions:
			possible_connections.append(connection.key_other)
	return possible_connections

func add_connection(connection: Connection):
	connections_dict[connection.key_center] = connection
	connections_dict[connection.key_other] = connection.flipped()
