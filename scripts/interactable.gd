extends Area3D

## Name of the career this object represents (e.g. "Software Engineer").
@export var career_name: String = ""
## Optional popup message to show when interacting.
@export var info_message: String = "You learned about this career!"

var player_nearby: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		interact()

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = true
		body.set_hud_prompt(true, "Press [E] to Learn about " + career_name)

func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("set_hud_prompt"):
		player_nearby = false
		body.set_hud_prompt(false)

func interact() -> void:
	if career_name != "":
		GameState.complete_career(career_name)
		# Add visual/audio feedback here
		print("Interacted with: ", career_name)
