extends Node

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

# change this to save under a different name
const SAVE_FILE_PATH = "res://JSON Files/Rooms/Room 4.json"

func _ready() -> void:
	save_tiles()
	
func save_tiles():
	var save_data = {}
	save_data["coords"] = []
	save_data["source_id"] = []
	save_data["atlas_coords"] = []
	var tiles = tile_map_layer.get_used_cells()
	
	for i in range(tiles.size()):
		#save_data["coords"].append(tiles[i])
		save_data["coords"] = [] + tiles
		save_data["source_id"].append(tile_map_layer.get_cell_source_id(tiles[i]))
		save_data["atlas_coords"].append(tile_map_layer.get_cell_atlas_coords(tiles[i]))
	
	# now to load into JSON
	var save_file = FileAccess.open(SAVE_FILE_PATH,FileAccess.WRITE)
	if save_file == null:
		print("error creating save file")
		return 1
	var json_string = JSON.stringify(save_data)
	save_file.store_string(json_string)
