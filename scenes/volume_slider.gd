extends HSlider

@export var bus_name: String

var bus_index: int

func _ready() -> void:



	# Fill (progress)
	var fill_sb = StyleBoxFlat.new()
	fill_sb.bg_color = Color(225/255.0, 244/255.0, 177/255.0) 
	fill_sb.content_margin_left = 4
	fill_sb.content_margin_right = 4
	fill_sb.content_margin_top = 4
	fill_sb.content_margin_bottom = 4
	add_theme_stylebox_override("grabber_area", fill_sb)
	add_theme_stylebox_override("grabber_area_highlight", fill_sb)
	
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)
	
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)
