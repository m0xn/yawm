extends Window

var os_icon_map: Dictionary[String, String] = {
	"Linux": "res://graphics/os_logos/linux_logo.svg",
	"Windows": "res://graphics/os_logos/windows_logo.svg"
	# NOTE: Implement MacOS support after testing
}

# NOTE: This variable maps Desktop Environments with their matching scripts or cmds
#		to change or open the selected wallpaper
var script_map: Dictionary[String, Array] = {
	"windows": ["https://raw.githubusercontent.com/m0xn/yawm/refs/heads/main/external_scripts/change_wallpaper_windows.ps1", "CMD.exe /C start"],
	"budgie": ["https://raw.githubusercontent.com/m0xn/yawm/refs/heads/main/external_scripts/change_wallpaper_gnome_based.sh", "eog"],
	"cinnamon": ["https://raw.githubusercontent.com/m0xn/yawm/refs/heads/main/external_scripts/change_wallpaper_cinnamon.sh", "xviewer"],
	"kde": ["https://raw.githubusercontent.com/m0xn/yawm/refs/heads/main/external_scripts/change_wallpaper_kde.sh", "gwenview"],
	"gnome": ["https://raw.githubusercontent.com/m0xn/yawm/refs/heads/main/external_scripts/change_wallpaper_gnome_based.sh", "eog"],
	"mate": ["https://raw.githubusercontent.com/m0xn/yawm/refs/heads/main/external_scripts/change_wallpaper_kde.sh", "eom"],
	"xfce": ["https://raw.githubusercontent.com/m0xn/yawm/refs/heads/main/external_scripts/change_wallpaper_xfce.sh", "ristretto"],
}

func _ready() -> void:
	# NOTE: Disable enable preview processing CB to simplify startup settings
	%DirSectionVBC.get_node("%EnablePrvwProcessingCB").hide()
	%SaveBTN.button_down.connect(verify_fields)

	DirAccess.make_dir_absolute("user://wps_dir")
	DirAccess.make_dir_absolute("user://thumbs_dir")
	DirAccess.make_dir_absolute("user://prvw_dir")

	var os_name = OS.get_name()
	var os_icon = load(os_icon_map[os_name])

	%DetectedOSLogoTR.texture = os_icon
	%DetectedOSNameLB.text = os_name + (" (%s)" % [OS.get_environment("XDG_SESSION_DESKTOP")] if os_name == "Linux" else "")

	var http_request := HTTPRequest.new()
	add_child(http_request)

	var map_entry = os_name.to_lower() if os_name != "Linux" else OS.get_environment("XDG_SESSION_DESKTOP").to_lower()

	if map_entry in script_map:
		var set_wp_script_url = script_map[map_entry][0]
		http_request.download_file = "user://%s" % [set_wp_script_url.get_file()]
		http_request.request(set_wp_script_url)

		AppData.settings.set_value("cmds", "set_wp_cmd", ("sh %s" if os_name != "Windows" else "powershell.exe -Command %s") % ProjectSettings.globalize_path("user://".path_join(set_wp_script_url.get_file())))
		%CmdsSectionVBC.get_node("%SetAsWpCmdLE").text = ("sh %s" if os_name != "Windows" else "powershell.exe -Command %s") % ProjectSettings.globalize_path("user://".path_join(set_wp_script_url.get_file()))

		AppData.settings.set_value("cmds", "open_img_vwr_cmd", script_map[map_entry][1])
		%CmdsSectionVBC.get_node("%OpenInImgVwrCmdLE").text = script_map[map_entry][1]

func verify_fields() -> void:
	for field in ["dirs|wps_dir", "dirs|thumbs_dir", "cmds|set_wp_cmd", "cmds|open_img_vwr_cmd"]:
		var section = field.split("|")[0]
		var param = field.split("|")[1]

		if AppData.settings.get_value(section, param) == "":
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_FIELDS"))
			return

	AppData.settings.save("user://settings.cfg")
	get_parent().remove_child(self)

	if len(DirAccess.get_files_at(AppData.settings.get_value("dirs", "wps_dir"))) != 0:
		var process_wps_window: Window = load("res://scenes/windows/ConfirmationWindow.tscn").instantiate()
		process_wps_window.init_window("PROCESS_WPS_WINDOW_TTL", tr("PROCESS_WPS_WINDOW_MSG_LB") % AppData.settings.get_value("dirs", "wps_dir"), import_found_wps)

		Global.nodes.app_root_ref.add_child(process_wps_window)

func import_found_wps(caller_window_ref: Window) -> void:
	var scene_tree_ref = Global.nodes.app_root_ref.get_tree()
	Global.nodes.app_root_ref.remove_child(caller_window_ref)

	var wps_dir = AppData.settings.get_value("dirs", "wps_dir")

	Utils.Dir.iterate_dir(wps_dir, func (filename):
		var img = Utils.ImgProcessing.render_img(
			wps_dir.path_join(filename),
			filename,
			AppData.settings.get_value("img_proc", "thumbs_df"),
			AppData.settings.get_value("dirs", "thumbs_dir")
		)

		AppData.wp_count += 1
		Utils.GC.load_into_grid_container(filename, img)
		Utils.GC.update_wp_count()

		await scene_tree_ref.process_frame
	)
