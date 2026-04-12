extends Area3D

@export var voter_name: String = "Voter"
@export var concern: String = ""
@export var option1: String = ""
@export var option2: String = ""
@export var correct_option: int = 1
@export var challenge_index: int = 2

var player_nearby: bool = false
var has_supported: bool = false
var interacting: bool = false
var current_step: int = 0

# Wandering logic
var spawn_pos: Vector3
var move_target: Vector3
var speed: float = 1.0
var wander_radius: float = 3.0
var move_state: String = "IDLE"

# 2-step voter challenges — identify issue → propose solution
var voter_scenarios = [
	{
		"steps": [
			{
				"title": "🏛️ Understand the Issue",
				"color": Color(0.3, 0.3, 1),
				"scenario": "CONSTITUENT: Maria Gonzalez, Local Business Owner\n\n\"I've been running my bakery for 12 years. Last year, three big chain stores opened nearby, and my revenue dropped 40%. I can barely afford rent anymore. The city needs to do something to help small businesses survive.\"\n\nWhat is the core policy issue here?",
				"options": [
					{"text": "A) Immigration policy — Maria needs visa assistance", "correct": false},
					{"text": "B) Local economic development — small businesses need support to compete with large chains", "correct": true},
					{"text": "C) Zoning law — the chains should be removed by force", "correct": false},
				],
				"fun_fact": "Small businesses generate 44% of U.S. economic activity and create two-thirds of new jobs. Supporting local businesses is a key economic policy issue at every level of government."
			},
			{
				"title": "🏛️ Propose a Solution",
				"color": Color(0.3, 0.3, 1),
				"scenario": "You've identified that Maria's concern is about small business competitiveness. Now she asks: \"What specific policy will you champion to help businesses like mine?\"\n\nWhat is the most effective, realistic policy response?",
				"options": [
					{"text": "A) Ban all chain stores from the city", "correct": false},
					{"text": "B) Create a small business tax credit program and a 'Shop Local' marketing initiative funded by the city", "correct": true},
					{"text": "C) Tell her the free market will sort itself out", "correct": false},
				],
				"fun_fact": "Many cities implement 'Shop Local' programs that have been shown to increase small business revenue by 5-15%. Tax incentives for small businesses are among the most bipartisan policies in local government."
			}
		]
	},
	{
		"steps": [
			{
				"title": "🏛️ Understand the Issue",
				"color": Color(0.3, 0.3, 1),
				"scenario": "CONSTITUENT: James Washington, Parent of Two\n\n\"My kids' school is falling apart. The roof leaks, the textbooks are from 2008, and they cut the music program. Meanwhile, the new stadium downtown got $50 million in funding. Where are our priorities?\"\n\nWhat is the core policy issue?",
				"options": [
					{"text": "A) Public education funding — schools are underfunded compared to other spending priorities", "correct": true},
					{"text": "B) Sports policy — the stadium should be demolished", "correct": false},
					{"text": "C) Real estate — James should move to a better school district", "correct": false},
				],
				"fun_fact": "In the U.S., public school funding varies dramatically by district. Schools in low-income areas receive on average $1,800 less per student than those in wealthy areas, creating an educational equity gap."
			},
			{
				"title": "🏛️ Propose a Solution",
				"color": Color(0.3, 0.3, 1),
				"scenario": "James wants to know your plan for education. He says: \"Don't give me vague promises. What specific action will you take?\"\n\nWhat is the most effective policy proposal?",
				"options": [
					{"text": "A) Promise to fix everything without explaining how to fund it", "correct": false},
					{"text": "B) Propose a school infrastructure bond measure with transparent spending oversight and a citizen review board", "correct": true},
					{"text": "C) Suggest he fundraise through bake sales", "correct": false},
				],
				"fun_fact": "School bond measures are how most communities fund school repairs and improvements. They require voter approval, which is why transparency and oversight are critical for building public trust."
			}
		]
	},
	{
		"steps": [
			{
				"title": "🏛️ Understand the Issue",
				"color": Color(0.3, 0.3, 1),
				"scenario": "CONSTITUENT: Dr. Sarah Chen, Emergency Room Physician\n\n\"Every night we have patients who avoid coming to the ER until their condition is critical because they can't afford insurance. I had a man with a treatable infection who waited so long it became sepsis. This is a public health crisis.\"\n\nWhat is the core policy issue?",
				"options": [
					{"text": "A) Hospital staffing — they need more doctors", "correct": false},
					{"text": "B) Healthcare access — uninsured residents delay treatment because of cost barriers", "correct": true},
					{"text": "C) Emergency room efficiency — they need faster triage", "correct": false},
				],
				"fun_fact": "Delayed healthcare due to cost leads to 5x higher treatment costs when patients finally seek care. Preventive care programs have been shown to reduce ER visits by 20-30% and save communities millions."
			},
			{
				"title": "🏛️ Propose a Solution",
				"color": Color(0.3, 0.3, 1),
				"scenario": "Dr. Chen asks: \"I've heard politicians promise healthcare reform before. What realistic, local-level action would you actually take?\"\n\nWhat is the most practical policy response?",
				"options": [
					{"text": "A) Overhaul the entire national healthcare system single-handedly", "correct": false},
					{"text": "B) Establish community health clinics with sliding-scale fees and expand Medicaid enrollment outreach", "correct": true},
					{"text": "C) Tell her that healthcare is not a local government responsibility", "correct": false},
				],
				"fun_fact": "Community health centers serve 30 million Americans regardless of ability to pay. They save the healthcare system an estimated $24 billion annually by providing preventive care instead of expensive ER visits."
			}
		]
	}
]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Label3D.text = voter_name
	spawn_pos = global_position
	move_target = spawn_pos
	
	var npc_scene = load("res://npc/npc_base.tscn")
	if npc_scene:
		var npc = npc_scene.instantiate()
		npc.set_process(false)
		npc.set_physics_process(false)
		npc.get_node("CollisionShape3D").disabled = true
		add_child(npc)
		if has_node("MeshInstance3D"):
			get_node("MeshInstance3D").hide()
			
	_start_idle()

func _process(delta: float) -> void:
	if has_supported or interacting:
		return
		
	if move_state == "WANDER":
		var dir = (move_target - global_position)
		dir.y = 0
		if dir.length() > 0.1:
			dir = dir.normalized()
			global_position.x += dir.x * speed * delta
			global_position.z += dir.z * speed * delta
			# Rotate
			var target_basis = Basis.looking_at(dir, Vector3.UP)
			transform.basis = transform.basis.slerp(target_basis, delta * 5.0)
		else:
			_start_idle()

func _start_idle() -> void:
	move_state = "IDLE"
	get_tree().create_timer(randf_range(2.0, 5.0)).timeout.connect(_start_wander)

func _start_wander() -> void:
	if not is_inside_tree() or has_supported or interacting:
		return
	move_state = "WANDER"
	var angle = randf() * PI * 2
	var dist = randf() * wander_radius
	move_target = spawn_pos + Vector3(cos(angle), 0, sin(angle)) * dist

func _input(event: InputEvent) -> void:
	if not has_supported and not interacting and player_nearby and event.is_action_pressed("interact"):
		start_dialogue()

func _on_body_entered(body: Node3D) -> void:
	if not has_supported and body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = true
		body.set_hud_prompt(true, "Press [E] to Talk to " + voter_name)

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = false
		body.set_hud_prompt(false)

func start_dialogue() -> void:
	interacting = true
	current_step = 0
	_show_current_step()

func _show_current_step() -> void:
	var case_data = voter_scenarios[challenge_index % voter_scenarios.size()]
	if current_step >= case_data["steps"].size():
		win_support()
		return
	
	var step_data = case_data["steps"][current_step]
	
	var ui_script = load("res://scenes/ui/challenge_ui.gd")
	var ui = CanvasLayer.new()
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	ui.layer = 5
	ui.set_script(ui_script)
	get_tree().root.add_child(ui)
	ui.setup(step_data)
	ui.challenge_complete.connect(_on_step_complete)

func _on_step_complete(_success: bool) -> void:
	current_step += 1
	await get_tree().create_timer(0.3).timeout
	_show_current_step()

func win_support() -> void:
	has_supported = true
	
	if JuiceManager:
		JuiceManager.shake_camera(0.05, 0.2)
		JuiceManager.flash_screen(Color(0.3, 0.3, 1, 0.05), 0.15)
	
	if AudioManager:
		AudioManager.play_sfx("support_won")

	var tween = create_tween()
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.2, 1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property($MeshInstance3D, "scale", Vector3(0, 0, 0), 0.4)
	
	$Label3D.text = "SUPPORTED!"
	$Label3D.modulate = Color(0.3, 0.5, 1)
	
	ObjectiveManager.update_progress(1)
	
	var overlaps = get_overlapping_bodies()
	if overlaps.size() > 0 and overlaps[0].has_method("set_hud_prompt"):
		overlaps[0].set_hud_prompt(false)
	
	await tween.finished
	queue_free()
