extends Control

@export var _tutorial_parts : Array [Control]

var _index := 0



func _on_previous_button_down():
	_tutorial_parts[_index].visible = false
	_index -= 1
	
	if _index < 0 :
		_index = _tutorial_parts.size()-1
	
	_tutorial_parts[_index].visible = true


func _on_next_button_down():
	_tutorial_parts[_index].visible = false
	_index += 1
	
	if _index > _tutorial_parts.size()-1 :
		_index = 0
	
	_tutorial_parts[_index].visible = true


func _on_close_button_down():
	queue_free()

