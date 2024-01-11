extends Control

var _tutorial_parts : Array [Control]

var _index := 0

func _ready():
	var parts = get_tree().get_nodes_in_group("Tutorial Parts")
	for part in parts:
		_tutorial_parts.push_back(part)
#		print(part.name)
	


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
	
	var i = 735477312704535067
	var str = String.num_int64(i,36, true)
	var ascii = str.to_ascii_buffer()
	
	var r = str.to_int()
	
	print(str)
	print(ascii)
	print(r)





func _on_close_button_down():
	queue_free()

