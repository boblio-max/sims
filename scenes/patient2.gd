extends Area3D

@export var patient_name: String = "Patient"
@export var symptom: String = ""
@export var option1: String = ""
@export var option2: String = ""
@export var correct_option: int = 1
@export var challenge_index: int = 2

var player_nearby: bool = false
var is_treated: bool = false
var interacting: bool = false
var current_step: int = 0

# Multi-step diagnosis challenges — each patient has 3 steps
var patient_cases = [
	{
		"steps": [
			{
				"title": "🩺 Step 1: Initial Assessment",
				"color": Color(1, 0.3, 0.3),
				"scenario": "PATIENT: Mr. Smith, 45 years old\nChief Complaint: High fever (103°F), persistent dry cough for 5 days, body aches, and fatigue. No known allergies.\n\nWhat diagnostic tests should you order first?",
				"options": [
					{"text": "A) Blood culture and chest X-ray", "correct": true},
					{"text": "B) MRI of the brain", "correct": false},
					{"text": "C) Knee reflex test", "correct": false},
				],
				"fun_fact": "Doctors follow a diagnostic process: history → physical exam → targeted tests. Ordering the right tests first saves time and avoids unnecessary procedures."
			},
			{
				"title": "🩺 Step 2: Diagnosis",
				"color": Color(1, 0.3, 0.3),
				"scenario": "TEST RESULTS for Mr. Smith:\n• Chest X-ray: Shows infiltrates in the lower right lobe\n• Blood work: Elevated white blood cell count (15,000/μL)\n• Temperature: Still 103°F\n\nBased on these results, what is the most likely diagnosis?",
				"options": [
					{"text": "A) Common cold (viral upper respiratory infection)", "correct": false},
					{"text": "B) Community-acquired pneumonia (bacterial lung infection)", "correct": true},
					{"text": "C) Stomach flu (gastroenteritis)", "correct": false},
				],
				"fun_fact": "Pneumonia affects 250 million people globally each year. Doctors use chest X-rays and blood tests together to distinguish bacterial pneumonia from viral infections, which require different treatments."
			},
			{
				"title": "🩺 Step 3: Treatment Plan",
				"color": Color(1, 0.3, 0.3),
				"scenario": "DIAGNOSIS CONFIRMED: Community-acquired pneumonia\n\nMr. Smith's oxygen saturation is 95% (borderline) and he's otherwise healthy. What is the appropriate treatment plan?",
				"options": [
					{"text": "A) Send him home with cough drops and tell him to rest", "correct": false},
					{"text": "B) Prescribe oral antibiotics (amoxicillin), rest, fluids, and schedule a follow-up in 48 hours", "correct": true},
					{"text": "C) Immediate surgery to remove the infected lung tissue", "correct": false},
				],
				"fun_fact": "For uncomplicated community-acquired pneumonia, outpatient antibiotics have a success rate over 90%. Doctors always schedule follow-ups to ensure the treatment is working."
			}
		]
	},
	{
		"steps": [
			{
				"title": "🩺 Step 1: Initial Assessment",
				"color": Color(1, 0.3, 0.3),
				"scenario": "PATIENT: Mrs. Jones, 32 years old\nChief Complaint: Sudden sharp pain in the lower right abdomen that started 6 hours ago. Pain worsens with movement. Mild nausea, low-grade fever (100.4°F).\n\nWhat should you do first?",
				"options": [
					{"text": "A) Give her pain medication and send her home", "correct": false},
					{"text": "B) Perform abdominal palpation, order CBC blood test and abdominal CT scan", "correct": true},
					{"text": "C) Schedule an appointment for next week", "correct": false},
				],
				"fun_fact": "Acute abdominal pain is one of the most common ER presentations. The location of pain is a critical diagnostic clue — right lower quadrant pain has a specific differential diagnosis."
			},
			{
				"title": "🩺 Step 2: Diagnosis",
				"color": Color(1, 0.3, 0.3),
				"scenario": "TEST RESULTS for Mrs. Jones:\n• Abdominal exam: Rebound tenderness at McBurney's point\n• CBC: Elevated WBC at 14,000/μL\n• CT scan: Inflamed appendix with no perforation\n\nWhat is your diagnosis?",
				"options": [
					{"text": "A) Acute appendicitis — the appendix is inflamed and needs treatment", "correct": true},
					{"text": "B) Food poisoning — she probably ate something bad", "correct": false},
					{"text": "C) Kidney stones — the pain is from the urinary tract", "correct": false},
				],
				"fun_fact": "McBurney's point (1/3 of the way from the hip bone to the belly button) is the classic location for appendicitis pain. It's named after surgeon Charles McBurney who described it in 1889."
			},
			{
				"title": "🩺 Step 3: Treatment Plan",
				"color": Color(1, 0.3, 0.3),
				"scenario": "DIAGNOSIS CONFIRMED: Acute appendicitis (non-perforated)\n\nMrs. Jones is stable. The appendix is inflamed but hasn't ruptured. What is the standard of care?",
				"options": [
					{"text": "A) Laparoscopic appendectomy (minimally invasive surgery) within 24 hours", "correct": true},
					{"text": "B) Prescribe antibiotics only and hope it resolves", "correct": false},
					{"text": "C) Wait and observe for a week to see if it gets worse", "correct": false},
				],
				"fun_fact": "Laparoscopic surgery uses tiny incisions and a camera, resulting in less pain, faster recovery (1-3 weeks vs 4-6), and smaller scars compared to open surgery. It's now the gold standard for appendectomies."
			}
		]
	},
	{
		"steps": [
			{
				"title": "🩺 Step 1: Initial Assessment",
				"color": Color(1, 0.3, 0.3),
				"scenario": "PATIENT: Robbie, 8 years old\nChief Complaint: Mom reports Robbie fell off his bike while playing. He's holding his left arm and crying. Visible swelling above the wrist. He can wiggle his fingers but it hurts.\n\nWhat is your first action?",
				"options": [
					{"text": "A) Tell him it's probably just a bruise and give him ice", "correct": false},
					{"text": "B) Immobilize the arm with a splint and order an X-ray of the forearm and wrist", "correct": true},
					{"text": "C) Put the arm in a full cast immediately", "correct": false},
				],
				"fun_fact": "In pediatric patients, doctors always immobilize a suspected fracture BEFORE imaging. Children's bones have growth plates that can be damaged, so proper assessment is critical for long-term development."
			},
			{
				"title": "🩺 Step 2: Diagnosis",
				"color": Color(1, 0.3, 0.3),
				"scenario": "X-RAY RESULTS for Robbie:\n• Buckle fracture (torus fracture) of the distal radius\n• No displacement\n• Growth plate appears intact\n• Good circulation to fingers (capillary refill < 2 seconds)\n\nWhat type of fracture is this?",
				"options": [
					{"text": "A) A compound fracture requiring emergency surgery", "correct": false},
					{"text": "B) A stable, incomplete fracture common in children — the bone buckled but didn't break through", "correct": true},
					{"text": "C) A dislocated shoulder", "correct": false},
				],
				"fun_fact": "Children's bones are more flexible than adults', so they bend and buckle rather than snapping completely. Buckle fractures are the most common pediatric forearm fractures and heal faster than adult fractures."
			},
			{
				"title": "🩺 Step 3: Treatment Plan",
				"color": Color(1, 0.3, 0.3),
				"scenario": "DIAGNOSIS CONFIRMED: Stable buckle fracture, distal radius\n\nRobbie's fracture is stable with no displacement. What is the appropriate treatment?",
				"options": [
					{"text": "A) Surgery with metal plates and screws", "correct": false},
					{"text": "B) No treatment needed — kids heal on their own", "correct": false},
					{"text": "C) Apply a removable splint or short cast for 3-4 weeks, prescribe children's ibuprofen, follow-up in 1 week", "correct": true},
				],
				"fun_fact": "Modern pediatric orthopedics increasingly uses removable splints instead of full casts for stable fractures. This allows for better hygiene, easier monitoring, and children can typically return to activity in 4-6 weeks."
			}
		]
	}
]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Label3D.text = patient_name
	var npc_scene = load("res://npc/npc_base.tscn")
	if npc_scene:
		var npc = npc_scene.instantiate()
		npc.set_process(false)
		npc.set_physics_process(false)
		npc.get_node("CollisionShape3D").disabled = true
		add_child(npc)
		if has_node("MeshInstance3D"):
			get_node("MeshInstance3D").hide()

func _input(event: InputEvent) -> void:
	if not is_treated and not interacting and player_nearby and event.is_action_pressed("interact"):
		start_diagnosis()

func _on_body_entered(body: Node3D) -> void:
	if not is_treated and body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = true
		body.set_hud_prompt(true, "Press [E] to Examine " + patient_name)

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = false
		body.set_hud_prompt(false)

func start_diagnosis() -> void:
	interacting = true
	current_step = 0
	_show_current_step()

func _show_current_step() -> void:
	var case_data = patient_cases[challenge_index % patient_cases.size()]
	if current_step >= case_data["steps"].size():
		complete_treatment()
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
	# Small delay between steps
	await get_tree().create_timer(0.3).timeout
	_show_current_step()

func complete_treatment() -> void:
	is_treated = true
	
	if JuiceManager:
		JuiceManager.shake_camera(0.05, 0.2)
		JuiceManager.flash_screen(Color(0, 1, 0.8, 0.05), 0.15)
	
	if AudioManager:
		AudioManager.play_sfx("heal_complete")

	var tween = create_tween()
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.2, 0.8, 1.2), 0.1)
	tween.tween_property($MeshInstance3D, "scale", Vector3(0, 0, 0), 0.4).set_trans(Tween.TRANS_BACK)
	
	$Label3D.text = "TREATED!"
	$Label3D.modulate = Color(0, 1, 0.5)
	
	ObjectiveManager.update_progress(1)
	
	var overlaps = get_overlapping_bodies()
	if overlaps.size() > 0 and overlaps[0].has_method("set_hud_prompt"):
		overlaps[0].set_hud_prompt(false)
	
	await tween.finished
	queue_free()
