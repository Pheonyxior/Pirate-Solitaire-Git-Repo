extends Sprite2D


@export var _anim_duration : float = .5
@export var _start_delay : float = .5

@onready var _eye : AnimatedSprite2D = $Eye
@onready var _victory_sound : AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	region_rect = Rect2(texture.get_width()*0.5,0,0,texture.get_height())
	_appear()


func _appear():
	
	_victory_sound.play()
	
	var tween := create_tween()

	
	tween.tween_property(self, "region_rect", Rect2(0,0,texture.get_width(),texture.get_height()), _anim_duration).set_delay(_start_delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	
	await get_tree().create_timer(_anim_duration - .05).timeout
	_eye.play()


