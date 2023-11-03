extends CharacterBody3D

const SPEED = 15.0
const JUMP = 10.0
const SLIDE = -1
const WALJMP = 16

@onready var pivot = $CameraOrigin
@export var sens = 0.3

var can_move = true
var can_fall = true

var speed = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func can_move_again(time):
	await get_tree().create_timer(time).timeout
	speed = sqrt(velocity.x**2 + velocity.y**2 + velocity.z**2)
	can_move = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta	
		if is_on_wall() and velocity.y < SLIDE:
			velocity.y = SLIDE
			
	# Wall jumping
	if Input.is_action_just_pressed("jump") and is_on_wall_only():
		can_move = false
		var normal = get_wall_normal()
		velocity.x = normal.x * WALJMP
		velocity.z = normal.z * WALJMP
		velocity.y = JUMP
		can_move_again(0.6)

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if can_move:
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

