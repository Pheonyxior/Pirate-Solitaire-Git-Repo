extends HSlider

@export var _audio_bus_name := "Sfx"

@onready var _audio_bus := AudioServer.get_bus_index(_audio_bus_name)

func _ready() -> void:
	print(name, " ready")
	value = CardManager._sfx_volume
	


func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_audio_bus, linear_to_db(value))
	CardManager._sfx_volume = value



func _on_volume_button_toggled(button_pressed):
	visible = button_pressed 
