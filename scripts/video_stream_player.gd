extends VideoStreamPlayer

@onready var video_stream_player: VideoStreamPlayer = $"."

var touch_start_pos: Vector2

func _ready():
	# Não inicia automaticamente, espera o toque
	video_stream_player.stop()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
		else:
			var touch_end_pos = event.position
			var delta = touch_end_pos - touch_start_pos

			# TOQUE SIMPLES = PLAY/PAUSE
			if delta.length() < 20:
				if video_stream_player.is_playing():
					video_stream_player.paused = !video_stream_player.paused
				else:
					video_stream_player.play()

			# ARRASTAR PARA A ESQUERDA = STOP
			elif delta.x < -50:
				video_stream_player.stop()

			# ARRASTAR PARA CIMA = REINICIAR
			elif delta.y < -50:
				video_stream_player.stop()
				video_stream_player.play()
