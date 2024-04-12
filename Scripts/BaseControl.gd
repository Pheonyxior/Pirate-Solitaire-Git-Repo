extends Control

func _on_button_toggled(button_pressed):
	visible = button_pressed
	

func _on_new_game_button_double_click():
	visible = !visible


func _on_close_button_button_up():
	visible = false

