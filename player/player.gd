extends CharacterBody3D

@export var speed: float = 6.0
@export var mouse_sensitivity: float = 0.003
@export var jump_velocity: float = 4.5

var GRAVITY := ProjectSettings.get_setting("physics/3d/default_gravity")

var yaw := 0.0
var pitch := 0.0

@onready var cam: Camera3D = $Camera3D

func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    add_to_group("player")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        yaw -= event.relative.x * mouse_sensitivity
        pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -1.3, 1.3)
        rotation.y = yaw
        cam.rotation.x = pitch

func _physics_process(delta: float) -> void:
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

    velocity.x = direction.x * speed
    velocity.z = direction.z * speed

    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    elif Input.is_action_just_pressed("ui_accept"):
        velocity.y = jump_velocity

    move_and_slide()
