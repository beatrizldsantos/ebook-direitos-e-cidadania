extends Node2D

@onready var container = $InteractiveArea/PentagonContainer
@onready var video_panel = $Background/Sprit2dPanel
@onready var video_player = $Background/Sprit2dPanel/SubViewportContainer/SubViewport/VideoStreamPlayer
var lines_container: Node2D

var icons = {}
var initial_positions = {}
var active = false

# Saude - Educacao, Moradia
# Educacao - Justica, Saude
# Moradia - Saude, Liberdade
# Liberdade - Justica, Moradia
# Justica - Liberdade, Educacao
var connections_pairs = [
	["Saude", "Educacao"],
	["Saude", "Moradia"],
	["Educacao", "Justica"],
	["Moradia", "Liberdade"],
	["Liberdade", "Justica"]
]

func _ready():
	randomize()
	
	await get_tree().process_frame
	
	var icon_names = ["Saude", "Educacao", "Moradia", "Liberdade", "Justica"]
	for icon_name in icon_names:
		var node = container.get_node_or_null(icon_name)
		if node:
			icons[icon_name] = node
			initial_positions[icon_name] = node.position
			node.pivot_offset = node.size / 2.0
	
	lines_container = Node2D.new()
	container.add_child(lines_container)
	container.move_child(lines_container, 0)

var is_locked: bool = false

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton or event is InputEventScreenDrag or (event is InputEventMouseMotion and event.button_mask > 0):
		if not AudioManager.is_enabled:
			return
			
		if not is_locked:
			var touched_name = get_touched_icon_name(event.position)
			if touched_name and touched_name != current_active_icon:
				start_interaction(touched_name)

func get_touched_icon_name(screen_pos: Vector2) -> String:
	for icon_name in icons:
		var icon = icons[icon_name]
		if icon.is_visible_in_tree() and icon.get_global_rect().has_point(screen_pos):
			return icon_name
	return ""

var current_active_icon = ""

func start_interaction(touched_name: String):
	if is_locked: return
	
	AudioManager.stop()
	
	is_locked = true
	active = true
	
	if video_panel:
		video_panel.visible = true
	if video_player:
		video_player.play()
		
	current_active_icon = touched_name
	var icon = icons[touched_name]
	
	var t_rot = create_tween()
	t_rot.tween_property(icon, "rotation_degrees", 360.0, 0.4).as_relative().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	shuffle_positions()
	
	await get_tree().create_timer(0.5).timeout
	
	show_lines()

func shuffle_positions():
	var positions = []
	for p in initial_positions.values():
		positions.append(p)
	
	positions.shuffle()
	
	var i = 0
	var t_move = create_tween().set_parallel(true)
	for icon_name in icons:
		t_move.tween_property(icons[icon_name], "position", positions[i], 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		i += 1

func show_lines():
	for c in lines_container.get_children():
		c.queue_free()
	
	for pair in connections_pairs:
		if icons.has(pair[0]) and icons.has(pair[1]):
			create_animated_line(icons[pair[0]], icons[pair[1]])

	await get_tree().create_timer(29.0).timeout
	end_interaction()

func create_animated_line(node_a, node_b):
	var line = Line2D.new()
	lines_container.add_child(line)
	
	line.width = 4.0
	line.default_color = Color(0.102, 0.102, 0.718, 1.0)
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	
	
	var grad = Gradient.new()
	grad.colors = [Color.WHITE]
	var tex = GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 16
	tex.height = 16
	line.texture = tex
	
	var mat = ShaderMaterial.new()
	var shader = Shader.new()
	
	shader.code = """
		shader_type canvas_item;
		
		void fragment() {
			float speed = 3.0;
			float dash_freq = 10.0; // Adjusted for texture
			
			// UV.x maps along the line length.
			float pattern = sin(UV.x * dash_freq - TIME * speed);
			
			if (pattern < 0.0) {
				discard;
			}
			// Use the LINE_COLOR (vertex color) which comes from default_color
			COLOR = COLOR;
		}
	"""
	mat.shader = shader
	line.material = mat
	
	
	var p1 = node_a.position + node_a.size / 2.0
	var p2 = node_b.position + node_b.size / 2.0
	
	line.add_point(p1)
	line.add_point(p1)
	var t = line.create_tween()
	t.tween_method(func(val):
		if is_instance_valid(line) and line.get_point_count() > 1:
			line.set_point_position(1, val),
		p1, p2, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	line.modulate.a = 0.0
	var t_fade = line.create_tween()
	t_fade.tween_property(line, "modulate:a", 1.0, 0.2)

func end_interaction():
	active = false
	current_active_icon = ""
	is_locked = false
	
	if video_player:
		video_player.stop()
	if video_panel:
		video_panel.visible = false
	
	var t_out = create_tween()
	t_out.tween_property(lines_container, "modulate:a", 0.0, 0.3)
	t_out.tween_callback(func():
		lines_container.modulate.a = 1.0
		for c in lines_container.get_children():
			c.queue_free()
	)
	
	var t_reset = create_tween().set_parallel(true)
	for icon_name in icons:
		t_reset.tween_property(icons[icon_name], "position", initial_positions[icon_name], 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		t_reset.tween_property(icons[icon_name], "rotation", 0.0, 0.5)
