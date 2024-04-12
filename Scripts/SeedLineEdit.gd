extends LineEdit

signal _seed_changed(seed: int)

func _ready():
	text_changed.connect(_on_text_changed)

func _on_text_changed(new_text):
	
	text = _format_text(new_text)
	
	caret_column = text.length()
	
	if text.length() != 0:
		var str := text
		if str.begins_with('_'):
			str[0] = '-'
		_seed_changed.emit(int(str))
	else:
		_seed_changed.emit(-1)

func _format_text(new_text : String) -> String :
	
	var nt := new_text.replacen(" ", "")
	
	print(nt)
	
	var ft := ""
	var max_l := 19
	if nt.begins_with('_'):
		ft += '_'
		max_l += 1
		print(ft)
	
	if nt.length() <= max_l:
		for i in nt.length():
			if nt[i] >= '0' and nt[i] <= '9':
				ft += nt[i]
	else:
		for i in max_l:
			if nt[i] >= '0' and nt[i] <= '9':
				ft += nt[i]
	
	return ft

func _on_copy_button_button_down():
	pass # Replace with function body.
	print("_on_copy_button_button_down")
	menu_option(MENU_SELECT_ALL)
	menu_option(MENU_COPY)
	caret_column += 1
	#MENU_COPY

func _on_paste_button_button_down():
	pass # Replace with function body.
	#text = DisplayServer.clipboard_get()
	print("_on_paste_button_button_down")
	clear()
	menu_option(MENU_PASTE)
	
	
	#MENU_PASTE

func _on_clear_button_button_down():
	clear()
