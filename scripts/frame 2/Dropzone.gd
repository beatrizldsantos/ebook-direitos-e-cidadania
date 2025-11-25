extends TextureRect

@export var accepted_type: String 
@export var frame2_path: NodePath

var frame2: Node


func _ready():
	if frame2_path == NodePath(""):
		push_error("Dropzone: frame2_path não configurado para %s" % [get_path()])
		return
	if not has_node(frame2_path):
		push_error("Dropzone: Node não encontrado em frame2_path '%s' (em %s)" % [str(frame2_path), get_path()])
		return
	frame2 = get_node(frame2_path)
	
	mouse_filter = Control.MOUSE_FILTER_STOP


func _can_drop_data(_at_position, data) -> bool:
	if not data.has("type"):
		print("Drop rejeitado: Dados inválidos (sem 'type')")
		return false
		
	if data["type"] != accepted_type:
		print("Drop rejeitado: Tipo '%s' não aceito em '%s' (esperado: '%s')" % [data["type"], name, accepted_type])
		return false
		
	print("Drop aceito! Tipo: ", data["type"])
	return true


func _drop_data(_at_position, data):
	if not _can_drop_data(_at_position, data):
		return

	var card: TextureRect = data["source"]

	card.queue_free()
	queue_free()

	if frame2:
		frame2.card_dropped(accepted_type)
