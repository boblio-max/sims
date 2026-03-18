extends Node3D

@onready var ui: Node = $WorldUI
@onready var portal: Node = $ReturnPortal

var evidence_collected: int = 0
var total_evidence: int = 3
var evidence_nodes: Array[Area3D] = []
var at_court: bool = false

func _ready() -> void:
	GameManager.current_career = "Lawyer"
	ui.set_objective("Collect evidence (3) and then present it in court.")
	ui.set_status("")

	portal.monitoring = false
	portal.get_node("Collision").disabled = true
	portal.visible = false

	evidence_nodes = [
		$Evidence1,
		$Evidence2,
		$Evidence3,
	]

func _process(delta: float) -> void:
	if GameManager.is_paused:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	for evidence in evidence_nodes.duplicate():
		if evidence and evidence.get_overlapping_bodies().has(player):
			if Input.is_action_just_pressed("ui_accept"):
				_collect_evidence(evidence)

	if evidence_collected >= total_evidence:
		if $CourtArea.get_overlapping_bodies().has(player):
			if Input.is_action_just_pressed("ui_accept") and not at_court:
				_present_case()

func _collect_evidence(evidence: Area3D) -> void:
	evidence_collected += 1
	evidence.queue_free()
	
	if AudioManager:
		AudioManager.play_sfx("pickup")
	
	ui.flash_status("Collected evidence: " + str(evidence_collected) + "/" + str(total_evidence))
	ui.show_progress(evidence_collected, total_evidence)
	
	if evidence_collected >= total_evidence:
		ui.set_objective("Go to the judge's bench and present your evidence. (Press [Space])")

func _present_case() -> void:
	at_court = true
	
	if AudioManager:
		AudioManager.play_sfx("success")
	
	ui.show_critical("You defended your client successfully!")
	ui.set_objective("Return to the hub when ready.")
	
	# Mark career complete
	GameManager.mark_career_complete("Lawyer", 100)
	
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
