extends "input_field_setting_entry.gd"

@onready var search_dir_fd = get_parent().get_node("SearchDirFD")

func handle_search_dir() -> void:
	search_dir_fd.show()
	if search_dir_fd.dir_selected.has_connections():
		return

	search_dir_fd.dir_selected.connect(func (selected_dir):
		editable_node[editable_field] = selected_dir
		editable_node[on_change_event].emit(selected_dir)
	)

func _on_value_change(new_value: Variant) -> void:
	if not DirAccess.dir_exists_absolute(new_value) or new_value == "":
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_INVALID_WPS_DIR_PATH"))
		editable_node[editable_field] = AppData.settings.get_value(stts_section, stts_name)
		AppData.settings.set_value(stts_section, stts_name, editable_node[editable_field])
		show_input_validity(false)
		return

	show_input_validity(true)

	super(new_value)

	var valid_wps = Utils.Dir.get_valid_img_files(new_value)
	if len(valid_wps) > 0:
		Utils.GC.empty_grid_container()
		AppData.wp_count = 0
		Utils.ImgProcessing.process_new_wps(valid_wps, true, true)

func _ready() -> void:
	super()

	%SearchWpsDirBTN.button_down.connect(handle_search_dir)
	%OpenInFEWpsDirBTN.button_down.connect(func (): OS.shell_show_in_file_manager(ProjectSettings.globalize_path(editable_node[editable_field])))
