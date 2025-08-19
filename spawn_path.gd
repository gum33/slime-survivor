extends Path2D

@export var camera_path : NodePath
@export var wall_path : NodePath
@export var margin : float = 100.0

var camera : Camera2D
var wall_tilemap : TileMapLayer
var world_bounds : Rect2
var tile_size : Vector2
@onready var pathfollow = $PathFollow2D

func _ready():
	camera = get_node(camera_path)
	wall_tilemap = get_node(wall_path)

	var wall_rect = wall_tilemap.get_used_rect()
	tile_size = wall_tilemap.tile_set.tile_size
	world_bounds = Rect2(
		Vector2(wall_rect.position) * tile_size,
		Vector2(wall_rect.size) * tile_size
	)

func _process(delta):
	_update_spawn_path()

func _update_spawn_path():
	var curve = Curve2D.new()

	var view_size = get_viewport_rect().size
	var cam_pos = camera.global_position
	var left   = cam_pos.x - view_size.x / 2 - margin
	var right  = cam_pos.x + view_size.x / 2 + margin
	var top    = cam_pos.y - view_size.y / 2 - margin
	var bottom = cam_pos.y + view_size.y / 2 + margin

	# Clamp to world bounds
	left   = max(left, world_bounds.position.x)
	right  = min(right, world_bounds.position.x + world_bounds.size.x)
	top    = max(top, world_bounds.position.y)
	bottom = min(bottom, world_bounds.position.y + world_bounds.size.y)

	# Rectangle around camera
	curve.add_point(Vector2(left, top))
	curve.add_point(Vector2(right, top))
	curve.add_point(Vector2(right, bottom))
	curve.add_point(Vector2(left, bottom))
	curve.add_point(Vector2(left, top)) # close loop

	self.curve = curve
