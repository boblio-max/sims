extends Node3D

@onready var ui: Node = $WorldUI
@onready var portal: Node = $ReturnPortal

var patients: Array[Dictionary] = []
var current_patient: Dictionary = {}
var treating: bool = false

func _ready() -> void:
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

func _start_treating(patient: Area3D) -> void:
    if patients.empty():
        return
    treating = true
    current_patient = patients.pop_front()
    ui.set_objective("Diagnose " + current_patient.name + ": " + current_patient.symptom)
    ui.set_status("Choose: 1=" + current_patient.options[0] + ", 2=" + current_patient.options[1] + ", 3=" + current_patient.options[2])

func _check_diagnosis_input() -> void:
    var choice := -1
    if Input.is_key_just_pressed(KEY_1):
        choice = 0
    elif Input.is_key_just_pressed(KEY_2):
        choice = 1
    elif Input.is_key_just_pressed(KEY_3):
        choice = 2

    if choice == -1:
        return

    treating = false
    if choice == current_patient.correct:
        ui.set_status("Correct diagnosis!", 2)
    else:
        ui.set_status("Incorrect. Try next patient.", 2)

    if patients.empty():
        _finish_clinic()
    else:
        ui.set_objective("Treat " + str(patients.size() + 1) + " more patient(s).")

func _finish_clinic() -> void:
    ui.set_objective("All patients treated! Return to the hub.")
    ui.set_status("Clinic closed for the day.", 3)
    portal.monitoring = true
    portal.get_node("Collision").disabled = false
    portal.visible = true
