extends "res://scenes/Mobs/MobBase.gd"

var health_factor = 3.0
var speed_factor = 0.5

func _ready():
	super._ready()
	max_health *= health_factor
	health = max_health
	speed *= speed_factor
	update_health_bar()
