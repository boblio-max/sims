extends Node3D

@onready var ui: Node = $WorldUI
@onready var portal: Node = $ReturnPortal

var patients: Array[Dictionary] = []
var current_patient: Dictionary = {}
var treating: bool = false
var correct_diagnoses: int = 0
var total_patients: int = 3

func _ready() -> void:
	GameManager.current_career = "Doctor"
	ui.set_objective("Treat 3 patients. Talk to them and diagnose their condition.")
	ui.set_status("")

	portal.monitoring = false
	portal.get_node("Collision").disabled = true
	portal.visible = false

	patients = [
		{"name": "Anna", "symptom": "High fever and cough.", "options": ["Common cold", "Flu", "Allergy"], "correct": 1},
		{"name": "Marco", "symptom": "Sharp belly pain after eating.", "options": ["Food poisoning", "Appendicitis", "Indigestion"], "correct": 0},
		{"name": "Jae", "symptom": "Headache and blurred vision.", "options": ["Migraine", "Concussion", "Stress"], "correct": 0},
	]

func _process(delta: float) -> void:
	if GameManager.is_paused:
		return
	
	if treating:
		_check_diagnosis_input()
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	for patient in [$Patient1, $Patient2, $Patient3]:
		if patient.get_overlapping_bodies().has(player):
			if Input.is_action_just_pressed("ui_accept"):
				_start_treating(patient)

var _prev_key_1: bool = false
var _prev_key_2: bool = false
var _prev_key_3: bool = false

func _start_treating(patient: Area3D) -> void:
	if patients.size() == 0:
		return
	treating = true
	current_patient = patients.pop_front()
	ui.set_objective("Diagnose " + current_patient.name + ": " + current_patient.symptom)
	ui.set_status("Choose: 1=" + current_patient.options[0] + ", 2=" + current_patient.options[1] + ", 3=" + current_patient.options[2])

func _check_diagnosis_input() -> void:
	var choice := -1
	var key_1 = Input.is_key_pressed(Key.KEY_1)
	var key_2 = Input.is_key_pressed(Key.KEY_2)
	var key_3 = Input.is_key_pressed(Key.KEY_3)

	if key_1 and not _prev_key_1:
		choice = 0
	elif key_2 and not _prev_key_2:
		choice = 1
	elif key_3 and not _prev_key_3:
		choice = 2

	_prev_key_1 = key_1
	_prev_key_2 = key_2
	_prev_key_3 = key_3

	if choice == -1:
		return

	treating = false
	if choice == current_patient.correct:
		correct_diagnoses += 1
		ui.flash_status("Correct diagnosis!")
		if AudioManager:
			AudioManager.play_sfx("success")
	else:
		ui.flash_status("Incorrect. Try next patient.")
		if AudioManager:
			AudioManager.play_sfx("fail")

	ui.show_progress(correct_diagnoses, total_patients)

	if patients.size() == 0:
		_finish_clinic()
	else:
		ui.set_objective("Treat " + str(patients.size()) + " more patient(s).")

func _finish_clinic() -> void:
	ui.set_objective("All patients treated! Return to the hub.")
	ui.show_critical("Clinic closed for the day. Score: %d/3" % correct_diagnoses)
	
	# Mark career complete with score
	GameManager.mark_career_complete("Doctor", correct_diagnoses * 33)
	
	portal.monitoring = true
	portal.get_node("Collision").disabled = false
	portal.visible = true
	
	# Add glow effect to portal
	if portal and portal.has_node("Mesh"):
		var mesh_node = portal.get_node("Mesh")
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(mesh_node, "modulate", Color(0, 1, 0.5, 1), 0.5)
		tween.tween_property(mesh_node, "modulate", Color(1, 1, 1, 1), 0.5)
