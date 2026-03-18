extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/NameLabel
@onready var content_label: Label = $Panel/ContentLabel

var current_lines: Array[String] = []
var current_line_index: int = 0
var is_active: bool = false
var char_name: String = ""

func _ready() -> void:
	panel.hide()
	add_to_group("dialogue_ui")

func show_dialogue(npc_name: String, lines: Array[String]) -> void:
	if is_active:
		return
		
	char_name = npc_name
	current_lines = lines
	current_line_index = 0
	is_active = true
	
	_update_ui()
	panel.show()
	
	# Optional: Lock player movement
	# GameManager.is_paused = true # This pauses everything, maybe not ideal
	# better to just handle it in the player script

func _input(event: InputEvent) -> void:
	if not is_active:
		return
		
	if event.is_action_pressed("ui_accept"):
		_next_line()

func _next_line() -> void:
	current_line_index += 1
	if current_line_index < current_lines.size():
		_update_ui()
	else:
		_close_dialogue()

func _update_ui() -> void:
	name_label.text = char_name
	content_label.text = current_lines[current_line_index]

func _close_dialogue() -> void:
	is_active = false
	panel.hide()
	
	# Resume player etc.
