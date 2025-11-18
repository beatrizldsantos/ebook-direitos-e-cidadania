extends VideoStreamPlayer

@onready var video_stream_player: VideoStreamPlayer = $"."
var touch_start_pos: Vector2

func _ready():
	add_to_group("video_group")  # permite AudioManager forçar stop
	video_stream_player.stop()

	AudioManager.video_playing = false
	AudioManager.audio_forced_on.connect(_on_audio_forced_on)


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position

		else:
			var touch_end_pos = event.position
			var delta = touch_end_pos - touch_start_pos

			# TAP = play/pause
			if delta.length() < 20:

				# vídeo tocando
				if video_stream_player.is_playing():
					video_stream_player.paused = not video_stream_player.paused

					if video_stream_player.paused:
						AudioManager.video_playing = false
						AudioManager.resume_current()
					else:
						AudioManager.video_playing = true
						AudioManager.pause_current()

				else:
					# usuário quer iniciar o vídeo
					AudioManager.video_playing = true
					AudioManager.pause_current()
					video_stream_player.play()

			# deslizar para esquerda = parar vídeo
			elif delta.x < -50:
				force_video_stop()
				AudioManager.resume_current()

			# deslizar para cima = restart vídeo
			elif delta.y < -50:
				force_video_stop()
				AudioManager.pause_current()
				AudioManager.video_playing = true
				video_stream_player.play()


# chamado pelo AudioManager quando som é ligado
func _on_audio_forced_on() -> void:
	if video_stream_player.is_playing() and not video_stream_player.paused:
		force_video_stop()  # Regra 2
		# audio será iniciado pelo AudioManager


# forçar parada total (regra 2)
func force_video_stop() -> void:
	video_stream_player.stop()
	AudioManager.video_playing = false
