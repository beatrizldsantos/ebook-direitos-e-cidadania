extends TextureRect

@export var card_type: String # "civis", "politicos", "sociais"


func _get_drag_data(_at_position):
	var preview := TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = size
	
	preview.position = - preview.size / 2
	
	preview.modulate = Color(1, 1, 1, 0.5)

	set_drag_preview(preview)

	print("drag iniciado:", card_type)

	return {
		"type": card_type,
		"source": self
	}


func _can_drop_data(_at_position, _data) -> bool:
	return false


func _drop_data(_at_position, _data):
	pass
