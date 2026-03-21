extends CanvasLayer

# Enhanced WorldUI - Better visual feedback and status management
# Supports glassmorphism style and dynamic animations

@export var objective_text: String = ""
@export var status_text: String = ""

@onready var objective_label: Label = $ObjectiveLabel
@onready var status_label: Label = $StatusLabel

var status_tween: Tween = null
var bg_panel: Panel = null

func _ready() -> void:
	# Add a background panel for glassmorphism effect if it doesn't exist
	if not has_node("GlassPanel"):
		bg_panel = Panel.new()
		bg_panel.name = "GlassPanel"
		add_child(bg_panel)
		move_child(bg_panel, 0) # Place behind labels
		
		# Setup professional look
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0.4)
		style.corner_radius_top_left = 12
		style.corner_radius_bottom_left = 12
		style.corner_radius_top_right = 12
		style.corner_radius_bottom_right = 12
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_color = Color(1, 1, 1, 0.1)
		bg_panel.add_theme_stylebox_override("panel", style)
		
		bg_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		bg_panel.offset_left = 10
		bg_panel.offset_top = 10
		bg_panel.offset_right = 620
		bg_panel.offset_bottom = 120
		bg_panel.modulate.a = 0.0

	objective_label.text = objective_text
	status_label.text = status_text
	
	# Setup better styling
	if objective_label:
		objective_label.modulate.a = 0.0
		objective_label.add_theme_font_size_override("font_size", 28)
		objective_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	if status_label:
		status_label.modulate.a = 0.0
		status_label.add_theme_font_size_override("font_size", 24)
	
	# Initial fade in
	var twin = create_tween()
	twin.tween_property(bg_panel, "modulate:a", 1.0, 0.5)
	twin.parallel().tween_property(objective_label, "modulate:a", 1.0, 0.5)

func set_objective(text: String) -> void:
	if objective_label:
		if objective_label.text == text: return
		
		var tween = create_tween()
		tween.tween_property(objective_label, "modulate:a", 0.0, 0.2)
		tween.tween_callback(func(): objective_label.text = text)
		tween.tween_property(objective_label, "modulate:a", 1.0, 0.3)

func set_status(text: String, duration: float = 2.0, color: Color = Color.WHITE) -> void:
	if not status_label:
		return
	
	if status_tween:
		status_tween.kill()
	
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)
	
	status_tween = create_tween()
	status_tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Fade and slide in
	status_label.position.y = 80 # Original position
	status_tween.tween_property(status_label, "modulate:a", 1.0, 0.2)
	
	if duration > 0:
		status_tween.tween_interval(duration)
		status_tween.tween_property(status_label, "modulate:a", 0.0, 0.4)

func show_critical(text: String) -> void:
	set_status(text, 4.0, Color(1.0, 0.8, 0.2)) # Gold/Yellow for critical
	
	if status_tween:
		status_tween.parallel().tween_property(status_label, "scale", Vector2(1.1, 1.1), 0.2)
		status_tween.tween_property(status_label, "scale", Vector2(1.0, 1.0), 0.1)

func flash_status(text: String, is_success: bool = true) -> void:
	var color = Color(0.4, 1.0, 0.4) if is_success else Color(1.0, 0.4, 0.4)
	set_status(text, 1.5, color)

func show_progress(current: int, total: int) -> void:
	var percent = float(current) / total
	set_status("Progress: %d/%d (%d%%)" % [current, total, int(percent * 100)], 1.5, Color(0.3, 0.8, 1.0))
