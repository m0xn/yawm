extends Node

func _ready() -> void:
	if not FileAccess.file_exists("user://settings.cfg"):
		return

	var wps_dir = AppData.settings.get_value("dirs", "wps_dir")
	if not DirAccess.dir_exists_absolute(wps_dir):
		AppData.settings.set_value("dirs", "wps_dirs", DefaultSettings.map["dirs"]["wps_dir"])
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_WPS_DIR") % wps_dir)
		
		if not DirAccess.dir_exists_absolute("user://wps_dir"):
			DirAccess.make_dir_absolute("user://wps_dir")
			Utils.Debug.log_msg(Types.DT.WARN, tr("DBG_MISSING_DEFAULT_WPS_DIR"))

			# NOTE: Fast reset all directories to avoid junk files about previous dirs
			if DirAccess.dir_exists_absolute("user://thumbs_dir"):
				DirAccess.remove_absolute("user://thumbs_dir")
				DirAccess.make_dir_absolute("user://thumbs_dir")

			if DirAccess.dir_exists_absolute("user://prvw_dir"):
				DirAccess.remove_absolute("user://prvw_dir")
				DirAccess.make_dir_absolute("user://prvw_dir")
