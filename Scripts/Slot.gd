extends Sprite2D
class_name Slot

@export var _slot_type : String
@export var _slot_color : String

var _held_card : Card
var _locked := false

func _enter_tree():
	
	if visible == false:
		process_mode = PROCESS_MODE_DISABLED
		
		return
	

	if(_slot_type == "Stack"):
		CardManager._add_stack_slot(self)
		
	elif(_slot_type == "Trail"):
		CardManager._add_trail_slot(self)
		
	elif(_slot_type == "Garbage"):
		CardManager._add_garbage_slot(self)
		
	elif(_slot_type == "Discard"):
		CardManager._discard_slots[_slot_color] = self
	
	else:
		push_warning(name, " has no valid slot type !")


func _has_point(input_pos : Vector2):
	return get_rect().has_point(to_local(input_pos))

func lock():
	_locked = true
#	texture = null

func unlock():
	_locked = false
#	texture = load("res://Sprites/Slot.png")
