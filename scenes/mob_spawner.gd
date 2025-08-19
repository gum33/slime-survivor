extends Node2D
var tree_spawner: Node = null
var PLAY_AREA: Rect2


@export var spawn_interval: float = 2.0      # seconds between spawns
@export var max_mobs: int = 10               # optional

var play_area: Rect2
var camera: Camera2D
var timer: Timer

var mob_scenes = [
	{"scene": preload("res://scenes/Mobs/green_slime.tscn"), "min_level": 1},
	{"scene": preload("res://scenes/Mobs/gray_slime.tscn"), "min_level": 4},
	{"scene": preload("res://scenes/Mobs/pink_slime.tscn"), "min_level": 2}
]

func get_random_mob_scene() -> PackedScene:
	var eligible = []
	for mob in mob_scenes:
		if Global.level >= mob["min_level"]:
			eligible.append(mob["scene"])
	
	if eligible.size() == 0:
		return mob_scenes[0]["scene"]  # fallback
	
	return eligible[randi() % eligible.size()]


func make_mob() -> Node2D:
	var pos = get_spawn_position()
	# Pick random mob scene
	var mob_scene: PackedScene = get_random_mob_scene()
	var mob = mob_scene.instantiate()
	mob.global_position = pos
	return mob

# call this when spawning
func get_spawn_position() -> Vector2:
	camera = get_parent().get_node("World/Camera2D")
	var wall_tilemap = get_parent().get_node("World/TileContainer/Wall")
	var cam = camera
	
	# Get the camera's center position in the world
	var cam_center = cam.global_position
	
	# Correctly calculate the play area from the TileMap's used tiles
	var used_rect = wall_tilemap.get_used_rect()
	var play_area = Rect2(
		wall_tilemap.to_global(wall_tilemap.map_to_local(used_rect.position)),
		wall_tilemap.to_global(wall_tilemap.map_to_local(used_rect.end) - wall_tilemap.map_to_local(used_rect.position))
	)

	# Get the camera's visible area in world coordinates
	var visible_area = cam.get_viewport().get_visible_rect()
	visible_area.position = cam_center - visible_area.size / 2.0
	
	# Define a spawning distance range
	var min_dist = max(visible_area.size.x, visible_area.size.y) * 0.7
	var max_dist = min_dist + 500.0 # Adjust this value as needed
	
	var max_tries = 50
	for i in range(max_tries):
		# 1. Generate a random point in a ring around the camera
		var angle = randf_range(0.0, PI * 2)
		var distance = randf_range(min_dist, max_dist)
		
		var offset = Vector2(cos(angle), sin(angle)) * distance
		var pos = cam_center + offset
		
		# 2. Check if the generated point is within the play area
		if not play_area.has_point(pos):
			continue
		
		# 3. Check if the generated point is not inside a wall
		var tile_coords = wall_tilemap.local_to_map(wall_tilemap.to_local(pos))
		var tile_id = wall_tilemap.get_cell_source_id(tile_coords)
		
		# If it's in the play area and not a wall, it's a valid spawn point
		if tile_id == -1:
			return pos
	
	return Vector2.ZERO # No valid position found
