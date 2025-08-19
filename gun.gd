extends Area2D

@onready var shoot_timer: Timer = $Timer
@export var damage: float = 25

func _physics_process(delta: float) -> void:
	var direction = get_global_mouse_position() - global_position
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)

func set_fire_rate(fire_rate : float) -> void:
	shoot_timer.wait_time = 1.0 / fire_rate
	
func shoot():
	const BULLET = preload("res://bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.damage = damage
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_bullet)

func _on_timer_timeout() -> void:
	shoot()
