extends Node2D
@onready var tile_map: TileMap = $TileMap



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tile_position = Vector2i(15,0)
	tile_map.set_cell(0,tile_position,0,Vector2i(0,0),0)
	
	var layer = 0
	var tile_pos = Vector2i(0,15) # where in the game/map/whatever the tile is going
	var source_id = 0 # -1 is a 'respective invalid value', other than that i dont know what source id even means
	var atlas_coords = Vector2i(1,1) # this is which tile it picks, from the tilemap
	tile_map.set_cell(
		layer,
		tile_pos,
		source_id,
		atlas_coords
	)
	
	# i think this would work for making sure the source_id is correct always?
	# source id i think is for WHICH atlas
	# can see this in TileSet on the left, under Atlas there is an ID

	# so to sum it up
	var layer2 = 0 #layer we are putting the cell on
	var tile_pos2 = Vector2i(-12,5) #where in the scene we are putting the cell
	var source_id2 = 0 # which 'atlas' we are using in the TileMap
	var atlas_coords2 = Vector2i(1,1) #which tile from the atlas is being selected
	tile_map.set_cell(
		layer2,
		tile_pos2,
		source_id2,
		atlas_coords2
	)
	
	var layer3 = 0
	var tile_pos3 = Vector2i(0,0)
	var source_id3 = 0
	var atlas_coords3 = Vector2i(0,0)
	for i in range(10):
		tile_map.set_cell(
			layer3,
			tile_pos3,
			source_id3,
			atlas_coords3
		)
		tile_pos3 += Vector2i(1,1)
		
	
	var dict = {
		"key": Vector2i(-2,-2)
	}
	var apple = dict["key"]
	var tile_pos4 = apple
	var atlas_coords4 = Vector2i(0,0)
	tile_map.set_cell(
		layer,
		tile_pos4,
		source_id,
		atlas_coords4
	)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
