extends Button

func _ready() -> void:
	button_down.connect(func ():
		var open_wp_cmd = AppData.settings.get_value("cmds", "open_img_vwr_cmd")
		var wps_dir = AppData.settings.get_value("dirs", "wps_dir")

		if AppData.currently_selected_thumbnail == null:
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_SELECTED_WP") % [tr("ADD_WP_BTN")])
			return

		var output: Array
		if OS.execute(open_wp_cmd, [wps_dir.path_join(AppData.currently_selected_thumbnail.filename)], output, true) != 0:
			var full_cmd = "[b]" + open_wp_cmd + "[/b]" + " " + wps_dir.path_join(AppData.currently_selected_thumbnail.filename)
			var error = "\n\n[bgcolor=black]%s[/bgcolor]" % [output.reduce(Utils.Str.flatten_output)]
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_INVALID_OPEN_WP_CMD") % [full_cmd, tr("STTS_CMDS_HEADER_LB"), tr("OPEN_IN_IMG_VIEWER_BTN")] + error)
	)
