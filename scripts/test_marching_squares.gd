extends Node2D

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back_to_menu()

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
