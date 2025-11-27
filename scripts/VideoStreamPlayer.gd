extends VideoStreamPlayer

@onready var video_stream_player: VideoStreamPlayer = $"."

var touch_start_pos: Vector2

func _ready():
	add_to_group("video_group")
	video_stream_player.stop()
	AudioManager.audio_forced_on.connect(_on_audio_forced_on)
	AudioManager.enabled_changed.connect(_on_audio_toggled)

var last_input_time: int = 0

func _input(event):
	# Debug para verificar o que está chegando
	# print("Evento: ", event) 
	var valid_input = false
	
	# Verifica Toque
	if event is InputEventScreenTouch:
		valid_input = true
	# Verifica Mouse
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		valid_input = true
		
	if not valid_input:
		return

	# Verifica se o evento ocorreu dentro da área do VideoStreamPlayer
	if not get_global_rect().has_point(event.position):
		return

	# DEBOUNCE: Evita duplo clique (Touch + Mouse emulado)
	# Se o evento atual acontecer muito rápido após o último, ignoramos.
	var current_time = Time.get_ticks_msec()
	if current_time - last_input_time < 100: # 100ms de tolerância
		return
	
	if event.pressed:
		touch_start_pos = event.position
	else:
		last_input_time = current_time # Atualiza tempo apenas no release (ação)
		# Pequeno delay ou verificação direta para garantir que o toque soltou
		_handle_tap_or_swipe(event.position)


func _handle_tap_or_swipe(end_pos: Vector2) -> void:
	var delta = end_pos - touch_start_pos

	if delta.length() < 20:
		if video_stream_player.is_playing():
			video_stream_player.paused = not video_stream_player.paused

			if video_stream_player.paused:
				return

			if not AudioManager.is_enabled:
				video_stream_player.paused = true
				return

			AudioManager.stop()
			return

		else:
			# Se não estiver tocando, força o play
			AudioManager.stop()
			video_stream_player.play()
			video_stream_player.paused = false # Garante que não está pausado
			return

	elif delta.x < -50:
		var was_playing := video_stream_player.is_playing()
		video_stream_player.stop()

		if was_playing and AudioManager.is_enabled:
			AudioManager.play_for_page(AudioManager.current_page_index)

		return

	elif delta.y < -50:
		if not AudioManager.is_enabled:
			return

		video_stream_player.stop()
		AudioManager.stop()
		video_stream_player.play()
		return


func _on_audio_forced_on() -> void:
	if video_stream_player.is_playing() and not video_stream_player.paused:
		video_stream_player.stop()


func _on_audio_toggled(value: bool) -> void:
	if not value:
		if video_stream_player.is_playing() or video_stream_player.paused:
			video_stream_player.stop()
