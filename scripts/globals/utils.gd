extends Node

class ImgProcessing:
	static func process_new_wps(missing_wps: PackedStringArray, is_thumbnail := true, render_prvw_imgs := false) -> void:
		var scene_tree_ref = Global.nodes.app_root_ref.get_tree()

		var wps_dir = AppData.settings.get_value("dirs", "wps_dir")
		var downscale_factor = AppData.settings.get_value("img_proc", "thumbs_df" if is_thumbnail else "prvw_df")

		var progress_label = "STTS_XFORM_THUMBS_LB" if is_thumbnail else "STTS_XFORM_PRVW_LB"
		var debug_label = "DBG_THUMBS_RNL_TIME" if is_thumbnail else "DBG_PRVW_RENDER_TIME"

		var progress_window = load("res://scenes/windows/ProgressWindow.tscn").instantiate()
		progress_window.init_window(Engine.tr(progress_label) % downscale_factor)
		progress_window.show()
		Global.nodes.app_root_ref.add_child.call_deferred(progress_window)

		var processed_wallpapers = 0
		var start_time = Time.get_ticks_msec()
		for wp in missing_wps:
			if progress_window.cancel_progress:
				progress_window.queue_free()
				return

			var rendered_img = ImgProcessing.render_img(wps_dir.path_join(wp), downscale_factor, is_thumbnail)
			processed_wallpapers += 1

			if is_thumbnail and AppData.settings.get_value("dirs", "enable_prvw_processing") and render_prvw_imgs:
				if not DirAccess.dir_exists_absolute("user://prvw_dir"):
					DirAccess.make_dir_absolute("user://prvw_dir")
					Debug.log_msg(Types.DT.WARN, Engine.tr("DBG_MISSING_PRVW_DIR"))

				ImgProcessing.render_img(wps_dir.path_join(wp), AppData.settings.get_value("img_proc", "prvw_df"), false)

			if is_thumbnail:
				GC.load_into_grid_container(wp, rendered_img)
				AppData.wp_count += 1
				GC.update_wp_count()

			progress_window.update_progress(processed_wallpapers, len(missing_wps), wp)
			await scene_tree_ref.process_frame

		progress_window.queue_free()

		var time_taken = Time.get_ticks_msec() - start_time
		if len(missing_wps) > 0:
			Debug.log_msg(Types.DT.INFO, Engine.tr(debug_label) % [len(missing_wps), time_taken, time_taken / 1000.0])

	static func render_img(img_path: String, downscale_factor: float, is_thumbnail := true, filename := "") -> Image:
		var img = Image.load_from_file(ProjectSettings.globalize_path(img_path))
		var img_size = img.get_size()
		img.resize(img_size.x * downscale_factor / 100, img_size.y * downscale_factor / 100)

		save_img(img, filename if filename != "" else img_path.get_file(), "user://thumbs_dir" if is_thumbnail else "user://prvw_dir")
		return img

	static func save_img(img: Image, filename: String, output_path: String) -> void:
		# NOTE: Refactor this fucntion to save the image depending on its **format**
		match filename.get_extension():
			"jpeg", "jpg":
				img.save_jpg(output_path.path_join(filename), 0.9)
			"png":
				img.save_png(output_path.path_join(filename))

class GC:
	static func load_into_grid_container(filename: String, img: Image) -> void:
		var img_texture := ImageTexture.create_from_image(img)

		var wallpaper_thumbnail = load("res://scenes/custom_components/WallpaperThumbnail.tscn").instantiate()
		wallpaper_thumbnail.get_node("WallpaperTR").texture = img_texture
		wallpaper_thumbnail.custom_minimum_size = AppData.thumbnail_base_size * AppData.settings.get_value("misc", "thumbs_init_scale")
		
		wallpaper_thumbnail.filename = filename
		wallpaper_thumbnail.get_node("FrameP").wallpaper_clicked.connect(GC._on_wallpaper_selection)

		Global.nodes.grid_container_ref.add_child(wallpaper_thumbnail)

	static func empty_grid_container() -> void:
		for thumb in Global.nodes.grid_container_ref.get_children():
			Global.nodes.grid_container_ref.remove_child(thumb)

	static func _on_wallpaper_selection(thumbnail_ref: Panel) -> void:
		if AppData.currently_selected_thumbnail != null:
			AppData.currently_selected_thumbnail.normalize_thumbnail()
			AppData.currently_selected_thumbnail.thumbnail_clicked = false

		thumbnail_ref.press_thumbnail()
		AppData.currently_selected_thumbnail = thumbnail_ref

		Preview.load_wp_into_preview(thumbnail_ref.filename)

	static func update_wp_count() -> void:
		Global.nodes.wallpaper_count_label_ref.text = Engine.tr("WP_COUNT_LB") + " " + str(AppData.wp_count)

class Preview:
	static func load_wp_into_preview(filename: String) -> void:
		var prvw_processing_enabled = AppData.settings.get_value("dirs", "enable_prvw_processing")
		var wps_dir = AppData.settings.get_value("dirs", "wps_dir")
		var wps_base_dir = "user://prvw_dir" if prvw_processing_enabled else wps_dir

		if not FileAccess.file_exists(wps_dir.path_join(filename)) and wps_base_dir == wps_dir:
			Debug.log_msg(Types.DT.ERROR, Engine.tr("DBG_MISSING_WP") % [filename, AppData.settings.get_value("dirs", "wps_dir")])
			Global.nodes.grid_container_ref.remove_child(AppData.currently_selected_thumbnail)
			AppData.currently_selected_thumbnail = null
			AppData.wp_count -= 1
			GC.update_wp_count()
			Global.nodes.preview_label_ref.text = "..."
			Global.nodes.preview_rect_ref.texture = ImageTexture.new()
			return

		if wps_base_dir == "user://prvw_dir" and not FileAccess.file_exists("user://prvw_dir".path_join(filename)):
			if FileAccess.file_exists(wps_dir.path_join(filename)):
				wps_base_dir = wps_dir
				if not AppData.denied_missing_prvw_imgs_render:
					var missing_prvw_imgs = Dir.get_missing_wps(false)

					var render_missing_prvw_imgs_window = load("res://scenes/windows/ConfirmationWindow.tscn").instantiate()
					var confirmation_msg = Engine.tr("RENDER_MISSING_PRVW_IMGS_LB") % len(missing_prvw_imgs) if len(missing_prvw_imgs) > 1 else Engine.tr("RENDER_MISSING_PRVW_IMG_LB")
					render_missing_prvw_imgs_window.init_window(Engine.tr("RENDER_MISSING_PRVW_IMGS_TTL"), confirmation_msg, func (caller_window):
						caller_window.queue_free()
						ImgProcessing.process_new_wps(missing_prvw_imgs, false)
						var debug_msg = Engine.tr("DBG_MISSING_PRVW_IMGS") % len(missing_prvw_imgs) if len(missing_prvw_imgs) > 1 else Engine.tr("DBG_MISSING_PRVW_IMG")
						Debug.log_msg(Types.DT.WARN, debug_msg)
					, func (caller_window):
						caller_window.queue_free()
						AppData.denied_missing_prvw_imgs_render = true
					)
					render_missing_prvw_imgs_window.window_input.connect(func (input):
						if input is InputEventKey:
							if input.keycode == KEY_ESCAPE and input.is_pressed():
								AppData.denied_missing_prvw_imgs_render = true
					)
					Global.nodes.app_root_ref.add_child(render_missing_prvw_imgs_window)

		Global.nodes.preview_label_ref.text = "%s (res: %d%%)" % [filename, AppData.settings.get_value("img_proc", "prvw_df") if prvw_processing_enabled and wps_base_dir == "user://prvw_dir" else 100]

		var full_res_wp = Image.load_from_file(ProjectSettings.globalize_path(wps_base_dir).path_join(filename))
		Global.nodes.preview_rect_ref.texture = ImageTexture.create_from_image(full_res_wp)

class Dir:
	static func iterate_dir(dir_path: String, callback: Callable) -> void:
		var dir = DirAccess.open(dir_path)
		dir.list_dir_begin()

		var filename = dir.get_next()

		while filename != "":
			await callback.call(filename)
			filename = dir.get_next()

		dir.list_dir_end()

	static func get_valid_img_files(dir_path: String) -> PackedStringArray:
		var valid_img_files: PackedStringArray
		var dir = DirAccess.open(dir_path)
		dir.list_dir_begin()

		var filename = dir.get_next()

		while filename != "":
			if dir.dir_exists(filename):
				filename = dir.get_next()
				continue

			if Format.img_format(dir_path.path_join(filename)) == "":
				filename = dir.get_next()
				continue

			valid_img_files.append(filename)
			filename = dir.get_next()

		dir.list_dir_end()
		return valid_img_files

	static func get_missing_wps(compare_to_thumbnails := true) -> PackedStringArray:
		var compare_dir = "user://thumbs_dir" if compare_to_thumbnails else "user://prvw_dir"
		var valid_wps = Dir.get_valid_img_files(AppData.settings.get_value("dirs", "wps_dir"))
		var missing_wps: PackedStringArray

		for wp in valid_wps:
			if FileAccess.file_exists(compare_dir.path_join(wp)):
				continue

			missing_wps.append(wp)

		return missing_wps

class Import:
	static func load_to_import_window(files_selected: PackedStringArray, node_ref: Node) -> void:
		var context = "MAIN" if node_ref.get_window().name == "root" else "WINDOW"
		var wallpaper_loader_window = load("res://scenes/windows/WallpaperLoader.tscn").instantiate() if context == "MAIN" else node_ref.get_window()
		wallpaper_loader_window.add_wps(files_selected)

		if context == "MAIN":
			wallpaper_loader_window.show()
			Global.nodes.app_root_ref.add_child(wallpaper_loader_window)

class Themes:
	static func change_acc_color(acc_color: Color) -> void:
		var hue = acc_color.h

		var theme_map = AccentMap.theme_map
		var data_type_map = AccentMap.data_type_map

		for type in theme_map:
			for property in theme_map[type]:
				var set_border_color = false

				var saturation = theme_map[type][property][0]
				var value = theme_map[type][property][1]
				var color = Color.from_hsv(hue, saturation / 100.0, value / 100.0)

				if property.substr(0, 3) == "bd_":
					property = property.trim_prefix("bd_")
					set_border_color = true

				var data_type = data_type_map[property]

				match data_type:
					Theme.DATA_TYPE_STYLEBOX:
						var stylebox = AppData.current_theme.get_stylebox(property, type) as StyleBoxFlat
						stylebox["border_color" if set_border_color else "bg_color"] = color
					Theme.DATA_TYPE_COLOR:
						AppData.current_theme.set_color(property, type, color)

		AppData.settings.set_value("misc", "acc_color", acc_color)

class Debug:
	static func log_msg(raw_type: Types.DT, msg: String, on_error_close: Callable = Callable.create(null, "_c_placeholder")) -> void:
		var type = ""

		match raw_type:
			Types.DT.INFO: type = "info"
			Types.DT.WARN: type = "warn"
			Types.DT.ERROR: type = "error"

		var debug_window = Global.nodes.app_root_ref.get_node("DebugWindowWND")
		var debug_entry = load("res://scenes/custom_components/DebugEntry.tscn").instantiate()

		var has_been_cached = len(AppData.cached_debug_res[type]) > 1
		var color_panel_stylebox = AppData.cached_debug_res[type][Types.STYLEBOX] if has_been_cached else StyleBoxFlat.new()

		var debug_icon = AppData.cached_debug_res[type][Types.ICON] if has_been_cached else load(AppData.debug_res_map[type][1])

		if not has_been_cached:
			color_panel_stylebox.bg_color = AppData.debug_res_map[type][Types.COLOR]
			AppData.cached_debug_res[type].append_array([color_panel_stylebox, debug_icon])

		debug_entry.get_node("ColorIndicatorP").add_theme_stylebox_override("panel", color_panel_stylebox)
		debug_entry.get_node("LogTypeIconTR").texture = debug_icon
		debug_entry.get_node("LogMsgRTL").text = "[b][color=%s][%s][/color][/b] " % [AppData.cached_debug_res[type][Types.COLOR], type.to_upper()] + msg

		debug_window.get_node("%DebugEntryContainerVBC").add_child(debug_entry)

		if raw_type == Types.DT.ERROR:
			var error_window: Window = Global.nodes.app_root_ref.get_node("ErrorWindowWND")
			error_window.show()
			error_window.get_node("%ErrorMsgRTL").text = "[b][color=%s][%s][/color][/b] " % [AppData.cached_debug_res["error"][Types.COLOR], "ERROR"] + msg

			if on_error_close.get_method() != "_c_placeholder":
				error_window.get_node("%CloseBTN").button_down.connect(on_error_close)
				error_window.close_requested.connect(on_error_close)

		var bbcode_tags_regex = RegEx.new()
		# NOTE: Remove all BBCode tags, image tags and hint info
		bbcode_tags_regex.compile("\\[.*?\\]|res:\\/(\\/\\w+)+.\\w+|\\.\\\n.*")
		var plain_log = Str.trim_extra_spaces(bbcode_tags_regex.sub(msg, "", true))

		AppData.logs += "\n#> " + plain_log + "." # NOTE: Missing dot after the RegEx search
		AppData.new_logs += 1
		Global.nodes.new_logs_ind_label_ref.show()
		Global.nodes.new_logs_ind_label_ref.text = str(AppData.new_logs)

class Str:
	static func flatten_array(accumulator: String, next_output: String, sep := "\n") -> String:
		return accumulator + sep + next_output

	static func trim_extra_spaces(input: String) -> String:
		var word_list = input.split(" ")
		var output = ""

		for word in word_list:
			if word == "":
				continue

			output += " " + word

		return output

class Stts:
	static func detect_imparity(caller_node: Node, value: Variant, stts_section: String, stts_name: String) -> void:
		caller_node.get_parent().get_node("ResetSettingBTN").call("show" if value != DefaultSettings.map[stts_section][stts_name] else "hide")

class Format:
	static func img_format(path: String) -> String:
		var file_handle = FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.READ)
		var signature = file_handle.get_buffer(3)

		for entry in AppData.file_signature_map:
			if AppData.file_signature_map[entry] == signature:
				return entry

		file_handle.close()
		return ""
