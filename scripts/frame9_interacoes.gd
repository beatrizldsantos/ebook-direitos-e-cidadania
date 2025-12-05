extends Node2D


@onready var area_limite_rect_node = $AreaLimite
@onready var cards_container = $Interacoes/Card
@onready var balloons_container = $Interacoes/Balao
@onready var interacoes = $Interacoes

var particle_count = 15 
var particle_speed_min = 80.0
var particle_speed_max = 150.0
var particle_radius = 8.0


var particles_agents: Array[Area2D] = []
var active_counts = {}

func _ready():
	
	for child in balloons_container.get_children():
		active_counts[child.name] = 0
		child.visible = false
		child.modulate.a = 0.0 
	_setup_cards()
	_setup_particles()

func _setup_cards():

	var map = {
		"combateAsFake": "balao_fakenews",
		"informacaoconfiavel": "balao_informacaoconfiavel",
		"liberdadedeexpressao": "balao_liberdadedeexpressao",
		"exposicaodedados": "balao_exposicao de dados"
	}

	for card in cards_container.get_children():
		if card.name in map:
			var area = Area2D.new()
			area.name = "Area_" + card.name
			area.monitorable = false
			area.monitoring = true
			

			var shape = CollisionShape2D.new()
			var rect_shape = RectangleShape2D.new()
			rect_shape.size = card.size
			shape.shape = rect_shape
			shape.position = card.size / 2
			
			area.add_child(shape)
			card.add_child(area)
			
			area.area_entered.connect(_on_card_area_entered.bind(map[card.name]))
			area.area_exited.connect(_on_card_area_exited.bind(map[card.name]))

func _setup_particles():
	
	var cpu_particles = CPUParticles2D.new()
	cpu_particles.name = "VisualParticles"
	
	var global_rect = area_limite_rect_node.get_global_rect()
	var local_pos = interacoes.get_global_transform().affine_inverse() * global_rect.position
	var bounds = Rect2(local_pos, global_rect.size)
	
	cpu_particles.position = bounds.get_center()
	cpu_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	cpu_particles.emission_sphere_radius = 30.0
	cpu_particles.amount = 50
	cpu_particles.gravity = Vector2(0, 980)
	cpu_particles.direction = Vector2(0, 0)
	cpu_particles.spread = 180
	cpu_particles.initial_velocity_min = 10.0
	cpu_particles.initial_velocity_max = 30.0
	cpu_particles.scale_amount_min = 2.0
	cpu_particles.scale_amount_max = 4.0
	cpu_particles.color = Color(0.965, 0.675, 0.93, 0.6)
	

	var gradient = GradientTexture2D.new()
	gradient.width = 12
	gradient.height = 12
	gradient.fill = GradientTexture2D.FILL_RADIAL
	gradient.fill_from = Vector2(0.5, 0.5)
	gradient.fill_to = Vector2(1.0, 1.0)
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0)])
	gradient.gradient = grad
	cpu_particles.texture = gradient
	
	interacoes.add_child(cpu_particles)
	
	particle_count = 40
	var spawn_center = bounds.get_center()
	var spawn_radius = 40.0
	
	for i in range(particle_count):
		var agent = Area2D.new()
		agent.name = "ParticleAgent_" + str(i)
		agent.monitorable = true
		agent.monitoring = false
		
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = particle_radius
		shape.shape = circle
		agent.add_child(shape)
		
		var sprite = Sprite2D.new()
		sprite.texture = gradient
		sprite.modulate = Color(0.949, 0.529, 0.902, 0.902)
		agent.add_child(sprite)
		
		
		var angle = randf() * TAU
		var r = sqrt(randf()) * spawn_radius
		agent.position = spawn_center + Vector2(cos(angle), sin(angle)) * r
		
	
		agent.set_meta("velocity", Vector2.ZERO)
		
		interacoes.add_child(agent)
		particles_agents.append(agent)

func _process(delta):
	var global_rect = area_limite_rect_node.get_global_rect()
	var local_pos = interacoes.get_global_transform().affine_inverse() * global_rect.position
	var bounds = Rect2(local_pos, global_rect.size)
	
	var radius = particle_radius
	
	var gravity = Vector2(0, 980)
	
	var accel = Input.get_accelerometer()
	if accel != Vector3.ZERO:
		gravity = Vector2(-accel.x, accel.y) * 200.0
		
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir != Vector2.ZERO:
		gravity = input_dir * 980.0
	
	var cpu_particles = interacoes.get_node_or_null("VisualParticles")
	if cpu_particles:
		cpu_particles.gravity = gravity
		if particles_agents.size() > 0:
			var center_mass = Vector2.ZERO
			for agent in particles_agents:
				center_mass += agent.position
			center_mass /= particles_agents.size()
			cpu_particles.position = center_mass
	
	var cohesion_strength = 2.0 
	var max_speed = 400.0
	var friction = 0.96
	

	var center_of_mass = Vector2.ZERO
	if particles_agents.size() > 0:
		for agent in particles_agents:
			center_of_mass += agent.position
		center_of_mass /= particles_agents.size()
	

	for agent in particles_agents:
		var velocity = agent.get_meta("velocity")
		

		velocity += gravity * delta
		

		var to_center = center_of_mass - agent.position
		velocity += to_center * cohesion_strength
		

		velocity *= friction
		
	
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed

		agent.position += velocity * delta
		

		var bounced = false
		var bounce_factor = -0.4
		
		if agent.position.x - radius < bounds.position.x:
			agent.position.x = bounds.position.x + radius
			velocity.x *= bounce_factor
			bounced = true
		elif agent.position.x + radius > bounds.end.x:
			agent.position.x = bounds.end.x - radius
			velocity.x *= bounce_factor
			bounced = true
			
		if agent.position.y - radius < bounds.position.y:
			agent.position.y = bounds.position.y + radius
			velocity.y *= bounce_factor
			bounced = true
		elif agent.position.y + radius > bounds.end.y:
			agent.position.y = bounds.end.y - radius
			velocity.y *= bounce_factor
			bounced = true
			

		if bounced:
			velocity += Vector2(randf_range(-20, 20), randf_range(-20, 20))
			
		agent.set_meta("velocity", velocity)

func _on_card_area_entered(area, balloon_name):
	if "ParticleAgent" in area.name:
		active_counts[balloon_name] += 1
		_update_balloon(balloon_name)

func _on_card_area_exited(area, balloon_name):
	if "ParticleAgent" in area.name:
		active_counts[balloon_name] -= 1
		_update_balloon(balloon_name)

func _update_balloon(balloon_name):
	var balloon = balloons_container.get_node(balloon_name)
	
	if active_counts[balloon_name] > 0:
		balloon.visible = true
		var tween = create_tween()
		tween.tween_property(balloon, "modulate:a", 1.0, 0.3)
	else:
		var tween = create_tween()
		tween.tween_property(balloon, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func():
			if active_counts[balloon_name] <= 0:
				balloon.visible = false
		)
