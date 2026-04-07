extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var num_sfx_players: int = 8

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	
	for i in range(num_sfx_players):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_players.append(p)

func play_sfx(sound_name: String) -> void:
	var path = "res://assets/audio/sfx/" + sound_name + ".wav"
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/sfx/" + sound_name + ".ogg"
	if ResourceLoader.exists(path):
		var player = _get_available_sfx_player()
		player.stream = load(path)
		player.play()

func play_music(track_name: String) -> void:
	var path = "res://assets/audio/music/" + track_name + ".ogg"
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/music/" + track_name + ".wav"
	if ResourceLoader.exists(path):
		var stream = load(path)
		if music_player.stream == stream: return
		
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, 1.0)
		tween.tween_callback(func(): 
			music_player.stream = stream
			music_player.play()
		)
		tween.tween_property(music_player, "volume_db", 0.0, 1.0)

func _get_available_sfx_player() -> AudioStreamPlayer:
	for p in sfx_players:
		if not p.playing:
			return p
	return sfx_players[0]
