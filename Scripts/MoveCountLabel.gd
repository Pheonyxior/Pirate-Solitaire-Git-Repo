@tool
extends RichTextLabel

func _ready():
	append_text("[center]")
	append_text("Number of moves : ")
	push_color(Color.WHITE)
	if Engine.is_editor_hint():
		append_text("95")
	else:
		append_text(str(CardManager._move_amount + 48))
