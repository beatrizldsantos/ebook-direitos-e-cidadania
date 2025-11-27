extends TextureRect
@export var tipo_esperado: String = ""

@onready var main_controller = get_node("../../../")

func _can_drop_data(_at_position, data):
	if data is Dictionary and data.has("tipo"):
		return data["tipo"] == tipo_esperado
	return false

func _drop_data(_at_position, data):
	data["no_origem"].visible = false
	self.visible = false # Esconde a caixa de drop imediatamente
	if main_controller:
		main_controller.processar_drop_correto(tipo_esperado)
