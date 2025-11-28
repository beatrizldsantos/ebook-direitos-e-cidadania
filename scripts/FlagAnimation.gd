extends Sprite2D

@export var animation_speed: float = 10.0
@export var total_frames: int = 10

var frame_width: float

func _ready():
	hframes = total_frames
	vframes = 1
	frame = 0

	if texture:
		frame_width = texture.get_width() / total_frames
	else:
		push_error("Texture não atribuída ao Sprite2D")

func _process(_delta):
	if not texture:
		return

	var current_frame = int(Time.get_ticks_msec() / 1000.0 * animation_speed) % total_frames
	frame = current_frame
