extends "res://Mobs/MobBase.gd"

var health_factor = 0.70
var speed_factor = 1.5

func _ready():
	super._ready()
	speed *= speed_factor
	max_health *= health_factor
	health = max_health
	update_health_bar()
