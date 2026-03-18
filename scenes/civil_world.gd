extends Node3D

@onready var ui: Node = $WorldUI
@onready var portal: Node = $ReturnPortal

var blocks: Array[Node3D] = []
var target_rotations: Array[float] = []
var blocks_completed: int = 0

func _ready() -> void:
	GameManager.current_career = "Civil Engineer"
	ui.set_objective("Rotate each block to match the blueprint. Use [Space] when near a block.")
	ui.set_status("")

	portal.monitoring = false
	portal.get_node("Collision").disabled = true
	portal.visible = false

	blocks = [$BlockA, $BlockB, $BlockC]
	target_rotations = [0.0, PI / 2, PI]

func _process(delta: float) -> void:
	if GameManager.is_paused:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	for i in range(blocks.size()):
		var block = blocks[i]
		if player.global_transform.origin.distance_to(block.global_transform.origin) < 3.0:
			if Input.is_action_just_pressed("ui_accept"):
				_rotate_block(i)

	if _all_blocks_correct():
		_finish_build()

func _rotate_block(index: int) -> void:
	var block = blocks[index]
	var basis = block.global_transform.basis.rotated(Vector3.UP, PI/2)
	block.global_transform = Transform3D(basis, block.global_transform.origin)
	
	if AudioManager:
		AudioManager.play_sfx("success")
	
	ui.flash_status("Rotated block " + str(index + 1))
	
	# Check if this block is now correct
	var current = blocks[index].global_transform.basis.get_euler().y
	if abs(fmod(current + PI * 2, PI*2) - target_rotations[index]) < 0.1:
		blocks_completed += 1
		ui.show_progress(blocks_completed, 3)

func _all_blocks_correct() -> bool:
	for i in range(blocks.size()):
		var current = blocks[i].global_transform.basis.get_euler().y
		if abs(fmod(current + PI * 2, PI*2) - target_rotations[i]) > 0.1:
			return false
	return true

func _finish_build() -> void:
	ui.set_objective("Perfect build! Return to the hub.")
	ui.show_critical("Construction complete.")
	
	# Mark career complete
	GameManager.mark_career_complete("Civil Engineer", 100)
	
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
