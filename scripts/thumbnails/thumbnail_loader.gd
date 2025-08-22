extends Node

func _ready() -> void:
	if FileAccess.file_exists("user://settings.cfg"):
		if not DirAccess.dir_exists_absolute("user://thumbs_dir"):
			DirAccess.make_dir_absolute("user://thumbs_dir")
			Utils.Debug.log_msg(Types.DT.WARN, tr("DBG_MISSING_THUMBS_DIR"))

			var valid_wps = Utils.Dir.get_valid_img_files(AppData.settings.get_value("dirs", "wps_dir"))

			var restore_missing_thumbs_window = load("res://scenes/windows/ConfirmationWindow.tscn").instantiate()
			get_parent().add_child.call_deferred(restore_missing_thumbs_window)
			restore_missing_thumbs_window.init_window(tr("RESTORE_MISSING_THUMBS_TTL"), tr("RESTORE_MISSING_THUMBS_LB") % AppData.settings.get_value("dirs", "wps_dir"), func (caller_window):
				caller_window.queue_free()
				Utils.ImgProcessing.process_new_wps(valid_wps, true, true)
			)
			return
	else:
		return # NOTE: Avoid loading thumbnails on startup configuration
	
	var start_time = Time.get_ticks_msec()
	var valid_thumbnails = Utils.Dir.get_valid_img_files("user://thumbs_dir")

	for thumbnail in valid_thumbnails:
		if not FileAccess.file_exists(ProjectSettings.globalize_path(AppData.settings.get_value("dirs", "wps_dir").path_join(thumbnail))):
			DirAccess.remove_absolute("user://thumbs_dir".path_join(thumbnail))
			if AppData.settings.get_value("dirs", "enable_prvw_processing"):
				DirAccess.remove_absolute("user://prvw_dir".path_join(thumbnail))

			continue

		var img := Image.load_from_file("user://thumbs_dir".path_join(thumbnail))

		AppData.wp_count += 1
		Utils.GC.update_wp_count()

		Utils.GC.load_into_grid_container(thumbnail, img)
		await get_tree().process_frame
	
	var time_to_import_ms = Time.get_ticks_msec() - start_time
	if not AppData.wp_count == 0:
		Utils.Debug.log_msg(Types.DT.INFO, tr("DBG_THUMBS_LOAD_TIME") % [AppData.wp_count, time_to_import_ms, time_to_import_ms / 1000.0])

	var missing_wps = Utils.Dir.get_missing_wps()
	if len(missing_wps) > 0:
		var confirmation_msg = tr("LOAD_NEW_WPS_LB") % len(missing_wps) if len(missing_wps) > 1 else tr("LOAD_NEW_WP_LB")
		var load_new_wps_window = load("res://scenes/windows/ConfirmationWindow.tscn").instantiate()
		get_parent().add_child.call_deferred(load_new_wps_window)
		load_new_wps_window.init_window(tr("LOAD_NEW_WPS_TTL"), confirmation_msg, func (caller_window):
			caller_window.queue_free()
			Utils.ImgProcessing.process_new_wps(missing_wps, true, true)
		)
