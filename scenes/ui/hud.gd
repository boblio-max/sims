extends CanvasLayer

@onready var progress_text: Label = %ProgressText
@onready var interaction_prompt: Label = %InteractionPrompt
@onready var notification: Label = %Notification
@onready var objective_panel: PanelContainer = %ObjectivePanel
@onready var objective_desc: Label = %ObjectiveDesc
@onready var objective_progress: Label = %ObjectiveProgress

var discovery_tween: Tween
var career_labels: Dictionary = {}

# Career names and their display colors
const CAREERS = {
	"Software Engineer": Color(0.2, 1, 0.3),
	"Civil Engineer": Color(1, 0.7, 0.2),
	"Doctor": Color(1, 0.3, 0.3),
	"Lawyer": Color(0.7, 0.3, 1),
	"Politician": Color(0.3, 0.3, 1),
}

func _ready() -> void:
	GameState.career_completed.connect(_on_career_completed)
	ObjectiveManager.objective_updated.connect(_on_objective_updated)
	ObjectiveManager.all_objectives_done.connect(_on_all_objectives_done)
	
	# Create crosshair
	_create_crosshair()
	
	# Create career tracker
	_create_career_tracker()
	
	# Initial slide-in for ProgressPanel
	var progress_panel = $Control/ProgressPanel
	var start_pos = progress_panel.position
	progress_panel.position.x = -250
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).tween_property(progress_panel, "position:x", start_pos.x, 0.8)
	update_hud()

func _create_crosshair() -> void:
	var crosshair = Control.new()
	crosshair.name = "Crosshair"
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.offset_left = -10
	crosshair.offset_top = -10
	crosshair.offset_right = 10
	crosshair.offset_bottom = 10
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Dot
	var dot = ColorRect.new()
	dot.color = Color(1, 1, 1, 0.7)
	dot.set_anchors_preset(Control.PRESET_CENTER)
	dot.offset_left = -2
	dot.offset_top = -2
	dot.offset_right = 2
	dot.offset_bottom = 2
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair.add_child(dot)
	
	$Control.add_child(crosshair)

func _create_career_tracker() -> void:
	var tracker = HBoxContainer.new()
	tracker.name = "CareerTracker"
	tracker.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	tracker.offset_left = -200
	tracker.offset_top = -50
	tracker.offset_right = 200
	tracker.offset_bottom = -15
	tracker.add_theme_constant_override("separation", 12)
	tracker.alignment = BoxContainer.ALIGNMENT_CENTER
	tracker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for career_name in CAREERS:
		var container = VBoxContainer.new()
		container.add_theme_constant_override("separation", 2)
		container.alignment = BoxContainer.ALIGNMENT_CENTER
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Icon circle
		var icon = ColorRect.new()
		icon.custom_minimum_size = Vector2(28, 28)
		icon.color = CAREERS[career_name] * 0.5
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(icon)
		
		# Short label
		var short_name = career_name.split(" ")[0].left(4) # "Soft", "Civi", "Doct", etc.
		var lbl = Label.new()
		lbl.text = short_name
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(lbl)
		
		tracker.add_child(container)
		career_labels[career_name] = {"icon": icon, "label": lbl}
	
	# Update already-completed careers
	for career_name in GameState.completed_careers:
		_mark_career_completed_ui(career_name)
	
	$Control.add_child(tracker)

func _mark_career_completed_ui(career_name: String) -> void:
	if career_name in career_labels:
		var data = career_labels[career_name]
		data["icon"].color = CAREERS[career_name]
		data["label"].add_theme_color_override("font_color", CAREERS[career_name])
		data["label"].text = "✓"

func update_hud() -> void:
	progress_text.text = GameState.get_progress_string()

func _on_career_completed(career_name: String) -> void:
	update_hud()
	_mark_career_completed_ui(career_name)
	show_notification(career_name + " Mastered!", Color(0.1, 1, 0.5))
	if JuiceManager:
		JuiceManager.shake_camera(0.1, 0.5)
		JuiceManager.flash_screen(Color(0, 1, 0.5, 0.1), 0.2)
	if AudioManager:
		AudioManager.play_sfx("victory")

func show_notification(message: String, color: Color = Color.WHITE) -> void:
	notification.text = ""
	notification.modulate = color
	notification.visible = true
	
	if discovery_tween: discovery_tween.kill()
	discovery_tween = create_tween()
	
	# Typewriter effect
	for i in range(message.length()):
		discovery_tween.tween_callback(func(): notification.text += message[i]).set_delay(0.04)
	
	discovery_tween.tween_interval(2.0)
	discovery_tween.tween_property(notification, "modulate:a", 0.0, 1.0)
	discovery_tween.tween_callback(func(): notification.visible = false)

func set_interaction_prompt(visible: bool, text: String = "Press [E] to Interact") -> void:
	interaction_prompt.text = text
	interaction_prompt.visible = visible
	if visible:
		interaction_prompt.scale = Vector2(0.8, 0.8)
		create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).tween_property(interaction_prompt, "scale", Vector2(1.0, 1.0), 0.5)

func _on_objective_updated(current: int, total: int, description: String) -> void:
	if not objective_panel.visible:
		objective_panel.visible = true
		objective_panel.position.x = get_viewport().size.x + 300
		create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).tween_property(objective_panel, "position:x", get_viewport().size.x - 270, 0.8)
	
	objective_desc.text = description
	objective_progress.text = str(current) + " / " + str(total)
	
	# Punch animation on progress
	objective_progress.scale = Vector2(1.5, 1.5)
	create_tween().tween_property(objective_progress, "scale", Vector2(1.0, 1.0), 0.3)

func _on_all_objectives_done() -> void:
	show_notification("Objective Complete!", Color(1, 0.8, 0.2))
	create_tween().set_delay(2.0).tween_property(objective_panel, "position:x", get_viewport().size.x + 300, 0.8).finished.connect(func(): objective_panel.visible = false)
