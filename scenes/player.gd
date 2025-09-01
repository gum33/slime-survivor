extends CharacterBody2D
class_name Player

signal health_depleted
signal damage_changed(new_damage: float)
signal speed_changed(new_speed: float)
signal fire_rate_changed(new_rate: float)
signal ricochet_changed(new_value: int)
signal lifesteal_changed(new_value: float)
signal knockback_changed(new_value: float)


const UpgradeTypes = preload("res://scenes/upgrade_types.gd")
var pause_scene = preload("res://scenes/level_transition.tscn")

@onready var gun: Node = $Gun
const MAX_HEALTH: float = 100.0
var health: float = MAX_HEALTH
var speed: float = 500
var bullet_speed: float = 1.0
var is_invincible = false
@onready var gun_pivot = $Gun
@onready var hit_sound = $HitSound
@onready var sprite: AnimatedSprite2D = $SoldierSprite

var hit_sounds: Array[AudioStream] = []
var last_direction: float = 1.0 # 1.0 for right, -1.0 for left

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 1200  # how quickly it stops
var is_hurt: bool = false
var is_dead: bool = false

@export
var lifesteal: float = 0.0
func _ready() -> void:
	sprite.animation = "Run"
	sprite.play()
		# Preload all the hit sounds
	hit_sounds = [
		preload("res://assets/sounds/player_hit/hit1.wav"),
		preload("res://assets/sounds/player_hit/hit2.wav"),
		preload("res://assets/sounds/player_hit/hit3.wav")
	]
	add_to_group("player")
	pause_scene
	$HurtBox.body_entered.connect(_on_body_entered)


func _on_body_entered(body) -> void:
	if is_dead:
		return
	if body.is_in_group("mob") and not body.is_dead and not is_invincible:
		# Apply damage
		set_health(health - body.damage)
		play_hurt_animation()
		# Add knockback velocity
		var direction = (global_position - body.global_position).normalized()
		apply_knockback(direction, 1000)
		# Kill the mob
		body.die()
		
func play_hurt_animation() -> void:
	if is_dead:
		return
	var sound = hit_sounds[randi() % hit_sounds.size()]
	hit_sound.stream = sound
	hit_sound.pitch_scale = randf_range(0.95, 1.05) # optional variation
	hit_sound.play()
	is_hurt = true
	sprite.play("Hurt")
	# Reset after animation finishes
	await sprite.animation_finished
	is_hurt = false

func apply_knockback(direction: Vector2, strength: float):
	knockback_velocity = direction * strength
	
func activate_lifesteal(damage: float) -> void:
	if lifesteal == 0.0:
		return
	var heal_amount = damage*lifesteal
	set_health(health + heal_amount)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	move_and_slide()
	if not is_hurt:
		if velocity.length() > 0.0:
			sprite.play("Run")
		else:
			sprite.play("Idle")

	if direction.x != 0.0:
		last_direction = sign(direction.x)
	if last_direction < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false



func set_health(value: float) -> void:
	value = min(MAX_HEALTH, value)
	health = value
	%ProgressBar.value = health
	if health <= 0.0:
		$Gun.stop_fire = true
		is_dead = true
		$DeathScream.play()
		sprite.play("Death")
		health_depleted.emit()

func set_speed(speed_value: float) -> void:
	speed = speed_value
	emit_signal("speed_changed", speed)

func set_damage(damage: float) -> void:
	gun.damage = damage
	emit_signal("damage_changed", damage)

func set_ricochet(value: float) -> void:
	gun.ricochet = value
	emit_signal("ricochet_changed", value)

func set_knockback(value: float) -> void:
	gun.knockback = value
	emit_signal("knockback_changed", value)
	
func set_lifesteal(value: float) -> void:
	lifesteal = value
	emit_signal("lifesteal_changed", value)

func upgrade(upgrade_type: int) -> void:
	match upgrade_type:
		UpgradeTypes.UpgradeType.MOVE_SPEED:
			set_speed(speed+50)
		UpgradeTypes.UpgradeType.BULLET_SPEED:
			var current_rate = 1.0 / gun.shoot_timer.wait_time
			var new_rate = current_rate + 0.3
			gun.set_fire_rate(new_rate)
			emit_signal("fire_rate_changed", new_rate)
		UpgradeTypes.UpgradeType.DAMAGE:
			set_damage(gun.damage + 10)
		UpgradeTypes.UpgradeType.RICOCHET:
			set_ricochet(gun.ricochet + 1)
		UpgradeTypes.UpgradeType.KNOCKBACK:
			set_knockback(gun.knockback+400)
		UpgradeTypes.UpgradeType.LIFESTEAL:
			set_lifesteal(lifesteal + 0.01)
			
