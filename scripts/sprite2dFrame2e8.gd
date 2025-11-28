@tool
extends Sprite2D

@export var animation_speed: float = 8.0
@export var total_frames: int = 4

func _ready():
	hframes = total_frames
	vframes = 1
	frame = 0

func _process(_delta):
	if hframes != total_frames:
		hframes = total_frames
	if vframes != 1:
		vframes = 1
	var current_time = Time.get_ticks_msec() / 1000.0
	frame = int(current_time * animation_speed) % total_frames
