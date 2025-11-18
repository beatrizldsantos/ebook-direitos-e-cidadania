extends VideoStreamPlayer

@onready var video_stream_player: VideoStreamPlayer = $"."
var touch_start_pos: Vector2

func _ready():
	add_to_group("video_group") 
	video_stream_player.stop()

	AudioManager.video_playing = false
	AudioManager.audio_forced_on.connect(_on_audio_forced_on)


func _input(event):

	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
		else:
			_handle_tap_or_swipe(event.position)

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			touch_start_pos = event.position
		else:
			_handle_tap_or_swipe(event.position)


func _handle_tap_or_swipe(end_pos: Vector2) -> void:
	var delta = end_pos - touch_start_pos

	if delta.length() < 20:

		if video_stream_player.is_playing():
			video_stream_player.paused = not video_stream_player.paused

			if video_stream_player.paused:
				AudioManager.video_playing = false
				# NÃO chamar AudioManager.resume_current()

			# voltou a tocar → garante áudio da tela pausado
			else:
				AudioManager.video_playing = true
				AudioManager.pause_current()

		else:
			AudioManager.video_playing = true
			AudioManager.pause_current() 
			video_stream_player.play()

	elif delta.x < -50:
		force_video_stop()
		
	elif delta.y < -50:
		force_video_stop()
		AudioManager.pause_current()      
		AudioManager.video_playing = true
		video_stream_player.play()

func _on_audio_forced_on() -> void:

	if video_stream_player.is_playing() and not video_stream_player.paused:
		force_video_stop()

# usado pelo AudioManager via call_group("video_group", "force_video_stop")
func force_video_stop() -> void:
	video_stream_player.stop()
	AudioManager.video_playing = false
