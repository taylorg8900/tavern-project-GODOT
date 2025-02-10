extends Area2D
 
@onready var game_manager: Node = %GameManager
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D



func _on_body_entered(body: Node2D) -> void:
	game_manager.add_point()
	queue_free()
