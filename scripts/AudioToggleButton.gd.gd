extends TextureButton


@export var texture_on: Texture2D
@export var texture_off: Texture2D

func _ready() -> void:
	
	_sync_visual(AudioManager.is_enabled)
	
	if not AudioManager.enabled_changed.is_connected(_on_enabled_changed):
		AudioManager.enabled_changed.connect(_on_enabled_changed)

func _on_enabled_changed(is_enabled: bool) -> void:
	_sync_visual(is_enabled)

func _sync_visual(is_enabled: bool) -> void:
	
	if texture_on and texture_off:
		texture_normal = texture_on if is_enabled else texture_off


	button_pressed = not is_enabled

func _pressed() -> void:

	AudioManager.toggle()

	if AudioManager.is_enabled:
		AudioManager.play_for_page(Main.pagina_atual)
