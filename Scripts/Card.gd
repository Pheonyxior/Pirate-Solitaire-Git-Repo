extends Sprite2D
class_name Card

#@export var _current_stack : int
const _tween_clamp_min = Vector2(50,50)
const _tween_clamp_max = Vector2(65,65)

@export var _highlight_color : Color

var _name : String

var _color : String
var _number 

var _initial_pos : Vector2

var _tween : Tween 

var _toggled := false


# Called when the node enters the scene tree for the first time.
func _ready():
	if _number != null:
		_name = str(_number) + " " + _color
	else:
		_name = _color



func _print_self():
	print(_name, " : ", z_index)
	await get_tree().create_timer(0.2).timeout
	_print_self()

func _has_point(input_pos : Vector2):
	return get_rect().has_point(to_local(input_pos))
	
func _is_suite_of(card : Card):
	
	return card._number != null && (_number == card._number -1 && _color != card._color)

func _pick(touch_pos : Vector2):
	_initial_pos = position
	add_child(DragComponent.new(to_local(touch_pos)))
	
	z_index += 90

func _toggle():
	_toggled = !_toggled
	if _toggled:
		modulate = _highlight_color
	else:
		modulate = Color.WHITE


func _untoggle():
	_toggled = false
	modulate = Color.WHITE

func _remove_drag_component():
	#removes the drag component and makes sure that it is removed from memory
	
	
	
	if get_child_count() != 0:
		if get_child(0) is DragComponent:
			get_child(0).free()
	
	
	z_index -= 90

func _reset_pos():
	position = _initial_pos

func _tween_to_position(destination : Vector2, speed := CardManager._tween_speed, start_pos := position):
	
	
	z_index += 100
	
	_tween = create_tween()
	
	var distance : Vector2 = (destination - start_pos)
	var lenght : float = distance.length()
	
	var fspeed : float = (lenght * speed)
	

	
	_tween.finished.connect(_on_tween_finished)
	

	_tween.tween_property(self, "position", destination, fspeed).from(start_pos)
	



func _on_tween_finished():
	
	z_index -= 100

	
	
	
	
