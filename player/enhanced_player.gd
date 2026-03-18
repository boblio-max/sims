extends CharacterBody3D

@export var speed: float = 6.0
@export var sprint_speed: float = 10.0
@export var mouse_sensitivity: float = 0.003
@export var jump_velocity: float = 4.5
@export var acceleration: float = 20.0
@export var deceleration: float = 15.0

const GRAVITY := ProjectSettings.get_setting("physics/3d/default_gravity")
const FOOTSTEP_DISTANCE := 0.5  # Distance traveled between footsteps

var yaw := 0.0
var pitch := 0.0
var velocity_smoothed := Vector3.ZERO
var distance_traveled := 0.0
var is_sprinting := false

@onready var cam: Camera3D = $Camera3D
@onready var raycast: RayCast3D = $InteractionRaycast

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	
	# Create raycast for interaction detection
	if not raycast:
		raycast = RayCast3D.new()
		add_child(raycast)
		raycast.position = Vector3(0, 0.6, 0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -1.3, 1.3)
		rotation.y = yaw
		cam.rotation.x = pitch
	
	# Pause menu toggle
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.toggle_pause()
	
	# Handle interaction
	if Input.is_action_just_pressed("ui_accept"):
		var object = get_interactable_object()
		if object and object.has_method("interact"):
			object.interact()

func _physics_process(delta: float) -> void:
	if GameManager.is_paused:
		return
	
	# Handle sprinting
	is_sprinting = Input.is_action_pressed("ui_shift")
	
	# Calculate movement direction
	var direction = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		direction -= transform.basis.z
	if Input.is_action_pressed("ui_down"):
		direction += transform.basis.z
	if Input.is_action_pressed("ui_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("ui_right"):
		direction += transform.basis.x

	direction.y = 0
	direction = direction.normalized()
	
	# Calculate target speed
	var current_max_speed = sprint_speed if is_sprinting else speed
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	# Smooth acceleration/deceleration
	if direction.length() > 0:
		horizontal_velocity = horizontal_velocity.lerp(direction * current_max_speed, acceleration * delta)
	else:
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, deceleration * delta)

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	# Handle jumping
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity

	velocity = move_and_slide()
	
	# Track distance for footsteps
	if is_on_floor() and get_real_velocity().length() > 0.1:
		distance_traveled += get_real_velocity().length() * delta
		if distance_traveled >= FOOTSTEP_DISTANCE:
			distance_traveled = 0.0
			_play_footstep()

func _play_footstep() -> void:
	# Play footstep sound if audio system is available
	if GameManager:
		# Sound will be added through AudioManager
		pass

func is_looking_at_interactive() -> bool:
	return raycast and raycast.is_colliding()

func get_interactable_object() -> Node:
	if raycast and raycast.is_colliding():
		return raycast.get_collider()
	return null
