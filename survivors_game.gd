extends Node2D

@export var tree_scene: PackedScene

var score: int = 0
var mob_level_kill_count = 0
var mob_level_kills_required = 5
@onready var navigation_2d = get_tree().get_first_node_in_group("navigation_2d")
@onready var camera: Camera2D = $World/Camera2D
@onready var wall_tilemap: TileMapLayer = $World/TileContainer/Wall
var tree_spawner: Node = null
var PLAY_AREA: Rect2

func _ready():
	var player = %Player
	var hud = $HUD
	hud.connect_player(player)
	var used_rect = wall_tilemap.get_used_rect()
	var tile_size = wall_tilemap.tile_set.tile_size
	camera.limit_left = used_rect.position.x * tile_size.x
	camera.limit_top = used_rect.position.y * tile_size.y
	camera.limit_right = (used_rect.position.x + used_rect.size.x) * tile_size.x
	camera.limit_bottom = (used_rect.position.y + used_rect.size.y) * tile_size.y

	PLAY_AREA = Rect2(
		wall_tilemap.map_to_local(used_rect.position),
		wall_tilemap.map_to_local(used_rect.end) - wall_tilemap.map_to_local(used_rect.position)
	)
	
	tree_spawner  = preload("res://tree_spawner.tscn").instantiate()
	navigation_2d.add_child(tree_spawner)
	tree_spawner.tree_scene = preload("res://pine_tree.tscn")
	tree_spawner.spawn_trees(PLAY_AREA)
	$World/NavigationRegion2D.bake_navigation_polygon()

func _physics_process(delta: float) -> void:
	camera.position = %Player.global_position

func reset_trees():
	for tree in get_tree().get_nodes_in_group("tree"):
		tree.queue_free()
	tree_spawner.spawn_trees(PLAY_AREA)
	var nav_region = $World/NavigationRegion2D
	nav_region.navigation_polygon.clear()
	await get_tree().process_frame
	nav_region.bake_navigation_polygon()


func reset_level_state() -> void:
	%Player.global_position = $SpawnPosition.global_position
	camera.global_position = $SpawnPosition.global_position
	#%Player.set_health(100)
	mob_level_kill_count = 0
	mob_level_kills_required = ceil(mob_level_kills_required * 1.5)
	
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		mob.queue_free()
	reset_trees()

func spawn_mob():
	var mob = $MobSpawner.make_mob()
	navigation_2d.add_child(mob)
	mob.health_depleted.connect(_on_mob_health_depleted)

# call this when spawning
func get_spawn_position() -> Vector2:
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
func _on_mob_health_depleted() -> void:
	Global.add_score(1)
	mob_level_kill_count += 1
		
	if mob_level_kill_count == mob_level_kills_required:
		%Player.is_invincible = true
		load_next_level()



func load_next_level():
	var level_transition = preload("res://level_transition.tscn").instantiate()
	$HUD.add_child(level_transition)
	

func setup_next_level():
	Global.set_level(Global.level + 1)
	if $MobTimer.wait_time > 0.05:
		$MobTimer.wait_time *= 0.8
	%Player.is_invincible = false
	reset_level_state()

func _on_timer_timeout() -> void:
	spawn_mob()


func _on_player_health_depleted() -> void:
	%GameOver.visible = true
	get_tree().paused = true

	

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	


func _on_start_game_pressed() -> void:
	pass # Replace with function body.
