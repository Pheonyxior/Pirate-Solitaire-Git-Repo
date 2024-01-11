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
		_seed_changed.emit(int(text))
	else:
		_seed_changed.emit(-1)

func _format_text(new_text : String) -> String :
	
	var nt := new_text
	var ft := ""
	var max_l := 19
	if nt.begins_with('_'):
		ft += '_'
		max_l += 1
	
	if nt.length() <= max_l:
		for i in nt.length():
			if nt[i] >= '0' and nt[i] <= '9':
				ft += nt[i]
	else:
		for i in max_l:
			if nt[i] >= '0' and nt[i] <= '9':
				ft += nt[i]
	
	return ft

#func _format_text(new_text) -> String :
#	var start_time := Time.get_ticks_usec()
#	var nt : String = new_text.replace(" ", "")
#	var digit_count := 0
#	var ft := ""
#
#	for char in nt:
#		if char >= '0' and char <= '9':
#			if digit_count % 3 == 0 and digit_count != 0:
#				ft += " "
#			ft += char
#			digit_count += 1
#
#
#	var end_time:= Time.get_ticks_usec()
##	print("loop execution time :", end_time - start_time)
#
##	print(ft)
#	return ft



#func _format_text(new_text) -> String :
#	var start_time := Time.get_ticks_usec()
#	#var nt : String = text.replace(" ", "")
#	var nt := ""
#	for str in new_text :
#		if str >= '0' and str <= '9':
#			nt += str
#
#	var comma_pos = nt.length() % 3
#
#	var ft := nt.substr(0, comma_pos)
#
#	while comma_pos < nt.length():
#		if ft != "":
#			ft += " "
#		ft += nt.substr(comma_pos, 3)
#		comma_pos += 3
#
#
#	var end_time:= Time.get_ticks_usec()
#	print("loop execution time :", end_time - start_time)
#
#	return ft

