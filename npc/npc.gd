extends CharacterBody3D

@export var character_name: String = "NPC"
@export var dialogue_lines: Array[String] = ["Hello!"]

@onready var label_3d: Label3D = $Label3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var bob_tween: Tween

func _ready() -> void:
	if label_3d:
		label_3d.text = character_name
	_start_bobbing()

func _process(delta: float) -> void:
	_look_at_player(delta)

func _look_at_player(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < 6.0:
			var target_pos = player.global_position
			target_pos.y = global_position.y # Keep horizontal
			var look_trans = global_transform.looking_at(target_pos, Vector3.UP)
			global_transform.basis = global_transform.basis.slerp(look_trans.basis, delta * 3.0)

func _start_bobbing() -> void:
	if not mesh: return
	
	if bob_tween:
		bob_tween.kill()
		
	bob_tween = create_tween().set_loops()
	var start_y = mesh.position.y
	bob_tween.tween_property(mesh, "position:y", start_y + 0.1, 1.5).set_trans(Tween.TRANS_SINE)
	bob_tween.tween_property(mesh, "position:y", start_y, 1.5).set_trans(Tween.TRANS_SINE)

func interact() -> void:
	var ui = get_tree().get_first_node_in_group("dialogue_ui")
	if ui:
		ui.show_dialogue(character_name, dialogue_lines)
	else:
		print("No dialogue UI found in group 'dialogue_ui'")
