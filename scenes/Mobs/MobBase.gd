extends CharacterBody2D

@export var max_health = 100 + (3*Global.level)
@export var damage = 10
var upgrade_chance = 0.1
const UpgradeTypes = preload("res://scenes/upgrade_types.gd")
signal health_depleted
@export var explosion_radius: float = 50.0

@onready var player = get_node("/root/Game/World/Player")

@export var base_speed: float = 150
var speed: float
var health: float
@onready var sprite = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar

# Reference to the NavigationAgent2D child node
@onready var nav_agent: NavigationAgent2D = $NavAgent
var is_dead: bool = false

func _ready() -> void:
	$NavAgent.radius = $CollisionShape2D.shape.radius + 10
	speed = base_speed * pow(1.2, Global.level -1)
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
	# Tell the navigation agent where to go.
	nav_agent.target_position = player.global_position

	# Get the next point in the path from the agent
	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	
	# Calculate the desired velocit
	var desired_velocity = axis * speed
	
	# Set the CharacterBody2D's velocity to the desired velocity
	# This is what move_and_slide() will use
	velocity = desired_velocity	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	# Move the mob
	move_and_slide()

func take_damage(damage: int) -> void:
	if is_dead:
		return
	health -= damage
	sprite.play("Hurt")
	update_health_bar()

	if health <= 0:
		die()

func update_health_bar() -> void:
	health_bar.max_value = max_health
	health_bar.value = health

func die():
	if is_dead:
		return
	$AnimatedSprite2D.scale *= 1.3
	$CollisionShape2D.call_deferred("set", "disabled", true)
	is_dead = true
	if randf() < upgrade_chance:
			pick_upgrade()
	sprite.play("Death")
	

		#const SMOKE_SCENE = preload("res://smoke_explosion/smoke_explosion.tscn")
		#var smoke = SMOKE_SCENE.instantiate()
		#get_parent().add_child(smoke)
		#smoke.global_position = global_position
	health_depleted.emit()

	
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
	new_upgrade.upgrade_type = type
	new_upgrade.sprite_texture = texture
	get_parent().add_child(new_upgrade)
	new_upgrade.global_position = global_position
	
	# Call its bounce animation
	if new_upgrade.has_method("play_spawn_bounce"):
		new_upgrade.play_spawn_bounce()
	


func _on_navigation_agent_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
