extends Node3D

# Main Hub - Career selection with progress tracking

@onready var progress_label: Label = $ProgressUI/ProgressLabel if has_node("ProgressUI/ProgressLabel") else Label.new()
@onready var score_label: Label = $ProgressUI/ScoreLabel if has_node("ProgressUI/ScoreLabel") else Label.new()

func _ready() -> void:
	GameManager.load_progress()
	
	# Update progress display
	_update_progress_display()
	
	# Play hub music
	if AudioManager:
		AudioManager.play_music("hub")

func _process(delta: float) -> void:
	# Check if player returned - update display
	if Input.is_action_just_pressed("ui_cancel"):
		if not GameManager.is_paused:
			GameManager.toggle_pause()

func _update_progress_display() -> void:
	# Update progress label if it exists
	var completion = GameManager.get_completion_percentage()
	if progress_label:
		progress_label.text = "Completion: %.0f%%" % completion
	if score_label:
		score_label.text = "Total Score: %d" % GameManager.total_score
	
	print("Progress: %d/5 careers completed" % _count_completed_careers())

func _count_completed_careers() -> int:
	var count = 0
	for complete in GameManager.careers_completed.values():
		if complete:
			count += 1
	return count
