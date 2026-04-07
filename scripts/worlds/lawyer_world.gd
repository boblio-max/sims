extends Node3D

func _ready() -> void:
	GameState.fix_environment_collisions(self)
	ObjectiveManager.reset()
	ObjectiveManager.start_objective("Find 3 pieces of misplaced evidence in the courtroom.", 3)
	ObjectiveManager.all_objectives_done.connect(_on_all_objectives_done)

func _on_all_objectives_done() -> void:
	GameState.complete_career("Lawyer")
