extends "input_field_setting_entry.gd"

@onready var container_base_name = name.trim_suffix("HBC")
@onready var search_cmd_btn: Button = get_node("Search%sBTN" % container_base_name)

@onready var search_cmd_fd: FileDialog = get_parent().get_node("SearchCmdFD")

func check_for_duplicate(cmd: String) -> void:
	var other_cmd_entry = "open_img_vwr_cmd" if container_base_name == "SetAsWpCmd" else "set_wp_cmd"
	if cmd == AppData.settings.get_value(stts_section, other_cmd_entry):
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_DUPLICATE_CMD") % [cmd, tr("%s_BTN" % container_base_name.trim_suffix("Cmd").to_snake_case().to_upper())])
		editable_node[editable_field] = ""
		show_input_validity(false)
		return

	show_input_validity(true)

func handle_cmd_search() -> void:
	search_cmd_fd.show()
	search_cmd_fd.file_selected.connect(func (selected_file):
		check_for_duplicate(selected_file)

		editable_node[editable_field] = selected_file
		editable_node[on_change_event].emit(selected_file)
	)

func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	check_for_duplicate(new_value)

func _ready() -> void:
	super()
	search_cmd_btn.button_down.connect(handle_cmd_search)
