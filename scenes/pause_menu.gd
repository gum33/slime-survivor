extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true) 
	visible = false
	
func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			print("Unpausing")
			get_tree().paused = false
			visible = false
		else:
			print("Pausing")
			get_tree().paused = true
			visible = true
