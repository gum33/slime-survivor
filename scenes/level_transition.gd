extends Control

@export var wait_time: float = 2.0


func _ready() -> void:
	var gameplay_scene = get_tree().current_scene
		
	process_mode = Node.PROCESS_MODE_ALWAYS
	%StageLabel.text = "Stage %d Complete" % Global.level

	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished

	var timer = get_tree().create_timer(wait_time)
	await timer.timeout
	get_tree().paused = true
	if gameplay_scene.has_method("setup_next_level"):
		gameplay_scene.setup_next_level()
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished

	get_tree().paused = false

	# Tell main gameplay scene to setup the next level


	queue_free()  # Remove transition overlay
