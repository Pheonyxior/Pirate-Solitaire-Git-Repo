extends Node
class_name MainGame


const _distribution_delay = 0.08
const _cards_per_stack = 6

const _input_wait_time = 0.5


@onready var _new_game_button : TextureButton = $"New Game Button"
@onready var _help_button : TextureButton = $"Help Button"
@onready var _volume_button : TextureButton = $"Volume Button"
@onready var _credits_button : TextureButton = $"Credits button"
@onready var _exit_button : TextureButton = $"Exit button"

@onready var _fregate_button : TextureButton = $"FregateButton"
@onready var _mobydick_button : TextureButton = $"MobydickButton"
@onready var _kraken_button : TextureButton = $"KrakenButton"

@onready var _win_count_label : Label = $"Win Count Label"

var _deck : Array [Card]



@export var _deck_sprite : Array [Sprite2D]

@onready var _slide_audio_player := $SlideStreamPlayer as AudioStreamPlayer
@onready var _pickdrop_audio_player := $PickDropStreamPlayer as AudioStreamPlayer
@onready var _music_stream_player := $MusicStreamPlayer as AudioStreamPlayer

@export var _slide_sound : AudioStreamWAV
@export var _drop_sound : AudioStreamWAV
@export var _pick_sound : AudioStreamWAV

@onready var _tuto_window = preload("res://00_Scènes/Tutorial.tscn")
@onready var _victory_screen = preload("res://00_Scènes/VictoryScreen.tscn")
var _victory_screen_instance

func _enter_tree():
	CardManager._game_scene = self

# Called when the node enters the scene tree for the first time.
func _ready():
	
	CardManager._beasts_button_group = _fregate_button.button_group
	CardManager._beasts_button_group.pressed.connect(CardManager._on_beast_button_pressed)
	
	_win_count_label.text = str(CardManager._win_count)
	
	
	await _create_deck()
	
	_display_deck_sprite()
	
	await get_tree().create_timer(2).timeout
	
	_new_game()
	
	
	



func _create_deck():

	for i in range(1,10,+1):
		_add_card_to_deck("Seag", i)
		_add_card_to_deck("Shrk", i)
		_add_card_to_deck("Whl", i)


# uncomment this and comment the block above to test sound effects and such
#	for i in range(1,10,+1):          
#		_add_card_to_deck("Seag", 1)
#		_add_card_to_deck("Shrk", 1)
#		_add_card_to_deck("Whl", 1)
	

	for i in range(1,7,+1):
		_add_card_to_deck("Pirate")

	_add_card_to_deck("Kraken")
	_add_card_to_deck("Mobydick")
	_add_card_to_deck("Fregate")

func _distribute_deck():
	
	if not _music_stream_player.playing:
		_music_stream_player.play()
	
	await get_tree().create_timer(.4).timeout
	
	var i := 0
	for y in _cards_per_stack:		
		for x in CardManager._card_stacks.size():
			CardManager._add_to_stack(_deck[i], x, false)
			
			_play_slide_sound()
			_deck[i]._tween_to_position(CardManager._stack_slot_pos(x) + 
			Vector2(0, CardManager._snap_offset*y),CardManager._tween_speed*0.6 ,_deck_sprite[y].position)
			
			
			if x == CardManager._card_stacks.size() -1:
				_deck_sprite[y].visible = false
			
			await get_tree().create_timer(_distribution_delay).timeout
			i += 1
			
		
	
	await get_tree().create_timer(_input_wait_time).timeout

func _on_card_distribution_finished():
	CardManager._update_board_state()
	_new_game_button.disabled = false

func _add_card_to_deck(color: String, number = null):
	var card = CardManager._create_card(color, number)
	_deck.push_back(card)
	add_child(card)
	card.position = Vector2(128,-30) 

func _display_deck_sprite():
	for i in _cards_per_stack:
		_deck_sprite[i].visible = true

func _new_game():
	
	if not _victory_screen_instance == null:
		_hide_victory_screen()
	
	CardManager._disable_input()
	
	for card in _deck:
		if not card._tween == null:
			card._tween.stop()
		card.position = Vector2.UP *100
	
	CardManager._reset_board_data()
	
	_new_game_button.disabled = true
	
	_disable_beast_buttons()



	_deck.shuffle()



	_display_deck_sprite()
	
	await _distribute_deck()
	
	_on_card_distribution_finished()

	

func _play_pick_sound():
	_pickdrop_audio_player.stream = _pick_sound
	_pickdrop_audio_player.play()

func _play_drop_sound():
	_pickdrop_audio_player.stream = _drop_sound
	_pickdrop_audio_player.play()

func _play_slide_sound():
	_slide_audio_player.play()


func _disable_all_buttons_detection():
	_new_game_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_help_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_volume_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _volume_button.button_pressed:
		_volume_button.get_child(0).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_volume_button.get_child(1).mouse_filter = Control.MOUSE_FILTER_IGNORE
	_exit_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_credits_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	_mobydick_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_kraken_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fregate_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _enable_all_buttons_detection():
	_new_game_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_help_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_volume_button.mouse_filter = Control.MOUSE_FILTER_STOP
	if _volume_button.button_pressed:
		_volume_button.get_child(0).mouse_filter = Control.MOUSE_FILTER_STOP
		_volume_button.get_child(1).mouse_filter = Control.MOUSE_FILTER_STOP
	_exit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_credits_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	_mobydick_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_kraken_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_fregate_button.mouse_filter = Control.MOUSE_FILTER_STOP


func _disable_beast_buttons():
	_fregate_button.button_pressed = false
	_fregate_button.disabled = true
	
	_mobydick_button.button_pressed = false
	_mobydick_button.disabled = true
	
	_kraken_button.button_pressed = false
	_kraken_button.disabled = true

func _display_victory_screen():
	
	

	_win_count_label.text = str(CardManager._win_count)
	_victory_screen_instance = _victory_screen.instantiate()
	add_child(_victory_screen_instance)
	
	var tween := create_tween()
	tween.tween_property(_music_stream_player,"volume_db", _music_stream_player.volume_db -8, 0.2).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(3).timeout
	
	var tween2 := create_tween()
	tween2.tween_property(_music_stream_player,"volume_db", _music_stream_player.volume_db +8, 2.2).set_ease(Tween.EASE_IN)

func _hide_victory_screen():
	_victory_screen_instance.free()
	

func _on_tree_exited():
	pass

func _on_new_game_button_down():
	_new_game()

func _on_new_game_button_long_press():
	_new_game()
	
	
func _on_help_button_down():
	var instance = _tuto_window.instantiate()
	add_child(instance)


func _on_exit_button_long_press():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)









