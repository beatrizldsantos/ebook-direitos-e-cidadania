extends Node

var paginas = [
	"res://scenes/frame1_capa.tscn",
	"res://scenes/frame2_cidadania.tscn",
	"res://scenes/frame3_cidVsEstad.tscn",
	"res://scenes/frame4_dirHum.tscn",
	"res://scenes/frame5_cidFormal.tscn",
	"res://scenes/frame6_participSocial.tscn",
	"res://scenes/frame7_futuro.tscn",
	"res://scenes/frame8_contracapa.tscn"
]
var pagina_atual = 0

func proxima_pagina():
	print(pagina_atual)
	if pagina_atual < paginas.size() - 1:
		pagina_atual += 1
		get_tree().change_scene_to_file(paginas[pagina_atual])

func pagina_anterior():
	print(pagina_atual)
	if pagina_atual > 0:
		pagina_atual -= 1
		get_tree().change_scene_to_file(paginas[pagina_atual])

func pagina_inicial():
	print(pagina_atual)
	pagina_atual = 0
	get_tree().change_scene_to_file(paginas[pagina_atual])
