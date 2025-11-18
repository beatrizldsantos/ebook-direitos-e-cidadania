extends Node

signal enabled_changed(is_enabled: bool)
signal audio_forced_on

var is_enabled: bool = true
var current_page_index: int = 0

# controla se o vídeo da página atual está rodando
var video_playing: bool = false  

var _player: AudioStreamPlayer

var _streams: Array[AudioStream] = [
	preload("res://assets/audio/t1_audio.wav"),
	preload("res://assets/audio/t2_audio.wav"),
	preload("res://assets/audio/t3_audio.wav"),
	preload("res://assets/audio/t4_audio.wav"),
	preload("res://assets/audio/t5_audio.wav"),
	preload("res://assets/audio/t6_audio.wav"),
	preload("res://assets/audio/t7_audio.wav"),
	preload("res://assets/audio/t8_audio.wav")
]

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)
	_player.bus = "Narration"
	_player.autoplay = false
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_enabled_state()


func set_enabled(value: bool) -> void:
	if is_enabled == value:
		return

	is_enabled = value
	_apply_enabled_state()
	emit_signal("enabled_changed", is_enabled)

	if is_enabled:
		emit_signal("audio_forced_on")

		# Se vídeo está rodando → parar vídeo (regra 2)
		if video_playing:
			get_tree().call_group("video_group", "force_video_stop")

		# depois que o vídeo parar, tocar áudio (regra 2)
		play_for_page(current_page_index)

	else:
		stop()


func toggle() -> void:
	set_enabled(!is_enabled)
	
func force_stop():
	_player.stop()

func _apply_enabled_state() -> void:
	if not is_enabled:
		stop()


func play_for_page(page_index: int) -> void:
	current_page_index = clamp(page_index, 0, _streams.size() - 1)

	# Vídeo rodando = NUNCA tocar áudio da página 5
	if video_playing:
		return
	
	if not is_enabled:
		return

	var stream = _streams[current_page_index]

	if _player.stream != stream:
		_player.stop()
		_player.stream = stream

	_player.play()


func stop() -> void:
	if _player.playing:
		_player.stop()


func refresh_current_page() -> void:
	play_for_page(current_page_index)


func pause_current() -> void:
	if _player.playing:
		_player.stream_paused = true


func resume_current() -> void:
	if not is_enabled:
		return
	if video_playing:
		return
	if _player.stream:
		_player.stream_paused = false
