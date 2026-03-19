extends Node

# Audio Manager - Handles all sound and music playback

var current_music: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 8

# Sound effect dictionary - Add your sounds here (loaded at runtime so missing files don't break the project)
var sfx_library: Dictionary = {}

# Music dictionary
var music_library: Dictionary = {}

func _safe_load_audio(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	return null

func _ready() -> void:
	add_to_group("audio_manager")

	# Initialize audio libraries
	sfx_library = {
		"success": _safe_load_audio("res://assets/sounds/success.wav"),
		"fail": _safe_load_audio("res://assets/sounds/fail.wav"),
		"pickup": _safe_load_audio("res://assets/sounds/pickup.wav"),
		"ui_click": _safe_load_audio("res://assets/sounds/ui_click.wav"),
		"footstep": _safe_load_audio("res://assets/sounds/footstep.wav"),
		"portal": _safe_load_audio("res://assets/sounds/portal.wav"),
	}

	music_library = {
		"menu": _safe_load_audio("res://assets/music/menu.ogg"),
		"hub": _safe_load_audio("res://assets/music/hub.ogg"),
		"gameplay": _safe_load_audio("res://assets/music/gameplay.ogg"),
	}

	# Create SFX players
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)

func _ready() -> void:
	add_to_group("audio_manager")
	
	# Create SFX players
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)

func play_sfx(sound_name: String, volume_db: float = 0.0) -> void:
	if not sfx_library.has(sound_name):
		push_warning("Sound '%s' not found" % sound_name)
		return
	
	var sound = sfx_library[sound_name]
	if sound == null:
		return
	
	# Find available player
	for player in sfx_players:
		if not player.playing:
			player.stream = sound
			player.volume_db = volume_db
			player.play()
			return
	
	print("All SFX players in use")

func play_music(music_name: String, fade_in: bool = true) -> void:
	if not music_library.has(music_name):
		push_warning("Music '%s' not found" % music_name)
		return
	
	var music = music_library[music_name]
	if music == null:
		return
	
	# Stop current music
	if current_music:
		if fade_in:
			var tween = create_tween()
			tween.tween_property(current_music, "volume_db", -80, 0.5)
			await tween.finished
		current_music.stop()
	
	# Play new music
	if not current_music:
		current_music = AudioStreamPlayer.new()
		add_child(current_music)
	
	current_music.stream = music
	if fade_in:
		current_music.volume_db = -80
		current_music.play()
		var tween = create_tween()
		tween.tween_property(current_music, "volume_db", 0, 1.0)
	else:
		current_music.play()

func stop_music(fade_out: bool = true) -> void:
	if current_music and current_music.playing:
		if fade_out:
			var tween = create_tween()
			tween.tween_property(current_music, "volume_db", -80, 0.5)
			await tween.finished
		current_music.stop()

func set_master_volume(volume: float) -> void:
	if AudioServer.get_bus_index("Master") > -1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(clamp(volume, 0.0, 1.0)))

func set_sfx_volume(volume: float) -> void:
	if AudioServer.get_bus_index("SFX") > -1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(clamp(volume, 0.0, 1.0)))
	for player in sfx_players:
		player.bus = "SFX"

func set_music_volume(volume: float) -> void:
	if AudioServer.get_bus_index("Music") > -1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(clamp(volume, 0.0, 1.0)))
	if current_music:
		current_music.bus = "Music"
