extends TextureButton

func _on_toggled(button_pressed):
	flip_h = button_pressed
	
	if button_pressed:
		self.position.x += get_child(0).size.x -4
	else:
		self.position.x -= get_child(0).size.x -4



