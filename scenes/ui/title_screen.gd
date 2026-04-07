extends CanvasLayer

@onready var play_button: Button = %PlayButton
@onready var how_to_button: Button = %HowToButton
@onready var quit_button: Button = %QuitButton

var showing_instructions: bool = false

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	how_to_button.pressed.connect(_on_how_to_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Animate title in
	var title_box = $Control/TitleBox
	title_box.modulate.a = 0
	title_box.position.y += 30
	var original_y = title_box.position.y - 30
	var tween = create_tween().set_parallel(true)
	tween.tween_property(title_box, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_box, "position:y", original_y, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_play_pressed() -> void:
	# Animate out
	var title_box = $Control/TitleBox
	var tween = create_tween().set_parallel(true)
	tween.tween_property(title_box, "modulate:a", 0.0, 0.3)
	tween.tween_property(title_box, "position:y", title_box.position.y - 20, 0.3)
	tween.tween_property($Control/BackgroundBlur, "color:a", 0.0, 0.3)
	await tween.finished
	
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameState.start_game()
	queue_free()

func _on_how_to_pressed() -> void:
	if showing_instructions: return
	showing_instructions = true
	
	# In-game instructions overlay
	var overlay = ColorRect.new()
	overlay.name = "InstructionsOverlay"
	overlay.color = Color(0, 0, 0, 0.75)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -320
	vbox.offset_top = -220
	vbox.offset_right = 320
	vbox.offset_bottom = 220
	vbox.add_theme_constant_override("separation", 8)
	overlay.add_child(vbox)
	
	var title = Label.new()
	title.text = "HOW TO PLAY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1, 0.84, 0))
	vbox.add_child(title)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	var sections = [
		["CONTROLS", Color(0.4, 0.8, 1)],
		["  WASD — Move around", Color.WHITE],
		["  Mouse — Look around", Color.WHITE],
		["  SPACE — Jump", Color.WHITE],
		["  SHIFT — Sprint", Color.WHITE],
		["  E — Interact with objects", Color.WHITE],
		["  ESC — Pause menu", Color.WHITE],
		["", Color.WHITE],
		["YOUR MISSION", Color(1, 0.84, 0)],
		["  Walk through portals to visit 5 career worlds.", Color.WHITE],
		["  Complete each career's unique mini-game:", Color.WHITE],
		["", Color.WHITE],
		["  💻  Software Engineer — Fix 4 bugs", Color(0.2, 1, 0.3)],
		["  🏗️  Civil Engineer — Scan 3 structural points", Color(1, 0.7, 0.2)],
		["  🩺  Doctor — Treat 3 patients correctly", Color(1, 0.3, 0.3)],
		["  ⚖️  Lawyer — Find 3 hidden evidence pieces", Color(0.7, 0.3, 1)],
		["  🏛️  Politician — Convince 3 voters", Color(0.3, 0.3, 1)],
		["", Color.WHITE],
		["  Complete all 5 to win!", Color(1, 0.9, 0)],
	]
	
	for section in sections:
		var lbl = Label.new()
		lbl.text = section[0]
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.add_theme_color_override("font_color", section[1])
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
		vbox.add_child(lbl)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 5)
	vbox.add_child(spacer)
	
	var close_btn = Button.new()
	close_btn.text = "Got it!"
	close_btn.custom_minimum_size = Vector2(0, 45)
	close_btn.add_theme_font_size_override("font_size", 20)
	close_btn.pressed.connect(func():
		overlay.queue_free()
		showing_instructions = false
	)
	vbox.add_child(close_btn)
	
	# Animate in
	overlay.modulate.a = 0
	$Control.add_child(overlay)
	create_tween().tween_property(overlay, "modulate:a", 1.0, 0.2)

func _on_quit_pressed() -> void:
	get_tree().quit()
