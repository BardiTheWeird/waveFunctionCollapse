extends Control

enum State {
	Idle,
	Collapsing,
	ChoosingTileToInspect,
	InspectingTile,
	ChoosingTileToInspectConnections,
	InspectingTileConnections,
}

onready var tile_manager = $"/root/TileManager"
onready var map : Map = get_parent()
var state = State.Idle

var tile_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_StartCollapse_pressed():
	state = State.Collapsing
	map.initialize_collapse()

func _on_CollapseStep_pressed():
	map.collapse_step()

func _on_InspectTile_pressed():
	populate_tile_list()
	$TileList.show()
	state = State.ChoosingTileToInspect

func _on_InspectTileConnections_pressed():
	populate_tile_list()
	pass # Replace with function body.

func _on_TileList_item_selected(index):
	$TileList.hide()
	var tile_key: String = tile_list[index]
	if state == State.ChoosingTileToInspect:
		state = State.InspectingTile
		map.draw_single_tile(tile_key)
	elif state == State.ChoosingTileToInspectConnections:
		state = State.InspectingTileConnections
		map.draw_all_tile_connections(tile_key)


func populate_tile_list():
	$TileList.clear()
	tile_list = tile_manager.tile_spec_dict.keys()
	for key in tile_list:
		$TileList.add_item(key)
