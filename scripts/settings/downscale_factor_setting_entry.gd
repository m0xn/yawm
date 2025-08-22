extends "spinbox_setting_entry.gd"

func handle_render_confirmation(caller_window: Window) -> void:
	caller_window.queue_free()
	AppData.settings.set_value(stts_section, stts_name, editable_node[editable_field])

	if stts_name == "thumbs_df":
		Utils.GC.empty_grid_container()
		AppData.wp_count = 0
		Utils.GC.update_wp_count()

	var valid_wps = Utils.Dir.get_valid_img_files(AppData.settings.get_value("dirs", "wps_dir"))
	show_input_validity(true)
	reset_to_def_btn["show" if check_imparity(editable_node[editable_field]) else "hide"].call()
	await Utils.ImgProcessing.process_new_wps(valid_wps, stts_name == "thumbs_df", AppData.settings.get_value("dirs", "enable_prvw_processing"))

	if AppData.random_wp == "":
		var random_idx = randi() % len(valid_wps)
		AppData.random_wp = valid_wps[random_idx]

	var output_dir = "user://thumbs_dir" if stts_name == "thumbs_df"  else "user://prvw_dir"
	var new_random_wp = Image.load_from_file(output_dir.path_join(AppData.random_wp))
	get_node("%%%s" % ("ThumbTextureTR" if stts_name == "thumbs_df" else "PrvwTextureTR")).texture = ImageTexture.create_from_image(new_random_wp)

func _on_value_change(new_value: Variant) -> void:
	# NOTE: Filter out signals coming from resetting the SpinBox value
	if new_value == AppData.settings.get_value(stts_section, stts_name):
		return

	var confirmation_label = "RENDER_THUMBS_CONFIRMATION_LB" if stts_name == "thumbs_df" else "RENDER_PRVW_CONFIRMATION_LB"
	print(confirmation_label, tr(confirmation_label))
	var confirmation_window = load("res://scenes/windows/ConfirmationWindow.tscn").instantiate()

	confirmation_window.init_window(tr("RENDER_WPS_CONFIRMATION_TTL"), tr(confirmation_label) % new_value, handle_render_confirmation, func(caller_window):
		caller_window.queue_free()
		editable_node[editable_field] = AppData.settings.get_value(stts_section, stts_name)
		reset_to_def_btn["show" if check_imparity(editable_node[editable_field]) else "hide"].call()
		show_input_validity(false)
	)
	add_child(confirmation_window)
