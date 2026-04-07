extends Area3D

@export var point_name: String = "Structural Point"
@export var scan_time: float = 2.0
@export var challenge_index: int = 0

var player_nearby: bool = false
var is_inspected: bool = false
var current_scan_time: float = 0.0
var scanning: bool = false
var interacting: bool = false

# Pool of structural engineering challenges
var challenges = [
	{
		"title": "🏗️ Structural Analysis",
		"color": Color(1, 0.7, 0.2),
		"scenario": "SCAN COMPLETE — Foundation Section A\n\nResults show hairline cracks in the concrete foundation with water seepage marks. The rebar is exposed in two locations and shows surface oxidation. Load-bearing capacity has decreased by 15%.\n\nWhat is the appropriate engineering response?",
		"options": [
			{"text": "A) Demolish the foundation and rebuild from scratch", "correct": false},
			{"text": "B) Apply epoxy injection to seal cracks, treat rebar rust, and install waterproof membrane", "correct": true},
			{"text": "C) Paint over the cracks to prevent further exposure", "correct": false},
		],
		"fun_fact": "Epoxy injection is a real technique civil engineers use to repair concrete cracks. It restores up to 95% of the original structural strength without costly demolition."
	},
	{
		"title": "🏗️ Structural Analysis",
		"color": Color(1, 0.7, 0.2),
		"scenario": "SCAN COMPLETE — Steel Beam B-7\n\nUltrasonic testing reveals internal fatigue cracking at the welded connection point. The beam shows deflection 12mm beyond design tolerance. This beam is part of the primary load path.\n\nWhat should the engineer recommend?",
		"options": [
			{"text": "A) Add temporary shoring, then replace the beam during a scheduled maintenance window", "correct": true},
			{"text": "B) Ignore it — 12mm is close enough to tolerance", "correct": false},
			{"text": "C) Weld additional plates on top of the existing beam", "correct": false},
		],
		"fun_fact": "Civil engineers use Non-Destructive Testing (NDT) methods like ultrasonic scanning to find internal defects invisible to the eye. This prevents catastrophic structural failures."
	},
	{
		"title": "🏗️ Structural Analysis",
		"color": Color(1, 0.7, 0.2),
		"scenario": "SCAN COMPLETE — Bridge Cable C-3\n\nVisual inspection shows 8 of 127 wire strands are broken. Corrosion pitting is present on the outer protective sheathing. The cable's remaining capacity is estimated at 88% of design load.\n\nHow should this be classified?",
		"options": [
			{"text": "A) No concern — 88% capacity is fine", "correct": false},
			{"text": "B) Immediate closure — any broken strands mean the bridge is unsafe", "correct": false},
			{"text": "C) Priority maintenance — schedule cable re-wrapping and strand repair, increase monitoring frequency", "correct": true},
		],
		"fun_fact": "Bridge cables are designed with redundancy (safety factors of 2.5x or more). Civil engineers calculate remaining capacity to determine urgency without over-reacting or under-reacting."
	},
	{
		"title": "🏗️ Structural Analysis",
		"color": Color(1, 0.7, 0.2),
		"scenario": "SCAN COMPLETE — Retaining Wall Section D\n\nThe wall shows a 3-degree outward lean. Drainage weep holes are blocked with sediment. Soil pressure readings are 20% above design specifications due to recent heavy rainfall.\n\nWhat is the priority action?",
		"options": [
			{"text": "A) Wait for the soil to dry out naturally after the rain stops", "correct": false},
			{"text": "B) Clear blocked weep holes immediately to restore drainage and relieve hydrostatic pressure", "correct": true},
			{"text": "C) Build a new wall in front of the existing one", "correct": false},
		],
		"fun_fact": "Hydrostatic pressure from trapped water is the #1 cause of retaining wall failures. Engineers design drainage systems specifically to prevent water buildup behind walls."
	},
	{
		"title": "🏗️ Structural Analysis",
		"color": Color(1, 0.7, 0.2),
		"scenario": "SCAN COMPLETE — Parking Garage Level 3\n\nChloride ion testing reveals salt contamination from road de-icing has penetrated 40mm into the 60mm concrete cover. Rebar at this depth will begin corroding within 2-3 years.\n\nWhat preventive measure should be taken?",
		"options": [
			{"text": "A) Apply a penetrating silane sealer to the concrete surface to halt further chloride ingress", "correct": true},
			{"text": "B) Do nothing until the rebar actually starts corroding", "correct": false},
			{"text": "C) Remove all concrete and start over", "correct": false},
		],
		"fun_fact": "In cold climates, road salt causes billions of dollars in infrastructure damage annually. Civil engineers use protective sealers and corrosion-resistant rebar (like epoxy-coated or stainless steel) to extend structure life."
	},
	{
		"title": "🏗️ Structural Analysis",
		"color": Color(1, 0.7, 0.2),
		"scenario": "SCAN COMPLETE — Roof Truss Assembly\n\nA timber roof truss shows signs of wood rot in the bottom chord near the bearing point. Moisture readings are at 28% (normal is <20%). The affected section is 0.4m long.\n\nWhat repair approach is correct?",
		"options": [
			{"text": "A) Sister a new treated-timber member alongside the damaged section with bolted connections", "correct": true},
			{"text": "B) Apply wood filler putty to fill the rotted areas", "correct": false},
			{"text": "C) Replace the entire roof", "correct": false},
		],
		"fun_fact": "Sistering is a common structural repair technique where a new member is bolted alongside a damaged one to restore load capacity. It's more cost-effective than full replacement."
	},
]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if scanning and not is_inspected:
		current_scan_time += delta
		
		if JuiceManager and Engine.get_frames_drawn() % 12 == 0:
			JuiceManager.shake_camera(0.02, 0.05)
		
		var percent = current_scan_time / scan_time
		$Label3D.text = "SCANNING: %d%%" % int(percent * 100)
		$MeshInstance3D.scale = Vector3(1, 1, 1) * (1.0 + (percent * 0.15))
		
		if current_scan_time >= scan_time:
			complete_scan()

func _input(event: InputEvent) -> void:
	if not is_inspected and not interacting and player_nearby:
		if event.is_action_pressed("interact"):
			start_scanning()
		elif event.is_action_released("interact"):
			stop_scanning()

func _on_body_entered(body: Node3D) -> void:
	if not is_inspected and body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = true
		body.set_hud_prompt(true, "Hold [E] to Scan " + point_name)

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = false
		stop_scanning()
		body.set_hud_prompt(false)

func start_scanning() -> void:
	scanning = true
	current_scan_time = 0.0

func stop_scanning() -> void:
	scanning = false
	current_scan_time = 0.0
	if not is_inspected:
		$Label3D.text = point_name
		$MeshInstance3D.scale = Vector3(1, 1, 1)

func complete_scan() -> void:
	scanning = false
	interacting = true
	
	if AudioManager:
		AudioManager.play_sfx("scan_complete")
	
	# Open structural analysis challenge
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
	complete_inspection()

func complete_inspection() -> void:
	is_inspected = true
	
	if JuiceManager:
		JuiceManager.shake_camera(0.12, 0.3)
		JuiceManager.flash_screen(Color(0, 0.5, 1, 0.1), 0.15)

	$Label3D.text = "INSPECTED"
	$Label3D.modulate = Color(0, 1, 0.5)
	
	var tween = create_tween()
	tween.tween_property($MeshInstance3D, "scale", Vector3(0, 0, 0), 0.4).set_trans(Tween.TRANS_BACK)
	
	ObjectiveManager.update_progress(1)
	
	var players = get_overlapping_bodies()
	if players.size() > 0 and players[0].has_method("set_hud_prompt"):
		players[0].set_hud_prompt(false)
