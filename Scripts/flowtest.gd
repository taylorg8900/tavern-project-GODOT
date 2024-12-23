extends Node2D
@onready var level_1_teleport_button: Button = $"buttons/level 1 teleport button"

@onready var player: CharacterBody2D = $Player
@onready var wall: TileMapLayer = $Wall
@onready var level_1_return_button: Button = $"buttons/level 1 return button"
@onready var level_2_teleport_button: Button = $"buttons/level 2 teleport button"
@onready var level_1_return_button_2: Button = $"buttons/level 1 return button2"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_1_teleport_button.connect("pressed", level_1_teleport)
	level_1_return_button.connect("pressed", return_teleport)
	level_2_teleport_button.connect("pressed", level_2_teleport)
	level_1_return_button_2.connect("pressed", return_teleport)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(get_global_mouse_position())
	if Input.is_action_just_pressed("interact"):
		place_cairn()
	#print(Vector2i(player.global_position) / Vector2i(4,4))
func level_1_teleport():
	player.global_position = Vector2(11,153)
	
	
func level_2_teleport():
	player.global_position = Vector2(27,-572)
	
	
func return_teleport():
	player.global_position = Vector2(0,0)

func place_cairn():
	wall.set_cell(
		(Vector2i(player.global_position) / Vector2i(4,4)) + Vector2i(0,-1),
		0,
		Vector2i(1,0)
	)
	
