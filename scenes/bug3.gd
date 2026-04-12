extends Area3D

@export var bug_name: String = "Bug"
@export var challenge_index: int = 3

var player_nearby: bool = false
var is_fixed: bool = false
var interacting: bool = false

# Wandering logic
var spawn_pos: Vector3
var move_target: Vector3
var speed: float = 2.0
var wander_radius: float = 6.0
var move_state: String = "IDLE"

# Pool of code debugging challenges
var challenges = [
	{
		"title": "🔧 Debug the Code",
		"color": Color(0.2, 1, 0.3),
		"scenario": "You found a bug in the server! Look at this Python code:\n\ndef calculate_average(numbers):\n    total = 0\n    for num in numbers:\n        total += num\n    return total / len(numbers)\n\nThis function crashes when called with an empty list. What's the fix?",
		"options": [
			{"text": "A) Add a try/except block around the whole function", "correct": false},
			{"text": "B) Check if the list is empty before dividing: if len(numbers) == 0: return 0", "correct": true},
			{"text": "C) Change 'total / len(numbers)' to 'total / (len(numbers) + 1)'", "correct": false},
		],
		"fun_fact": "Division by zero is one of the most common bugs in software. Real engineers use guard clauses to handle edge cases before they cause crashes."
	},
	{
		"title": "🔧 Debug the Code",
		"color": Color(0.2, 1, 0.3),
		"scenario": "The login system has a critical security vulnerability:\n\ndef check_password(input_password, stored_password):\n    if input_password == stored_password:\n        return True\n    return False\n\nA hacker can bypass this. What's the real-world fix?",
		"options": [
			{"text": "A) Hash the input password and compare hashes, never store plain text", "correct": true},
			{"text": "B) Make the password longer", "correct": false},
			{"text": "C) Add a second if-statement to double check", "correct": false},
		],
		"fun_fact": "Real software engineers NEVER store passwords as plain text. They use hashing algorithms like bcrypt that convert passwords into unreadable strings."
	},
	{
		"title": "🔧 Debug the Code",
		"color": Color(0.2, 1, 0.3),
		"scenario": "The shopping cart has an off-by-one error:\n\ndef get_items(cart, count):\n    result = []\n    for i in range(1, count):\n        result.append(cart[i])\n    return result\n\nCalling get_items(['Apple', 'Bread', 'Milk'], 3) returns only ['Bread', 'Milk']. Why?",
		"options": [
			{"text": "A) The range should start at 0, not 1 — range(0, count)", "correct": true},
			{"text": "B) The count should be count + 1", "correct": false},
			{"text": "C) The append function is broken", "correct": false},
		],
		"fun_fact": "Off-by-one errors (OBOE) are so common they have their own name! In most programming languages, arrays/lists start at index 0, not 1."
	},
	{
		"title": "🔧 Debug the Code",
		"color": Color(0.2, 1, 0.3),
		"scenario": "The user registration form is accepting invalid emails:\n\ndef is_valid_email(email):\n    return '@' in email\n\nSomeone entered 'not-an-email@' and it passed validation. How should this be fixed?",
		"options": [
			{"text": "A) Just check for a period too — '.' in email", "correct": false},
			{"text": "B) Use a proper regex pattern that validates the full email format (user@domain.tld)", "correct": true},
			{"text": "C) Check if the email is longer than 5 characters", "correct": false},
		],
		"fun_fact": "Input validation is a critical security practice. Real engineers use regular expressions (regex) and established libraries to validate data formats like emails, phone numbers, and URLs."
	},
	{
		"title": "🔧 Debug the Code",
		"color": Color(0.2, 1, 0.3),
		"scenario": "The search feature is extremely slow on large datasets:\n\ndef find_user(users, target_name):\n    for user in users:\n        if user.name == target_name:\n            return user\n    return None\n\nWith 1 million users, each search takes seconds. What's the best optimization?",
		"options": [
			{"text": "A) Use a faster computer", "correct": false},
			{"text": "B) Use a dictionary/hash map for O(1) lookups instead of O(n) linear search", "correct": true},
			{"text": "C) Sort the list first", "correct": false},
		],
		"fun_fact": "Data structure choice is crucial in software engineering. A hash map can find items in O(1) constant time, while a list requires O(n) time — that's the difference between milliseconds and minutes!"
	},
	{
		"title": "🔧 Debug the Code",
		"color": Color(0.2, 1, 0.3),
		"scenario": "The API is leaking sensitive user data:\n\ndef get_user_profile(user_id):\n    user = database.get(user_id)\n    return {\n        'name': user.name,\n        'email': user.email,\n        'password': user.password,\n        'ssn': user.ssn\n    }\n\nWhat's wrong with this code?",
		"options": [
			{"text": "A) It should return XML instead of a dictionary", "correct": false},
			{"text": "B) The database query is too slow", "correct": false},
			{"text": "C) It's exposing password and SSN — only return public fields like name and email", "correct": true},
		],
		"fun_fact": "Data exposure is a top 10 security vulnerability (OWASP). Engineers must design APIs to only return the minimum data needed — this is called the Principle of Least Privilege."
	},
]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Label3D.text = bug_name
	spawn_pos = global_position
	move_target = spawn_pos
	
	var npc_scene = load("res://npc/npc_base.tscn")
	if npc_scene:
		var npc = npc_scene.instantiate()
		npc.set_process(false)
		npc.set_physics_process(false)
		npc.get_node("CollisionShape3D").disabled = true
		# Make it smaller to look like a bug
		npc.scale = Vector3(0.5, 0.5, 0.5)
		add_child(npc)
		if has_node("MeshInstance3D"):
			get_node("MeshInstance3D").hide()
			
	_start_idle()

func _process(delta: float) -> void:
	if is_fixed or interacting:
		return
		
	if move_state == "WANDER":
		var dir = (move_target - global_position)
		dir.y = 0
		if dir.length() > 0.1:
			dir = dir.normalized()
			global_position.x += dir.x * speed * delta
			global_position.z += dir.z * speed * delta
			var target_basis = Basis.looking_at(dir, Vector3.UP)
			transform.basis = transform.basis.slerp(target_basis, delta * 5.0)
		else:
			_start_idle()

func _start_idle() -> void:
	move_state = "IDLE"
	get_tree().create_timer(randf_range(1.0, 3.0)).timeout.connect(_start_wander)

func _start_wander() -> void:
	if not is_inside_tree() or is_fixed or interacting:
		return
	move_state = "WANDER"
	var angle = randf() * PI * 2
	var dist = randf() * wander_radius
	move_target = spawn_pos + Vector3(cos(angle), 0, sin(angle)) * dist

func _input(event: InputEvent) -> void:
	if not is_fixed and not interacting and player_nearby and event.is_action_pressed("interact"):
		open_challenge()

func _on_body_entered(body: Node3D) -> void:
	if not is_fixed and body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = true
		body.set_hud_prompt(true, "Press [E] to Debug " + bug_name)

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = false
		body.set_hud_prompt(false)

func open_challenge() -> void:
	interacting = true
	
	var challenge_data = challenges[challenge_index % challenges.size()]
	
	var ui_script = load("res://scenes/ui/challenge_ui.gd")
	var ui = CanvasLayer.new()
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	ui.layer = 5
	ui.set_script(ui_script)
	get_tree().root.add_child(ui)
	ui.setup(challenge_data)
	ui.challenge_complete.connect(_on_challenge_complete)

func _on_challenge_complete(_success: bool) -> void:
	fix_bug()

func fix_bug() -> void:
	is_fixed = true
	
	if JuiceManager:
		JuiceManager.shake_camera(0.1, 0.25)
		JuiceManager.flash_screen(Color(0, 1, 0.3, 0.05), 0.1)
	
	if AudioManager:
		AudioManager.play_sfx("bug_fixed")

	# Green glow
	var mesh_res = $MeshInstance3D.mesh
	if mesh_res and mesh_res.material is ShaderMaterial:
		var mat = mesh_res.material as ShaderMaterial
		create_tween().tween_property(mat, "shader_parameter/glow_color", Color(0, 1, 0.2, 1), 0.5)
	
	var tween = create_tween()
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.5, 1.5, 1.5), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property($MeshInstance3D, "scale", Vector3(0, 0, 0), 0.3)
	
	$Label3D.text = "FIXED!"
	$Label3D.modulate = Color(0, 1, 0)
	
	ObjectiveManager.update_progress(1)
	
	var overlaps = get_overlapping_bodies()
	if overlaps.size() > 0 and overlaps[0].has_method("set_hud_prompt"):
		overlaps[0].set_hud_prompt(false)
	
	await tween.finished
	queue_free()
