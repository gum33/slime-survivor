extends CharacterBody2D

signal health_depleted
signal damage_changed(new_damage)
signal speed_changed(new_speed)
signal fire_rate_changed(new_rate)
const UpgradeTypes = preload("res://scenes/upgrade_types.gd")

@onready var gun: Node = $Gun
var health: float = 100
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
	$HurtBox.body_entered.connect(_on_body_entered)


func _on_body_entered(body) -> void:
	if body.is_in_group("mob") and not body.is_dead and not is_invincible:
		# Apply damage
		set_health(health - body.damage)
		play_hurt_animation()
		var sound = hit_sounds[randi() % hit_sounds.size()]
		hit_sound.stream = sound
		hit_sound.pitch_scale = randf_range(0.95, 1.05) # optional variation
		hit_sound.play()
		# Add knockback velocity
		var direction = (global_position - body.global_position).normalized()
		apply_knockback(direction,1000 )
		# Kill the mob
		body.die()
		
func play_hurt_animation() -> void:
	is_hurt = true
	sprite.play("Hurt")
	# Reset after animation finishes
	await sprite.animation_finished
	is_hurt = false

func apply_knockback(direction: Vector2, strength: float):
	knockback_velocity = direction * strength

func _physics_process(delta: float) -> void:
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
	health = value
	%ProgressBar.value = health
	if health <= 0.0:
		sprite.play("Death")
		health_depleted.emit()

func set_speed(speed_value: float) -> void:
	speed = speed_value
	emit_signal("speed_changed", speed)

func set_damage(damage: float) -> void:
	gun.damage = damage
	emit_signal("damage_changed", damage)

func upgrade(upgrade_type: int) -> void:
	match upgrade_type:
		UpgradeTypes.UpgradeType.MOVE_SPEED:
			set_speed(speed * 1.05)
		UpgradeTypes.UpgradeType.BULLET_SPEED:
			var current_rate = 1.0 / gun.shoot_timer.wait_time
			var new_rate = current_rate * 1.1
			gun.set_fire_rate(new_rate)
			emit_signal("fire_rate_changed", new_rate)
		UpgradeTypes.UpgradeType.DAMAGE:
			set_damage(gun.damage + 10)
			
