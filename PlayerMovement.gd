extends CharacterBody3D

@onready var pivot = $Pivot
@export var sens = 0.2

const CAMERA_MAX = -60
const CAMERA_MIN = -5
const SPEED = 15.0
const JUMP = 10.0
const SLIDE = -1
const WALJMP = 16

var can_move = true
var can_fall = true
var speed = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func can_move_again(time):
	await get_tree().create_timer(time).timeout
	speed = sqrt(velocity.x**2 + velocity.y**2 + velocity.z**2)
	can_move = true
	
func manage_falling(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

func manage_sliding(delta):
	if not is_on_floor() and is_on_wall() and velocity.y < SLIDE:
		velocity.y = SLIDE

func manage_jumping(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP

func manage_walljump(delta):
	if Input.is_action_just_pressed("jump") and is_on_wall_only():
		can_move = false
		var normal = get_wall_normal()
		velocity.x = normal.x * WALJMP
		velocity.z = normal.z * WALJMP
		velocity.y = JUMP
		can_move_again(0.6)

func manage_running(delta):
	var input_keys = Input.get_vector("left", "right", "up", "down")
	var keys_vector = Vector3(input_keys.x, 0, input_keys.y)
	var direction = (transform.basis * keys_vector).normalized()
	if can_move and direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	if can_move and not direction:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func manage_exiting(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(
			deg_to_rad(-event.relative.y * sens)
		)
		pivot.rotation.x = clamp(
			pivot.rotation.x, 
			deg_to_rad(CAMERA_MAX), 
			deg_to_rad(CAMERA_MIN)
		)

func _physics_process(delta):
	manage_falling(delta)
	manage_jumping(delta)
	manage_running(delta)
	manage_exiting(delta)
	move_and_slide()
