extends CharacterBody3D

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	velocity.x = 0
	velocity.z = 0
		
	move_and_slide()
