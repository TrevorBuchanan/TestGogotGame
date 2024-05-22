extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 8
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20
# Mouse sensitivity
@export var mouse_sensitivity = 0.00001

# Camera object
@onready var camera = $Pivot/Camera3D

var target_velocity = Vector3.ZERO
var camera_pitch = 0.0
var camera_limit = 1.5 # Limit the camera's pitch (in radians)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly.
	if is_on_floor():
		var input_vector = Vector2.ZERO
		if Input.is_action_pressed("move_right"):
			input_vector.x += 1
		if Input.is_action_pressed("move_left"):
			input_vector.x -= 1
		if Input.is_action_pressed("move_back"):
			input_vector.y += 1
		if Input.is_action_pressed("move_forward"):
			input_vector.y -= 1
	
		# Transform the input vector into a three-dimensional direction vector
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()
			var transform = global_transform.basis
			direction += transform.x * input_vector.x + transform.z * input_vector.y
		
		# Apply the speed to the normalized direction components
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
	
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
		
	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
	# Handle mouse look
	handle_mouse_look(delta)


func handle_mouse_look(delta):
	var mouse_motion = -Input.get_last_mouse_velocity() * mouse_sensitivity
	camera_pitch = clamp(camera_pitch + mouse_motion.y, -camera_limit, camera_limit)
	camera.rotation_degrees.x = rad_to_deg(camera_pitch)
	rotate_y(mouse_motion.x)
