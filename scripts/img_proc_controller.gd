extends VBoxContainer

func _ready() -> void:
	# NOTE: Implement a way of loading a placeholder image if there is no thumbnails or preview images loaded
	var random_thumb_img = Image.load_from_file(AppData.settings.get_value("dirs", "thumbs_dir").path_join(AppData.random_wp))
	var random_prvw_img = Image.load_from_file(AppData.settings.get_value("dirs", "prvw_dir").path_join(AppData.random_wp))

	if random_thumb_img and random_prvw_img:
		%ThumbTextureTR.texture = ImageTexture.create_from_image(random_thumb_img)
		%PrvwTextureTR.texture = ImageTexture.create_from_image(random_prvw_img)

	%ThumbsApplyDFBTN.button_down.connect(apply_df_factor.bind(%ThumbsDfSB, %ThumbTextureTR, AppData.settings.get_value("dirs", "thumbs_dir"), "STTS_XFORM_THUMBS_LB"))
	%PrvwApplyDFBTN.button_down.connect(apply_df_factor.bind(%PrvwDfSB, %PrvwTextureTR, AppData.settings.get_value("dirs", "prvw_dir"), "STTS_XFORM_PRVW_LB"))

var loaded_thumbnails = 0
func apply_df_factor(spinbox_ref: SpinBox, texture_rect_ref: TextureRect, output_dir: String, progress_info: String) -> void:
	loaded_thumbnails = 0
	var rendering_thumbnails = output_dir == AppData.settings.get_value("dirs", "thumbs_dir")

	if rendering_thumbnails:
		Utils.GC.empty_grid_container()
		AppData.wp_count = 0
		Utils.GC.update_wp_count()

	if len(DirAccess.get_files_at(AppData.settings.get_value("dirs", "wps_dir"))) == 0:
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_EMPTY_WPS_DIR") % [AppData.settings.get_value("dirs", "wps_dir"), tr("ADD_WP_BTN")])
		return

	var progress_window = Global.res.progress_window_res.instantiate()
	progress_window.init(tr(progress_info))
	progress_window.show()
	add_child(progress_window)

	var total_thumbnails = AppData.wp_count if AppData.wp_count != 0 else len(DirAccess.get_files_at(AppData.settings.get_value("dirs", "wps_dir")))

	var downscale_factor = spinbox_ref.value
	await Utils.Dir.iterate_dir(AppData.settings.get_value("dirs", "wps_dir"), func (filename):
		var downscaled_img = Utils.ImgProcessing.render_img(AppData.settings.get_value("dirs", "wps_dir").path_join(filename), filename, downscale_factor, output_dir)
		Utils.GC.load_into_grid_container(filename, downscaled_img)

		if filename == AppData.random_wp:
			texture_rect_ref.texture = ImageTexture.create_from_image(downscaled_img)

		loaded_thumbnails += 1
		if rendering_thumbnails:
			AppData.wp_count = loaded_thumbnails
			Utils.GC.update_wp_count()

		progress_window.update_progress(loaded_thumbnails, total_thumbnails, tr(progress_info) + " " + str(downscale_factor), filename)
		await get_tree().process_frame
	)

	remove_child(progress_window)
