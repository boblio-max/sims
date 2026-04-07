extends Node3D

## Path to the target scene to teleport to (e.g. "res://scenes/doctor_world.tscn").
@export var target_scene: String = ""

var career_map: Dictionary = {
	"res://scenes/software_engineer_world.tscn": "Software Engineer",
	"res://scenes/civil_engineer_world.tscn": "Civil Engineer",
	"res://scenes/doctor_world.tscn": "Doctor",
	"res://scenes/lawyer_world.tscn": "Lawyer",
	"res://scenes/politician_world.tscn": "Politician",
}

func _ready() -> void:
	# Check if this portal's career is already completed
	_update_portal_visual()

func _update_portal_visual() -> void:
	if target_scene in career_map:
		var career = career_map[target_scene]
		if GameState.is_career_completed(career):
			# Make portal glow green to show completion
			var glow_mesh = get_node_or_null("PortalGlow")
			if glow_mesh and glow_mesh is MeshInstance3D:
				var mat = StandardMaterial3D.new()
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mat.albedo_color = Color(0.1, 0.9, 0.2, 0.6)
				mat.emission_enabled = true
				mat.emission = Color(0.1, 1, 0.2)
				mat.emission_energy_multiplier = 3.0
				glow_mesh.set_surface_override_material(0, mat)

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and target_scene != "":
		# Fade transition
		if JuiceManager:
			JuiceManager.flash_screen(Color(1, 1, 1, 0.3), 0.4)
		
		# Small delay for the flash to register
		await get_tree().create_timer(0.15).timeout
		get_tree().change_scene_to_file(target_scene)
