extends Node

func _ready() -> void:
	AppData.current_theme = load(ProjectSettings.get_setting("gui/theme/custom"))
	Utils.Themes.change_acc_color(AppData.settings.get_value("misc", "acc_color"))
