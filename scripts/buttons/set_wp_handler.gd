extends Button

func _ready() -> void:
	# NOTE: Implement splitting by spaces to form more complex commands
	button_down.connect(func ():
		var set_wp_cmd = AppData.settings.get_value("cmds", "set_wp_cmd")
		var wps_dir = AppData.settings.get_value("dirs", "wps_dir")

		if AppData.currently_selected_thumbnail == null:
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_SELECTED_WP") % [tr("ADD_WP_BTN")])
			return
	
		var output: Array
		if OS.execute(set_wp_cmd, [wps_dir.path_join(AppData.currently_selected_thumbnail.filename)], output, true) != 0:
			var full_cmd = "[b]" + set_wp_cmd + "[/b]" + " " + wps_dir.path_join(AppData.currently_selected_thumbnail.filename)
			var error = "\n\n[bgcolor=black]%s[/bgcolor]" % [output.reduce(Utils.Str.flatten_output)]
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_INVALID_SET_WP_CMD") % [full_cmd, tr("STTS_CMDS_HEADER_LB"), tr("STTS_SET_AS_WP_SCRIPT_LB")] + error)
	)
