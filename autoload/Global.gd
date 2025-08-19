extends Node

signal score_changed(new_score)
signal level_changed(new_level)

var score: int = 0
var level: int = 1

func add_score(amount: int) -> void:
	score += amount
	emit_signal("score_changed", score)

func set_level(new_level: int) -> void:
	level = new_level
	emit_signal("level_changed", level)
