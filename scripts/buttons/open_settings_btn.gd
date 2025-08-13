extends TextureButton

func _ready() -> void:
	button_down.connect(func ():
		var settings_window = get_parent().get_node_or_null("SettingsWindow")

		if settings_window == null:
			get_parent().add_child(Global.res.settings_window_res.instantiate())
			return

		settings_window.show()
	)
