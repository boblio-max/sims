extends Node3D

@onready var ui: Node = $WorldUI
@onready var portal: Node = $ReturnPortal

var bugs_remaining: int = 3
var bug_areas: Array[Area3D] = []

func _ready() -> void:
    ui.set_objective("Fix the server by debugging 3 issues. (Press [Space] when near a glitch)")
    ui.set_status("")

    portal.monitoring = false
    portal.get_node("Collision").disabled = true
    portal.visible = false

    bug_areas = [
        $Bug1,
        $Bug2,
        $Bug3,
    ]

func _process(delta: float) -> void:
    if bugs_remaining <= 0:
        return
    for bug in bug_areas:
        if bug and bug.get_overlapping_bodies().has(get_tree().get_first_node_in_group("player")):
            if Input.is_action_just_pressed("ui_accept"):
                _fix_bug(bug)

func _fix_bug(bug: Area3D) -> void:
    if bug in bug_areas:
        bug_areas.erase(bug)
        bug.queue_free()
        bugs_remaining -= 1
        ui.set_status("Bug fixed! " + str(bugs_remaining) + " remaining", 1.6)
        if bugs_remaining <= 0:
            _on_all_bugs_fixed()

func _on_all_bugs_fixed() -> void:
    ui.set_objective("All bugs fixed! Go to the portal to return.")
    ui.set_status("Server is stable. Great job!", 3)
    portal.monitoring = true
    portal.get_node("Collision").disabled = false
    portal.visible = true
