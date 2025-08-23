extends Node

var locale_idx = ["es", "en"]

func _ready() -> void:
	if not FileAccess.file_exists("user://settings.cfg"):
		AppData.settings.set_value("misc", "locale_idx", locale_idx.find(OS.get_locale_language()))

	TranslationServer.set_locale(locale_idx[AppData.settings.get_value("misc", "locale_idx")])
	Utils.GC.update_wp_count()
