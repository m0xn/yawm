extends Node

func _ready() -> void:
	# NOTE: Load default config at startup, then modify it based on the 'settings.cfg' file or the startup config
	AppData.settings = ConfigFile.new()
	load_default_settings()

	if FileAccess.file_exists("user://settings.cfg"):
		AppData.settings.load("user://settings.cfg")
	else:
		get_parent().get_node("WelcomeWindowWND").show()

func load_default_settings() -> void:
	for section in DefaultSettings.map:
		for param in DefaultSettings.map[section]:
			AppData.settings.set_value(section, param, DefaultSettings.map[section][param])
