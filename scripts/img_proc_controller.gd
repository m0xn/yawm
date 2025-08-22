extends VBoxContainer

func _ready() -> void:
	var valid_wps = Utils.Dir.get_valid_img_files(AppData.settings.get_value("dirs", "wps_dir"))

	if valid_wps.is_empty():
		%ThumbTextureTR.texture = load("res://graphics/template_images/thumbnail_template.png")
		%PrvwTextureTR.texture = load("res://graphics/template_images/preview_template.png")
	else:
		var random_idx = randi() % len(valid_wps)
		AppData.random_wp = valid_wps[random_idx]

		var thumb_img = Image.load_from_file("user://thumbs_dir".path_join(valid_wps[random_idx]))
		var prvw_img = Image.load_from_file("user://prvw_dir".path_join(valid_wps[random_idx]))

		%ThumbTextureTR.texture = ImageTexture.create_from_image(thumb_img)
		%PrvwTextureTR.texture = ImageTexture.create_from_image(prvw_img)
