extends CanvasLayer

signal diagnosis_complete(success: bool)

@onready var symptom_label: Label = %SymptomLabel
@onready var option1: Button = %Option1
@onready var option2: Button = %Option2

var correct_option: int = 0
var already_answered: bool = false

func _ready() -> void:
	option1.pressed.connect(func(): _on_option_selected(1))
	option2.pressed.connect(func(): _on_option_selected(2))
	
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Animate panel in
	var panel = $Control/Panel
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)

func setup(symptom: String, opt1: String, opt2: String, correct: int) -> void:
	symptom_label.text = ""
	option1.text = opt1
	option2.text = opt2
	correct_option = correct
	
	# Hide buttons until text finishes
	option1.visible = false
	option2.visible = false
	
	# Typewriter effect
	var tween = create_tween()
	for i in range(symptom.length()):
		tween.tween_callback(func(): symptom_label.text += symptom[i]).set_delay(0.025)
	
	# Show buttons after text completes
	tween.tween_callback(func():
		option1.visible = true
		option2.visible = true
		# Pop buttons in
		option1.scale = Vector2(0.5, 0.5)
		option2.scale = Vector2(0.5, 0.5)
		create_tween().tween_property(option1, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_ELASTIC)
		create_tween().tween_property(option2, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_ELASTIC)
	)

func _on_option_selected(index: int) -> void:
	if already_answered: return
	already_answered = true
	
	if AudioManager:
		AudioManager.play_sfx("button_click")
	
	var success = (index == correct_option)
	
	# Visual feedback before closing
	var selected_btn = option1 if index == 1 else option2
	var other_btn = option2 if index == 1 else option1
	
	if success:
		selected_btn.add_theme_color_override("font_color", Color(0, 1, 0.5))
		selected_btn.text = "✓ " + selected_btn.text
	else:
		selected_btn.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		selected_btn.text = "✗ " + selected_btn.text
		# Show correct answer
		var correct_btn = option1 if correct_option == 1 else option2
		correct_btn.add_theme_color_override("font_color", Color(0, 1, 0.5))
		correct_btn.text = "✓ " + correct_btn.text
	
	other_btn.disabled = true
	selected_btn.disabled = true
	
	# Brief delay so player sees feedback
	await get_tree().create_timer(0.8).timeout
	
	# Animate out
	var panel = $Control/Panel
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(0.8, 0.8), 0.2)
	tween.tween_property(panel, "modulate:a", 0.0, 0.2)
	await tween.finished
	
	diagnosis_complete.emit(success)
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()
