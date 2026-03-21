extends Area3D

@export var target_scene: String = ""

func _ready() -> void:
    connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
    if not body.is_in_group("player"):
        return
    if target_scene == "":
        return
    
    if body.is_in_group("player"):
		# Play portal sound
		var audio = get_node_or_null("/root/AudioManager")
		if audio:
			audio.play_sfx("portal")
		
		# Optional: Add a screen fade effect here
		_fade_to_black()
		
		# Wait for fade
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file(target_scene)

func _fade_to_black() -> void:
	var canvas = CanvasLayer.new()
	var color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(color_rect)
	get_tree().root.add_child(canvas)
	
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.4)
