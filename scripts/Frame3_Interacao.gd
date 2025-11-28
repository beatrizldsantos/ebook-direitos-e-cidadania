extends Control

@onready var modelo_marshal = $ModeloMarshal
@onready var card_marshall = $Card_marshall
@onready var estadania_carvalho = $EstadaniadeCarvalho
@onready var card_estadania = $Card_estadania

var timer_marshall: Timer
var timer_estadania: Timer


var touch_points = {}
var start_distance = 0.0
var current_distance = 0.0
var zoom_threshold = 20.0 
var gesture_processed = false 

func _ready():
	timer_marshall = Timer.new()
	timer_marshall.one_shot = true
	timer_marshall.timeout.connect(_on_timer_marshall_timeout)
	add_child(timer_marshall)
	
	timer_estadania = Timer.new()
	timer_estadania.one_shot = true
	timer_estadania.timeout.connect(_on_timer_estadania_timeout)
	add_child(timer_estadania)
	
	if card_marshall: card_marshall.visible = false
	if card_estadania: card_estadania.visible = false

func _input(event):
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)
	
	
	elif event is InputEventMagnifyGesture:
		if event.factor < 1.0 or event.factor > 1.0:
			var center = event.position
			
			check_interaction(center)

func handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)
	
	if touch_points.size() != 2:
		gesture_processed = false
	
	if touch_points.size() == 2:
		var p1 = touch_points.values()[0]
		var p2 = touch_points.values()[1]
		start_distance = p1.distance_to(p2)
		current_distance = start_distance

func handle_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position
	
	if touch_points.size() == 2:
		var p1 = touch_points.values()[0]
		var p2 = touch_points.values()[1]
		current_distance = p1.distance_to(p2)
		
		var distance_change = abs(current_distance - start_distance)
		
		if distance_change > zoom_threshold and not gesture_processed:
			var center = (p1 + p2) / 2
			check_interaction(center)
			gesture_processed = true

func check_interaction(center_point: Vector2):
	if is_point_inside_control(center_point, modelo_marshal):
		toggle_card_marshall()
	elif is_point_inside_control(center_point, estadania_carvalho):
		toggle_card_estadania()
	
	elif card_marshall.visible and is_point_inside_control(center_point, card_marshall):
		toggle_card_marshall()
	elif card_estadania.visible and is_point_inside_control(center_point, card_estadania):
		toggle_card_estadania()

func is_point_inside_control(point: Vector2, control: Control) -> bool:
	if not control or not control.is_visible_in_tree():
		return false
	return control.get_global_rect().has_point(point)

func toggle_card_marshall():
	if card_marshall.visible:
		hide_card_marshall()
	else:
		show_card_marshall()

func toggle_card_estadania():
	if card_estadania.visible:
		hide_card_estadania()
	else:
		show_card_estadania()

func show_card_marshall():
	if card_marshall:
		card_marshall.visible = true
		timer_marshall.start(10.0)

func hide_card_marshall():
	if card_marshall:
		card_marshall.visible = false
		timer_marshall.stop()

func show_card_estadania():
	if card_estadania:
		card_estadania.visible = true
		timer_estadania.start(10.0)

func hide_card_estadania():
	if card_estadania:
		card_estadania.visible = false
		timer_estadania.stop()

func _on_timer_marshall_timeout():
	hide_card_marshall()

func _on_timer_estadania_timeout():
	hide_card_estadania()
