extends CanvasLayer

@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Celebratory audio
	if AudioManager:
		AudioManager.play_sfx("victory_fanfare")
	
	# Pause the game and show mouse
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Animate the whole panel in
	var control = $Control
	control.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(control, "modulate:a", 1.0, 0.5)
	
	# Delay fireworks
	await get_tree().create_timer(0.8).timeout
	if not is_inside_tree(): return
	
	var fw_left = get_node_or_null("Control/FireworkLeft")
	var fw_right = get_node_or_null("Control/FireworkRight")
	
	if fw_left: fw_left.emitting = true
	if fw_right: fw_right.emitting = true
	
	if JuiceManager:
		JuiceManager.shake_camera(0.15, 0.5)
	
	# Periodic fireworks
	while is_inside_tree():
		await get_tree().create_timer(randf_range(1.5, 3.0)).timeout
		if not is_inside_tree(): return
		var targets = []
		if fw_left: targets.append(fw_left)
		if fw_right: targets.append(fw_right)
		if targets.size() > 0:
			var f = targets[randi() % targets.size()]
			f.restart()
			f.emitting = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameState.restart_game()
	get_tree().change_scene_to_file("res://scenes/main_hub.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
