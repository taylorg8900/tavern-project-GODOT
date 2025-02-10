extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var jump_sound = $JumpSound
@onready var coyote_timer = $CoyoteTimer

const GRAVITY = 340
const MAX_HORIZONTAL_SPEED = 70
const HORIZONTAL_ACCELERATION = 550
const JUMP_SPEED = 160
const JUMP_TERMINATION_MULTIPLIER = 2.5


func _physics_process(delta):
	# get a Vector2i representing the inputs (up, right, left)
	var input_vector = get_input_vector()
	
	velocity.x += input_vector.x * HORIZONTAL_ACCELERATION * delta
	
	# slows down the player with acceleration, if not holding left or right
	if input_vector.x == 0:
		velocity.x = lerp(0.0, velocity.x, pow(2, -30 * delta))
	
	# clamp is used to keep velocity within a certain range
	velocity.x = clamp(velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
	
	# can jump if either on floor or coyote time hasnt ran out
	if input_vector.y < 0 && (is_on_floor() || !coyote_timer.is_stopped()):  
		velocity.y = input_vector.y * JUMP_SPEED
		

	if velocity.y < 0 && !Input.is_action_pressed("jump"):
		velocity.y += GRAVITY * JUMP_TERMINATION_MULTIPLIER * delta
		#velocity.y = 0
	else:
		velocity.y += GRAVITY * delta
		
	var was_on_floor = is_on_floor()
	
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	velocity = velocity
	
	if was_on_floor && !is_on_floor():
		coyote_timer.start()

	update_animation(input_vector)
	
func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left") #basically makes it compatible with controller, dont need but since im stealing it ill keep it
	input_vector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return input_vector

func update_animation(input_vector):
	
	#if !is_on_floor():
		#animated_sprite.play("jump")
	if input_vector.x != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	
	if input_vector.x != 0:
		animated_sprite.flip_h = true if input_vector.x < 0 else false
