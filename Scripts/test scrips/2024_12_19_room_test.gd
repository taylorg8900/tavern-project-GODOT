extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var button: Button = $Button




const ROOM_1_PATH = "res://JSON Files/Rooms/set 1/Room 1.json"
const ROOM_2_PATH = "res://JSON Files/Rooms/set 1/Room 2.json"
const ROOM_3_PATH = "res://JSON Files/Rooms/set 1/Room 3.json"
const ROOM_4_PATH = "res://JSON Files/Rooms/set 1/Room 4.json"
const ROOM_5_PATH = "res://JSON Files/Rooms/set 1/Room 5.json"
const ROOM_6_PATH = "res://JSON Files/Rooms/set 1/Room 6.json"
const ROOM_7_PATH = "res://JSON Files/Rooms/set 1/Room 7.json"
const ROOM_8_PATH = "res://JSON Files/Rooms/set 1/Room 8.json"
const ROOM_9_PATH = "res://JSON Files/Rooms/set 1/Room 9.json"
const ROOM_10_PATH = "res://JSON Files/Rooms/set 1/Room 10.json"
const ROOM_11_PATH = "res://JSON Files/Rooms/set 1/Room 11.json"
const ROOM_12_PATH = "res://JSON Files/Rooms/set 1/Room 12.json"
const ROOM_13_PATH = "res://JSON Files/Rooms/set 1/Room 13.json"
const ROOM_14_PATH = "res://JSON Files/Rooms/set 1/Room 14.json"
const ROOM_15_PATH = "res://JSON Files/Rooms/set 1/Room 15.json"

const ROOM_1_1_PATH = "res://JSON Files/Rooms/set 2/Room 1_1.json"
const ROOM_1_2_PATH = "res://JSON Files/Rooms/set 2/Room 1_2.json"
const ROOM_1_3_PATH = "res://JSON Files/Rooms/set 2/Room 1_3.json"
const ROOM_1_4_PATH = "res://JSON Files/Rooms/set 2/Room 1_4.json"
const ROOM_2_1_PATH = "res://JSON Files/Rooms/set 2/Room 2_1.json"
const ROOM_2_2_PATH = "res://JSON Files/Rooms/set 2/Room 2_2.json"
const ROOM_2_3_PATH = "res://JSON Files/Rooms/set 2/Room 2_3.json"
const ROOM_2_4_PATH = "res://JSON Files/Rooms/set 2/Room 2_4.json"
const ROOM_2_5_PATH = "res://JSON Files/Rooms/set 2/Room 2_5.json"
const ROOM_2_6_PATH = "res://JSON Files/Rooms/set 2/Room 2_6.json"
const ROOM_3_1_PATH = "res://JSON Files/Rooms/set 2/Room 3_1.json"
const ROOM_3_2_PATH = "res://JSON Files/Rooms/set 2/Room 3_2.json"
const ROOM_3_3_PATH = "res://JSON Files/Rooms/set 2/Room 3_3.json"
const ROOM_3_4_PATH = "res://JSON Files/Rooms/set 2/Room 3_4.json"
const ROOM_4_1_PATH = "res://JSON Files/Rooms/set 2/Room 4_1.json"




const UP = Vector2i(3,2)
const RIGHT = Vector2i(4,2)
const DOWN = Vector2i(5,2)
const LEFT = Vector2i(6,2)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.button_up.connect(generate_with_button)
	generate_with_button()
	
	# going to attempt and do graph magic here
	var graph = {
		1: [2],
		2: [3, 7],
		3: [4],
		4: [5],
		5: [6],
		6: [3],
		7: [8],
		8: [9],
		9: [10],
		10: [7]
	}
	var graph2 = {
		1: [2],
		2: [1, 3, 7],
		3: [2, 4, 6],
		4: [3, 5],
		5: [4, 6],
		6: [3, 5],
		7: [2, 8, 10],
		8: [7, 9],
		9: [8, 10],
		10: [7, 9]
	}
	
	# [tree components, loop components]
	var separated_graph = 0
	


'''
# used chatgpt for this, and it actually gave me something that worked so im adopting it into these functions here
func separate_graph(graph):
	var visited_nodes = []
	var tree_components = []
	var loop_components = []
	
	for node in graph:
		if node not in visited_nodes:
			var component_nodes = breadth_first_search(graph, node, visited_nodes)
			
			
func breadth_first_search(graph, start, visited):
	# performs bfs to extract a connected component
	var component = []
	var queue = [start]
	
	while queue: # not sure what this is asking, maybe while queue has items in it?
		var node = queue.pop_front()
		if node not in visited:
			visited.append(node)
			component.append(node)
'''
# deprecated, don't use anymore
func get_room_info(file_path):
	var room_data = get_json_info(file_path)
	var dict = {}
	
	# add room data to the dict
	dict["save_data"] = room_data
	
	# find total number of directional tiles in the room_data, this is our "total_paths"
	var counter = 0
	var atlas_coords = return_rooms_atlas_coords_list(room_data)
	for tile in atlas_coords:
		if is_directional_tile(tile):
			counter += 1
	dict["total_paths"] = counter
	
	# retrieve amount of paths available to each specific direction the room has
	dict["available_paths"] = {}
	if find_path_tiles_coords(room_data, UP).size() > 0:
		dict["available_paths"]["up"] = find_target_coords(room_data, UP)
	if find_path_tiles_coords(room_data, DOWN).size() > 0:
		dict["available_paths"]["down"] = find_target_coords(room_data, DOWN)
	if find_path_tiles_coords(room_data, LEFT).size() > 0:
		dict["available_paths"]["left"] = find_target_coords(room_data, LEFT)
	if find_path_tiles_coords(room_data, RIGHT).size() > 0:
		dict["available_paths"]["right"] = find_target_coords(room_data, RIGHT)
		
	return dict

# TODO: get safeguards for these conditions:
# no rooms in the json dict that match 
# no rooms in rooms_dict have available paths
# no rooms in json dict have matching num_paths

func place_compatible_room(num_paths, json_files_info_dict, rooms_dict={}):
	# if rooms_dict is empty, then simply find a room in json_files_info_dict with the matching num_paths and place / return
	if rooms_dict.is_empty():
		# find all room with a matching num_paths
		var matching_rooms = []
		for key in json_files_info_dict:
			if json_files_info_dict[key]["num_paths"] == num_paths:
				matching_rooms.append(json_files_info_dict[key]["json_info"])
		# randomly select one 
		var random_int = randi_range(0, matching_rooms.size())
		var room_save_data = matching_rooms[randi_range(0, matching_rooms.size() - 1)]
		
		var return_dict = {}
		return_dict["coords"] = return_room_coords_list(room_save_data)
		return_dict["source_ids"] = return_rooms_source_id_list(room_save_data)
		return_dict["atlas_coords"] = return_rooms_atlas_coords_list(room_save_data)
		
		return_dict["available_paths"] = {}
		if find_path_tiles_coords(room_save_data, UP).size() > 0:
			return_dict["available_paths"]["up"] = find_target_coords(room_save_data, UP)
		if find_path_tiles_coords(room_save_data, DOWN).size() > 0:
			return_dict["available_paths"]["down"] = find_target_coords(room_save_data, DOWN)
		if find_path_tiles_coords(room_save_data, LEFT).size() > 0:
			return_dict["available_paths"]["left"] = find_target_coords(room_save_data, LEFT)
		if find_path_tiles_coords(room_save_data, RIGHT).size() > 0:
			return_dict["available_paths"]["right"] = find_target_coords(room_save_data, RIGHT)
		
		for i in range(return_dict["coords"].size()):
			tile_map_layer.set_cell(
				return_dict["coords"][i],
				return_dict["source_ids"][i],
				return_dict["atlas_coords"][i]
			)
		
		return return_dict
	
	# otherwise, iterate through the rooms_dict until we find a room with available paths
	# if the room has available paths, select one randomly and place a new room from json_files_info_dict off of it which matched our num_paths
	else:
		for room in rooms_dict:
			
			if rooms_dict[room]["available_paths"].size() > 0:
				
				# obtain random available path direction from the room
				var available_paths = rooms_dict[room]["available_paths"].keys()
				var random_available_path = available_paths[randi() % available_paths.size()]
				
				# obtain random available path, from in the list of path directions
				var random_path = randi() % rooms_dict[room]["available_paths"][random_available_path].size() # gives a random index for the list which is at random_available_path
				
				# find all room which are compatible with the path direction we have randomly selected, and the num_paths
				var matching_rooms = []
				for file_info in json_files_info_dict:
					if json_files_info_dict[file_info]["num_paths"] == num_paths and json_files_info_dict[file_info]["available_paths"].has(get_inverse_str_direction(random_available_path)):
						matching_rooms.append(json_files_info_dict[file_info]["json_info"])
				
				# select one of the possible matching rooms randomly 
				var selected_room = matching_rooms[randi() % matching_rooms.size()]
				
				# find offset between our room in the rooms_dict, and one of our selected room's appropriate directional tile
				var offset_coords_list = find_room_offset(
					selected_room, 
					direction_str_to_direction_tile(get_inverse_str_direction(random_available_path)),
					rooms_dict[room]["available_paths"][random_available_path][random_path]
				)
				
				# TODO: if i run into issues later, it might be because of how im using random_offset_index to modify the available paths for the return_dict in the section after placing the tiles
				var random_offset_index = randi() % offset_coords_list.size()
				var random_offset = offset_coords_list[random_offset_index]
				
				# create dict object for new room
				var return_dict = {}
				return_dict["coords"] = return_room_coords_list(selected_room , random_offset)
				return_dict["source_ids"] = return_rooms_source_id_list(selected_room)
				return_dict["atlas_coords"] = return_rooms_atlas_coords_list(selected_room)
				
				return_dict["available_paths"] = {}
				if find_path_tiles_coords(selected_room, UP).size() > 0:
					return_dict["available_paths"]["up"] = find_target_coords(selected_room, UP, random_offset)
				if find_path_tiles_coords(selected_room, DOWN).size() > 0:
					return_dict["available_paths"]["down"] = find_target_coords(selected_room, DOWN, random_offset)
				if find_path_tiles_coords(selected_room, LEFT).size() > 0:
					return_dict["available_paths"]["left"] = find_target_coords(selected_room, LEFT, random_offset)
				if find_path_tiles_coords(selected_room, RIGHT).size() > 0:
					return_dict["available_paths"]["right"] = find_target_coords(selected_room, RIGHT, random_offset)
				
				# use set cell to place the new room
				for i in range(return_dict["coords"].size()):
					tile_map_layer.set_cell(
						return_dict["coords"][i],
						return_dict["source_ids"][i],
						return_dict["atlas_coords"][i]
					)
				
				# modify both the room we branched off of from the rooms_dict, and the newly placed room by removing the paths that got used by each
				rooms_dict[room]["available_paths"][random_available_path].remove_at(random_path)
				if rooms_dict[room]["available_paths"][random_available_path].is_empty():
					rooms_dict[room]["available_paths"].erase(random_available_path)
				return_dict["available_paths"][get_inverse_str_direction(random_available_path)].remove_at(random_offset_index)
				if return_dict["available_paths"][get_inverse_str_direction(random_available_path)].is_empty():
					return_dict["available_paths"].erase(get_inverse_str_direction(random_available_path))
				
				return return_dict
				
		



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
func find_target_coords(room_save_data, direction, offset=Vector2i(0,0)):
	
	var direction_tile_coords = find_path_tiles_coords(room_save_data, direction)
	var add_offset = Vector2i(0,0)
	var return_list = []
	
	if direction == UP:
		add_offset = Vector2i(0,-1)
	elif direction == DOWN:
		add_offset = Vector2i(0,1)
	elif direction == RIGHT:
		add_offset = Vector2i(1,0)
	else:
		add_offset = Vector2i(-1,0)
	for element in direction_tile_coords:
		return_list.append(element + add_offset + offset)
			
	return return_list
		
# returns a Vector2i, which is the offset between our 'target_coords' and the path tiles in 'room_save_data' which are facing the direction of 'direction_tile'
func find_room_offset(room_save_data, direction, target_coords=Vector2i(0,0)):
	var coords = find_path_tiles_coords(room_save_data, direction)
	var offset_coords = []
	for coord in coords:
		offset_coords.append(target_coords - coord)
	return offset_coords



# misc helper functions
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
func get_inverse_str_direction(direction):
	if direction == "up":
		return "down"
	elif direction == "down":
		return "up"
	elif direction == "right":
		return "left"
	else:
		return "right"
func direction_str_to_direction_tile(direction):
	if direction == "up":
		return UP
	elif direction == "down":
		return DOWN
	elif direction == "right":
		return RIGHT
	else:
		return LEFT

# functions for use with JSON files and information represented by them
func get_json_info(file_path): # opens json file and returns to us an object which is the information inside the file
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
func return_json_info_dict(file_path): # returns a dict, with the file's number of directional tiles, their directions, and the all of the json info it contains
	# create a dict to store the 3 pieces of info we want
	var dict = {}
	# store our information from the json file in a useable format
	var json_info = get_json_info(file_path)
	dict["json_info"] = json_info
	# find the number of directional tiles contained inside of the file
	# iterate through atlas_coords
	var atlas_coords_list = return_rooms_atlas_coords_list(json_info)
	var counter = 0
	for tile in atlas_coords_list:
		if is_directional_tile(tile):
			counter += 1
	dict["num_paths"] = counter
	
	dict["available_paths"] = {}
	if find_path_tiles_coords(json_info, UP).size() > 0:
		dict["available_paths"]["up"] = find_target_coords(json_info, UP)
	if find_path_tiles_coords(json_info, DOWN).size() > 0:
		dict["available_paths"]["down"] = find_target_coords(json_info, DOWN)
	if find_path_tiles_coords(json_info, LEFT).size() > 0:
		dict["available_paths"]["left"] = find_target_coords(json_info, LEFT)
	if find_path_tiles_coords(json_info, RIGHT).size() > 0:
		dict["available_paths"]["right"] = find_target_coords(json_info, RIGHT)
	
	return dict


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
func string_to_vector2i(string): # turns a json string into a useable Vector2i
	# remove unnecessary parts of the string, cast values we want to ints, and return a Vector2i
	var parts = string.strip_edges().split(",")
	var x = int(parts[0])
	var y = int(parts[1])
	
	return Vector2i(x, y)



func generate_with_button():
	tile_map_layer.clear()
	var json_files_info_dict = {}

	json_files_info_dict["Room 1_1"] = return_json_info_dict(ROOM_1_1_PATH)
	json_files_info_dict["Room 1_2"] = return_json_info_dict(ROOM_1_2_PATH)
	json_files_info_dict["Room 1_3"] = return_json_info_dict(ROOM_1_3_PATH)
	json_files_info_dict["Room 1_4"] = return_json_info_dict(ROOM_1_4_PATH)
	json_files_info_dict["Room 2_1"] = return_json_info_dict(ROOM_2_1_PATH)
	json_files_info_dict["Room 2_2"] = return_json_info_dict(ROOM_2_2_PATH)
	json_files_info_dict["Room 2_3"] = return_json_info_dict(ROOM_2_3_PATH)
	json_files_info_dict["Room 2_4"] = return_json_info_dict(ROOM_2_4_PATH)
	json_files_info_dict["Room 2_5"] = return_json_info_dict(ROOM_2_5_PATH)
	json_files_info_dict["Room 2_6"] = return_json_info_dict(ROOM_2_6_PATH)
	json_files_info_dict["Room 3_1"] = return_json_info_dict(ROOM_3_1_PATH)
	json_files_info_dict["Room 3_2"] = return_json_info_dict(ROOM_3_2_PATH)
	json_files_info_dict["Room 3_3"] = return_json_info_dict(ROOM_3_3_PATH)
	json_files_info_dict["Room 3_4"] = return_json_info_dict(ROOM_3_4_PATH)
	json_files_info_dict["Room 4_1"] = return_json_info_dict(ROOM_4_1_PATH)
	
	var rooms_dict = {}
	var paths_list = [1,4,3,1,1,2,1,1]
	for i in range(paths_list.size()):
		rooms_dict["room " + str(i)] = place_compatible_room(paths_list[i], json_files_info_dict, rooms_dict)
	
	# places colored tile at center of screen so we can orient ourselves
	tile_map_layer.set_cell(
		Vector2i(0,0),
		0,
		Vector2i(7,2)
	)
