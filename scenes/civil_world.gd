extends Node3D

@onready var ui: Node = $WorldUI
@onready var portal: Node = $ReturnPortal

var blocks: Array[Node3D] = []
var target_rotations: Array[float] = []

func _ready() -> void:
    ui.set_objective("Rotate each block to match the blueprint. Use [Space] when near a block.")
    ui.set_status("")

    portal.monitoring = false
    portal.get_node("Collision").disabled = true
    portal.visible = false

    blocks = [$BlockA, $BlockB, $BlockC]
    target_rotations = [0.0, PI / 2, PI]

func _process(delta: float) -> void:
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return

    for i in range(blocks.size()):
        var block = blocks[i]
        if player.global_transform.origin.distance_to(block.global_transform.origin) < 3.0:
            if Input.is_action_just_pressed("ui_accept"):
                _rotate_block(i)

    if _all_blocks_correct():
        _finish_build()

func _rotate_block(index: int) -> void:
    var block = blocks[index]
    var basis = block.global_transform.basis.rotated(Vector3.UP, PI/2)
    block.global_transform = Transform3D(basis, block.global_transform.origin)
    ui.set_status("Rotated block " + str(index + 1), 1.2)

func _all_blocks_correct() -> bool:
    for i in range(blocks.size()):
        var current = blocks[i].global_transform.basis.get_euler().y
        if abs(fmod(current + PI * 2, PI*2) - target_rotations[i]) > 0.1:
            return false
    return true

func _finish_build() -> void:
    ui.set_objective("Perfect build! Return to the hub.")
    ui.set_status("Construction complete.", 3)
    portal.monitoring = true
    portal.get_node("Collision").disabled = false
    portal.visible = true
