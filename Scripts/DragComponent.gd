extends Node
class_name DragComponent

@onready var _affected_card := get_parent() as Card
var _offset: Vector2

#var affected_card : CardV2

func _init(touch_offset):
	_offset = touch_offset
	

func _unhandled_input(event):
	if event is InputEventScreenDrag:
		
		if event.index == CardManager._current_input:
		
			_affected_card.position = event.position - _offset
		

	



