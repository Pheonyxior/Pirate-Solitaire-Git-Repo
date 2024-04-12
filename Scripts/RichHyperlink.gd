extends RichTextLabel

func _ready():
	text = tr("CREDITS")

func _on_meta_clicked(meta):
	OS.shell_open(str(meta))
