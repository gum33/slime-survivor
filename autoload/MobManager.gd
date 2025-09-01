extends Node

var mob_count: int = 0
const MAX_MOBS: int = 200

var drop_count: int = 0
const MAX_DROPS: int = 5
func register_mob(mob: Node) -> void:
	mob_count += 1
	mob.tree_exited.connect(_on_mob_exited.bind(mob))

func _on_mob_exited(mob: Node) -> void:
	mob_count -= 1
