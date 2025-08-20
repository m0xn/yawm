extends Button

@export var cmd_ref: String

func execute_command() -> void:
	var raw_cmd = AppData.settings.get_value("cmds", cmd_ref)
	var wps_dir = ProjectSettings.globalize_path(AppData.settings.get_value("dirs", "wps_dir"))

	if wps_dir == "":
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DDG_MISSING_DIR") % ["STTS_WPS_DIR_LB", "STTS_WPS_DIR_LB"])
		return

	if AppData.currently_selected_thumbnail == null:
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_SELECTED_WP") % [tr("ADD_WP_BTN")])
		return

	var split_cmd = raw_cmd.split(" ")

	var cmd = split_cmd[0]
	var args = []

	if len(split_cmd) > 1:
		split_cmd.remove_at(0)
		args.append_array(split_cmd)

	args.append(wps_dir.path_join(AppData.currently_selected_thumbnail.filename))

	var output: Array
	if OS.execute(cmd, args, output, true) != 0:
		var final_cmd = cmd + " " + args.reduce(Utils.Str.flatten_array)
		var error = "\n\n[bgcolor=black]%s[/bgcolor]" % output.reduce(Utils.Str.flatten_array)
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_INVALID_CMD") % [final_cmd, tr("%s_BTN" % cmd_ref.trim_suffix("_cmd").to_upper())] + error)

func _ready() -> void:
	button_down.connect(execute_command)
