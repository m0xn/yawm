extends "base_window.gd"

func _ready() -> void:
	super()
	reset_size()
	get_node("%ErrorMsgRTL").fit_content = true
