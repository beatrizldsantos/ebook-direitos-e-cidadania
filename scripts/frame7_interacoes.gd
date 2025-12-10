extends Control

@onready var area_node = $AreaLimite
var btn_proximo: Button
@onready var msg_panel = $MensagemFinal
@onready var city_sprite = $Sprit2dPanel/construcao
@onready var sfx_fit = get_node_or_null("SFX_Fit")
@onready var sfx_win = get_node_or_null("SFX_Win")

var pairings = []
var gravity = Vector2(0, 100)
var restitution = 0.6
var damping = 0.98
var tilt_speed = 2000.0
var touch_force = 10.0

var pilares_preenchidos = 0
var total_pilares = 5
var is_finished = false
var original_city_scale = Vector2.ONE

var city_anim_playing = false
var city_anim_speed = 3.0
var city_anim_accum = 0.0

func _ready():
	if city_sprite:
		original_city_scale = city_sprite.scale
		city_sprite.visible = false
		city_sprite.frame = 0
	
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
	
	if btn_proximo:
		btn_proximo.visible = true
		btn_proximo.disabled = false

func advance_city_stage(frame_idx):
	if city_sprite:
		if not city_sprite.visible:
			city_sprite.visible = true
			city_sprite.scale = Vector2.ZERO
			var t = create_tween()
			t.tween_property(city_sprite, "scale", original_city_scale, 0.3).set_trans(Tween.TRANS_BACK)
		
		city_sprite.frame = frame_idx
		var tween = create_tween()
		tween.tween_property(city_sprite, "scale", original_city_scale * 1.05, 0.1).set_trans(Tween.TRANS_BACK)
		tween.tween_property(city_sprite, "scale", original_city_scale, 0.1)

func _process(delta):
	if city_anim_playing and city_sprite:
		city_anim_accum += delta * city_anim_speed
		var frame_idx = int(city_anim_accum) % 5
		city_sprite.frame = frame_idx
	
	if is_finished:
		return

	var tilt = Vector2.ZERO
	var accel = Input.get_accelerometer()
	if accel != Vector3.ZERO:
		tilt = Vector2(accel.x, -accel.y) * tilt_speed * delta

	var keyboard_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if keyboard_input != Vector2.ZERO:
		tilt += keyboard_input * tilt_speed * delta

	var bounds = area_node.get_rect()
	
	for p in pairings:
		if p.locked: continue
			
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
	
	resolve_collisions()

func check_fit(p):
	if p.locked: return
	
	var circle: TextureRect = p.circle
	var target: TextureRect = p.target
	
	if circle.get_global_rect().intersects(target.get_global_rect()):
		var c_center = circle.get_global_rect().get_center()
		var t_center = target.get_global_rect().get_center()
		
		if c_center.distance_to(t_center) < 50.0:
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
	
	advance_city_stage(pilares_preenchidos - 1)
	
	if pilares_preenchidos >= total_pilares:
		var t = create_tween()
		t.tween_interval(0.5)
		t.tween_callback(finalize_game)

func resolve_collisions():
	var bounds = area_node.get_rect()
	var margin = 15.0

	for i in range(pairings.size()):
		var p1 = pairings[i]
		if p1.locked: continue
		
		for j in range(i + 1, pairings.size()):
			var p2 = pairings[j]
			if p2.locked: continue
			
			var c1 = p1.circle
			var c2 = p2.circle
			
			var r1 = (c1.size.x * c1.scale.x) * 0.5
			var r2 = (c2.size.x * c2.scale.x) * 0.5
			
			var center1 = c1.position + c1.size * c1.scale * 0.5
			var center2 = c2.position + c2.size * c2.scale * 0.5
			
			var diff = center1 - center2
			var dist = diff.length()
			var min_dist = r1 + r2 + margin
			
			if dist < min_dist:
				var overlap = min_dist - dist
				var normal = Vector2.UP
				
				if dist > 0.1:
					normal = diff / dist
				else:
					normal = Vector2(randf() - 0.5, randf() - 0.5).normalized()
				
				if dist < (r1 + r2):
					var physical_overlap = (r1 + r2) - dist
					var separation = normal * (physical_overlap * 0.5)
					if not p1.dragging: c1.position += separation
					if not p2.dragging: c2.position -= separation
				
				var force_strength = 50.0 * (overlap / min_dist)
				
				if not p1.dragging:
					p1.velocity += normal * force_strength
				if not p2.dragging:
					p2.velocity -= normal * force_strength

	for p in pairings:
		if p.locked or p.dragging: continue
		
		var c = p.circle
		var pos = c.position
		var c_size = c.size * c.scale
		
		if pos.x < bounds.position.x: pos.x = bounds.position.x
		elif pos.x + c_size.x > bounds.position.x + bounds.size.x: pos.x = bounds.position.x + bounds.size.x - c_size.x
		
		if pos.y < bounds.position.y: pos.y = bounds.position.y
		elif pos.y + c_size.y > bounds.position.y + bounds.size.y: pos.y = bounds.position.y + bounds.size.y - c_size.y
		
		c.position = pos

func finalize_game():
	is_finished = true
	city_anim_playing = true
	
	if city_sprite:
		var pulse = create_tween()
		pulse.tween_property(city_sprite, "scale", original_city_scale * 1.1, 0.2)
		pulse.tween_property(city_sprite, "scale", original_city_scale, 0.2)

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
