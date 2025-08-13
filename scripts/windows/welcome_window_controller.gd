extends Window

@onready var startup_stts_window_res = preload("res://scenes/windows/StartupSettingsWindow.tscn")

func _ready() -> void:
	%StartBTN.button_down.connect(func ():
		var window = startup_stts_window_res.instantiate()
		window.show()
		get_parent().add_child(window)

		get_parent().remove_child(self)
	)
