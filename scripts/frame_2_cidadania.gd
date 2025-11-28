extends Node2D
@onready var piramide_base = $ControlCards/Piramide/Base
@onready var piramide_meio = $ControlCards/Piramide/Meio
@onready var piramide_topo = $ControlCards/Piramide/Topo

@onready var drop_zones = $ControlCards/DropZone

@onready var balao = $ControlCards/Piramide/balao_piramide


@onready var sprit2d_panel = $Control/Sprit2dPanel
@onready var balao_olimpiadas = $Control/Balaoolimpiadas

func _ready():
	piramide_base.visible = false
	piramide_meio.visible = false
	piramide_topo.visible = false
	
	
	if balao:
		balao.visible = false

	if has_node("ControlCards"):
		$ControlCards.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if has_node("ControlCards/Cards"):
		$ControlCards/Cards.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if has_node("ControlCards/DropZone"):
		$ControlCards/DropZone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	if sprit2d_panel:
		sprit2d_panel.gui_input.connect(_on_sprit2d_panel_gui_input)

func _on_sprit2d_panel_gui_input(event):
	if event is InputEventScreenTouch and event.pressed:
		_show_balao_olimpiadas()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_balao_olimpiadas()

func _show_balao_olimpiadas():
	if balao_olimpiadas:
		balao_olimpiadas.visible = true
		get_tree().create_timer(10.0).timeout.connect(func(): if balao_olimpiadas: balao_olimpiadas.visible = false)


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
