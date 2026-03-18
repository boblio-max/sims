extends Control

# Main Menu - Title screen with game start options

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var title_label: Label = $VBoxContainer/TitleLabel

func _ready() -> void:
	GameManager.load_progress()
	
	# Connect buttons
	if play_button:
		play_button.pressed.connect(_on_play)
	if continue_button:
		continue_button.pressed.connect(_on_continue)
		# Disable if no save exists
		continue_button.disabled = GameManager.total_score == 0
	if settings_button:
		settings_button.pressed.connect(_on_settings)
	if quit_button:
		quit_button.pressed.connect(_on_quit)
	
	if title_label:
		title_label.text = "CAREER QUEST"
	
	# Play menu music
	if AudioManager:
		AudioManager.play_music("menu")
	
	# Focus play button
	if play_button:
		play_button.grab_focus()

func _on_play() -> void:
	GameManager.reset_progress()
	AudioManager.play_sfx("ui_click") if AudioManager else null
	get_tree().change_scene_to_file("res://scenes/main_hub.tscn")

func _on_continue() -> void:
	AudioManager.play_sfx("ui_click") if AudioManager else null
	get_tree().change_scene_to_file("res://scenes/main_hub.tscn")

func _on_settings() -> void:
	AudioManager.play_sfx("ui_click") if AudioManager else null
	# Open settings - to be implemented
	print("Settings not implemented yet")

func _on_quit() -> void:
	AudioManager.play_sfx("ui_click") if AudioManager else null
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_quit()
		get_tree().root.set_input_as_handled()
