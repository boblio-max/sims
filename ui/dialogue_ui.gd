extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/NameLabel
@onready var content_label: Label = $Panel/ContentLabel
@onready var prompt_label: Label = $Panel/PromptLabel
@onready var interact_hint: Label = $InteractHint if has_node("InteractHint") else null

var current_lines: Array[String] = []
var current_line_index: int = 0
var is_active: bool = false
var char_name: String = ""
var is_typing: bool = false
var type_timer: SceneTreeTimer = null

func _ready() -> void:
	panel.hide()
	if interact_hint:
		interact_hint.hide()
	add_to_group("dialogue_ui")

func show_dialogue(npc_name: String, lines: Array[String]) -> void:
	if is_active:
		return
		
	char_name = npc_name
	current_lines = lines
	current_line_index = 0
	is_active = true
	
	if interact_hint:
		interact_hint.hide()
		
	panel.show()
	_display_current_line()

func set_interact_hint_visible(visible: bool) -> void:
	if not is_active and interact_hint:
		interact_hint.visible = visible

func _input(event: InputEvent) -> void:
	if not is_active:
		return
		
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			_skip_typing()
		else:
			_next_line()

func _display_current_line() -> void:
	name_label.text = char_name
	content_label.text = ""
	_type_text(current_lines[current_line_index])

func _type_text(text: String) -> void:
	is_typing = true
	content_label.text = ""
	for i in range(text.length()):
		if not is_typing: break
		content_label.text += text[i]
		
		# Play a subtle sound if AudioManager exists
		if i % 2 == 0 and AudioManager:
			# AudioManager.play_sfx("type") # Optional if sound exists
			pass
			
		await get_tree().create_timer(0.03).timeout
	
	is_typing = false

func _skip_typing() -> void:
	is_typing = false
	content_label.text = current_lines[current_line_index]

func _next_line() -> void:
	current_line_index += 1
	if current_line_index < current_lines.size():
		_display_current_line()
	else:
		_close_dialogue()

func _close_dialogue() -> void:
	is_active = false
	panel.hide()

func _process(_delta: float) -> void:
	if not is_active:
		return
		
	# Keep prompt blinking if active and not typing
	if not is_typing:
		prompt_label.visible = fmod(OS.get_ticks_msec() / 500.0, 2.0) < 1.0
	else:
		prompt_label.visible = false
