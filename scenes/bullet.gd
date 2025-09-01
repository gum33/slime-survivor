extends Area2D


const SPEED: float = 1000
const RANGE: int = 1200
var travelled_distance = 0
var damage: float = 25
var ricochet: int = 0
var knockback: float = 0
var player: Player = null
var is_ricochet: bool = false
func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body: Node2D) -> void:

	if body.has_method("take_damage"):
		var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
		var knockback_direction: Vector2 = direction * knockback
		var mob_damage = damage
		if is_ricochet:
			mob_damage *= 0.5
		else:
			player.activate_lifesteal(damage)
		body.take_damage(mob_damage, knockback_direction)
	if ricochet > 0 and body.is_in_group("mob"):
		ricochet_to_next_target(body)
		ricochet -= 1
	else:
		queue_free()

func ricochet_to_next_target(hit_mob: Node) -> void:
	is_ricochet = true
	var mobs = get_tree().get_nodes_in_group("mob")
	var closest: Node = null
	var min_dist: float = 400

	for mob in mobs:
		if mob == hit_mob or mob.is_dead:
			continue
		var dist = global_position.distance_to(mob.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = mob

	if closest:
		# Change direction towards next mob
		var new_direction = (closest.global_position - global_position).normalized()
		rotation = new_direction.angle()
	else:
		# No targets left, maybe queue_free the bullet
		queue_free()
