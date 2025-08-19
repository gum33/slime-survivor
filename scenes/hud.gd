extends CanvasLayer

@onready var level_value = %LevelValue
@onready var score_value = %ScoreValue
@onready var speed_value = %SpeedValue
@onready var damage_value = %DamageValue
@onready var firerate_value = %FireRateValue


func _ready() -> void:
	Global.score_changed.connect(_on_score_changed)
	Global.level_changed.connect(_on_level_changed)
	var player = get_node("res://scenes/player.tscn")
	# Set initial values
	_on_score_changed(Global.score)
	_on_level_changed(Global.level)

func _on_score_changed(new_score: int) -> void:
	score_value.text = str(new_score)

func _on_level_changed(new_level: int) -> void:
	level_value.text = str(new_level)

func connect_player(player) -> void:
	player.speed_changed.connect(_on_speed_changed)
	player.damage_changed.connect(_on_damage_changed)
	player.fire_rate_changed.connect(_on_fire_rate_changed)

func _on_speed_changed(speed: float):
	speed_value.text = str(int(speed))
	
func _on_damage_changed(damage: float) -> void:
	damage_value.text = str(int(damage))

func _on_fire_rate_changed(fire_rate: float) -> void:
	firerate_value.text = str(round(fire_rate * 100) / 100)
