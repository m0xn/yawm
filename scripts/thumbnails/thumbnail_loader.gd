extends Node

func _ready() -> void:
	if FileAccess.file_exists("user://settings.cfg"):
		if AppData.settings.get_value("dirs", "thumbs_dir") == "":
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_DIR") % [tr("STTS_THUMBS_DIR_LB"), tr("STTS_THUMBS_DIR_LB")])
			return
	else:
		return # NOTE: Avoid loading thumbnails on startup configuration

	var start_time = Time.get_ticks_msec()
	await Utils.Dir.iterate_dir(AppData.settings.get_value("dirs", "thumbs_dir"), func (filename):
		if filename.get_extension() not in ["jpeg", "jpg", "png"]:
			Utils.Debug.log_msg(Types.DT.WARN, tr("DBG_THUMB_W_UNSUPPORTED_FF") % [filename, filename.get_extension()])
			return

		var img := Image.load_from_file(AppData.settings.get_value("dirs", "thumbs_dir").path_join(filename))

		AppData.wp_count += 1
		Utils.GC.update_wp_count()

		Utils.GC.load_into_grid_container(filename, img)
		await get_tree().process_frame
	)
	
	var time_to_import_ms = Time.get_ticks_msec() - start_time
	Utils.Debug.log_msg(Types.DT.INFO, tr("DBG_IMPORTED_WALLPAPERS_INFO") % [AppData.wp_count, time_to_import_ms, time_to_import_ms / 1000.0])
