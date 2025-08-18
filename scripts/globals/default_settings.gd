extends Node

var map: Dictionary = {
	"dirs": {
		"wps_dir": "user://wps_dir",
		"thumbs_dir": "user://thumbs_dir",
		"enable_prvw_processing": false,
		"prvw_dir": "user://prvw_dir"
	},
	"cmds": {
		"set_wp_cmd": "",
		"open_img_vwr_cmd": ""
	},
	"img_proc": {
		"thumbs_df": 25,
		"prvw_df": 100
	},
	"misc": {
		"locale_idx": 0,
		"acc_color": Color.from_hsv(263 / 359.0, 1.0, 1.0),
		"scale_step": 0.01,
		"thumbs_init_scale": 1.0,
		"enable_dnd_tooltip": true
	},
}
