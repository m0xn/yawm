extends "input_field_setting_entry.gd"

@onready var container_base_name = name.trim_suffix("HBC")
@onready var search_dir_btn: Button = get_node("Search%sBTN" % container_base_name)
@onready var open_in_fe_btn: Button = get_node("OpenInFE%sBTN" % container_base_name)

@onready var search_dir_fd: FileDialog = get_parent().get_node("SearchDirFD")

var duplicates_search_list: PackedStringArray

func check_for_duplicates(dir_path: String) -> void:
	for entry in duplicates_search_list:
		if dir_path == AppData.settings.get_value(stts_section, entry):
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_DUPLICATE_PATH") % [dir_path, tr("STTS_%s_LB" % container_base_name.to_snake_case().to_upper())])
			editable_node[editable_field] = DefaultSettings.map[stts_section][stts_name]
			AppData.settings.set_value(stts_section, stts_name, editable_node[editable_field])

func handle_search_dir() -> void:
	search_dir_fd.show()
	search_dir_fd.dir_selected.connect(func (selected_dir):
		check_for_duplicates(selected_dir)
		
		editable_node[editable_field] = selected_dir
		editable_node[on_change_event].emit(selected_dir)
	)

func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	check_for_duplicates(new_value)

	if not DirAccess.dir_exists_absolute(new_value) or new_value == "":
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_INVALID_DIR_PATH") % tr("STTS_%s_LB" % container_base_name.to_snake_case().to_upper()))
		editable_node[editable_field] = DefaultSettings.map[stts_section][stts_name]
		AppData.settings.set_value(stts_section, stts_name, editable_node[editable_field])
		show_input_validity(false)
		return

	show_input_validity(true)

func _ready() -> void:
	super()
	for stts_entry in ["wps_dir", "thumbs_dir", "prvw_dir"]:
		if stts_entry == container_base_name.to_snake_case():
			continue
		duplicates_search_list.append(stts_entry)


	search_dir_btn.button_down.connect(handle_search_dir)
	open_in_fe_btn.button_down.connect(func (): OS.shell_show_in_file_manager(ProjectSettings.globalize_path(editable_node[editable_field])))
