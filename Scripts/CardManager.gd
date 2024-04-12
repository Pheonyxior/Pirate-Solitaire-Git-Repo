extends Node

const _stack_number = 6
const _snap_offset = 8

const _tween_speed = .0036 # the lower the value the higher the speed
const _discard_delay = .4


var _game_scene : MainGame
var _beasts_button_group : ButtonGroup = load("res://beasts_buttons.tres")

var _current_input := 0

var _card_stacks := []
var _stack_slots : Array [Slot] = []    # the slots on which the cards are stacked initially
										# can hold stacks of cards
var _trail_slots : Array [Slot] = []    # slots that are initially empty
										# can hold a single card
var _garbage_slots : Array [Slot] = []


var _discard_slots = {
	
}

var _color_trails = {
	Whl =  0,
	Shrk = 0,
	Seag = 0
}

var _can_play := false

# the stack of card(s) the player is currently dragging
var _held_stack := []
# the index of the stack of card(s) the player is currently dragging
var _held_stack_index:= 0


var _pirates_index : Array [int]

var _mobydick_index : int
var _kraken_index : int
var _fregate_index : int

var _selected_beast_index : int
var _beast_discard_slot

var _is_selecting_pirates := false
var _selected_pirates_index : Array [int]

var _is_double_clicking := false

var _win_count : int
var _sfx_volume : float = 0.5
var _music_volume : float = 0.5

#var _move_amount := -1



func _ready():
	
	_load()
	_beasts_button_group.pressed.connect(_on_beast_button_pressed)


func _notification(what):
	
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save()
		_game_scene.get_tree().quit()
		get_tree().quit() # default behavior
	
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_save()

func _save():

	var config = ConfigFile.new()
	
	config.set_value("data", "win_count", _win_count)
	config.set_value("data", "sfx_volume", _sfx_volume)
	config.set_value("data", "music_volume", _music_volume)
	
	config.save("user://scores.cfg")

func _load():
	
	var config = ConfigFile.new()
	
	var data = config.load("user://scores.cfg")
	
	if not data == OK:
		return
	
	_win_count = config.get_value("data", "win_count")
	_sfx_volume = config.get_value("data","sfx_volume")
	_music_volume = config.get_value("data", "music_volume")


func _create_card(color : String, number = null) -> Card:
	var card = preload("res://00_Scènes/Card.tscn")
	var card_instance = card.instantiate()
	card_instance._color = color
	card_instance._number = number
	
	
	if number != null:
		var format_string = "res://Sprites/cards/%s%s Pirate Card.png"
		
		card_instance.texture = load( format_string % [number, color])
	else:
		var format_string = "res://Sprites/cards/%s Pirate Card.png"
		
		card_instance.texture = load( format_string % color)
	
	return card_instance

func _unhandled_input(event):
	if !_can_play:
		return
		
	if event is InputEventMouseButton && not _is_selecting_pirates:
		if event.double_click : 
			_cancel_drop()
			
			for i in _card_stacks.size():
				if _card_stacks[i].size() == 0:
					continue
					# we use card_index -1 to adjust for the array size having +1 compared to the array index
				var card = _card_stacks[i].back() as Card
				if card._has_point(event.position):
					if _color_trails.has(card._color):
						if _color_trails[card._color] == card._number -1:
#						var same_color_slot = _discard_slots[card._color]
							_card_stacks[i].pop_back()
							await _discard_card(card)
							_update_board_state()
							_is_double_clicking = false
							return
			for i in _trail_slots.size():
				if _trail_slots[i]._locked:
					continue
				var card = _trail_slots[i]._held_card as Card
				if card != null:
					if card._has_point(event.position):
						if _color_trails.has(card._color):
							if _color_trails[card._color] == card._number -1:
								_trail_slots[i]._held_card = null
								await _discard_card(card)
								_update_board_state()
								_is_double_clicking = false
								return
	
	
	if event is InputEventScreenTouch :
		
		if event.pressed :
			# we disable the button detection so that they don't catch our finger input
			# while dragging a card
			_game_scene._disable_all_buttons_detection()
			
			if _is_selecting_pirates:
				for i in _pirates_index:
					var pirate : Card
					
					if i >= _card_stacks.size():
						pirate = _trail_slots[i - _card_stacks.size()]._held_card
					elif not _card_stacks[i].is_empty():
						
						pirate = _card_stacks[i].back()
					
					if pirate == null:
						
						continue
					
					if pirate._has_point(event.position):
						pirate._toggle()
						if pirate._toggled:
							_selected_pirates_index.append(i)
						elif not pirate._toggled:
							_selected_pirates_index.erase(i)
						if _selected_pirates_index.size() == 2:
							
							_discard_beast()
				return
			
			
			for i in _card_stacks.size():
				
				if _card_stacks[i].size() == 0:
					pass
				
				# we iterate through each stack of cards from the last card added to the first
				for card_index in range(_card_stacks[i].size(), 0, -1):
					# we use card_index -1 to adjust for the array size having +1 compared to the array index
					var card = _card_stacks[i][card_index-1] as Card

					
					if card._has_point(event.position) and not card._tween.is_running():
						
						# we use card_index -1 for the same reason as before, but we don't have to do the same
						# for size() because slice's second argument is exclusive
						var sliced_stack = _card_stacks[i].slice(card_index-1, _card_stacks[i].size())
						
						# if the stack we're trying to pick is a single card, or is a suite of card
						if _stack_is_suit(sliced_stack):
																			
							_pick_stack(sliced_stack, event.position)
							_current_input = event.index
							_held_stack_index = i
							return
							
						# if the stack we clicked on is not a suit we break out of the loop
						# because there is no point in checking those above
						else:
							break
			
			for i in _trail_slots.size():
				if _trail_slots[i]._locked:
					continue
				
				var card = _trail_slots[i]._held_card as Card
				if card != null:
					if card._has_point(event.position) and not card._tween.is_running():
						_pick_card(card, event.position)
						_current_input = event.index
						# we put an offset of the number of card stacks on the index to differentiate the trail slots from the card stacks
						_held_stack_index = _card_stacks.size() + i
						return
				
		# if the player releases his touch from the screen aka drops the card(s) they're dragging
		elif !event.pressed && event.index == _current_input:
			
			# enable button detection when releasing touch/click
			_game_scene._enable_all_buttons_detection()
			
			# makes sure that the player is holding card(s) before calling drop stack
			if(_held_stack.size() != 0):
				_drop_stack(event.position)
	
	

func _pick_stack(card_stack: Array, touch_pos: Vector2):

	if not _held_stack.is_empty():
		return
	
	_game_scene._play_pick_sound()
	
	_held_stack = card_stack as Array[Card]
	
	for card in card_stack:

		card._pick(touch_pos)

func _stack_is_suit(sliced_stack: Array) -> bool:
	if sliced_stack.size() == 1:
		return true
	
	for i in range(1, sliced_stack.size(), +1):
		# if the card [i] is not a suite of card[i-1]
		if !sliced_stack[i]._is_suite_of(sliced_stack[i-1]):
			return false
	return true

func _pick_card(card: Card, touch_pos: Vector2):
	
	if not _held_stack.is_empty():
		return
	
	_game_scene._play_pick_sound()
	
	_held_stack.push_back(card)
	card._pick(touch_pos)

func _drop_stack(drop_pos : Vector2):
	
	_game_scene._play_drop_sound()
	
	for i in _card_stacks.size():
		
		#  if the card stack is the one we picked card(s) from, we ignore it
		if i != _held_stack_index:
			
			# if the card stack is empty we verify if we're dropping on the stack slot
			if _card_stacks[i].size() == 0:
				
				if _stack_slots[i]._has_point(_held_stack[0].position) || _stack_slots[i]._has_point(drop_pos) :
					
					_cancel_drag()
					_remove_cards_from_previous_stack()
					_append_cards_to_new_stack(i)
					_held_stack.clear()
					
					_update_board_state()
					return
				else: 
					continue
				
			var card = _card_stacks[i].back() as Card
			if card._has_point(_held_stack[0].position) || card._has_point(drop_pos) :
				# if the first card of the stack the player is holding is a valid suite to the card it's dropped on
				if _held_stack[0]._is_suite_of(card):
					
					_cancel_drag()
					
					_remove_cards_from_previous_stack()
					
					_append_cards_to_new_stack(i)
					
					_held_stack.clear()
					
					_update_board_state()
					return
					
	# after verifying the card stacks and the slot stacks we verify the trail slots
	# we verify first if the stack we're holding is equal to 1 because trails can only hold a single card anyway
	if _held_stack.size() == 1:
		
		var card = _held_stack[0] as Card
		
		for i in _trail_slots.size():
			
			if _trail_slots[i]._locked:
				continue
			
			var slot = _trail_slots[i]
			if slot._held_card == null:
#				if _stack_slots[i]._has_point(_held_stack[0].position) || _stack_slots[i]._has_point(drop_pos) :
				if slot._has_point(_held_stack[0].position) || slot._has_point(drop_pos):
					_cancel_drag()
					_remove_cards_from_previous_stack()
					_add_to_trail(card, i)
				
					_held_stack.clear()
					
					_update_board_state()
					return
		
		# if the card's number we're holding is the next card in its color trail
		# we're checking if we're dropping on its slot, in which case the player forcefully
		# discards a card, even if it could be useful hence not automatically discarded
		if _color_trails.has(card._color):
			if _color_trails[card._color] == card._number -1:
				var same_color_slot = _discard_slots[card._color]
				if same_color_slot._has_point(_held_stack[0].position) || same_color_slot._has_point(drop_pos):
					_cancel_drag()
					_remove_cards_from_previous_stack()
					
					_discard_card(card, false)
					_snap_to_slot(card, same_color_slot.position)
					
					_held_stack.clear()
					
					
					_update_board_state()
					return
		# use garbage slots to help debug
		for i in _garbage_slots.size():
			var slot = _garbage_slots[i]
			if slot._has_point(drop_pos):
				_cancel_drag()
				_remove_cards_from_previous_stack()
				_snap_to_slot(card, slot.position)
				if slot._held_card != null:
					card.z_index = slot._held_card.z_index +1
				slot._held_card = card
				_held_stack.clear()
				_update_board_state()
				return
	
	# if no slot contained the drop_pos point, cancel the drop
	_cancel_drop()

func _update_board_state():
	_disable_input()
	#_increase_move_amount()
	_discard_available_cards()

func _finish_update_board_state():
	
	_selected_pirates_index.clear()
	_get_available_pirates_index()
	
	if _pirates_index.size() >= 2:
		_check_beasts()
	
	_enable_input()
	
	if _has_won():
		
		_win_count += 1
		if (_win_count > 9999 ): _win_count = 9999
		_save()
		_game_scene._display_victory_screen()

func _discard_available_cards(discarded_cards : int = 0):
	
	
	var check_left = false
	
	var discards = discarded_cards
	
	for stack in _card_stacks:
		if stack.is_empty():
			continue
		
		var card = stack.back() as Card
		
		if(_is_discardable(card)):
			
			stack.pop_back()
			
			await _discard_card(card, true, discards)
			discards += 1
			
			check_left = true
	
	for slot in _trail_slots:
		
		if slot._locked:
			continue
		
		var card = slot._held_card
		if card == null:
			continue
			
		if _is_discardable(card):
			

			slot._held_card = null
			await _discard_card(card, true, discards)
			discards += 1
			
			check_left = true
			
	
	
	
	if check_left:
		_discard_available_cards(discards)
	else:
		_finish_update_board_state()

func _is_discardable(card: Card) -> bool:
	
#	if card._color == "Gold Sabre":
#		return true
		
	if card._number == null:
		return false
	
	if (card._number == 1 or card._number == 2) and _color_trails[card._color] == card._number -1:
		return true
		
	if (_color_trails["Whl"] >= card._number -1 
	and _color_trails["Shrk"] >= card._number -1 
	and _color_trails["Seag"] >= card._number -1):
		return true
	
	return false

func _discard_card(card: Card, tween_to_slot := true, speed_modifier : float = 0):
	if card._number != null :
		card.z_index = card._number
	else :
		card.z_index = card.get_index()*0.2 +1
		
	if tween_to_slot:
		
		_game_scene._play_slide_sound()
		card._tween_to_position(_discard_slots[card._color].position, _tween_speed * 0.8)
		
		var modified_delay = _discard_delay - (speed_modifier *0.025)
		if modified_delay < 0.08:
			modified_delay = 0.08
		await get_tree().create_timer(modified_delay).timeout
		
	_color_trails[card._color] = card._number

func _check_beasts():
	var card
	
	var slot_is_free := false
	var moby_is_available := false
	var kraken_is_available := false
	var fregate_is_available := false
	
	for i in _trail_slots.size():
		
		if _trail_slots[i]._locked:
			continue
		
		if _trail_slots[i]._held_card == null:
			slot_is_free = true
			continue
		
		card = _trail_slots[i]._held_card._color
		
		if card == "Mobydick":
			moby_is_available = true
			_mobydick_index = i + _card_stacks.size()
			
		elif card == "Kraken":
			kraken_is_available = true
			_kraken_index = i + _card_stacks.size()
			
		elif card == "Fregate":
			fregate_is_available = true
			_fregate_index = i + _card_stacks.size()
	
	if slot_is_free and not (moby_is_available and kraken_is_available and fregate_is_available):
		for i in _card_stacks.size():
			
			if _card_stacks[i].is_empty():
				continue
			
			card = _card_stacks[i].back()._color
			
			if card == "Mobydick":
				moby_is_available = true
				_mobydick_index = i

				
			elif card == "Kraken":
				kraken_is_available = true
				_kraken_index = i

				
			elif card == "Fregate":
				fregate_is_available = true
				_fregate_index = i

	
	_game_scene._fregate_button.disabled = !fregate_is_available
	_game_scene._mobydick_button.disabled = !moby_is_available
	_game_scene._kraken_button.disabled = !kraken_is_available

func _discard_beast():
	_game_scene._disable_beast_buttons()
	_is_selecting_pirates = false
	
	var beast_is_in_trail = _selected_beast_index >= _card_stacks.size()
	var beast
	
	if beast_is_in_trail:
		_beast_discard_slot = _trail_slots[_selected_beast_index - _card_stacks.size()]
		_beast_discard_slot._held_card.z_index = 9
		_beast_discard_slot._held_card.position.y -= 1
		
		beast = _beast_discard_slot._held_card
		
	else:
		for slot in _trail_slots:
			if slot._locked:
				continue
			
			if slot._held_card == null:
				_beast_discard_slot = slot
				
				# since we know the beast is not in the trail, we discard it here
				beast = _card_stacks[_selected_beast_index].pop_back() as Card
				
				beast.z_index = 9
				beast._discard_beast = true
				beast._tween_to_position(_beast_discard_slot.position)
				_game_scene._play_slide_sound()
				
				break
	
	
	if beast._name == "Fregate":
		_game_scene._fregate_button.modulate = Color(Color.WHITE,0.5)
	elif beast._name == "Kraken":
		_game_scene._kraken_button.modulate = Color(Color.WHITE,0.5)
	else:
		_game_scene._mobydick_button.modulate = Color(Color.WHITE,0.5)
	
	await _discard_pirates(_beast_discard_slot.position)
	_beast_discard_slot.lock()
	_beast_discard_slot = null
	
	
	_update_board_state()

func _get_available_pirates_index():
	
	_pirates_index.clear()
	
	for i in _card_stacks.size():
		if _card_stacks[i].is_empty():
			continue
		
		var card = _card_stacks[i].back() as Card
		
		if card._color == "Pirate":
			_pirates_index.append(i)
	
	for i in _trail_slots.size():
		
		if _trail_slots[i]._locked:
			continue
		
		if _trail_slots[i]._held_card != null and _trail_slots[i]._held_card._color == "Pirate":
			_pirates_index.append(i + _card_stacks.size())

func _selected_pirates() -> Array [Card]:
	
	var selected_pirates : Array [Card] = []
	
	for i in _selected_pirates_index:
		var pirate : Card
					
		if i >= _card_stacks.size():
			pirate = _trail_slots[i - _card_stacks.size()]._held_card
		else:
			pirate = _card_stacks[i].back()
		
		selected_pirates.append(pirate)
	
	return selected_pirates

func _discard_pirates(slot_pos : Vector2):
	# we iterate through the 2 selected pirates thanks to their stack index, we use pop_back
	# to get their card reference and remove them from their stack at the same time
	var pirate : Card
		
	if _selected_pirates_index[0] < _card_stacks.size():
		pirate = _card_stacks[_selected_pirates_index[0]].pop_back() as Card
			

	else:
		pirate = _trail_slots[_selected_pirates_index[0] - _card_stacks.size()]._held_card
		_trail_slots[_selected_pirates_index[0] - _card_stacks.size()]._held_card = null
		
	pirate._untoggle()
	pirate.z_index = 8
	pirate._tween_to_position(slot_pos)
	_game_scene._play_slide_sound()
	
	if _selected_pirates_index[1] < _card_stacks.size():
		pirate = _card_stacks[_selected_pirates_index[1]].pop_back() as Card
			

	else:
		pirate = _trail_slots[_selected_pirates_index[1] - _card_stacks.size()]._held_card
		_trail_slots[_selected_pirates_index[1] - _card_stacks.size()]._held_card = null
		
	pirate._untoggle()
	pirate.z_index = 8
	pirate._tween_to_position(slot_pos)
	_game_scene._play_slide_sound()
	
	await get_tree().create_timer(_discard_delay*2).timeout
	
func _cancel_drag():
	for card in _held_stack:
		card._remove_drag_component()

func _append_cards_to_new_stack(stack_index : int):
	for i in range(0, _held_stack.size(), +1) :
		_add_to_stack(_held_stack[i], stack_index)

func _snap_to_card(card : Card, card_pos : Vector2):
	
	card.position = card_pos
	card.position.y += _snap_offset
	# attibutes the card pos to the slot_pos so that the coming card snaps on the previous one

func _snap_to_slot(card: Card, slot_pos : Vector2):
	
	card.position = slot_pos

func _add_to_stack(card: Card, stack_index: int, snap_card := true):
	
	if snap_card:
		if  _card_stacks[stack_index].is_empty():
			_snap_to_slot(card, _stack_slots[stack_index].position)
		else:
			_snap_to_card(card, _card_stacks[stack_index].back().position)
	
	_card_stacks[stack_index].push_back(card)
	card.z_index = _card_stacks[stack_index].find(card)

func _add_to_trail(card: Card, trail_index: int):
	_snap_to_slot(card, _trail_slots[trail_index].position)
	_trail_slots[trail_index]._held_card = card

func _remove_cards_from_previous_stack():
	if _held_stack_index < _card_stacks.size():
		var previous_stack = _card_stacks[_held_stack_index] as Array
		previous_stack.resize(previous_stack.size()-_held_stack.size())
		
	else :
		_trail_slots[_held_stack_index - _card_stacks.size()]._held_card = null

func _cancel_drop():
	_cancel_drag()
	for card in _held_stack:
		card._reset_pos()
	_held_stack.clear()

func _stack_slot_pos(stack_index : int) -> Vector2:
	return _stack_slots[stack_index].position

func _enable_input():
	_can_play = true
	

func _disable_input():
	_game_scene._disable_beast_buttons()
	_can_play = false

func _has_won() -> bool:
	
	for stack in _card_stacks:
		if not stack.is_empty():
			return false
	
	return true

func _reset_board_data():
	
	_is_selecting_pirates = false
	
	for stack in _card_stacks:
		stack.clear()
	
	for slot in _stack_slots:
		slot._held_card = null
	
	for slot in _trail_slots:
		slot._held_card = null
		slot.unlock()
	
	for slot in _garbage_slots:
		slot._held_card = null
	
	for i in _color_trails:
		_color_trails[i] = 0
	
	_selected_pirates_index.clear()
	
	_pirates_index.clear()

	_held_stack.clear()
	
	_held_stack_index = 0
	
	_game_scene._fregate_button.modulate = Color.WHITE
	_game_scene._mobydick_button.modulate = Color.WHITE
	_game_scene._kraken_button.modulate = Color.WHITE
	
	#_move_amount = -1
	
func _add_stack_slot(slot: Slot):
	_card_stacks.push_back([])
	_stack_slots.push_back(slot)

func _add_trail_slot(slot: Slot):
	_trail_slots.push_back(slot)

func _add_garbage_slot(slot: Slot):
	_garbage_slots.push_back(slot)

func _increase_move_amount():
	pass
	#_move_amount += 1

func _on_beast_button_pressed(button):
	var toggled_button = _beasts_button_group.get_pressed_button()
	
	if toggled_button != null:
		
		if toggled_button.name == "FregateButton":
			_selected_beast_index = _fregate_index
		elif toggled_button.name == "MobydickButton":
			_selected_beast_index = _mobydick_index
		else:
			_selected_beast_index = _kraken_index
		
		if(_pirates_index.size()== 2):
			_selected_pirates_index = _pirates_index.duplicate()
			_discard_beast()
		else:
			_is_selecting_pirates = true
		
		
	else:
		
		_is_selecting_pirates = false
		
		for card in _selected_pirates():
			card._toggle()
		_selected_pirates_index.clear()
		
