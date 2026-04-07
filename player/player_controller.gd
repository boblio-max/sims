extends CharacterBody3D

## Movement speed in units per second.
@export var speed: float = 5.0
## Sprint speed multiplier.
@export var sprint_speed: float = 8.5
## Jump impulse velocity.
@export var jump_velocity: float = 5.0
## Mouse sensitivity for camera look.
@export var mouse_sensitivity: float = 0.002
## How fast the player accelerates/decelerates (smoothing).
@export var acceleration: float = 12.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Camera3D
@onready var interaction_area: Area3D = $InteractionArea

var can_move: bool = true
var head_bob_timer: float = 0.0
var camera_base_y: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_base_y = camera.position.y
	
	GameState.all_careers_completed.connect(_on_all_careers_completed)
	
	if JuiceManager:
		JuiceManager.shake_requested.connect(_on_camera_shake_requested)
	
	# Instantiate Title Screen if in Hub and game hasn't started
	if get_tree().current_scene.name == "MainHub" and not GameState.is_game_started:
		var title = load("res://scenes/ui/title_screen.tscn").instantiate()
		add_child(title)
	
	# Instantiate HUD
	var hud = load("res://scenes/ui/hud.tscn").instantiate()
	add_child(hud)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(89), deg_to_rad(89))

	if event.is_action_pressed("ui_cancel"):
		_toggle_pause_menu()

	if event.is_action_pressed("interact"):
		_handle_interaction()


func _handle_interaction():
	var bodies = interaction_area.get_overlapping_areas()
	for body in bodies:
		if body.has_method("interact"):
			body.interact()
			break

func _on_all_careers_completed():
	var victory = load("res://scenes/ui/victory_screen.tscn").instantiate()
	add_child(victory)

func set_hud_prompt(visible: bool, text: String = ""):
	for child in get_children():
		if child.name.begins_with("HUD"):
			child.set_interaction_prompt(visible, text)
			break


func _physics_process(delta: float) -> void:
	if not can_move or get_tree().paused:
		return
	
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Sprint
	var current_speed = sprint_speed if Input.is_action_pressed("move_forward") and Input.is_key_pressed(KEY_SHIFT) else speed

	# Get input direction
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Smooth acceleration/deceleration
	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)

	move_and_slide()
	
	# Head bob
	_apply_head_bob(delta, current_speed)

func _apply_head_bob(delta: float, current_speed: float) -> void:
	if is_on_floor() and velocity.length() > 0.5:
		var bob_frequency = 10.0 if current_speed > speed else 7.0
		var bob_amplitude = 0.04 if current_speed > speed else 0.025
		head_bob_timer += delta * bob_frequency
		camera.position.y = camera_base_y + sin(head_bob_timer) * bob_amplitude
	else:
		head_bob_timer = 0.0
		camera.position.y = lerp(camera.position.y, camera_base_y, 10.0 * delta)

func _on_camera_shake_requested(intensity: float, duration: float):
	var original_pos = camera.position
	var tween = create_tween()
	
	for i in range(int(duration * 20)):
		var offset = Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity),
			0
		)
		tween.tween_property(camera, "position", original_pos + offset, 0.05)
	
	tween.tween_property(camera, "position", original_pos, 0.05)

func _toggle_pause_menu() -> void:
	# Check if already showing a pause menu
	for child in get_children():
		if child.name == "PauseMenu":
			# Unpause
			child.queue_free()
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
	
	# Create pause menu
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var pause = CanvasLayer.new()
	pause.name = "PauseMenu"
	pause.process_mode = Node.PROCESS_MODE_ALWAYS
	pause.layer = 10
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	pause.add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -150
	vbox.offset_top = -120
	vbox.offset_right = 150
	vbox.offset_bottom = 120
	vbox.add_theme_constant_override("separation", 20)
	bg.add_child(vbox)
	
	var title = Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(1, 0.84, 0))
	vbox.add_child(title)
	
	var resume_btn = Button.new()
	resume_btn.text = "Resume"
	resume_btn.custom_minimum_size = Vector2(0, 50)
	resume_btn.add_theme_font_size_override("font_size", 22)
	resume_btn.pressed.connect(func():
		pause.queue_free()
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	)
	vbox.add_child(resume_btn)
	
	var hub_btn = Button.new()
	hub_btn.text = "Return to Hub"
	hub_btn.custom_minimum_size = Vector2(0, 50)
	hub_btn.add_theme_font_size_override("font_size", 22)
	hub_btn.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_hub.tscn")
	)
	vbox.add_child(hub_btn)
	
	var quit_btn = Button.new()
	quit_btn.text = "Quit to Desktop"
	quit_btn.custom_minimum_size = Vector2(0, 50)
	quit_btn.add_theme_font_size_override("font_size", 22)
	quit_btn.pressed.connect(func(): get_tree().quit())
	vbox.add_child(quit_btn)
	
	add_child(pause)
