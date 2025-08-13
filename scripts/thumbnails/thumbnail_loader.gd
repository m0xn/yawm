extends Node

var wps_filename_list: PackedStringArray

func _ready() -> void:
	if FileAccess.file_exists("user://settings.cfg"):
		if AppData.settings.get_value("dirs", "thumbs_dir") == "":
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_THUMBS_DIR") % [tr("STTS_DIR_HEADER_LB"), tr("STTS_THUMBS_DIR_LB")])
			return
	else:
		return

	Utils.Dir.iterate_dir(AppData.settings.get_value("dirs", "thumbs_dir"), func (filename):
		if filename.get_extension() not in ["jpeg", "jpg", "png"]:
			Utils.Debug.log_msg(Types.DT.WARN, tr("DBG_THUMB_W_UNSUPPORTED_FF") % [filename, filename.get_extension()])
			return

		var img := Image.load_from_file(AppData.settings.get_value("dirs", "thumbs_dir").path_join(filename))
		AppData.wp_count += 1
		Utils.GC.load_into_grid_container(filename, img)
		wps_filename_list.append(filename)
	)
	
	if len(wps_filename_list) != 0:
		AppData.random_wp = wps_filename_list[randi_range(0, len(wps_filename_list))]
		wps_filename_list.clear()

	Global.nodes.wallpaper_count_label_ref.text = tr("WP_COUNT_LB") + " " + str(AppData.wp_count)
