extends VBoxContainer

func _ready() -> void:
	var random_thumbnail_img = Image.load_from_file(AppData.settings.get_value("dirs", "thumbs_dir").path_join(AppData.random_wp))
	%ThumbTextureTR.texture = ImageTexture.create_from_image(random_thumbnail_img)

	var random_preview_img = Image.load_from_file(AppData.settings.get_value("dirs", "wps_dir").path_join(AppData.random_wp))
	%PrvwTextureTR.texture = ImageTexture.create_from_image(random_preview_img)

	%ThumbsApplyDFBTN.button_down.connect(transform_thumbnails)
	%PrvwApplyDFBTN.button_down.connect(transform_preview_imgs)

func process_img(img: Image, path: String, out_dir: String, downscale_factor: float) -> void:
	var img_copy = img.duplicate()
	var img_size = img.get_size()

	img_copy.resize(img_size.x * downscale_factor, img_size.y * downscale_factor)
	Utils.ImgProcessing.save_img(img_copy, path, out_dir)

	Utils.GC.load_into_grid_container(path, img_copy)

func transform_thumbnails() -> void:
	var progress_window: Window = Global.res.progress_window_res.instantiate()
	progress_window.show()
	add_child(progress_window)

	var prev_wp_count = AppData.wp_count

	Utils.GC.empty_grid_container()
	AppData.wp_count = 0
	Utils.GC.update_wp_count()
	
	var downscale_factor = %ThumbsDFSB.value

	progress_window.init("%s %d" % [tr("STTS_XFORM_THUMBS_LB"), downscale_factor])

	# NOTE: Iterate thumbs dir to process ONLY the wallpapers loaded into the grid_container
	await Utils.Dir.iterate_dir(AppData.settings.get_value("dirs", "thumbs_dir"), func (path):
		process_img(Image.load_from_file(AppData.settings.get_value("dirs", "wps_dir").path_join(path)), path, AppData.settings.get_value("dirs", "thumbs_dir"), downscale_factor)

		if path == AppData.random_wp:
			var random_thumbnail_img = Image.load_from_file(AppData.settings.get_value("dirs", "thumbs_dir").path_join(AppData.random_wp))
			%ThumbTextureTR.texture = ImageTexture.create_from_image(random_thumbnail_img)

		AppData.wp_count += 1
		Utils.GC.update_wp_count()

		progress_window.update_progress(AppData.wp_count, prev_wp_count, "", path)
		await get_tree().process_frame
	)

	remove_child(progress_window)

var processed_wps := 0

func transform_preview_imgs() -> void:
	processed_wps = 0

	var progress_window: Window = Global.res.progress_window_res.instantiate()
	progress_window.show()
	add_child(progress_window)

	var downscale_factor = %PrvwDFSB.value

	progress_window.init("%s %d" % [tr("STTS_XFORM_PRVW_LB"), downscale_factor])

	await Utils.Dir.iterate_dir(AppData.settings.get_value("dirs", "thumbs_dir"), func (path):
		process_img(Image.load_from_file(AppData.settings.get_value("dirs", "wps_dir").path_join(path)), path, AppData.settings.get_value("dirs", "prvw_dir"), downscale_factor)

		if path == AppData.random_wp:
			var random_preview_img = Image.load_from_file(AppData.settings.get_value("dirs", "prvw_dir").path_join(AppData.random_wp))
			%PrvwTextureTR.texture = ImageTexture.create_from_image(random_preview_img)

		processed_wps += 1
		progress_window.update_progress(processed_wps, AppData.wp_count, "", path)
		await get_tree().process_frame
	)

	remove_child(progress_window)
