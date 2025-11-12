extends Node

signal enabled_changed(is_enabled: bool)

var is_enabled: bool = true


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

# Página atual (espelha Main.pagina_atual)
var current_page_index: int = 0

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)
	_player.bus = "Narration" 
	_player.autoplay = false
	_player.stream = null
	_player.volume_db = 0.0
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	_apply_enabled_state()

func set_enabled(value: bool) -> void:
	if is_enabled == value:
		return
	is_enabled = value
	_apply_enabled_state()
	emit_signal("enabled_changed", is_enabled)
	if is_enabled:
		play_for_page(current_page_index)
	else:
		stop()

func toggle() -> void:
	set_enabled(!is_enabled)

func _apply_enabled_state() -> void:
	# Se usar bus dedicado, você pode só mutar o bus:
	# AudioServer.set_bus_mute(AudioServer.get_bus_index("Narration"), !is_enabled)
	# OU controlar o player diretamente (mais simples e explícito):
	if not is_enabled:
		stop()

func play_for_page(page_index: int) -> void:
	current_page_index = clamp(page_index, 0, _streams.size() - 1)
	if not is_enabled:
		return
	var stream: AudioStream = _streams[current_page_index]
	if stream == null:
		stop()
		return
	if _player.stream != stream:
		_player.stop()
		_player.stream = stream
	_player.play()

func stop() -> void:
	if _player.playing:
		_player.stop()

func refresh_current_page() -> void:
	play_for_page(current_page_index)
