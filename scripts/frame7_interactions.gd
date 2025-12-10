extends Control

@onready var area_node = $AreaLimite
var btn_proximo: Button
@onready var sfx_fit = $SFX_Fit
@onready var sfx_win = $SFX_Win
@onready var msg_panel = $MensagemFinal

var pairings = []
# Structure: { "circle": Node, "target": Node, "locked": bool, "velocity": Vector2, "dragging": bool }

var gravity = Vector2(0, 100)
var restitution = 0.6
var damping = 0.98
var tilt_speed = 1000.0
var touch_force = 10.0

# State
var pilares_preenchidos = 0
var total_pilares = 5
var is_finished = false

func _ready():
	call_deferred("init_game")

func init_game():
	btn_proximo = get_node_or_null("../VBoxContainerBotao/HBoxContainer/proximo")
	var map = {
		"Circ_igualdade": "Igualdade",
		"Circ_presenvacao": "Preservacao",
		"Circ_tecnologia": "Tecnologia",
		"Circ_democracia": "Democracia",
		"Circ_educa": "Educacao"
	}
	
	for circle_name in map.keys():
		var circle = get_node_or_null(circle_name)
		var target = get_node_or_null(map[circle_name])
		
		if circle and target:
			pairings.append({
				"circle": circle,
				"target": target,
				"locked": false,
				"velocity": Vector2.ZERO,
				"dragging": false,
				"drag_offset": Vector2.ZERO
			})
	
	if msg_panel:
		msg_panel.visible = false
		msg_panel.modulate.a = 0
	
	# Enable next button (User request: unlocked by default)
	if btn_proximo:
		btn_proximo.disabled = false
		btn_proximo.visible = true

func _process(delta):
	if is_finished:
		return

	var tilt = Vector2.ZERO
	var accel = Input.get_accelerometer()
	
	if accel != Vector3.ZERO:
		tilt = Vector2(-accel.x, accel.y) * tilt_speed * delta
	
	var keyboard_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if keyboard_input != Vector2.ZERO:
		tilt += keyboard_input * tilt_speed * delta


	var bounds = area_node.get_rect()
	
	for p in pairings:
		if p.locked:
			continue
			
		var circle: TextureRect = p.circle
		
		if p.dragging:
			pass
		else:
			p.velocity += gravity * delta
			p.velocity += tilt
		
			var new_pos = circle.position + p.velocity * delta
			
		
			var c_size = circle.size * circle.scale
			
			if new_pos.x < bounds.position.x:
				new_pos.x = bounds.position.x
				p.velocity.x *= -restitution
			elif new_pos.x + c_size.x > bounds.position.x + bounds.size.x:
				new_pos.x = bounds.position.x + bounds.size.x - c_size.x
				p.velocity.x *= -restitution
			
			if new_pos.y < bounds.position.y:
				new_pos.y = bounds.position.y
				p.velocity.y *= -restitution
			
			elif new_pos.y + c_size.y > bounds.position.y + bounds.size.y:
				new_pos.y = bounds.position.y + bounds.size.y - c_size.y
				p.velocity.y *= -restitution
			
			circle.position = new_pos
			p.velocity *= damping
		
		check_fit(p)

func check_fit(p):
	if p.locked: return
	
	var circle: TextureRect = p.circle
	var target: TextureRect = p.target
	
	if circle.get_global_rect().intersects(target.get_global_rect()):
		var c_center = circle.get_global_rect().get_center()
		var t_center = target.get_global_rect().get_center()
		
		var dist = c_center.distance_to(t_center)
		if dist < 50.0:
			lock_piece(p)

func lock_piece(p):
	p.locked = true
	p.velocity = Vector2.ZERO
	p.dragging = false
	
	var circle = p.circle
	var target = p.target
	
	var t_center = target.position + target.size / 2
	var c_size = circle.size * circle.scale
	
	var tween = create_tween()
	tween.tween_property(circle, "position", t_center - c_size / 2, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(circle, "scale", Vector2(1.2, 1.2), 0.1)
	tween.chain().tween_property(circle, "scale", Vector2(1.0, 1.0), 0.1)

	if sfx_fit and sfx_fit.stream:
		sfx_fit.play()
	
	pilares_preenchidos += 1
	if pilares_preenchidos >= total_pilares:
		complete_level()

func complete_level():
	is_finished = true
	
	if sfx_win and sfx_win.stream:
		sfx_win.play()
		
	if msg_panel:
		msg_panel.visible = true
		msg_panel.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(msg_panel, "modulate:a", 1.0, 1.0)
	
	if btn_proximo:
		btn_proximo.visible = true
		btn_proximo.disabled = false

func _input(event):
	if is_finished: return
	
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		var pos = event.position
		var pressed = event.pressed
		var button_index = 1
		if event is InputEventMouseButton:
			button_index = event.button_index
			
		if button_index == 1:
			if pressed:
				for p in pairings:
					if p.locked: continue
					if p.circle.get_global_rect().has_point(pos):
						p.dragging = true
						p.drag_offset = p.circle.global_position - pos
						p.velocity = Vector2.ZERO
						break
			else:
				for p in pairings:
					if p.dragging:
						p.dragging = false
						pass
						
	elif event is InputEventMouseMotion:
		for p in pairings:
			if p.dragging:
				var new_global_pos = event.position + p.drag_offset
				p.circle.global_position = new_global_pos
				p.velocity = event.relative / get_process_delta_time()
				
	elif event is InputEventScreenDrag:
		for p in pairings:
			if p.dragging:
				var new_global_pos = event.position + p.drag_offset
				p.circle.global_position = new_global_pos
				if event.velocity != Vector2.ZERO:
					p.velocity = event.velocity
