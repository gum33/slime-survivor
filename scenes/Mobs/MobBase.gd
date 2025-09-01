extends CharacterBody2D

@export var max_health = 99 + pow(Global.level, 3)
@export var damage = 10
var upgrade_chance = 0.1
const UpgradeTypes = preload("res://scenes/upgrade_types.gd")
signal health_depleted
@export var explosion_radius: float = 50.0

var knockback_velocity: Vector2 = Vector2.ZERO
@export
var knockback_friction: float = 1000  # how quickly it stops

@onready var player = get_node("/root/Game/World/Player")
@export var death_pitch: float = 1.0
@export var base_speed: float = 150
var speed: float
var health: float
@onready var sprite = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar
# Reference to the NavigationAgent2D child node
@onready var nav_agent: NavigationAgent2D = $NavAgent
## Flag that turns on when mob is dead
var is_dead: bool = false 
## Flag that disables mob being able to drop upgrades
var can_drop_upgrade: bool = true
var nav_update_timer: float = 0.0

signal upgrade_dropped

func _ready() -> void:
	MobManager.register_mob(self)
	$NavAgent.radius = $CollisionShape2D.shape.radius + 10
	$DeathPop.pitch_scale = death_pitch
	speed = base_speed * pow(1.1, Global.level -1)
	health = max_health
	sprite.animation = "Idle"
	sprite.play()
	sprite.animation_finished.connect(_on_animation_finished)
	add_to_group("mob")
	# We don't need to manually find the Navigation2D parent anymore.
	# The NavigationAgent2D will find it for us.
	if not nav_agent:
		print("Error: NavigationAgent2D node not found as a child of the mob.")
		set_process(false)
		set_physics_process(false)

	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if nav_agent.is_navigation_finished():
		return
	nav_update_timer -= delta
	if nav_update_timer <= 0.0:
		nav_agent.target_position = player.global_position
		nav_update_timer = 0.33  # update path 4 times per second

	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	
	var desired_velocity = axis * speed
	
	velocity = desired_velocity	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	move_and_slide()

func take_damage(damage: int, knockback: Vector2) -> void:
	if is_dead:
		return
	knockback_velocity = knockback
	health -= damage
	sprite.play("Hurt")
	update_health_bar()

	if health <= 0:
		health_depleted.emit()
		die()
		return
	$HitSound.pitch_scale = randf_range(0.95, 1.05)
	$HitSound.play()

func update_health_bar() -> void:
	health_bar.max_value = max_health
	health_bar.value = health

## Kills the mob
func die() -> void:
	if is_dead:
		return
	$AnimatedSprite2D.scale *= 1.3
	$CollisionShape2D.call_deferred("set", "disabled", true)
	is_dead = true
	if (
		randf() < upgrade_chance 
		and can_drop_upgrade 
		and MobManager.drop_count < MobManager.MAX_DROPS
	):
		pick_upgrade()
	sprite.play("Death")
	$DeathPop.play()

	
func _on_animation_finished():
	if sprite.animation == "Death":
		queue_free()
	if sprite.animation == "Hurt" and health > 0:
		sprite.play("Idle")
func pick_upgrade():
	var upgrades = [
		{
			"type": UpgradeTypes.UpgradeType.MOVE_SPEED, 
			"texture": preload("res://assets/upgrades/speedboost.png")
		},
		{
			"type": UpgradeTypes.UpgradeType.BULLET_SPEED,
			"texture": preload("res://assets/upgrades/bulletspeed.png")
		},
		{
			"type": UpgradeTypes.UpgradeType.DAMAGE,
			"texture": preload("res://assets/upgrades/damage.png")
		}
	]
	
	var choice = upgrades[randi() % upgrades.size()]
	drop_upgrade(choice.type, choice.texture)

func drop_upgrade(type: int, texture: Texture2D) -> void:
	const UPGRADE = preload("res://scenes/speedboost.tscn")
	var new_upgrade = UPGRADE.instantiate()
	MobManager.drop_count += 1
	new_upgrade.upgrade_type = type
	new_upgrade.sprite_texture = texture
	get_parent().call_deferred("add_child", new_upgrade)
	new_upgrade.global_position = position
	emit_signal("upgrade_dropped")
	# Call its bounce animation
	if new_upgrade.has_method("play_spawn_bounce"):
		new_upgrade.play_spawn_bounce()
	


func _on_navigation_agent_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
