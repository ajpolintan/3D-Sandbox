extends CharacterBody3D

@onready var camera_mount = $Camera_Mount
@onready var model = $"3d_Model"
# Player Variables
const SPEED = 10.0
const JUMP_VELOCITY = 4.5

# Mouse Sensitivity 
@export var sensitivity = 0.5

var _camera_input_direction := Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	# check if the mouse moves AND if the input is within the game screen (aka mouse mode is GAME SCREEN)
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	
	# if camera moves
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * sensitivity
	

# Checks inputs. If there is a mouse input, rotate the player
func _input(event):
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
func _physics_process(delta: float) -> void:
	# Camera Controls
	camera_mount.rotation.x += _camera_input_direction.y * delta
	camera_mount.rotation.x = clamp(camera_mount.rotation.x, -PI / 6.0, PI / 3.0)
	camera_mount.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY * 2

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forwards", "Backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
