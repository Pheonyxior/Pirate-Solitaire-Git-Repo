@tool
extends RichTextLabel

func _ready():
	await get_tree().create_timer(0.4).timeout
	#append_text("[center]")
	append_text(tr("VS1"))
#	push_color(Color('fbdd93'))
	push_color(Color.WHITE)
	if Engine.is_editor_hint():
		append_text("95")
	else:
		append_text(str(CardManager._move_amount))
	#push_color(Color('e9d8c7'))
	append_text(tr("VS2"))
