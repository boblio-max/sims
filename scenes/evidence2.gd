extends Area3D

@export var evidence_name: String = "Evidence"
@export var challenge_index: int = 2

var player_nearby: bool = false
var is_collected: bool = false
var interacting: bool = false

# Pool of evidence examination challenges
var challenges = [
	{
		"title": "⚖️ Examine Evidence",
		"color": Color(0.7, 0.3, 1),
		"scenario": "CASE: State v. Henderson — Alleged Burglary\n\nYou found a handwritten journal belonging to the defendant. The entry dated the night of the crime reads: 'Went to Jake's house tonight. Took what I needed.'\n\nThe defense argues this was obtained during an illegal search without a warrant. Is this evidence admissible?",
		"options": [
			{"text": "A) Yes — the content proves guilt, so it should be admitted regardless", "correct": false},
			{"text": "B) No — evidence obtained without a warrant violates the 4th Amendment (exclusionary rule)", "correct": true},
			{"text": "C) Yes — journals are always admissible as personal documents", "correct": false},
		],
		"fun_fact": "The Exclusionary Rule prevents illegally obtained evidence from being used in court. It was established in Mapp v. Ohio (1961) to protect citizens' 4th Amendment rights."
	},
	{
		"title": "⚖️ Examine Evidence",
		"color": Color(0.7, 0.3, 1),
		"scenario": "CASE: Rodriguez v. Metro Hospital — Medical Malpractice\n\nA witness states: 'My neighbor told me that the surgeon was drinking coffee during the operation and seemed distracted.'\n\nThe plaintiff wants to use this testimony. Should the court allow it?",
		"options": [
			{"text": "A) Yes — the witness is under oath and believable", "correct": false},
			{"text": "B) No — this is hearsay (the witness didn't personally observe it, they're repeating what someone else said)", "correct": true},
			{"text": "C) Yes — any testimony about a surgery is relevant", "correct": false},
		],
		"fun_fact": "Hearsay is an out-of-court statement offered to prove the truth of the matter. Under the Federal Rules of Evidence (Rule 802), hearsay is generally inadmissible because the original speaker can't be cross-examined."
	},
	{
		"title": "⚖️ Examine Evidence",
		"color": Color(0.7, 0.3, 1),
		"scenario": "CASE: Williams Enterprises v. GreenTech Corp — Contract Dispute\n\nGreenTech's lawyer presents an email chain showing contract negotiations. However, the emails are screenshots from a phone — not the original digital records from the email server.\n\nShould the court accept these screenshots?",
		"options": [
			{"text": "A) Yes — screenshots are the same as originals", "correct": false},
			{"text": "B) Only if GreenTech can prove the originals are unavailable and the screenshots are authentic (Best Evidence Rule)", "correct": true},
			{"text": "C) No — digital evidence is never reliable", "correct": false},
		],
		"fun_fact": "The Best Evidence Rule (FRE Rule 1002) requires the original document when proving its contents. Digital forensics experts are often called to authenticate electronic evidence in modern cases."
	},
	{
		"title": "⚖️ Examine Evidence",
		"color": Color(0.7, 0.3, 1),
		"scenario": "CASE: State v. Park — Assault Charge\n\nThe defendant confessed to the crime during police questioning. However, the officers did not read the defendant their Miranda rights before the interrogation began.\n\nCan the confession be used at trial?",
		"options": [
			{"text": "A) Yes — a confession is always valid evidence", "correct": false},
			{"text": "B) Yes — Miranda rights only apply to violent crimes", "correct": false},
			{"text": "C) No — without Miranda warnings, the confession was obtained in violation of the 5th Amendment and must be suppressed", "correct": true},
		],
		"fun_fact": "Miranda v. Arizona (1966) established that suspects must be informed of their rights before custodial interrogation. 'You have the right to remain silent' is one of the most famous phrases in American law."
	},
	{
		"title": "⚖️ Examine Evidence",
		"color": Color(0.7, 0.3, 1),
		"scenario": "CASE: Taylor v. Davis — Personal Injury\n\nThe plaintiff was injured in a car accident. The defense wants to introduce evidence that the plaintiff was convicted of shoplifting 15 years ago to undermine their credibility.\n\nShould this prior conviction be admissible?",
		"options": [
			{"text": "A) Yes — any criminal history is relevant to credibility", "correct": false},
			{"text": "B) No — a 15-year-old misdemeanor conviction is too remote in time and too prejudicial to be relevant (FRE Rule 609)", "correct": true},
			{"text": "C) Yes — once a criminal, always untrustworthy", "correct": false},
		],
		"fun_fact": "Federal Rule of Evidence 609 limits the use of prior convictions for impeachment. Convictions older than 10 years are generally excluded unless their probative value substantially outweighs their prejudicial effect."
	},
	{
		"title": "⚖️ Examine Evidence",
		"color": Color(0.7, 0.3, 1),
		"scenario": "CASE: Chen v. Apex Manufacturing — Product Liability\n\nAn expert witness with a PhD in mechanical engineering testifies that the product's design was defective. The defense challenges the expert's methodology.\n\nUnder what standard should the court evaluate this expert testimony?",
		"options": [
			{"text": "A) If the expert has a degree, their testimony is automatically valid", "correct": false},
			{"text": "B) The Daubert standard — the court must assess whether the methodology is scientifically valid and reliable", "correct": true},
			{"text": "C) Expert testimony is never allowed — only facts matter", "correct": false},
		],
		"fun_fact": "The Daubert standard (from Daubert v. Merrell Dow, 1993) makes judges 'gatekeepers' of expert testimony. They evaluate the methodology, peer review, error rate, and general acceptance in the scientific community."
	},
]

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Label3D.text = evidence_name

func _input(event: InputEvent) -> void:
	if not is_collected and not interacting and player_nearby and event.is_action_pressed("interact"):
		open_challenge()

func _on_body_entered(body: Node3D) -> void:
	if not is_collected and body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = true
		body.set_hud_prompt(true, "Press [E] to Examine " + evidence_name)

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
	collect_evidence()

func collect_evidence() -> void:
	is_collected = true
	
	if JuiceManager:
		JuiceManager.shake_camera(0.08, 0.2)
		JuiceManager.flash_screen(Color(0.7, 0.3, 1, 0.1), 0.1)
	
	if AudioManager:
		AudioManager.play_sfx("evidence_collected")

	var tween = create_tween()
	tween.tween_property($MeshInstance3D, "scale", Vector3(1.5, 1.5, 1.5), 0.15).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($MeshInstance3D, "scale", Vector3(0, 0, 0), 0.2)
	
	$Label3D.text = "EXAMINED!"
	$Label3D.modulate = Color(0.7, 0.3, 1)
	
	ObjectiveManager.update_progress(1)
	
	var overlaps = get_overlapping_bodies()
	if overlaps.size() > 0 and overlaps[0].has_method("set_hud_prompt"):
		overlaps[0].set_hud_prompt(false)
	
	await tween.finished
	queue_free()
