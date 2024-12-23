extends CharacterBody2D



@onready var coyote_timer: Timer = $CoyoteTimer
@onready var marker_2d: Marker2D = $Marker2D
@onready var animated_sprite: AnimatedSprite2D = $Marker2D/AnimatedSprite2D


const SPEED = 75.0
const GRAVITY = 600
const JUMP_HEIGHT = 200


func _physics_process(delta: float) -> void:
	jump_stuff(delta)

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction > 0:
		marker_2d.scale.x =  1
	elif direction < 0:
		marker_2d.scale.x = -1
	
	# play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		# add jump animation later
		pass
	# apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# coyote time logic
	var was_on_floor = is_on_floor()
	
	
	
	move_and_slide()

func jump_stuff(delta):
	# logic for jumping, and jump cutting if in the air
	var jump = Input.is_action_just_pressed("jump")
	if is_on_floor() and jump:
		velocity.y = -1 * JUMP_HEIGHT
	if not is_on_floor():
		velocity.y += delta * GRAVITY
	if not is_on_floor() and Input.is_action_just_released("jump") and velocity.y < 0: # jump cutting
		velocity.y = 0
	
	
