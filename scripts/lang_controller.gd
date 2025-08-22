extends Node

var locale_idx = ["es", "en"]

func _ready() -> void:
	TranslationServer.set_locale(locale_idx[AppData.settings.get_value("misc", "locale_idx")])
	Utils.GC.update_wp_count()
