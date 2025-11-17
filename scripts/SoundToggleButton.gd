extends TextureButton

@export var texture_on: Texture2D
@export var texture_off: Texture2D

func _ready():
	AudioManager.enabled_changed.connect(_on_enabled_changed)
	_update_icon(AudioManager.is_enabled)

func _on_pressed():
	AudioManager.toggle()

func _on_enabled_changed(value: bool):
	_update_icon(value)

func _update_icon(enabled: bool):
	texture_normal = texture_on if enabled else texture_off
