extends CharacterBody3D

@export var character_name: String = "NPC"
@export var dialogue_lines: Array[String] = ["Hello!"]

@onready var label_3d: Label3D = $Label3D

func _ready() -> void:
	if label_3d:
		label_3d.text = character_name

func interact() -> void:
	var ui = get_tree().get_first_node_in_group("dialogue_ui")
	if ui:
		ui.show_dialogue(character_name, dialogue_lines)
	else:
		print("No dialogue UI found in group 'dialogue_ui'")
