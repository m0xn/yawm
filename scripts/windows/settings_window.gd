extends "base_hide_window.gd"

func _ready() -> void:
	super()
	close_requested.connect(func ():
		AppData.settings.save("user://settings.cfg")
	)
