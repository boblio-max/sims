extends Node3D

func _ready() -> void:
	GameState.fix_environment_collisions(self)
	ObjectiveManager.reset()
	ObjectiveManager.start_objective("Win the support of 3 voters by answering their concerns correctly.", 3)
	ObjectiveManager.all_objectives_done.connect(_on_all_objectives_done)

func _on_all_objectives_done() -> void:
	GameState.complete_career("Politician")
