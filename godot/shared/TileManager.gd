extends Node

onready var texture_manager = get_node("/root/TextureManager")
onready var tile_prefab = Prefab.create($Tile)

var tile_spec_dict = {}

func add_tile_spec(tile_spec: TileSpec):
	tile_spec_dict[tile_spec.key] = tile_spec

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func create_tile(spec: TileSpec) -> Spatial:
	var tile : Spatial = tile_prefab.instance()
	var mesh : MeshInstance = tile.get_node("Mesh")
	var material : SpatialMaterial = mesh.get_surface_material(0).duplicate()
	material.albedo_texture = texture_manager.generate_texture(spec)
	mesh.set_surface_material(0, material)

	return tile
