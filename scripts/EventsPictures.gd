extends TextureRect

const IMAGENS := [
	preload("res://assets/images/Components_Frame 6/6.1 Assem.const.png"),
	preload("res://assets/images/Components_Frame 6/6.2 Mov.Sem.T.png"),
	preload("res://assets/images/Components_Frame 6/6.3 Mov.Ind.png"),
	preload("res://assets/images/Components_Frame 6/6.4 Frent.Luta.png"),
	preload("res://assets/images/Components_Frame 6/6.5 Diretas.Já.png")
]

var indice_atual: int = 0


func _ready() -> void:
	texture = IMAGENS[indice_atual]


var current_angle: float = 0.0
var smoothing_speed: float = 5.0

func _physics_process(delta: float) -> void:
	# Tenta usar a gravidade (mais estável), fallback para acelerômetro
	var sensor_vector = Input.get_gravity()
	if sensor_vector == Vector3.ZERO:
		sensor_vector = Input.get_accelerometer()
	
	if sensor_vector == Vector3.ZERO:
		return

	# Calcula o ângulo de inclinação (Roll)
	# No Android: Inclinar para Esquerda gera X negativo -> Ângulo Positivo
	var target_angle = rad_to_deg(atan2(sensor_vector.x, sensor_vector.y)) * -1.0
	
	# Suaviza o valor do ângulo para evitar tremedeira nas imagens
	current_angle = lerp(current_angle, target_angle, smoothing_speed * delta)

	var novo_indice := _indice_por_angulo(current_angle)

	if novo_indice != indice_atual:
		indice_atual = novo_indice
		texture = IMAGENS[indice_atual]


func _indice_por_angulo(angulo: float) -> int:
	# Intervalos ajustados para maior conforto (máximo ~60 graus)
	if angulo < 10.0:
		return 0
	elif angulo < 25.0:
		return 1
	elif angulo < 40.0:
		return 2
	elif angulo < 55.0:
		return 3
	else:
		return 4


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		indice_atual = min(indice_atual + 1, IMAGENS.size() - 1)
		texture = IMAGENS[indice_atual]
	elif event.is_action_pressed("ui_left"):
		indice_atual = max(indice_atual - 1, 0)
		texture = IMAGENS[indice_atual]
