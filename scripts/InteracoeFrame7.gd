extends Node2D
@export_group("Texturas dos Balões")
@export var tex_balao_cidadania: Texture2D
@export var tex_balao_estadania: Texture2D
@export var tex_balao_direitos: Texture2D
@export var tex_balao_participacao: Texture2D
@export var tex_balao_oque_e_cid: Texture2D 


@onready var drag_button: TextureButton = $DragButton
@onready var balao_feedback: TextureRect = $DragButton/BalaoFeedback

@onready var topic_cidadania = $Interacoes/Topics/TopicItem_Cidadania
@onready var topic_estadania = $Interacoes/Topics/TopicItem_Estadania
@onready var topic_direitos = $Interacoes/Topics/TopicItem_DireitosHumanos
@onready var topic_participacao = $Interacoes/Topics/TopicItem_ParticipacaoSocial
@onready var topic_oque_e_cid = $Interacoes/Topics/TopicItem_OQueECid # <--- NOVO NÓ


var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var mapas_de_interacao: Dictionary = {}

func _ready() -> void:
	mapas_de_interacao = {
		topic_cidadania: tex_balao_cidadania,
		topic_estadania: tex_balao_estadania,
		topic_direitos: tex_balao_direitos,
		topic_participacao: tex_balao_participacao,
		topic_oque_e_cid: tex_balao_oque_e_cid 
	}
	
	drag_button.button_down.connect(_on_drag_start)
	drag_button.button_up.connect(_on_drag_end)
	
	if balao_feedback:
		balao_feedback.visible = false
	else:
		push_error("ALERTA: Crie um TextureRect chamado 'BalaoFeedback' dentro do DragButton")

func _process(_delta: float) -> void:
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		drag_button.global_position = mouse_pos - drag_offset
		_verificar_hover_nos_topicos()

func _on_drag_start() -> void:
	is_dragging = true
	drag_offset = get_global_mouse_position() - drag_button.global_position
	drag_button.move_to_front() 

func _on_drag_end() -> void:
	is_dragging = false
	if balao_feedback:
		balao_feedback.visible = false

func _verificar_hover_nos_topicos() -> void:
	var mouse_pos = get_global_mouse_position()
	var encontrou_algum = false
	
	for topic_node in mapas_de_interacao.keys():
		if topic_node and topic_node.get_global_rect().has_point(mouse_pos):
			_mostrar_balao(mapas_de_interacao[topic_node])
			encontrou_algum = true
			break 
	
	if not encontrou_algum and balao_feedback:
		balao_feedback.visible = false

func _mostrar_balao(textura: Texture2D) -> void:
	if balao_feedback.texture != textura or not balao_feedback.visible:
		balao_feedback.texture = textura
		balao_feedback.visible = true
