extends Node3D

@onready var ui: Node = $WorldUI
@onready var portal: Node = $ReturnPortal

var evidence_collected: int = 0
var total_evidence: int = 3
var evidence_nodes: Array[Area3D] = []
var at_court: bool = false

func _ready() -> void:
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
    ui.set_status("Collected evidence: " + str(evidence_collected) + "/" + str(total_evidence), 1.5)
    if evidence_collected >= total_evidence:
        ui.set_objective("Go to the judge's bench and present your evidence. (Press [Space])")

func _present_case() -> void:
    at_court = true
    ui.set_status("You defended your client successfully!", 3)
    ui.set_objective("Return to the hub when ready.")
    portal.monitoring = true
    portal.get_node("Collision").disabled = false
    portal.visible = true
