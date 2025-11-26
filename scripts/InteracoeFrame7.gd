extends Node2D

@export_group("Configurações de Limite")
@export var area_limite: Control # <--- ARRASTE O NÓ 'AreaLimite' PARA CÁ NO INSPECTOR

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
@onready var topic_oque_e_cid = $Interacoes/Topics/TopicItem_OQueECid

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var mapas_de_interacao: Dictionary = {}
var touch_index: int = -1 

func _ready() -> void:
	mapas_de_interacao = {
		topic_cidadania: tex_balao_cidadania,
		topic_estadania: tex_balao_estadania,
		topic_direitos: tex_balao_direitos,
		topic_participacao: tex_balao_participacao,
		topic_oque_e_cid: tex_balao_oque_e_cid
	}
	
	drag_button.gui_input.connect(_on_drag_button_input)
	
	if balao_feedback:
		balao_feedback.visible = false

func _input(event: InputEvent) -> void:
	if not is_dragging:
		return

	if event is InputEventScreenTouch:
		if not event.pressed and event.index == touch_index:
			_on_drag_end()
	
	elif event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_drag_end()

func _process(_delta: float) -> void:
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		
		var nova_posicao = mouse_pos - drag_offset
		
		if area_limite:
			var rect = area_limite.get_global_rect()
			
			var largura_btn = drag_button.size.x * drag_button.scale.x
			var altura_btn = drag_button.size.y * drag_button.scale.y
			
		
			nova_posicao.x = clamp(nova_posicao.x, rect.position.x, rect.end.x - largura_btn)
			nova_posicao.y = clamp(nova_posicao.y, rect.position.y, rect.end.y - altura_btn)
		
		# 3. Aplicamos a posição final
		drag_button.global_position = nova_posicao
		
		_verificar_hover_nos_topicos(mouse_pos)

func _on_drag_button_input(event: InputEvent) -> void:
	if is_dragging: return
	if event is InputEventScreenTouch and event.pressed:
		touch_index = event.index
		_iniciar_arraste()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_iniciar_arraste()

func _iniciar_arraste() -> void:
	var global_pos = get_global_mouse_position()
	is_dragging = true
	drag_offset = global_pos - drag_button.global_position
	drag_button.move_to_front()

func _on_drag_end() -> void:
	is_dragging = false
	touch_index = -1
	if balao_feedback:
		balao_feedback.visible = false
	

func _verificar_hover_nos_topicos(mouse_pos: Vector2) -> void:
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
