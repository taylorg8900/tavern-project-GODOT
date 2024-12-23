extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer

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
	
	
	var dict = place_room2(second_room_save_data, RIGHT_TILE)
	var offset = find_room_offset(second_room_save_data,LEFT_TILE,dict["right"])
	dict = place_room2(second_room_save_data,RIGHT_TILE, offset)
	offset = find_room_offset(second_room_save_data, LEFT_TILE, dict["right"])
	dict = place_room2(second_room_save_data,RIGHT_TILE,offset)
	offset = find_room_offset(second_room_save_data, LEFT_TILE, dict["right"])
	dict = place_room2(second_room_save_data,RIGHT_TILE, offset)
	
	


# gets a JSON file, and uses json.get_data() to return to us a useful dictionary that represents what was in the JSON file
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
	
	# add information from save_data into arrays after casting them to appropriate data type (using functions to keep it compact)
	var coords_list = return_room_coords_list(room_save_data, coord_amount)
	var source_id_list = return_rooms_source_id_list(room_save_data)
	var atlas_coords_list = return_rooms_atlas_coords_list(room_save_data)
	
	# places our tiles
	for i in range(coords_list.size()):
		tile_map_layer.set_cell(
			coords_list[i],
			source_id_list[i],
			atlas_coords_list[i]
		)
	
	# finds our 'top right coord' by finding smallest Y component and largest X component in our coords list
	var top_right_coords = Vector2i(0,9999) # this is probably stupid, but will work for our purposes here in finding the smallest Y value and largest X value in the coords
	for coords in coords_list:
		if coords[0] > top_right_coords[0]:
			top_right_coords[0] = coords[0]
		if coords[1] < top_right_coords[1]:
			top_right_coords[1] = coords[1]
	#print("top right coords: ",top_right_coords)
	return top_right_coords + Vector2i(1,0) # so next room doesn't overlap it, can make (2,0) to see gap between rooms 
	
func place_room2(room_save_data, direction_tile, offset=Vector2i(0,0)):
	var coords_list = return_room_coords_list(room_save_data, offset)
	var source_id_list = return_rooms_source_id_list(room_save_data)
	var atlas_coords_list = return_rooms_atlas_coords_list(room_save_data)
	
	# places our tiles
	for i in range(coords_list.size()):
		if not is_directional_tile(atlas_coords_list[i]):
			tile_map_layer.set_cell(
				coords_list[i],
				source_id_list[i],
				atlas_coords_list[i]
			)
	# create an object to return, which contains coordinates of paths not currently used (i.e. all paths that aren't the ones matching 'direction_tile')
	# TODO: make this so it only returns coordinates which aren't 'connected' to the previous room
	var dict = {}
	
	dict["right"] = find_target_coords(room_save_data,RIGHT_TILE,offset)
	dict["up"] = find_target_coords(room_save_data,UP_TILE,offset)
	dict["down"] = find_target_coords(room_save_data,DOWN_TILE,offset)
	dict["left"] = find_target_coords(room_save_data,LEFT_TILE,offset)
	
	return dict
	
		
	
		
# group of functions that go through the save data and return lists of coords, source_ids, and atlas coords, and a bool to check for directional tiles (for in the set_cell method only)
func return_room_coords_list(room_save_data, offset=Vector2i(0,0)):
	var coords_list = []
	if "coords" in room_save_data:
		for item in range(room_save_data["coords"].size()):
			coords_list.append(string_to_vector2i(room_save_data["coords"][item]) + offset)
	return coords_list
func return_rooms_source_id_list(room_save_data):
	var source_id_list = []
	if "source_id" in room_save_data:
		for item in range(room_save_data["source_id"].size()):
			source_id_list.append(int(room_save_data["source_id"][item]))
	return source_id_list
func return_rooms_atlas_coords_list(room_save_data):
	var atlas_coords_list = []
	if "atlas_coords" in room_save_data:
		for item in range(room_save_data["atlas_coords"].size()):
			atlas_coords_list.append(string_to_vector2i(room_save_data["atlas_coords"][item]))
	return atlas_coords_list
func is_directional_tile(variable):
	var bingbong = variable==DOWN_TILE or variable==UP_TILE or variable==LEFT_TILE or variable==RIGHT_TILE
	return bingbong
# function to turn information from JSON format into a Vector2i variable
func string_to_vector2i(string):
	# remove unnecessary parts of the string, cast values we want to ints, and return a Vector2i
	var parts = string.strip_edges().split(",")
	var x = int(parts[0])
	var y = int(parts[1])
	
	return Vector2i(x, y)

# returns a list of coordinates representing our direction tiles, and the direction_tile is defined as one of (up, right, down, left) as per global consts above
func find_path_tiles_coords(room_save_data, direction_tile, offset=Vector2i(0,0)):
	# finds tiles with the atlas coordinates of our 'direction_tile', and adds them to a list which is returned
	var direction_tile_coords = []
	if "atlas_coords" in room_save_data and "coords" in room_save_data:
		for item in range(room_save_data["atlas_coords"].size()):
			if string_to_vector2i(room_save_data["atlas_coords"][item]) == direction_tile:
				direction_tile_coords.append(string_to_vector2i(room_save_data["coords"][item]) + offset)
	#print(direction_tile_coords)
	return direction_tile_coords
	
# returns a Vector2i, which is the offset between our 'target_coords' and the path tiles in 'room_save_data' which are facing the direction of 'direction_tile'
# TODO add functionality for selecting which path tiles to get the offset from, for now I will just use one direction per room so it's easy
func find_room_offset(room_save_data, direction_tile, target_coords=Vector2i(0,0)):
	
	
	# returns a list of all path tiles matching the 'direction_tile' argument, but for now will only use element [0] since im lazy right now
	var direction_tile_coords = find_path_tiles_coords(room_save_data, direction_tile)
	
	# get the offset, based on subtracting the current room's path tile coords from the target_coords which represent the previous room
	# so if target_coords is (5,5) and our current rooms path tile is at (1,1), then the offset would be (4,4)
	var offset = target_coords - direction_tile_coords[0] 
	print("(inside find_room_offset function): target_coords = ",target_coords,", direction_tile_coords = ",direction_tile_coords[0],)
	print("offset = ",offset)
	return(offset)
	
# return a list containing coordinates which represent the direction_tile in room_save_data, plus a Vector2i to say where it is point to (if tile is at 0,0 and pointing right, then target_coords would be 1,0
func find_target_coords(room_save_data, direction_tile, offset=Vector2i(0,0)):
	
	var direction_tile_coords = find_path_tiles_coords(room_save_data, direction_tile)
	var add_offset = Vector2i(0,0)
	if direction_tile == UP_TILE:
		add_offset = Vector2i(0,-1)
	elif direction_tile == DOWN_TILE:
		add_offset = Vector2i(0,1)
	elif direction_tile == RIGHT_TILE:
		add_offset = Vector2i(1,0)
	else:
		add_offset = Vector2i(-1,0)
	# TODO: add functionality where I can select indexes in the direction_tile_coords list, in the case of there being multiple paths in or out of a room
	
	if direction_tile_coords.size() != 0:
		return( direction_tile_coords[0] + add_offset + offset)
	
		
	
	
