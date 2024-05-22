extends Node2D

@export var backgound_color : Color = Color.BLUE
@export var point_color1 : Color = Color.AQUA
@export var point_color2 : Color = Color.RED
@export var line_color : Color = Color.ANTIQUE_WHITE
@export var marching_square_color : Color = Color.AQUAMARINE
@export_range(0, 1, 0.01) var land_threshold : float = 0.5
@export var grid_size : int = 100
@export var width : int = 1800
@export var height : int = 1200
@export var noise : NoiseTexture2D

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back_to_menu()

func _draw():
	# Draw background
	draw_rect(Rect2(0, 0, width, height), backgound_color)
	# Draw reference lines
	draw_lines()
	# Draw reference points
	draw_points()
	# Draw marching squares
	draw_marching_squares()

func draw_lines():
	var i = 0
	while i <= height:
		draw_line(Vector2(0, i), Vector2(width, i), line_color, 1.0)
		i += grid_size

	i = 0
	while i <= width:
		draw_line(Vector2(i, 0), Vector2(i, height), line_color, 1.0)
		i += grid_size

func draw_points():
	if noise and noise.noise:
		var i = 0
		var j = 0
		while i <= width:
			j = 0
			while j <= height:
				var value = noise.noise.get_noise_2d(i, j)
				value = (value + 1.0) / 2.0  # Normalize to between 0 and 1
				if value > land_threshold:
					value = 1.0
				else:
					value = 0.0
				var lerp_color = point_color1.lerp(point_color2, value)
				draw_circle(Vector2(i, j), 8, lerp_color)
				j += grid_size
			i += grid_size
	else:
		print("No noise resource found!")

func draw_marching_squares():
	var points = PackedVector2Array([Vector2(0, 0), Vector2(100, 50), Vector2(50, 100)])
	draw_polygon(points, [marching_square_color])  # Color for each vertex, in this case, all the same

func back_to_menu():
	# Load the new scene
	var new_scene = load("res://scenes/main_menu.tscn")
	# Get the root node (usually it's the first node in the current scene tree)
	var root = get_tree().root
	# Create an instance of the new scene
	var new_scene_instance = new_scene.instantiate()
	# Add the new scene to the root node
	root.add_child(new_scene_instance)
	# Remove the current scene
	var current_scene = get_tree().current_scene
	current_scene.queue_free()
	# Set the new scene as the current scene
	get_tree().current_scene = new_scene_instance
