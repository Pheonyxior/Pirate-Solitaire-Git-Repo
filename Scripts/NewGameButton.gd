extends TextureButton

var timer := Timer.new()
signal long_press

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(timer)
	timer.timeout.connect(_long_press)

func _long_press():
	long_press.emit()
	timer.stop()

func _on_button_down():
	timer.start(1.0)


func _on_button_up():
	timer.stop()
