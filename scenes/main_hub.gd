extends Node3D

# Main Hub - Career selection with progress tracking

@onready var progress_label: Label = $ProgressUI/ProgressLabel if has_node("ProgressUI/ProgressLabel") else Label.new()
@onready var score_label: Label = $ProgressUI/ScoreLabel if has_node("ProgressUI/ScoreLabel") else Label.new()

func _ready() -> void:
    # Set player to initial position
    if player:
        player.global_position = Vector3(0, 2, 6)
    
    # Initialize UI
    _update_progress_display()
    
    # Play hub music
    var audio = get_node_or_null("/root/AudioManager")
    if audio:
        audio.play_music("hub")
    
    # Smooth fade-in
    _fade_in_from_black()

func _fade_in_from_black() -> void:
    var canvas = CanvasLayer.new()
    var color_rect = ColorRect.new()
    color_rect.color = Color(0, 0, 0, 1)
    color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.add_child(color_rect)
    get_tree().root.add_child(canvas)
    
    var tween = create_tween()
    tween.tween_property(color_rect, "color:a", 0.0, 0.6)
    tween.tween_callback(func(): canvas.queue_free())

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
