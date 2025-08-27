extends Node2D

var richochet = 0
var lifesteal = 0
var knockback = 0


func update_ricochet() -> void:
	richochet += 1
	$Gun.ricochet = 1
	
