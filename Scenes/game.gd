extends Node2D

@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var mouse_light: PointLight2D = $mouse_light

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouse_light.global_position = get_global_mouse_position()
