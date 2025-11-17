extends VideoStreamPlayer

@onready var video_stream_player: VideoStreamPlayer = $"."
var touch_start_pos: Vector2

func _ready():
	video_stream_player.stop()
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
					AudioManager.pause_current()

				else:
					if AudioManager.is_enabled:
						AudioManager.pause_current()

					video_stream_player.play()

			# deslizar para esquerda = stop
			elif delta.x < -50:
				video_stream_player.stop()

				if AudioManager.is_enabled:
					AudioManager.resume_current()

			elif delta.y < -50:
				video_stream_player.stop()

				if AudioManager.is_enabled:
					AudioManager.pause_current()

				video_stream_player.play()

func _on_audio_forced_on() -> void:
	# Se o vídeo estiver tocando, NÃO toca áudio e NÃO pausa vídeo
	if video_stream_player.is_playing() and not video_stream_player.paused:
		return
