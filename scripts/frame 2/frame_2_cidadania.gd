extends Node

@onready var pyramid_base  = $ControlCards/Piramide/Base
@onready var pyramid_mid   = $ControlCards/Piramide/Meio
@onready var pyramid_top   = $ControlCards/Piramide/Topo

var placed_civis := false
var placed_politicos := false
var placed_sociais := false


func _ready():

	pyramid_base.modulate = Color(1,1,1,0)
	pyramid_mid.modulate  = Color(1,1,1,0)
	pyramid_top.modulate  = Color(1,1,1,0)


func card_dropped(card_type: String):
	match card_type:
		"civis":
			placed_civis = true
			_show_layer(pyramid_base)

		"politicos":
			placed_politicos = true
			_show_layer(pyramid_mid)

		"sociais":
			placed_sociais = true
			_show_layer(pyramid_top)

	_check_complete()


func _show_layer(node: TextureRect):
	var new_color = node.modulate
	new_color.a = 1.0
	node.modulate = new_color


func _check_complete():
	if placed_civis and placed_politicos and placed_sociais:
		print("Pirâmide concluída!")
