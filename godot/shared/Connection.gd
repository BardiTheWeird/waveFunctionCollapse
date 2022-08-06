class_name Connection

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT,
}

const direction_to_offset_dict = {
	Direction.UP: Vector2(0, -1),
	Direction.RIGHT: Vector2(1, 0),
	Direction.DOWN: Vector2(0, 1),
	Direction.LEFT: Vector2(-1, 0),
}

const ALL_DIRECTIONS = [
	Direction.UP,
	Direction.RIGHT,
	Direction.DOWN,
	Direction.LEFT,
]

const HORIZONTAL_DIRECTIONS = [
	Direction.RIGHT,
	Direction.LEFT,
]

const VERTICAL_DIRECTIONS = [
	Direction.UP,
	Direction.DOWN,
]

const flipped_directions_dict = {
	Direction.UP: Direction.DOWN,
	Direction.DOWN: Direction.UP,
	Direction.LEFT: Direction.RIGHT,
	Direction.RIGHT: Direction.LEFT,
}

static func get_direction_flipped(direction: int) -> int:
	return flipped_directions_dict[direction]

var key_center: String
var key_other: String
var directions: Array

func directions_to_offsets() -> Array:
	var offsets = []
	for direction in directions:
		offsets.append(direction_to_offset_dict[direction])

	return offsets

func flipped() -> Connection:
	var flipped_dicretions = []
	for direction in directions:
		flipped_dicretions.append(flipped_directions_dict[direction])
	return get_script().new(key_other, key_center, flipped_dicretions)

func _init(key_center_: String, key_other_: String, directions_: Array):
	key_center = key_center_
	key_other = key_other_
	directions = directions_
