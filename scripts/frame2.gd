extends Node2D

# --- REFERÊNCIAS AOS NODES (Arraste do Inspector) ---

@export_group("Cartões")
@export var card_civis: Control
@export var card_politicos: Control
@export var card_sociais: Control

@export_group("Dropzones")
@export var drop_civis: Control
@export var drop_politicos: Control
@export var drop_sociais: Control

@export_group("Pirâmide")
@export var pyramid_base: Control
@export var pyramid_meio: Control
@export var pyramid_topo: Control

# Estado interno
var drops_completed = 0
const TOTAL_DROPS = 3

func _ready():
	# Garante o estado inicial correto ao carregar a cena
	reset_activity()

func reset_activity():
	drops_completed = 0
	
	# 1. Mostrar todos os Cartões
	if card_civis: card_civis.visible = true
	if card_politicos: card_politicos.visible = true
	if card_sociais: card_sociais.visible = true
	
	# 2. Mostrar todas as Dropzones
	if drop_civis: drop_civis.visible = true
	if drop_politicos: drop_politicos.visible = true
	if drop_sociais: drop_sociais.visible = true
	
	# 3. Esconder a Pirâmide (começa apagada)
	if pyramid_base: pyramid_base.visible = false
	if pyramid_meio: pyramid_meio.visible = false
	if pyramid_topo: pyramid_topo.visible = false
	
	print("Atividade reiniciada.")

# Método chamado pelos scripts das Dropzones
func card_dropped(type: String):
	print("Cartão solto corretamente: ", type)
	
	match type:
		"civis":
			# Some cartão e dropzone, aparece base
			if card_civis: card_civis.visible = false
			if drop_civis: drop_civis.visible = false
			if pyramid_base: pyramid_base.visible = true
			drops_completed += 1
			
		"politicos":
			# Some cartão e dropzone, aparece meio
			if card_politicos: card_politicos.visible = false
			if drop_politicos: drop_politicos.visible = false
			if pyramid_meio: pyramid_meio.visible = true
			drops_completed += 1
			
		"sociais":
			# Some cartão e dropzone, aparece topo
			if card_sociais: card_sociais.visible = false
			if drop_sociais: drop_sociais.visible = false
			if pyramid_topo: pyramid_topo.visible = true
			drops_completed += 1
			
	check_victory()

func check_victory():
	# Se todos os 3 drops foram feitos, a pirâmide deve estar completa
	if drops_completed >= TOTAL_DROPS:
		print("Parabéns! Pirâmide completa.")
		# Aqui você pode adicionar lógica extra de vitória se desejar
