extends VideoStreamPlayer

@onready var video_stream_player: VideoStreamPlayer = $"."
var touch_start_pos: Vector2

func _ready():
	video_stream_player.stop()
	
	# SE O ÁUDIO FOR LIGADO → PARE O VÍDEO
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
				if video_stream_player.is_playing():

					video_stream_player.paused = !video_stream_player.paused

					if video_stream_player.paused:
						AudioManager.pause_current()
					else:
						AudioManager.pause_current()
						
				else:
					video_stream_player.play()
					AudioManager.pause_current()

			# deslizar para esquerda = stop
			elif delta.x < -50:
				video_stream_player.stop()
				AudioManager.resume_current()

			# deslizar para cima = reiniciar
			elif delta.y < -50:
				video_stream_player.stop()
				video_stream_player.play()
				AudioManager.pause_current()

func _on_audio_forced_on() -> void:
	# Se o áudio foi ligado → parar vídeo imediatamente
	if video_stream_player.is_playing() and not video_stream_player.paused:
		video_stream_player.stop()
