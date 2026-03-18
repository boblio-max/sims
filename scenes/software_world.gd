extends Node3D

@onready var ui: Node = $WorldUI
@onready var portal: Node = $ReturnPortal

var bugs_remaining: int = 3
var bug_areas: Array[Area3D] = []
var bugs_fixed: int = 0

func _ready() -> void:
	GameManager.current_career = "Software Engineer"
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
	if GameManager.is_paused:
		return
	
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
		bugs_fixed += 1
		
		# Play success sound
		if AudioManager:
			AudioManager.play_sfx("success")
		
		ui.flash_status("Bug fixed! " + str(bugs_remaining) + " remaining")
		ui.show_progress(bugs_fixed, 3)
		
		if bugs_remaining <= 0:
			_on_all_bugs_fixed()

func _on_all_bugs_fixed() -> void:
	ui.set_objective("All bugs fixed! Go to the portal to return.")
	ui.show_critical("Server is stable. Great job!")
	
	# Mark career complete
	GameManager.mark_career_complete("Software Engineer", 100)
	
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
