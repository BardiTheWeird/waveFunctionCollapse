class_name Connection

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT,
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

var flipped_directions_dict = {
	Direction.UP: Direction.DOWN,
	Direction.DOWN: Direction.UP,
	Direction.LEFT: Direction.RIGHT,
	Direction.RIGHT: Direction.LEFT,
}

var key_center: String
var key_other: String
var directions: Array

func flipped() -> Connection:
	var flipped_dicretions = []
	for direction in directions:
		flipped_dicretions.append(flipped_directions_dict[direction])
	return get_script().new(key_other, key_center, flipped_dicretions)

func _init(key_center_: String, key_other_: String, directions_: Array):
	key_center = key_center_
	key_other = key_other_
	directions = directions_
