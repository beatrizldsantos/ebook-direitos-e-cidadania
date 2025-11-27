extends TextureRect 

@export var tipo_cartao: String = ""

func _get_drag_data(at_position):
	var data = {
		"tipo": tipo_cartao,
		"no_origem": self
	}
	
	var preview = self.duplicate()
	preview.modulate.a = 0.5 
	
	var c = Control.new()
	c.add_child(preview)
	preview.position = -preview.size / 2
	set_drag_preview(c)
	
	return data
