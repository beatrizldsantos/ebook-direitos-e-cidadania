extends TextureRect

# imagens em ordem de inclinação
const IMAGENS := [
	preload("res://assets/images/Components_Frame 6/6.1 Assem.const.png"),
	preload("res://assets/images/Components_Frame 6/6.2 Mov.Sem.T.png"),
	preload("res://assets/images/Components_Frame 6/6.3 Mov.Ind.png"),
	preload("res://assets/images/Components_Frame 6/6.4 Frent.Luta.png"),
	preload("res://assets/images/Components_Frame 6/6.5 Diretas.Já.png")
]

var indice_atual: int = 0


func _ready() -> void:
	# começa mostrando a primeira imagem
	texture = IMAGENS[indice_atual]


func _physics_process(_delta: float) -> void:
	# tenta sensores reais (para celular/tablet)
	var acc := Input.get_accelerometer()
	var grav := Input.get_gravity()

	var angulo: float

	if acc != Vector3.ZERO:
		angulo = rad_to_deg(atan2(acc.x, acc.y)) * -1.0
	elif grav != Vector3.ZERO:
		angulo = rad_to_deg(atan2(grav.x, grav.y)) * -1.0
	else:
		# no notebook normalmente não existe sensor
		return

	var novo_indice := _indice_por_angulo(angulo)

	if novo_indice != indice_atual:
		indice_atual = novo_indice
		texture = IMAGENS[indice_atual]


func _indice_por_angulo(angulo: float) -> int:
	if angulo < 30.0:
		return 0
	elif angulo < 55.0:
		return 1
	elif angulo < 75.0:
		return 2
	elif angulo < 95.0:
		return 3
	else:
		return 4


# --- TESTE NO NOTEBOOK ---
# Use → e ← para mudar imagens
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		indice_atual = min(indice_atual + 1, IMAGENS.size() - 1)
		texture = IMAGENS[indice_atual]
	elif event.is_action_pressed("ui_left"):
		indice_atual = max(indice_atual - 1, 0)
		texture = IMAGENS[indice_atual]
