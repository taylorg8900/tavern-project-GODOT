extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer



const FIRST_ROOM_PATH = "res://JSON Files/Rooms/First Room.json"
const SECOND_ROOM_PATH = "res://JSON Files/Rooms/Second Room.json"
const THIRD_ROOM_PATH = "res://JSON Files/Rooms/Third Room.json"
const FOURTH_ROOM_PATH = "res://JSON Files/Rooms/Fourth Room.json"
const FIFTH_ROOM_PATH = "res://JSON Files/Rooms/Fifth Room.json"



const UP = Vector2i(3,2)
const RIGHT = Vector2i(4,2)
const DOWN = Vector2i(5,2)
const LEFT = Vector2i(6,2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	var first_room_save_data = get_room_info(FIRST_ROOM_PATH)
	var second_room_save_data = get_room_info(SECOND_ROOM_PATH)
	var third_room_save_data = get_room_info(THIRD_ROOM_PATH)
	var fourth_room_save_data = get_room_info(FOURTH_ROOM_PATH)
	var fifth_room_save_data = get_room_info(FIFTH_ROOM_PATH)
	
	var dict = {
		
		"available_paths": {
			"right": [Vector2i(28,28)],
			"left": [Vector2i(19,15)],
			"up": [Vector2i(30,30)]
		}
	}
	#place_room(first_room_save_data, LEFT, dict)
	var room1 = place_room(third_room_save_data)
	
	var room2 = place_room(first_room_save_data, RIGHT, room1)
	var room3 = place_room(second_room_save_data, LEFT, room1)
	var room4 = place_room(fifth_room_save_data, RIGHT, room2)
	
	print(room1)
	print(room2)
	
	
func clear_dict(dict):
	dict.clear()



	
func place_room(room_save_data, direction=null, arg_dict={}):
	if arg_dict == null: # if we accidentally tried to use a room that was never placed to begin with, return
		return
	var path = ""
	var inverse_path = ""
	var offset = Vector2i(0,0)
	
	if arg_dict.has("available_paths") and direction != null: # ignore both default arguments
		if direction == UP:
			path = "up"
			inverse_path = "down"
		elif direction == DOWN:
			path = "down"
			inverse_path = "up"
		elif direction == RIGHT:
			path = "right"
			inverse_path = "left"
		else:
			path = "left"
			inverse_path = "right"
		# if arg_dict has no available paths or room_save_data isn't able to connect, return early
		if arg_dict["available_paths"].has(path) and find_path_tiles_coords(room_save_data, get_inverse_direction(direction)).size() > 0:
			offset = find_room_offset(room_save_data, get_inverse_direction(direction), arg_dict["available_paths"][path][0])[0] # always want to use first available path in dict, i think
		else:
			return
	
	var return_dict = {}
	return_dict["coords"] = return_room_coords_list(room_save_data, offset)
	return_dict["source_ids"] = return_rooms_source_id_list(room_save_data)
	return_dict["atlas_coords"] = return_rooms_atlas_coords_list(room_save_data)
	
	return_dict["available_paths"] = {}
	if find_path_tiles_coords(room_save_data, UP, offset).size() > 0:
		return_dict["available_paths"]["up"] = find_target_coords(room_save_data, UP, offset)
	if find_path_tiles_coords(room_save_data, DOWN, offset).size() > 0:
		return_dict["available_paths"]["down"] = find_target_coords(room_save_data, DOWN, offset)
	if find_path_tiles_coords(room_save_data, LEFT, offset).size() > 0:
		return_dict["available_paths"]["left"] = find_target_coords(room_save_data, LEFT, offset)
	if find_path_tiles_coords(room_save_data, RIGHT, offset).size() > 0:
		return_dict["available_paths"]["right"] = find_target_coords(room_save_data, RIGHT, offset)
	
	
	for i in range(return_dict["coords"].size()):
		tile_map_layer.set_cell(
			return_dict["coords"][i],
			return_dict["source_ids"][i],
			return_dict["atlas_coords"][i]
		)
	
	# now to modify both the return_dict and the argument_dict, and remove the available paths from them if they got used
	if arg_dict.is_empty(): #if default argument, return dict without modifying anything
		return return_dict
	
	else:
		# modify argument dictionary, delete paths if they are empty
		arg_dict["available_paths"][path].remove_at(0)
		if arg_dict["available_paths"][path].is_empty():
			arg_dict["available_paths"].erase(path)
		# modify return dictionary, delete paths if they are empty
		return_dict["available_paths"][inverse_path].remove_at(0)
		if return_dict["available_paths"][inverse_path].is_empty():
			return_dict["available_paths"].erase(inverse_path)
	return return_dict

	
	
	
# returns a list of coordinates representing our direction tiles, and the direction_tile is defined as one of (up, right, down, left) as per global consts above
func find_path_tiles_coords(room_save_data, direction_tile, offset=Vector2i(0,0)):
	# finds tiles with the atlas coordinates of our 'direction_tile', and adds them to a list which is returned
	var direction_tile_coords = []
	if "atlas_coords" in room_save_data and "coords" in room_save_data:
		for item in range(room_save_data["atlas_coords"].size()):
			if string_to_vector2i(room_save_data["atlas_coords"][item]) == direction_tile:
				direction_tile_coords.append(string_to_vector2i(room_save_data["coords"][item]) + offset)
	return direction_tile_coords

# return a list containing coordinates which represent the direction_tile in room_save_data, plus a Vector2i to say where it is point to (if tile is at 0,0 and pointing right, then target_coords would be 1,0
func find_target_coords(room_save_data, direction_tile, offset=Vector2i(0,0)):
	
	var direction_tile_coords = find_path_tiles_coords(room_save_data, direction_tile)
	var add_offset = Vector2i(0,0)
	var return_list = []
	
	if direction_tile == UP:
		add_offset = Vector2i(0,-1)
	elif direction_tile == DOWN:
		add_offset = Vector2i(0,1)
	elif direction_tile == RIGHT:
		add_offset = Vector2i(1,0)
	else:
		add_offset = Vector2i(-1,0)
	for element in direction_tile_coords:
		return_list.append(element + add_offset + offset)
			
	return return_list
		
# returns a Vector2i, which is the offset between our 'target_coords' and the path tiles in 'room_save_data' which are facing the direction of 'direction_tile'
func find_room_offset(room_save_data, direction_tile, target_coords=Vector2i(0,0)):
	var coords = find_path_tiles_coords(room_save_data, direction_tile)
	var offset_coords = []
	for coord in coords:
		offset_coords.append(target_coords - coord)
	return offset_coords
		
	
		
# group of functions that return lists of coords, source_ids, and atlas coords
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
	var bingbong = variable==DOWN or variable==UP or variable==LEFT or variable==RIGHT
	return bingbong
func get_inverse_direction(direction):
	if direction == UP:
		return(DOWN)
	elif direction == DOWN:
		return(UP)
	elif direction == RIGHT:
		return(LEFT)
	else:
		return(RIGHT)
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
# function to turn information from JSON format into a Vector2i variable
func string_to_vector2i(string):
	# remove unnecessary parts of the string, cast values we want to ints, and return a Vector2i
	var parts = string.strip_edges().split(",")
	var x = int(parts[0])
	var y = int(parts[1])
	
	return Vector2i(x, y)
func clear_list(list):
	list.clear()

func deprecated_place_room(room_save_data, direction_tile, offset=Vector2i(0,0)):
	var coords_list = return_room_coords_list(room_save_data, offset)
	var source_id_list = return_rooms_source_id_list(room_save_data)
	var atlas_coords_list = return_rooms_atlas_coords_list(room_save_data)
	
	# places our tiles
	for i in range(coords_list.size()):
		#if not is_directional_tile(atlas_coords_list[i]):
		tile_map_layer.set_cell(
			coords_list[i],
			source_id_list[i],
			atlas_coords_list[i]
		)
	# create an object to return, which contains coordinates of paths not currently used (i.e. all paths that aren't the ones matching 'direction_tile')
	# TODO: make this so it only returns coordinates which aren't 'connected' to the previous room
	var dict = {}
	
	dict["right"] = find_target_coords(room_save_data,RIGHT,offset)
	dict["up"] = find_target_coords(room_save_data,UP,offset)
	dict["down"] = find_target_coords(room_save_data,DOWN,offset)
	dict["left"] = find_target_coords(room_save_data,LEFT,offset)
	
	return dict
