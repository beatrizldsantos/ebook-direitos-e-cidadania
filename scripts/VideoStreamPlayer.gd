extends VideoStreamPlayer

@onready var video_stream_player: VideoStreamPlayer = $"."
@onready var panel := get_tree().get_current_scene().get_node("Control/Panel")

var touch_start_pos: Vector2

func _ready():
	add_to_group("video_group")
	video_stream_player.stop()
	AudioManager.audio_forced_on.connect(_on_audio_forced_on)
	AudioManager.enabled_changed.connect(_on_audio_toggled)


func _input(event):

	if event is InputEventScreenTouch:
		if not panel.get_global_rect().has_point(event.position):
			return

		if event.pressed:
			touch_start_pos = event.position
		else:
			_handle_tap_or_swipe(event.position)

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not panel.get_global_rect().has_point(event.position):
			return

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
				return

			if not AudioManager.is_enabled:
				video_stream_player.paused = true
				return

			AudioManager.stop()
			return

		else:
			if not AudioManager.is_enabled:
				return

			AudioManager.stop()
			video_stream_player.play()
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
