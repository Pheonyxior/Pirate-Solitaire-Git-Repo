extends TextureButton
class_name CustomButton

var timer := Timer.new()
var tween : Tween
signal long_press

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_long_press)

func _long_press():
	long_press.emit()
	if tween.is_running():
		tween.stop()
	self_modulate = Color.WHITE


func _on_button_down():
	timer.start(1.0)
	
	tween = create_tween()
	tween.tween_property(self, "self_modulate", Color.TRANSPARENT, 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	


func _on_button_up():
	timer.stop()
	if tween.is_running():
		tween.stop()
	self_modulate = Color.WHITE
