extends Node2D
@onready var mouselight: PointLight2D = $mouselight


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouselight.global_position = get_global_mouse_position()
