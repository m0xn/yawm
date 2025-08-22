extends TextureButton

func _ready() -> void:
	button_down.connect(func ():
		var settings_window = Global.nodes.app_root_ref.get_node_or_null("SettingsWindow")
		
		if settings_window == null:
			settings_window = load("res://scenes/windows/SettingsWindow.tscn").instantiate()
			Global.nodes.app_root_ref.add_child(settings_window)

		settings_window.show()
	)
