extends CanvasLayer

# Enhanced WorldUI - Better visual feedback and status management

@export var objective_text: String = ""
@export var status_text: String = ""

@onready var objective_label: Label = $ObjectiveLabel
@onready var status_label: Label = $StatusLabel

var status_tween: Tween = null

func _ready() -> void:
	objective_label.text = objective_text
	status_label.text = status_text
	
	# Setup better styling
	if objective_label:
		objective_label.modulate.a = 0.9
	if status_label:
		status_label.modulate.a = 0.0

func set_objective(text: String) -> void:
	if objective_label:
		objective_label.text = text
		# Animate appearance
		if objective_label.modulate.a < 0.9:
			var tween = create_tween()
			tween.tween_property(objective_label, "modulate:a", 0.9, 0.3)

func set_status(text: String, duration: float = 2.0) -> void:
	if not status_label:
		return
	
	# Cancel previous tween if exists
	if status_tween:
		status_tween.kill()
	
	status_label.text = text
	status_tween = create_tween()
	
	# Fade in
	status_tween.tween_property(status_label, "modulate:a", 1.0, 0.2)
	
	# Hold
	if duration > 0:
		status_tween.tween_callback(func(): pass).set_delay(duration - 0.2)
	
	# Fade out
	status_tween.tween_property(status_label, "modulate:a", 0.0, 0.3)

func show_critical(text: String) -> void:
	if not status_label:
		return
	
	if status_tween:
		status_tween.kill()
	
	status_label.text = text
	status_label.modulate.a = 0.0
	
	status_tween = create_tween()
	status_tween.set_trans(Tween.TRANS_BOUNCE)
	status_tween.tween_property(status_label, "modulate:a", 1.0, 0.4)
	status_tween.tween_callback(func(): pass).set_delay(3.0)
	status_tween.tween_property(status_label, "modulate:a", 0.0, 0.3)

func flash_status(text: String) -> void:
	if not status_label:
		return
	
	if status_tween:
		status_tween.kill()
	
	status_label.text = text
	status_label.modulate.a = 0.0
	
	status_tween = create_tween()
	status_tween.tween_property(status_label, "modulate:a", 1.0, 0.15)
	status_tween.tween_callback(func(): pass).set_delay(1.5)
	status_tween.tween_property(status_label, "modulate:a", 0.0, 0.2)

func show_progress(current: int, total: int) -> void:
	set_status("Progress: %d/%d" % [current, total], 1.0)

func clear_status() -> void:
	if status_tween:
		status_tween.kill()
	status_label.text = ""
	status_label.modulate.a = 0.0
