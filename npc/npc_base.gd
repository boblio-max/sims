extends CharacterBody3D

@export var speed: float = 1.5
@export var wander_radius: float = 5.0
@export var can_wander: bool = true

var spawn_pos: Vector3
var move_target: Vector3
var state: String = "IDLE"

func _ready() -> void:
	spawn_pos = global_position
	move_target = spawn_pos
	if can_wander:
		_start_idle()

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	if state == "WANDER" and can_wander:
		var dir = (move_target - global_position)
		dir.y = 0
		if dir.length() > 0.5:
			dir = dir.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			# Rotate towards target gracefully
			var target_basis = Basis.looking_at(dir, Vector3.UP)
			transform.basis = transform.basis.slerp(target_basis, delta * 5.0)
		else:
			_start_idle()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()

func _start_idle() -> void:
	state = "IDLE"
	get_tree().create_timer(randf_range(1.0, 4.0)).timeout.connect(_start_wander)

func _start_wander() -> void:
	if not is_inside_tree():
		return
	state = "WANDER"
	var angle = randf() * PI * 2
	var dist = randf() * wander_radius
	move_target = spawn_pos + Vector3(cos(angle), 0, sin(angle)) * dist
