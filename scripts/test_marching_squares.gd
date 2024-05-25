extends Node2D

@export var backgound_color : Color = Color.BLUE
@export var point_color1 : Color = Color.AQUA
@export var point_color2 : Color = Color.RED
@export var line_color : Color = Color.ANTIQUE_WHITE
@export var marching_square_color : Color = Color.AQUAMARINE
@export_range(0, 1, 0.01) var ground_threshold : float = 0.5
@export var grid_size : int = 50
@export var width : int = 1800
@export var height : int = 1200
@export var noise : NoiseTexture2D
@export var lerp : bool = true
@export_range(0, 1, 0.01) var bias : float = 0.5
@export var lerp_scale : float = 0

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back_to_menu()

func _draw():
	# Draw background
	draw_rect(Rect2(0, 0, width, height), backgound_color)
	# Draw reference lines
	draw_lines()
	# Draw marching squares
	draw_marching_squares()
	# Draw reference points
	draw_points()

func draw_lines():
	var i = 0
	while i <= height:
		draw_line(Vector2(0, i), Vector2(width, i), line_color, 4)
		i += grid_size

	i = 0
	while i <= width:
		draw_line(Vector2(i, 0), Vector2(i, height), line_color, 4)
		i += grid_size

func draw_points():
	if noise and noise.noise:
		var i = 0
		var j = 0
		while i <= width:
			j = 0
			while j <= height:
				var value = (noise.noise.get_noise_2d(i, j) + 1.0) / 2.0
				var lerp_color = point_color1.lerp(point_color2, value)
				draw_circle(Vector2(i, j), 10, lerp_color)
				j += grid_size
			i += grid_size
	else:
		print("No noise resource found!")

func draw_marching_squares():
	# Triangle table that holds all of the triangle connections
	var triTable = [ [], 
					 [0, 4, 7], 
					 [4, 1, 5], 
					 [0, 1, 7, 7, 1, 5], 
					 [6, 5, 2], 
					 [0, 6, 7, 0, 2, 6, 0, 5, 2, 0, 4, 5],
					 [4, 2, 6, 4, 1, 2],
					 [0, 1, 7, 7, 1, 6, 6, 1, 2],
					 [7, 6, 3],
					 [0, 4, 3, 4, 6, 3],
					 [7, 4, 3, 3, 4, 1, 3, 1, 5, 3, 5, 6],
					 [0, 1, 5, 0, 5, 6, 0, 6, 3],
					 [7, 5, 3, 3, 5, 2],
					 [0, 4, 3, 3, 4, 5, 3, 5, 2],
					 [7, 2, 3, 7, 4, 2, 4, 1, 2],
					 [0, 1, 3, 1, 2, 3]]
	
	var pt_vals = [0, 0, 0, 0]
	var square_index = 0b0000
	var i = 0
	var j = 0
	while j < height:
		i = 0
		while i < width:
			pt_vals = [0, 0, 0, 0]
			square_index = 0b0000
			pt_vals[0] = (noise.noise.get_noise_2d(i, j) + 1.0) / 2.0
			pt_vals[1] = (noise.noise.get_noise_2d(i + grid_size, j) + 1.0) / 2.0
			pt_vals[2] = (noise.noise.get_noise_2d(i + grid_size, j + grid_size) + 1.0) / 2.0
			pt_vals[3] = (noise.noise.get_noise_2d(i, j + grid_size) + 1.0) / 2.0
			
			if pt_vals[0] > ground_threshold: 
				square_index |= 0b0001
			if pt_vals[1] > ground_threshold:
				square_index |= 0b0010
			if pt_vals[2] > ground_threshold: 
				square_index |= 0b0100
			if pt_vals[3] > ground_threshold: 
				square_index |= 0b1000
			
			var offsets = get_offsets(pt_vals, square_index)
			
			var tris = triTable[square_index]
			var k = 0
			while k < len(tris): # Draw a triangle
				var points = PackedVector2Array([Vector2(i + offsets[tris[k]][0], j + offsets[tris[k]][1]), 
									Vector2(i + offsets[tris[k + 1]][0], j + offsets[tris[k + 1]][1]), 
									Vector2(i + offsets[tris[k + 2]][0], j + offsets[tris[k + 2]][1])])
				draw_polygon(points, [marching_square_color])  
				k += 3
			i += grid_size
		j += grid_size

func get_offsets(points_values, square_index):
	# Edge table to aid in linear interpolation to create smoothing
	var edgeTable = [ 0x0, 0x9, 0xc, 0x5, 0x6, 0xf, 0xa, 0x3, 
					  0x3, 0xa, 0xf, 0x6, 0x5, 0xc, 0x9, 0x0 ]
	# Offsets for points on each "marching" square
	var offsets = [ [0, 0], 
					[grid_size, 0], 
					[grid_size, grid_size], 
					[0, grid_size],
					[grid_size / 2.0, 0],
					[grid_size, grid_size / 2.0],
					[grid_size / 2.0, grid_size],
					[0, grid_size / 2.0]]
	
	var edges = edgeTable[square_index]
	
	if lerp:
		if edges & 0b1000 > 0: 
			offsets[4][0] = marching_squares_lerp(points_values[0], points_values[1])
		if edges & 0b0100 > 0:
			offsets[5][1] = marching_squares_lerp(points_values[1], points_values[2]) 
		if edges & 0b0010 > 0: 
			offsets[6][0] = marching_squares_lerp(points_values[3], points_values[2]) 
		if edges & 0b0001 > 0: 
			offsets[7][1] = marching_squares_lerp(points_values[0], points_values[3])
	return offsets

func marching_squares_lerp(val1, val2):
	var shift = bias + ((val1 * 0.5) - (val2 * 0.5)) * lerp_scale
	return lerp(0, grid_size, shift)
	#var mu = (ground_threshold - val1) / (val2 - val1)
	#return mu


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

func _process(_delta):
	queue_redraw()
