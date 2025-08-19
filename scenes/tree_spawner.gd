extends Node

@export var tree_scene: PackedScene
@export var rock_scene: PackedScene
@export var min_trees: int = 5
@export var max_extra: int = 20
@export var margin: int = 200
@export var min_distance: int = 50

@onready var navigation_2d = get_tree().get_first_node_in_group("navigation_2d")

func _ready():
	
	# Make sure we found the Navigation2D node before trying to spawn trees
	if not navigation_2d:
		print("Error: Navigation2D node not found in 'navigation_2d' group. Trees will not be spawned correctly.")
		set_process(false) # Stop the script from running if it can't find the node.
		
func spawn_trees(play_area: Rect2):
	var number_of_trees = calculate_number_of_trees()
	var positions = []
	var margin = 50.0 # Adjust this value as needed
	var min_distance = 50.0 # Adjust this value as needed
	
	for i in range(number_of_trees):
		var pos = Vector2()
		var max_tries = 50
		var found_valid_pos = false
		
		for tries in range(max_tries):
			# Generate a random position within the defined play_area
			pos = Vector2(
				randf_range(play_area.position.x + margin, play_area.end.x - margin),
				randf_range(play_area.position.y + margin, play_area.end.y - margin)
			)
			
			var too_close = false
			for other_pos in positions:
				if pos.distance_to(other_pos) < min_distance:
					too_close = true
					break
			
			if not too_close:
				found_valid_pos = true
				break
		
		if found_valid_pos:
			positions.append(pos)
			var object = pick_object()
			var new_tree = object.instantiate()
			navigation_2d.add_child(new_tree)
			new_tree.global_position = pos
			
func pick_object() -> PackedScene:
	var object_scene: PackedScene
	if randf() <= 0.8:
		object_scene = tree_scene
	else:
		object_scene = rock_scene
	return object_scene

func calculate_number_of_trees() -> int:
	var min_trees = 100 # Increased base number of trees
	var max_extra = 200 # You can also increase the cap on extra trees
	
	# Lowering lambda to get a higher average number of extra trees
	var lambda = 0.05 
	
	var r = randf()
	var extra_trees = int(-log(1 - r) / lambda)
	extra_trees = clamp(extra_trees, 0, max_extra)
	var number_of_trees = min_trees + extra_trees
	return number_of_trees
