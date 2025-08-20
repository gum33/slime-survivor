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
	
	tree_spawner  = preload("res://scenes/tree_spawner.tscn").instantiate()
	navigation_2d.add_child(tree_spawner)
	tree_spawner.tree_scene = preload("res://scenes/pine_tree.tscn")
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
	mob_level_kill_count = 0
	mob_level_kills_required = ceil(mob_level_kills_required * 1.5)
	reset_trees()
	$MobTimer.paused = false

func spawn_mob():
	var mob = $MobSpawner.make_mob()
	navigation_2d.add_child(mob)
	mob.health_depleted.connect(_on_mob_health_depleted)


func _on_mob_health_depleted() -> void:
	Global.add_score(1)
	mob_level_kill_count += 1
		
	if mob_level_kill_count == mob_level_kills_required:
		%Player.is_invincible = true
		load_next_level()



func load_next_level():
	$MobTimer.paused = true
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		mob.can_drop_upgrade = false
		mob.die()
	var level_transition = preload("res://scenes/level_transition.tscn").instantiate()
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
