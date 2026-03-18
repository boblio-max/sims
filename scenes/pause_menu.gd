extends CanvasLayer

# Pause Menu - Appears when game is paused

@onready var pause_panel: PanelContainer = $PausePanel
@onready var resume_button: Button = $PausePanel/VBoxContainer/ResumeButton
@onready var menu_button: Button = $PausePanel/VBoxContainer/MenuButton
@onready var quit_button: Button = $PausePanel/VBoxContainer/QuitButton
@onready var settings_button: Button = $PausePanel/VBoxContainer/SettingsButton

func _ready() -> void:
	visible = false
	
	if resume_button:
		resume_button.pressed.connect(_on_resume)
	if menu_button:
		menu_button.pressed.connect(_on_return_to_menu)
	if quit_button:
		quit_button.pressed.connect(_on_quit)
	if settings_button:
		settings_button.pressed.connect(_on_settings)
	
	GameManager.paused_changed.connect(_on_pause_toggled)

func _on_pause_toggled() -> void:
	visible = GameManager.is_paused
	if visible:
		# Focus first button
		if resume_button:
			resume_button.grab_focus()

func _on_resume() -> void:
	GameManager.toggle_pause()

func _on_return_to_menu() -> void:
	GameManager.is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit() -> void:
	get_tree().quit()

func _on_settings() -> void:
	# Open settings dialog
	print("Settings not implemented yet")

# Also handle ESC key press
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		_on_resume()
		get_tree().root.set_input_as_handled()
