extends Button

func _ready() -> void:
	button_down.connect(func ():
		var raw_cmd = AppData.settings.get_value("cmds", "open_img_vwr_cmd")
		var wps_dir = AppData.settings.get_value("dirs", "wps_dir")

		if AppData.currently_selected_thumbnail == null:
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_SELECTED_WP") % [tr("ADD_WP_BTN")])
			return

		var cmd_args = raw_cmd.split(" ")
		var cmd = cmd_args[0]
		cmd_args.remove_at(0)

		cmd_args.append(wps_dir.path_join(AppData.currently_selected_thumbnail.filename))

		var output: Array
		if OS.execute(cmd, cmd_args, output, true) != 0:
			var full_cmd = "[b]" + cmd + "[/b]" + " " + cmd_args.reduce(Utils.Str.flatten_array)
			var error = "\n\n[bgcolor=black]%s[/bgcolor]" % [output.reduce(Utils.Str.flatten_array)]
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_INVALID_OPEN_WP_CMD") % [full_cmd, tr("STTS_CMDS_HEADER_LB"), tr("OPEN_IN_IMG_VIEWER_BTN")] + error)
	)
