extends "base_setting_entry.gd"

@onready var img_proc_section = get_window().get_node("%PanelsContainerVBC/ImgProcSectionVBC")

func _on_value_change(new_value: Variant) -> void:
	super(new_value)

	if get_window().name == "SettingsWindow":
		img_proc_section.get_node("PrvwProcHeaderLB")["show" if new_value else "hide"].call()
		img_proc_section.get_node("PrvwDfHBC")["show" if new_value else "hide"].call()

	# NOTE: "and new_value" just verifies that the field is set to *true* in order to execute the code
	if not new_value:
		return

	if len(Utils.Dir.get_valid_img_files("user://prvw_dir")) == 0:
		await Utils.ImgProcessing.process_new_wps(Utils.Dir.get_valid_img_files(AppData.settings.get_value("dirs", "wps_dir")), false)
		var random_wp_img = Image.load_from_file("user://prvw_dir".path_join(AppData.random_wp))
		img_proc_section.get_node("%PrvwTextureTR").texture = ImageTexture.create_from_image(random_wp_img)

	if not DirAccess.dir_exists_absolute("user://prvw_dir"):
		DirAccess.make_dir_absolute("user://prvw_dir")
		Utils.Debug.log_msg(Types.DT.WARN, tr("DBG_MISSING_PRVW_DIR"))

		var restore_missing_prvw_imgs_window = load("res://scenes/windows/ConfirmationWindow.tscn").instantiate()
		get_parent().add_child.call_deferred(restore_missing_prvw_imgs_window)
		restore_missing_prvw_imgs_window.init_window(tr("RESTORE_MISSING_PRVW_IMGS_TTL"), tr("RESTORE_MISSING_PRVW_IMGS_LB") % AppData.settings.get_value("dirs", "wps_dir"), func (caller_window):
			caller_window.queue_free()
			Utils.ImgProcessing.process_new_wps(Utils.Dir.get_valid_img_files(AppData.settings.get_value("dirs", "wps_dir")), false)
		)

func _ready() -> void:
	super()
	editable_node[on_change_event].emit(editable_node[editable_field])
