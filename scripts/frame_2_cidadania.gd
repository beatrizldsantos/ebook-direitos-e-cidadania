extends Node2D
@onready var piramide_base = $ControlCards/Piramide/Base
@onready var piramide_meio = $ControlCards/Piramide/Meio
@onready var piramide_topo = $ControlCards/Piramide/Topo

@onready var drop_zones = $ControlCards/DropZone
# Caminho atualizado conforme solicitação exata
@onready var balao = $ControlCards/Piramide/balao_piramide

func _ready():
	piramide_base.visible = false
	piramide_meio.visible = false
	piramide_topo.visible = false
	
	# Garante que começa invisível, se o nó existir
	if balao:
		balao.visible = false

	if has_node("ControlCards"):
		$ControlCards.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if has_node("ControlCards/Cards"):
		$ControlCards/Cards.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if has_node("ControlCards/DropZone"):
		$ControlCards/DropZone.mouse_filter = Control.MOUSE_FILTER_IGNORE

func processar_drop_correto(tipo_cartao: String):
	match tipo_cartao:
		"civis":
			piramide_topo.visible = true
		"politicos":
			piramide_meio.visible = true
		"sociais":
			piramide_base.visible = true
	
	verificar_vitoria()

func verificar_vitoria():
	if piramide_base.visible and piramide_meio.visible and piramide_topo.visible:
		print("A pirâmide está completa.")
		drop_zones.visible = false
		if balao:
			balao.visible = true
