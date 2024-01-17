extends RichTextLabel

func _ready():
	pass
	push_color(Color('fbdd93'))
	append_text("[url]https://victor-pernet.itch.io/pirate-solitaire[/url]")
	push_color(Color.WHITE)
	append_text("\nby clicking on the \nDownload Now button.")

func _on_meta_clicked(meta):
	pass # Replace with function body.
	OS.shell_open(str(meta))
