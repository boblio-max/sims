extends Node

# Signal for camera to listen to
signal shake_requested(intensity: float, duration: float)

func shake_camera(intensity: float = 0.2, duration: float = 0.3) -> void:
	shake_requested.emit(intensity, duration)

func flash_screen(color: Color = Color.WHITE, duration: float = 0.1) -> void:
	var canvas = CanvasLayer.new()
	var rect = ColorRect.new()
	rect.color = color
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(rect)
	get_tree().root.add_child(canvas)
	
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(canvas.queue_free)

func time_freeze(scale: float = 0.1, duration: float = 0.05) -> void:
	Engine.time_scale = scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
