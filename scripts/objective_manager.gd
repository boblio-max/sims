extends Node

signal objective_updated(current: int, total: int, description: String)
signal objective_completed(description: String)
signal all_objectives_done()

var current_objective_description: String = ""
var current_count: int = 0
var total_count: int = 0
var is_active: bool = false

func start_objective(description: String, total: int) -> void:
	current_objective_description = description
	current_count = 0
	total_count = total
	is_active = true
	objective_updated.emit(current_count, total_count, current_objective_description)

func update_progress(amount: int = 1) -> void:
	if not is_active: return
	
	current_count += amount
	objective_updated.emit(current_count, total_count, current_objective_description)
	
	if current_count >= total_count:
		complete_objective()

func complete_objective() -> void:
	is_active = false
	objective_completed.emit(current_objective_description)
	all_objectives_done.emit()

func reset():
	is_active = false
	current_count = 0
	total_count = 0
	current_objective_description = ""
