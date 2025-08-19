extends Area2D
const UpgradeTypes = preload("res://scenes/upgrade_types.gd")



@export_enum(
	"MOVE_SPEED", "BULLET_SPEED", "DAMAAGE"
	) var upgrade_type: int

@export var sprite_texture: Texture2D:
	set(value):
		sprite_texture = value
		if has_node("Sprite2D"):
			$Sprite2D.texture = value



func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if body.has_method("upgrade"):
		body.upgrade(upgrade_type)

func play_spawn_bounce():
	scale = Vector2(0.5, 0.5) # start smaller
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.25), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
