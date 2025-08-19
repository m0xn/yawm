extends RichTextLabel

func _ready() -> void:
	meta_clicked.connect(func(meta): OS.shell_open(str(meta)))
