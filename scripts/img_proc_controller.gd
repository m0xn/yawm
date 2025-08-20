extends VBoxContainer

var random_wp: String

func _ready() -> void:
	var wps = DirAccess.get_files_at(AppData.settings.get_value("dirs", "thumbs_dir"))
	if len(wps) == 0 or AppData.settings.get_value("dirs", "thumbs_dir") == "":
		%ThumbTextureTR.texture = load("res://graphics/template_images/thumbnail_template.png")
		%PrvwTextureTR.texture = load("res://graphics/template_images/preview_template.png")
	else:
		random_wp = wps[randi_range(0, len(wps))]

		var random_thumb_img = Image.load_from_file(AppData.settings.get_value("dirs", "thumbs_dir").path_join(random_wp))
		var random_prvw_img = Image.load_from_file(AppData.settings.get_value("dirs", "prvw_dir").path_join(random_wp))

		%ThumbTextureTR.texture = ImageTexture.create_from_image(random_thumb_img)
		%PrvwTextureTR.texture = ImageTexture.create_from_image(random_prvw_img)

	%ThumbsApplyDFBTN.button_down.connect(apply_df_factor.bind(%ThumbsDfSB, %ThumbTextureTR, AppData.settings.get_value("dirs", "thumbs_dir"), "STTS_XFORM_THUMBS_LB"))
	%PrvwApplyDFBTN.button_down.connect(apply_df_factor.bind(%PrvwDfSB, %PrvwTextureTR, AppData.settings.get_value("dirs", "prvw_dir"), "STTS_XFORM_PRVW_LB"))

var processed_imgs = 0
func apply_df_factor(spinbox_ref: SpinBox, texture_rect_ref: TextureRect, output_dir: String, progress_info: String) -> void:
	processed_imgs = 0
	var rendering_thumbnails = output_dir == AppData.settings.get_value("dirs", "thumbs_dir")

	if output_dir == "":
		var stts_dir_name = tr("STTS_THUMBS_DIR_LB") if rendering_thumbnails else tr("STTS_PRVW_DIR_LB")
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_DIR") % [stts_dir_name, stts_dir_name])
		return

	if rendering_thumbnails:
		Utils.GC.empty_grid_container()
		AppData.wp_count = 0
		Utils.GC.update_wp_count()

	if len(DirAccess.get_files_at(AppData.settings.get_value("dirs", "wps_dir"))) == 0:
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_EMPTY_WPS_DIR") % [AppData.settings.get_value("dirs", "wps_dir"), tr("ADD_WP_BTN")])
		return

	var progress_window = load("res://scenes/windows/ProgressWindow.tscn").instantiate()
	progress_window.init(tr(progress_info))
	progress_window.show()
	add_child(progress_window)

	var total_thumbnails = AppData.wp_count if AppData.wp_count != 0 else len(DirAccess.get_files_at(AppData.settings.get_value("dirs", "wps_dir")))

	var downscale_factor = spinbox_ref.value
	await Utils.Dir.iterate_dir(AppData.settings.get_value("dirs", "wps_dir"), func (filename):
		if progress_window.cancel_progress:
			progress_window.queue_free()
			return

		var downscaled_img = Utils.ImgProcessing.render_img(AppData.settings.get_value("dirs", "wps_dir").path_join(filename), filename, spinbox_ref.value, output_dir)
		processed_imgs += 1

		if filename == random_wp:
			texture_rect_ref.texture = ImageTexture.create_from_image(downscaled_img)

		if rendering_thumbnails:
			Utils.GC.load_into_grid_container(filename, downscaled_img)
			AppData.wp_count = processed_imgs
			Utils.GC.update_wp_count()

		progress_window.update_progress(processed_imgs, total_thumbnails, "%s %d%%" % [tr(progress_info), downscale_factor], filename)
		await get_tree().process_frame
	)

	remove_child(progress_window)
