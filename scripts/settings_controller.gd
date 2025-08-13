extends Node

var default_settings: Dictionary = {
	"os": {
		"base_os": "",
		"desktop_environment": ""
	},
	"dirs": {
		"wps_dir": "",
		"thumbs_dir": "",
		"enable_prvw_processing": false,
		"prvw_dir": ""
	},
	"cmds": {
		"set_wp_cmd": "",
		"open_img_vwr_cmd": ""
	},
	"img_proc": {
		"thumbs_df": 0.25,
		"prvw_df": 1
	},
	"misc": {
		"locale_idx": 0,
		"acc_color": Color.from_hsv(263 / 359.0, 1.0, 1.0),
		"scale_step": 0.1,
		"thumbs_init_scale": 1.0,
		"enable_dnd_tooltip": true
	},
}

func _ready() -> void:
	# NOTE: Load default config at startup, then modify it based on the 'settings.cfg' file or the startup config
	AppData.settings = ConfigFile.new()
	load_default_settings()

	if FileAccess.file_exists("user://settings.cfg"):
		AppData.settings.load("user://settings.cfg")
	else:
		get_parent().get_node("WelcomeWindowWND").show()

	apply_ui_settings()

func load_default_settings() -> void:
	for section in default_settings:
		for param in default_settings[section]:
			AppData.settings.set_value(section, param, default_settings[section][param])

# NOTE: Apply settings regarding UI elements at the start of the program 
func apply_ui_settings() -> void:
	var scale_slider = Global.nodes.app_root_ref.get_node("%ScaleHSL")

	Global.nodes.app_root_ref.get_node("%ScaleFactorLB").text = str(AppData.settings.get_value("misc", "thumbs_init_scale")) + "x"
	scale_slider.value = AppData.settings.get_value("misc", "thumbs_init_scale")

	scale_slider.step = AppData.settings.get_value("misc", "scale_step")

	Global.nodes.app_root_ref.get_node("%DNDTooltipHBC").call("show" if AppData.settings.get_value("misc", "enable_dnd_tooltip") else "hide")
