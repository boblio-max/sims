extends Node

# Global game state manager - Autoload singleton
# Add to Project -> Project Settings -> Autoload as "GameManager"

signal paused_changed
signal score_changed

@export var master_volume: float = 0.8
@export var music_volume: float = 0.7
@export var sfx_volume: float = 0.8

# Tracking career completion
var careers_completed: Dictionary = {
	"Software Engineer": false,
	"Doctor": false,
	"Lawyer": false,
	"Civil Engineer": false,
	"Soccer Player": false,
}

var career_scores: Dictionary = {
	"Software Engineer": 0,
	"Doctor": 0,
	"Lawyer": 0,
	"Civil Engineer": 0,
	"Soccer Player": 0,
}

var total_score: int = 0
var current_career: String = ""
var is_paused: bool = false

func _ready() -> void:
	add_to_group("game_manager")

func mark_career_complete(career_name: String, score: int = 100) -> void:
	if careers_completed.has(career_name):
		careers_completed[career_name] = true
		career_scores[career_name] = score
		total_score += score
		save_progress()
		print("Career '%s' completed! Total score: %d" % [career_name, total_score])

func get_completion_percentage() -> float:
	var completed = 0
	for complete in careers_completed.values():
		if complete:
			completed += 1
	return float(completed) / careers_completed.size() * 100.0

func reset_progress() -> void:
	careers_completed = {
		"Software Engineer": false,
		"Doctor": false,
		"Lawyer": false,
		"Civil Engineer": false,
		"Soccer Player": false,
	}
	career_scores = {
		"Software Engineer": 0,
		"Doctor": 0,
		"Lawyer": 0,
		"Civil Engineer": 0,
		"Soccer Player": 0,
	}
	total_score = 0
	current_career = ""
	save_progress()

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	paused_changed.emit()

func save_progress() -> void:
	var save_data = {
		"careers": careers_completed,
		"scores": career_scores,
		"total": total_score,
	}
	# Could be saved to file here
	print("Progress saved: %s" % save_data)

func load_progress() -> void:
	# Could load from file here
	pass

func set_audio_volumes(master: float, music: float, sfx: float) -> void:
	master_volume = clamp(master, 0.0, 1.0)
	music_volume = clamp(music, 0.0, 1.0)
	sfx_volume = clamp(sfx, 0.0, 1.0)
	
	# Apply to audio busses if they exist
	if AudioServer.get_bus_index("Music") > -1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_volume))
	if AudioServer.get_bus_index("SFX") > -1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))
