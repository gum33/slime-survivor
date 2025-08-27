extends Control

@export var wait_time: float = 2.0


var Upgrades: UpgradeTypes = UpgradeTypes.new()
signal upgrade_selected(upgrade_type)
var gameplay_scene: Node
@onready
var menu_box: VBoxContainer = $CanvasLayer/MarginContainer/MenuBox


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true) 
	$CanvasLayer.visible = false
	menu_box.visible = false


func transition_level() -> void:
	$CanvasLayer.visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	%StageLabel.text = "Stage %d Complete" % Global.level
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	var timer = get_tree().create_timer(wait_time)
	await timer.timeout
	show_upgrades()
	menu_box.visible = true
	get_tree().paused = true

func start_next_level() -> void:
	if gameplay_scene.has_method("setup_next_level"):
		gameplay_scene.setup_next_level()
	remove_buttons()
	menu_box.visible = false
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	$CanvasLayer.visible = false
	get_tree().paused = false

func remove_buttons() -> void:
	for button in %UpgradeButtons.get_children():
		%UpgradeButtons.remove_child(button)

func get_random_upgrades(n: int) -> Array[UpgradeTypes.UpgradeType]:
	var upgrade_array: Array[UpgradeTypes.UpgradeType] = []
	while len(upgrade_array) < 3:
		var upgrade = Upgrades.get_item_weighted()
		if upgrade in upgrade_array:
			continue
		upgrade_array.append(upgrade)
	return upgrade_array

func show_upgrades():
	var upgrades = get_random_upgrades(3)
	for upgrade in upgrades:
		var btn = Button.new()
		btn.text = Upgrades.upgrade_names[upgrade]
		btn.pressed.connect(func():
			emit_signal("upgrade_selected", upgrade)
		)
		%UpgradeButtons.add_child(btn)
