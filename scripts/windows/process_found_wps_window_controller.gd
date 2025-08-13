extends Window

func _ready() -> void:
	%ProcessWpsMsgLB.text = tr("PROCESS_WPS_WINDOW_MSG_LB").format([AppData.settings.get_value("dirs", "wps_dir")])

	%NoBTN.button_down.connect(func (): get_parent().remove_child(self))
	%OkBTN.button_down.connect(import_found_wps)

func import_found_wps() -> void:
	var scene_tree_ref = get_tree()
	get_parent().remove_child(self)

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
