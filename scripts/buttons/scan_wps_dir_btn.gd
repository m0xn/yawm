extends Button

var new_wallpapers: PackedStringArray
func handle_new_wps_import() -> void:
	new_wallpapers.clear()

	Utils.Dir.iterate_dir(AppData.settings.get_value("dirs", "wps_dir"), func (filename):
		if not FileAccess.file_exists(AppData.settings.get_value("dirs", "thumbs_dir").path_join(filename)):
			new_wallpapers.append(AppData.settings.get_value("dirs", "wps_dir").path_join(filename))
	)

	if len(new_wallpapers) == 0:
		Utils.Debug.log_msg(Types.DT.INFO, tr("DBG_NO_NEW_WPS_FOUND_SCAN") % AppData.settings.get_value("dirs", "wps_dir"))
		return
	
	var import_found_wps_window = load("res://scenes/windows/ConfirmationWindow.tscn").instantiate()
	import_found_wps_window.show()
	add_child(import_found_wps_window)

	import_found_wps_window.init_window("NEW_WPS_FOUND_SCAN_WND_TTL", tr("NEW_WPS_FOUND_SCAN_WND_LB" if len(new_wallpapers) > 1 else "NEW_WP_FOUND_SCAN_WND_LB") % len(new_wallpapers), func (caller_window):
		Utils.Import.load_to_import_window(new_wallpapers, self)
		caller_window.queue_free()
	)

func _ready() -> void:
	button_down.connect(handle_new_wps_import)
