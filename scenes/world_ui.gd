extends CanvasLayer

@export var objective_text: String = ""
@export var status_text: String = ""

@onready var objective_label: Label = $ObjectiveLabel
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
    objective_label.text = objective_text
    status_label.text = status_text

func set_objective(text: String) -> void:
    objective_label.text = text

func set_status(text: String, duration: float = 2.0) -> void:
    status_label.text = text
    if duration > 0:
        await get_tree().create_timer(duration).timeout
        status_label.text = ""
