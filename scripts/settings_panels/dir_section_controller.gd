extends VBoxContainer

var file_dialog_target: String

@onready var search_wps_dir_btn: Button = %SearchWpsDirBTN
@onready var search_thumbnails_dir_btn: Button = %SearchThumbsDirBTN
@onready var search_prvw_dir_btn: Button = %SearchPrvwDirBTN

signal prvw_toggled(value: bool)

func is_a_valid_dir(path: String, le_ref: LineEdit) -> bool:
	if DirAccess.open(path) == null:
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_INVALID_DIR_PATH") % [path])
		le_ref.text = ""
		return false
	return true

func _ready() -> void:
	%WpsDirLE.text = AppData.settings.get_value("dirs", "wps_dir")
	%ThumbsDirLE.text = AppData.settings.get_value("dirs", "thumbs_dir")
	%PrvwDirLE.text = AppData.settings.get_value("dirs", "prvw_dir")

	for dir_name in ["wps_dir", "thumbs_dir", "prvw_dir"]:
		if AppData.settings.get_value("dirs", dir_name) == "":
			if not DirAccess.dir_exists_absolute("user://" + dir_name):
				DirAccess.make_dir_absolute("user://" + dir_name)

			var default_path = OS.get_user_data_dir().path_join(dir_name)
			get_node("%%%sLE" % dir_name.to_pascal_case()).text = default_path
			AppData.settings.set_value("dirs", dir_name, default_path)

	$EnablePrvwProcessingCB.toggled.connect(func (toggled_on):
		$PrvwDirVBC.call("show" if toggled_on else "hide")
		AppData.settings.set_value("dirs", "enable_prvw_processing", toggled_on)
		prvw_toggled.emit(AppData.settings.get_value("dirs", "enable_prvw_processing"))
	)

	search_wps_dir_btn.button_down.connect(show_file_dialog.bind(search_wps_dir_btn))
	search_thumbnails_dir_btn.button_down.connect(show_file_dialog.bind(search_thumbnails_dir_btn))
	search_prvw_dir_btn.button_down.connect(show_file_dialog.bind(search_prvw_dir_btn))

	%WpsDirLE.text_submitted.connect(func (path):
		var valid_dir = is_a_valid_dir(path, %WpsDirLE)
		AppData.settings.set_value("dirs", "wps_dir", path if valid_dir else "")
	)

	%ThumbsDirLE.text_submitted.connect(func (path):
		var valid_dir = is_a_valid_dir(path, %ThumbsDirLE)
		AppData.settings.set_value("dirs", "thumbs_dir", path if valid_dir else "")
	)

	%PrvwDirLE.text_submitted.connect(func (path):
		var valid_dir = is_a_valid_dir(path, %PrvwDirLE)
		AppData.settings.set_value("dirs", "prvw_dir", path if valid_dir else "")
	)

	$SearchDirFD.dir_selected.connect(load_dir_path)

func show_file_dialog(caller_button: Button) -> void:
	file_dialog_target = caller_button.name.trim_prefix("Search").trim_suffix("BTN")
	$SearchDirFD.show()

func load_dir_path(selected_dir: String) -> void:
	if dir_already_selected(selected_dir):
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_ALREADY_SELECTED_DIR"))
		return

	var path_line_edit: LineEdit = get_node("%" + file_dialog_target + "LE")
	AppData.settings.set_value("dirs", file_dialog_target.to_snake_case(), selected_dir)
	path_line_edit.text = selected_dir

func dir_already_selected(selected_dir: String) -> bool:
	for dir in [AppData.settings.get_value("dirs", "wps_dir"),
				AppData.settings.get_value("dirs", "thumbs_dir"),
				AppData.settings.get_value("dirs", "prvw_dir")]:
		if selected_dir == dir:
			return true
	return false
