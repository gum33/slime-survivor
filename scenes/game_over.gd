extends CanvasLayer

@onready var panel = $MarginContainer/ColorRect/PanelContainer
@onready var animation_player = $AnimationPlayer
@onready var score_label = %Score
@onready var level_label = $%LevelLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	set_process_input(true) 
	visible = false

func game_over() -> void:
	visible = true
	score_label.text = "Score: %d" %Global.score
	level_label.text = "Level: %d" %Global.level
	animation_player.play("fade_in")
	await animation_player.animation_finished
	panel.visible = true
	get_tree().paused = true
	

func _on_play_again_pressed() -> void:
	get_tree().paused = false
	Global.reset_variables()
	get_tree().reload_current_scene()
