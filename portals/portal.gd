extends Area3D

@export var target_scene: String = ""

func _ready() -> void:
    connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
    if not body.is_in_group("player"):
        return
    if target_scene == "":
        return
    get_tree().change_scene_to_file(target_scene)
