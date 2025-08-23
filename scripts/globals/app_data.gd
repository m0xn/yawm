extends Node

var wp_count := 0
var wps_to_load: int

var currently_selected_thumbnail: Panel
var thumbnail_base_size := Vector2(150.0, 150.0)

var current_theme: Theme

var settings: ConfigFile

var random_wp: String

var debug_res_map: Dictionary[String, Array] = {
	"error": ["#c01c28", "res://graphics/app_icons/debug_error_icon.svg"],
	"info": ["#3584e4", "res://graphics/app_icons/debug_info_icon.svg"],
	"warn": ["#f5c211", "res://graphics/app_icons/debug_warn_icon.svg"]
}

# NOTE: This variable holds references to the panel stylebox and debug icons (loaded at runtime)
var cached_debug_res: Dictionary[String, Array] = {
	"error": ["#c01c28"],
	"info": ["#3584e4"],
	"warn": ["#f5c211"]
}

var logs: String = "# LOGS #"

var new_logs: int = 0

var file_signature_map: Dictionary[String, PackedByteArray] = {
	"jpg": PackedByteArray([0xff, 0xd8, 0xff]),
	"png": PackedByteArray([0x89, 0x50, 0x4e])
}

var denied_missing_prvw_imgs_render: bool
