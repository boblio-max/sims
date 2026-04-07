extends Node

signal career_completed(career_name)
signal all_careers_completed

var completed_careers: Array = []
var total_careers: int = 5
var is_game_started: bool = false
var is_game_finished: bool = false

func start_game():
	is_game_started = true
	completed_careers = []
	is_game_finished = false

func restart_game():
	is_game_started = false
	is_game_finished = false
	completed_careers = []

func complete_career(career_name: String):
	if not completed_careers.has(career_name):
		completed_careers.append(career_name)
		career_completed.emit(career_name)
		
		if completed_careers.size() >= total_careers:
			is_game_finished = true
			all_careers_completed.emit()

func is_career_completed(career_name: String) -> bool:
	return completed_careers.has(career_name)

func get_progress_string() -> String:
	return str(completed_careers.size()) + " / " + str(total_careers)

func fix_environment_collisions(root_node: Node) -> void:
	for node in root_node.get_children():
		if node is MeshInstance3D:
			var parent = node.get_parent()
			if parent is CollisionObject3D:
				pass
			else:
				var has_collision = false
				for child in node.get_children():
					if child is CollisionObject3D:
						has_collision = true
						break
				
				if not has_collision and node.mesh != null:
					node.create_trimesh_collision()
					var static_body = node.get_child(node.get_child_count() - 1)
					if static_body:
						static_body.name = "AutoCollision"
						
		if node is CSGShape3D:
			node.use_collision = true

		
		if node.get_child_count() > 0:
			fix_environment_collisions(node)
