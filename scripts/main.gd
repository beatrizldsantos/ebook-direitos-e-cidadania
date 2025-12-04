extends Node

var paginas = [
	"res://scenes/frame1_capa.tscn",
	"res://scenes/frame2_cidadania.tscn",
	"res://scenes/frame3_cidVsEstad.tscn",
	"res://scenes/frame4_dirHum.tscn",
	"res://scenes/frame5_cidFormal.tscn",
	"res://scenes/frame6_participSocial.tscn",
	"res://scenes/frame7_futuro.tscn",
	"res://scenes/frame9_Cidademrede.tscn",
	"res://scenes/frame8_contracapa.tscn"
]

var pagina_atual := 0

func _ready() -> void:
	AudioManager.play_for_page(0)

func _go_to_page(index: int) -> void:
	pagina_atual = clamp(index, 0, paginas.size() - 1)

	AudioManager.play_for_page(pagina_atual)
	
	get_tree().change_scene_to_file(paginas[pagina_atual])

func proxima_pagina() -> void:
	if pagina_atual < paginas.size() - 1:
		_go_to_page(pagina_atual + 1)

func pagina_anterior() -> void:
	if pagina_atual > 0:
		_go_to_page(pagina_atual - 1)

func pagina_inicial() -> void:
	_go_to_page(0)
