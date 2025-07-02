extends CharacterBody3D

@onready var PIVOT = $Pivot
@export var CAMERA_MAX = -PI/3
@export var CAMERA_MIN = -PI/20
@export var SENSIBILTY = 0.005
@export var WALLJUMP = 12
@export var GRAVITY = 20
@export var SPEED = 8.0
@export var SLIDE = -1.0
@export var JUMP = 15.0

var can_move = true
var can_fall = true
var speed = 0

func can_move_now(time):
	await get_tree().create_timer(time).timeout
	speed = velocity.length()
	can_move = true
	
func manage_falling(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

func manage_sliding(delta):
	if not is_on_floor() and is_on_wall() and velocity.y < SLIDE:
		velocity.y = SLIDE

func manage_jumping(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP

func manage_walljump(delta):
	if Input.is_action_just_pressed("jump") and is_on_wall_only():
		var normal = get_wall_normal()
		velocity.x = normal.x * SPEED
		velocity.z = normal.z * SPEED
		velocity.y = WALLJUMP
		can_move = false
		can_move_now(0.6)

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
		rotate_y(-event.relative.x * SENSIBILTY)
		PIVOT.rotate_x(-event.relative.y * SENSIBILTY)
		PIVOT.rotation.x = clamp(
			PIVOT.rotation.x,
			CAMERA_MAX,
			CAMERA_MIN
		)

func _physics_process(delta):
	manage_falling(delta)
	manage_jumping(delta)
	manage_sliding(delta)
	manage_running(delta)
	manage_exiting(delta)
	manage_walljump(delta)
	move_and_slide()
