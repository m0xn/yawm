extends Node

class ImgProcessing:
	static func render_img(img_path: String, filename: String, downscale_factor: float, output_dir: String) -> Image:
		var img = Image.load_from_file(img_path)
		var img_size = img.get_size()
		img.resize(img_size.x * downscale_factor / 100, img_size.y * downscale_factor / 100)

		save_img(img, filename, output_dir)
		return img

	static func save_img(img: Image, filename: String, output_path: String) -> void:
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
		
		wallpaper_thumbnail.filename = filename
		wallpaper_thumbnail.get_node("FrameP").wallpaper_clicked.connect(Utils.GC._on_wallpaper_selection)

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

		Utils.Preview.load_wp_into_preview(thumbnail_ref.filename)

	static func update_wp_count() -> void:
		Global.nodes.wallpaper_count_label_ref.text = Engine.tr("WP_COUNT_LB") + " " + str(AppData.wp_count)

class Preview:
	static func load_wp_into_preview(filename: String) -> void:
		Global.nodes.preview_label_ref.text = filename

		var wps_base_dir = AppData.settings.get_value("dirs", "prvw_dir") if AppData.settings.get_value("dirs", "enable_prvw_processing") else AppData.settings.get_value("dirs", "wps_dir")
		if not FileAccess.file_exists(wps_base_dir.path_join(filename)):
			Utils.Debug.log_msg(Types.DT.ERROR, Engine.tr("DBG_INVALID_PRVW_DIR_PATH" if AppData.settings.get_value("dirs", "enable_prvw_processing") else "DBG_INVALID_WPS_DIR_PATH") % [wps_base_dir.path_join(filename), Engine.tr("STTS_DIR_HEADER_LB"), Engine.tr("STTS_WPS_DIR_LB")])

		var full_res_wp = Image.load_from_file(ProjectSettings.globalize_path(wps_base_dir).path_join(filename))
		Global.nodes.preview_rect_ref.texture = ImageTexture.create_from_image(full_res_wp)

class Dir:
	static func iterate_dir(dir_name: String, callback: Callable) -> void:
		var dir = DirAccess.open(dir_name)
		dir.list_dir_begin()

		var filename = dir.get_next()

		while filename != "":
			await callback.call(filename)
			filename = dir.get_next()

		dir.list_dir_end()

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
		var plain_log = Utils.Str.trim_extra_spaces(bbcode_tags_regex.sub(msg, "", true))

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
