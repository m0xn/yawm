extends TextureButton

func _ready() -> void:
	button_down.connect(func ():
		var settings_window = get_node_or_null("%SettingsWindow")
		
		if settings_window == null:
			settings_window = load("res://scenes/windows/SettingsWindow.tscn").instantiate()
			settings_window.unique_name_in_owner = true
			Global.nodes.app_root_ref.add_child(settings_window)

		settings_window.show()
	)
