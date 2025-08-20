extends "base_window.gd"

var wp_list_container: ListContainer

func _ready() -> void:
	super()
	close_requested.connect(func (): AppData.wps_to_load = 0)

func add_wps(wp_paths: PackedStringArray) -> void:
	wp_list_container = %WPListVBC

	AppData.wps_to_load += len(wp_paths)
	%WPNoLB.text = tr("WP_IMPORT_WP_NO_LB") + " " + str(AppData.wps_to_load)

	for path in wp_paths:
		if path.get_extension() not in ["png", "jpg", "jpeg"]:
			queue_free()
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_UNSUPPORTED_FILE_FORMAT") % [path.get_extension()])
			return

		wp_list_container.add_item(func (item):
			item.get_node("%WPFilenameLB").text = path.get_file()
			item.get_node("%WPAbsPathLB").text = path

			item.get_node("%WPRenameLE").placeholder_text = path.get_file()
			item.get_node("%WPDeleteEntryBTN").button_down.connect(func ():
				wp_list_container.remove_item(item)
				AppData.wps_to_load = wp_list_container.item_count
				%WPNoLB.text = tr("WP_IMPORT_WP_NO_LB") + " " + str(AppData.wps_to_load)
			)
		)
		
	if not %LoadWallpapersBTN.button_down.has_connections():
		%LoadWallpapersBTN.button_down.connect(import_wallpapers)

func import_wallpapers() -> void:
	var progress_window: Window = load("res://scenes/windows/ProgressWindow.tscn").instantiate()
	progress_window.init(tr("P_BAR_IMPORTING_INFO_LB"))
	progress_window.show()
	Global.nodes.app_root_ref.add_child(progress_window)

	await wp_list_container.process_items(func (item, processed_wallpapers):
		if progress_window.cancel_progress:
			progress_window.queue_free()
			return

		var item_line_edit = item.get_node("%WPRenameLE")
		var original_ext = item.get_node("%WPFilenameLB").text.get_extension()

		var filename = item.get_node("%WPFilenameLB").text if item_line_edit.text == "" else item_line_edit.text
		var img_path = item.get_node("%WPAbsPathLB").text
		var processed_filename = filename if filename.ends_with(original_ext) else filename + "." + original_ext
		
		var thumbnail_img = Utils.ImgProcessing.render_img(img_path, processed_filename, AppData.settings.get_value("img_proc", "thumbs_df"), AppData.settings.get_value("dirs", "thumbs_dir"))
		Utils.GC.load_into_grid_container(processed_filename, thumbnail_img)

		Utils.ImgProcessing.render_img(
			img_path,
			processed_filename,
			AppData.settings.get_value("img_proc", "prvw_df") if AppData.settings.get_value("dirs", "prvw_dir") == "" else 1.0,
			AppData.settings.get_value("dirs", "wps_dir") if AppData.settings.get_value("dirs", "prvw_dir") == "" else AppData.settings.get_value("dirs", "prvw_dir")
		)

		AppData.wp_count += 1
		Utils.GC.update_wp_count()

		if item_line_edit.text != "":
			DirAccess.rename_absolute(img_path, img_path.get_base_dir().path_join(processed_filename))

		if not FileAccess.file_exists(AppData.settings.get_value("dirs", "wps_dir").path_join(processed_filename)):
			DirAccess.copy_absolute(img_path, AppData.settings.get_value("dirs", "wps_dir").path_join(processed_filename))

		progress_window.update_progress(processed_wallpapers, wp_list_container.item_count, "", filename)

		await get_tree().process_frame
	)

	progress_window.queue_free()
	queue_free()
