extends Sprite2D

@export var animation_speed: float = 10.0
@export var total_frames: int = 10

func _ready():
	hframes = total_frames
	vframes = 1
	frame = 0

func _process(_delta):
	var current_frame = int(Time.get_ticks_msec() / 1000.0 * animation_speed) % total_frames
	frame = current_frame
