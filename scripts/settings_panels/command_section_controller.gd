extends VBoxContainer

func _ready() -> void:
	%SetAsWpScriptBTN.button_down.connect(func ():
		$SetAsWpScriptFD.show()
		$SetAsWpScriptFD.file_selected.connect(func (path):
			%SetAsWpScriptLE.text = path
			AppData.settings.set_value("cmds", "set_wp_cmd", path)
		)
	)

	%OpenInImgVwrBTN.button_down.connect(func ():
		$SetAsWpScriptFD.show()
		$SetAsWpScriptFD.file_selected.connect(func (path):
			%OpenInImgVwrLE.text = path
			AppData.settings.set_value("cmds", "open_img_vwr_cmd", path)
		)
	)

	%SetAsWpScriptLE.text_changed.connect(func (path): AppData.settings.set_value("cmds", "set_wp_cmd", path))
	%OpenInImgVwrLE.text_changed.connect(func (path): AppData.settings.set_value("cmds", "open_img_vwr_cmd", path))

	%SetAsWpScriptLE.text = AppData.settings.get_value("cmds", "set_wp_cmd")
	%OpenInImgVwrLE.text = AppData.settings.get_value("cmds", "open_img_vwr_cmd")
