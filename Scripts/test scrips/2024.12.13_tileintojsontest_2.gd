extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

@onready var savebutton: Button = $savebutton
@onready var loadbutton: Button = $loadbutton
@onready var randombutton: Button = $randombutton
@onready var resetbutton: Button = $resetbutton
@onready var clearbutton: Button = $clearbutton

const SAVE_FILE_PATH = "user://tile_test_save.json"


func _ready() -> void:
	savebutton.button_up.connect(save_tiles)
	loadbutton.button_up.connect(load_tiles)
	randombutton.button_up.connect(random_place_tiles)
	resetbutton.button_up.connect(reset_tiles)
	clearbutton.button_up.connect(clear_tiles)
	place_tiles()
	
# function to save tiles into a .JSON
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
	
# function to load tiles from the .JSON
func load_tiles():
	# straight up stealing this code lol
	# got a lot of info from MizizizizTutorials "How to save and load data in Godot 4"
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		print("save file not found")
		return
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var json_string = save_file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON parse error ", json.get_error_message(), " on line ", json.get_error_line())
		return
	var save_data = json.get_data()
	var coords_list = []
	var source_id_list = []
	var atlas_coords_list = []
	
	# add information from save_data into arrays after casting them to appropriate data type
	if "coords" in save_data:
		for item in range(save_data["coords"].size()):
			coords_list.append(string_to_vector2i(save_data["coords"][item]))
	if "source_id" in save_data:
		for item in range(save_data["source_id"].size()):
			source_id_list.append(int(save_data["source_id"][item]))
	if "atlas_coords" in save_data:
		for item in range(save_data["atlas_coords"].size()):
			atlas_coords_list.append(string_to_vector2i(save_data["atlas_coords"][item]))

	# now that information is loaded into variables, place them on screen
	tile_map_layer.clear()
	for i in range(coords_list.size()):
		tile_map_layer.set_cell(
			coords_list[i],
			source_id_list[i],
			atlas_coords_list[i]
		)
	
# function to place tiles from JSON somewhere randomly
func random_place_tiles():
	var random_range = Vector2i(randi_range(-32,32), randi_range(0, 10))
	place_tiles(random_range)
	
	
# function to reset tiles by erasing all and placing new ones, does not use JSON
func reset_tiles():
	tile_map_layer.clear()
	place_tiles()

# function to clear tiles, used by the clearbutton
func clear_tiles():
	tile_map_layer.clear()
	
# places tiles, is called by reset_tile and random_place_tiles
func place_tiles(vector=Vector2i(0,0)):
	var coords_list = [
		Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0),
		Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1),
		Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2),
		Vector2i(0,3), Vector2i(1,3), Vector2i(2,3), Vector2i(3,3)
	]
	var source_id = 0
	var atlas_coords_list = [
		Vector2i(0,4), Vector2i(1,4), Vector2i(1,4), Vector2i(2,4),
		Vector2i(0,5), Vector2i(1,5), Vector2i(1,5), Vector2i(2,5),
		Vector2i(0,5), Vector2i(1,5), Vector2i(1,5), Vector2i(2,5),
		Vector2i(0,6), Vector2i(1,6), Vector2i(1,6), Vector2i(2,6),
	]
	for i in range(16):
		tile_map_layer.set_cell(
			coords_list[i] + vector,
			source_id,
			atlas_coords_list[i]
		)

# function to turn strings from the JSON file into Vector2i's
func string_to_vector2i(string):
	# remove unnecessary parts of the string, cast values we want to ints, and return a Vector2i
	var parts = string.strip_edges().split(",")
	var x = int(parts[0])
	var y = int(parts[1])
	
	return Vector2i(x, y)


	
	
	
	
	
