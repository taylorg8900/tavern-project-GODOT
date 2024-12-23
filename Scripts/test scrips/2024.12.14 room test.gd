extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

@onready var room_1_button: Button = $Buttons/room1button
@onready var room_2_button: Button = $Buttons/room2button
@onready var room_3_button: Button = $Buttons/room3button
@onready var resetbutton: Button = $Buttons/resetbutton

const FIRST_ROOM_PATH = "res://JSON Files/Rooms/First Room.json"
const SECOND_ROOM_PATH = "res://JSON Files/Rooms/Second Room.json"
const THIRD_ROOM_PATH = "res://JSON Files/Rooms/Third Room.json"

const UP_TILE = Vector2i(3,2)
const RIGHT_TILE = Vector2i(4,2)
const DOWN_TILE = Vector2i(5,2)
const LEFT_TILE = Vector2i(6,2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetbutton.button_up.connect(reset_tiles)
	
	var first_room_save_data = get_room_info(FIRST_ROOM_PATH)
	var second_room_save_data = get_room_info(SECOND_ROOM_PATH)
	var third_room_save_data = get_room_info(THIRD_ROOM_PATH)
	
	#place_room(first_room_save_data)
	
	var top_right = place_room(first_room_save_data)
	print(top_right)
	top_right = place_room(second_room_save_data, top_right)
	print(top_right)
	top_right = place_room(third_room_save_data, top_right)
	print(top_right)
	
	
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
	
	
# gets a JSON file, and uses json.get_data() to return to us a useful variable that we can use later
func get_room_info(file_path):
	if !FileAccess.file_exists(file_path):
		print("save file not found")
		return
	var save_file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = save_file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON parse error ", json.get_error_message(), " on line ", json.get_error_line())
		return
	return(json.get_data())

func reset_tiles():
	tile_map_layer.clear()

# function to place a room, and return the 'top right corner' coords of said room's position in the scene
func place_room(room_save_data, coord_amount=Vector2i(0,0)):
	var coords_list = []
	var source_id_list = []
	var atlas_coords_list = []
	var top_right_coords = Vector2i(0,9999) # this is probably stupid, but will work for our purposes here in finding the smallest Y value and largest X value in the coords
	
	# add information from save_data into arrays after casting them to appropriate data type
	if "coords" in room_save_data:
		for item in range(room_save_data["coords"].size()):
			coords_list.append(string_to_vector2i(room_save_data["coords"][item]) + coord_amount)
	if "source_id" in room_save_data:
		for item in range(room_save_data["source_id"].size()):
			source_id_list.append(int(room_save_data["source_id"][item]))
	if "atlas_coords" in room_save_data:
		for item in range(room_save_data["atlas_coords"].size()):
			atlas_coords_list.append(string_to_vector2i(room_save_data["atlas_coords"][item]))
	
	# places our tiles
	for i in range(coords_list.size()):
		tile_map_layer.set_cell(
			coords_list[i],
			source_id_list[i],
			atlas_coords_list[i]
		)
	
	# finds our 'top right coord' by finding smallest Y component and largest X component in our coords list
	for coords in coords_list:
		if coords[0] > top_right_coords[0]:
			top_right_coords[0] = coords[0]
		if coords[1] < top_right_coords[1]:
			top_right_coords[1] = coords[1]
	print("top right coords: ",top_right_coords)
	return top_right_coords + Vector2i(1,0) # so next room doesn't overlap it, can make (2,0) to see gap between rooms 
	
# function to turn information from JSON format into a Vector2i variable
func string_to_vector2i(string):
	# remove unnecessary parts of the string, cast values we want to ints, and return a Vector2i
	var parts = string.strip_edges().split(",")
	var x = int(parts[0])
	var y = int(parts[1])
	
	return Vector2i(x, y)
