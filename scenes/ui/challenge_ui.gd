extends CanvasLayer

signal challenge_complete(success: bool)

var title_text: String = "Challenge"
var title_color: Color = Color.WHITE
var scenario_text: String = ""
var options: Array = []  # Array of {text: String, correct: bool}
var fun_fact: String = ""
var already_answered: bool = false

# Timer logic
var time_limit: float = 15.0
var time_left: float = 15.0
var timer_label: Label
var timer_active: bool = false

func _ready() -> void:
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func setup(config: Dictionary) -> void:
	title_text = config.get("title", "Challenge")
	title_color = config.get("color", Color.WHITE)
	scenario_text = config.get("scenario", "")
	options = config.get("options", [])
	fun_fact = config.get("fun_fact", "")
	
	_build_ui()

func _build_ui() -> void:
	# Background overlay
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)
	
	# Main container
	var panel = PanelContainer.new()
	panel.name = "MainPanel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -340
	panel.offset_top = -220
	panel.offset_right = 340
	panel.offset_bottom = 220
	bg.add_child(panel)
	
	# StyleBox for the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.border_color = title_color * 0.6
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(0)
	panel.add_theme_stylebox_override("panel", style)
	
	var outer_vbox = VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", 0)
	panel.add_child(outer_vbox)
	
	# === TITLE BAR ===
	var title_bar = PanelContainer.new()
	var title_style = StyleBoxFlat.new()
	title_style.bg_color = title_color * 0.25
	title_style.set_content_margin_all(12)
	title_style.corner_radius_top_left = 10
	title_style.corner_radius_top_right = 10
	title_bar.add_theme_stylebox_override("panel", title_style)
	outer_vbox.add_child(title_bar)
	
	var title_label = Label.new()
	title_label.text = title_text
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", 26)
	title_label.add_theme_color_override("font_color", title_color)
	
	var title_hbox = HBoxContainer.new()
	title_hbox.add_child(title_label)
	
	# Timer
	timer_label = Label.new()
	timer_label.text = "15.0s"
	timer_label.add_theme_font_size_override("font_size", 20)
	timer_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	title_hbox.add_child(timer_label)
	
	title_bar.add_child(title_hbox)
	
	# === CONTENT AREA ===
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 20)
	outer_vbox.add_child(margin)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.name = "ContentVBox"
	content_vbox.add_theme_constant_override("separation", 14)
	margin.add_child(content_vbox)
	
	# Scenario text
	var scenario_label = Label.new()
	scenario_label.name = "ScenarioLabel"
	scenario_label.text = ""
	scenario_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	scenario_label.add_theme_font_size_override("font_size", 16)
	scenario_label.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
	content_vbox.add_child(scenario_label)
	
	# Separator
	var sep = HSeparator.new()
	sep.add_theme_color_override("separator", Color(1, 1, 1, 0.1))
	content_vbox.add_child(sep)
	
	# Options container
	var options_vbox = VBoxContainer.new()
	options_vbox.name = "OptionsVBox"
	options_vbox.add_theme_constant_override("separation", 8)
	content_vbox.add_child(options_vbox)
	
	# Fun fact label (hidden initially)
	var fact_label = Label.new()
	fact_label.name = "FactLabel"
	fact_label.visible = false
	fact_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	fact_label.add_theme_font_size_override("font_size", 14)
	fact_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1))
	content_vbox.add_child(fact_label)
	
	# Animate panel in
	panel.scale = Vector2(0.85, 0.85)
	panel.modulate.a = 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	
	# Typewriter the scenario
	await tween.finished
	var tw = create_tween()
	for i in range(scenario_text.length()):
		var ch = scenario_text[i]
		tw.tween_callback(func(): scenario_label.text += ch).set_delay(0.018)
	
	# After text, show options
	tw.tween_callback(_show_options)
	
func _process(delta: float) -> void:
	if timer_active and not already_answered:
		# Use unscaled delta because tree is paused
		time_left -= delta
		if time_left < 0:
			time_left = 0
			_on_timeout()
		timer_label.text = "%.1fs" % time_left
        
func _on_timeout() -> void:
	if already_answered: return
	already_answered = true
	timer_active = false
	timer_label.text = "TIME'S UP!"
	timer_label.add_theme_color_override("font_color", Color.RED)
	
	if JuiceManager:
		JuiceManager.shake_camera(0.15, 0.4)
		JuiceManager.flash_screen(Color(1, 0, 0, 0.15), 0.2)
		
	# Find all option buttons to disable
	var options_vbox = _find_node_recursive(self, "OptionsVBox")
	if options_vbox:
		for i in range(options_vbox.get_child_count()):
			var btn = options_vbox.get_child(i) as Button
			if btn: btn.disabled = true
			
	await get_tree().create_timer(1.5).timeout
	_close(false)


func _show_options() -> void:
	var options_vbox = get_node_or_null("*/MainPanel/*/ContentVBox/OptionsVBox")
	if not options_vbox:
		# Fallback: find it
		options_vbox = _find_node_recursive(self, "OptionsVBox")
	if not options_vbox: return
	
	for i in range(options.size()):
		var opt = options[i]
		var btn = Button.new()
		btn.name = "Option_" + str(i)
		btn.text = opt["text"]
		btn.custom_minimum_size = Vector2(0, 42)
		btn.add_theme_font_size_override("font_size", 15)
		
		# Style the button
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
		btn_style.set_border_width_all(1)
		btn_style.border_color = Color(1, 1, 1, 0.15)
		btn_style.set_corner_radius_all(6)
		btn_style.set_content_margin_all(10)
		btn.add_theme_stylebox_override("normal", btn_style)
		
		var hover_style = btn_style.duplicate()
		hover_style.bg_color = title_color * 0.3
		hover_style.border_color = title_color * 0.6
		btn.add_theme_stylebox_override("hover", hover_style)
		
		var idx = i
		btn.pressed.connect(func(): _on_option_selected(idx))
		options_vbox.add_child(btn)
		
		# Pop in animation
		btn.scale = Vector2(0.7, 0.7)
		btn.modulate.a = 0
		var delay = i * 0.08
		var t = create_tween().set_parallel(true)
		t.tween_property(btn, "scale", Vector2(1, 1), 0.25).set_trans(Tween.TRANS_ELASTIC).set_delay(delay)
		t.tween_property(btn, "modulate:a", 1.0, 0.15).set_delay(delay)

	# Start timer after options are shown
	timer_active = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_option_selected(index: int) -> void:
	if already_answered: return
	already_answered = true
	
	if AudioManager:
		AudioManager.play_sfx("button_click")
	
	var is_correct = options[index].get("correct", false)
	
	# Find all option buttons
	var options_vbox = _find_node_recursive(self, "OptionsVBox")
	if options_vbox:
		for i in range(options_vbox.get_child_count()):
			var btn = options_vbox.get_child(i) as Button
			if not btn: continue
			btn.disabled = true
			
			if i == index:
				if is_correct:
					btn.text = "✓  " + btn.text
					btn.add_theme_color_override("font_color", Color(0.2, 1, 0.4))
				else:
					btn.text = "✗  " + btn.text
					btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
			
			# Always highlight the correct answer
			if options[i].get("correct", false) and (not is_correct or i != index):
				btn.text = "✓  " + btn.text
				btn.add_theme_color_override("font_color", Color(0.2, 1, 0.4))
	
	# Show fun fact
	var fact_label = _find_node_recursive(self, "FactLabel")
	if fact_label and fun_fact != "":
		fact_label.text = "💡 " + fun_fact
		fact_label.visible = true
		fact_label.modulate.a = 0
		create_tween().tween_property(fact_label, "modulate:a", 1.0, 0.3)
	
	# Juice
	if is_correct:
		if JuiceManager:
			JuiceManager.flash_screen(Color(0, 1, 0.5, 0.08), 0.15)
	else:
		if JuiceManager:
			JuiceManager.shake_camera(0.1, 0.3)
	
	# Delay then close
	await get_tree().create_timer(2.0).timeout
	_close(is_correct)

func _close(success: bool) -> void:
	var panel = _find_node_recursive(self, "MainPanel")
	if panel:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(panel, "scale", Vector2(0.85, 0.85), 0.2)
		tween.tween_property(panel, "modulate:a", 0.0, 0.2)
		await tween.finished
	
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if success:
		challenge_complete.emit(true)
	else:
		# If it's a fail (like timeout or wrong answer if we want strict mode)
		# But the existing code says "always emit true so you can proceed"
		# Let's make time out fail!
		challenge_complete.emit(false)
		
	queue_free()

func _find_node_recursive(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var result = _find_node_recursive(child, target_name)
		if result: return result
	return null
