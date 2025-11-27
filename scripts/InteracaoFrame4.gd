extends Node2D

@onready var pentagono = $InteractiveArea/PentagonContainer
@onready var connections = $InteractiveArea/Connections

var is_dragging: bool = false
var completed: bool = false
var center_pos: Vector2
var current_angle: float = 0.0
var total_rotation: float = 0.0 

var lines: Array = []

func _ready():
	lines = connections.get_children()
	pentagono.modulate.a = 1.0 
	
	for line in lines:
		line.modulate.a = 0.0
	
	await get_tree().process_frame
	center_pos = get_viewport_rect().size / 2.0

func _input(event):
	if completed: return

	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			current_angle = (event.position - center_pos).angle()
		else:
			is_dragging = false

	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and is_dragging:
		process_rotation(event.position)

func process_rotation(touch_pos: Vector2):
	var vector_to_mouse = touch_pos - center_pos
	var new_angle = vector_to_mouse.angle()
	
	var angle_delta = angle_difference(current_angle, new_angle)
	
	total_rotation += abs(angle_delta)
	
	current_angle = new_angle
	update_visuals()
	
	if total_rotation >= 2 * PI:
		finish_interaction()

func update_visuals():
	var total_lines = lines.size()
	var progress_value = (total_rotation / (2 * PI)) * total_lines
	
	for i in range(total_lines):
		var line = lines[i]
		
		if i < int(progress_value):
			line.modulate.a = 1.0 
		elif i == int(progress_value):
			line.modulate.a = progress_value - i
		else:
			line.modulate.a = 0.0 

func finish_interaction():
	completed = true
	
	for line in lines:
		line.modulate.a = 1.0
	
	print("Ciclo completo. Aguardando 10s para apagar...")
	await get_tree().create_timer(10.0).timeout
	reset_interaction()

func reset_interaction():
	var tween = create_tween()
	
	for line in lines:
		tween.tween_property(line, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	
	total_rotation = 0.0
	completed = false
	print("Interação resetada (Ícones mantidos visíveis).")
