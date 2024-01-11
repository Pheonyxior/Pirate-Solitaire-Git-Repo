extends CustomButton

var d_timer := Timer.new()

signal double_click

func _ready():
	super()
	d_timer.one_shot = true
	add_child(d_timer)
	

func _on_button_down():
	super()
	if d_timer.is_stopped():
		d_timer.start(0.4)
	else:
		double_click.emit()
