extends Node3D

@onready var ui: Node = $WorldUI
@onready var portal: Node = $ReturnPortal
@onready var ball: RigidBody3D = $PenaltyBall

var shots_taken: int = 0
var shots_goal: int = 0
var max_shots: int = 5
var ready_for_shot: bool = true

func _ready() -> void:
    ui.set_objective("Score 3/5 penalties. Move near the ball and press [Space] to shoot.")
    ui.set_status("")

    portal.monitoring = false
    portal.get_node("Collision").disabled = true
    portal.visible = false

    ball.sleeping = true
    ball.gravity_scale = 0
    if ball.physics_material_override == null:
        ball.physics_material_override = PhysicsMaterial.new()
    ball.physics_material_override.bounce = 0.5

func _process(delta: float) -> void:
    if shots_taken >= max_shots:
        return

    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return

    if ready_for_shot and _player_near_ball(player):
        if Input.is_action_just_pressed("ui_accept"):
            _take_shot(player)

func _player_near_ball(player: Node) -> bool:
    return player.global_transform.origin.distance_to(ball.global_transform.origin) < 3.0

func _take_shot(player: Node) -> void:
    shots_taken += 1
    ready_for_shot = false
    ball.gravity_scale = 1.0

    var direction = (Vector3(0, 0, -1) + Vector3(randf() - 0.5, 0, 0)).normalized()
    var strength = 12 + randf() * 4
    ball.global_transform = Transform3D(Basis(), ball.global_transform.origin)
    ball.linear_velocity = direction * strength + Vector3(0, 4, 0)

    ui.set_status("Shot " + str(shots_taken) + " of " + str(max_shots), 2)

    await get_tree().create_timer(1.5).timeout
    _check_goal()

func _check_goal() -> void:
    if $GoalArea.get_overlapping_bodies().has(ball):
        shots_goal += 1
        ui.set_status("Goal! " + str(shots_goal) + " / " + str(max_shots), 2)
    else:
        ui.set_status("Missed! " + str(shots_goal) + " / " + str(max_shots), 2)

    if shots_taken >= max_shots:
        _finish_shootout()
    else:
        ready_for_shot = true
        ball.gravity_scale = 0
        ball.linear_velocity = Vector3.ZERO
        ball.angular_velocity = Vector3.ZERO
        ball.global_transform.origin = Vector3(0, 0.3, -6)

func _finish_shootout() -> void:
    if shots_goal >= 3:
        ui.set_objective("You won the shootout! Return to the hub.")
        ui.set_status("Victory! " + str(shots_goal) + " / " + str(max_shots), 4)
    else:
        ui.set_objective("You lost the shootout. Try again or return to the hub.")
        ui.set_status("Final score " + str(shots_goal) + " / " + str(max_shots), 4)

    portal.monitoring = true
    portal.get_node("Collision").disabled = false
    portal.visible = true
