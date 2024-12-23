extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer



func _ready() -> void:
	
	var data = {
		"Foreground_Layer": []
	}
	
	var cells = tile_map_layer.get_used_cells()
	for i in range(len(cells)):
		var coords = cells[i]
		var source_id = tile_map_layer.get_cell_source_id(cells[i])
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(cells[i])
		#print(coords, source_id, atlas_coords)
		# now to add these into their own dict, in a list 
		var new_entry = {"coords": coords, "source_id": source_id, "atlas_coords": atlas_coords}
		data["Foreground_Layer"].append(new_entry)
	print(data)
	
	var coords_increase = Vector2i(0,5)
	for i in range(len(data["Foreground_Layer"])):
		#print("penis")
		var coords = data["Foreground_Layer"][i]["coords"] + coords_increase
		var source_id = data["Foreground_Layer"][i]["source_id"]
		var atlas_coords = data["Foreground_Layer"][i]["atlas_coords"]
		tile_map_layer.set_cell(
			coords,
			source_id,
			atlas_coords
			)
	# now that the dict is storing a list of dicts
	# gonna try putting it into a .json file somehow
	# then going to try and access that .json file, and place the tiles somewhere else as well
	data.text = "oogabooga"
	print(data)
	for key in data["Foreground_Layer"]:
		print(key["coords"])
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
