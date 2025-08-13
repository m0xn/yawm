extends VBoxContainer

@onready var current_theme = load(ProjectSettings.get_setting("gui/theme/custom"))

func _ready() -> void:
	%LangOB.item_selected.connect(change_locale)
	%AccColorCB.color_changed.connect(change_acc_color)
	%ScaleStepSB.value_changed.connect(func (step): AppData.settings.set_value("misc", "scale_step", step))
	%EnableDNDHintCB.toggled.connect(func (toggled):
		Global.nodes.app_root_ref.get_node("%DNDTooltipHBC").call("show" if toggled else "hide")
		AppData.settings.set_value("misc", "enable_dnd_tooltip", toggled)
	)
	%ThumbsInitialScaleSB.value_changed.connect(func (val): AppData.settings.set_value("misc", "thumbs_init_scale", val))

	%LangOB.select(AppData.settings.get_value("misc", "locale_idx"))
	%AccColorCB.color = AppData.settings.get_value("misc", "acc_color")
	%ScaleStepSB.value = AppData.settings.get_value("misc", "scale_step")
	%EnableDNDHintCB.button_pressed = AppData.settings.get_value("misc", "enable_dnd_tooltip")
	%ThumbsInitialScaleSB.value = AppData.settings.get_value("misc", "thumbs_init_scale")

func change_locale(locale_idx: int) -> void:
	var new_locale = %LangOB.get_item_text(locale_idx)
	AppData.settings.set_value("misc", "locale_idx", locale_idx)

	ProjectSettings.set_setting("internationalization/locale/test", new_locale)
	ProjectSettings.save()

func change_acc_color(acc_color: Color) -> void:
	var hue = acc_color.h

	var theme_map = AccentMap.theme_map
	var data_type_map = AccentMap.data_type_map

	for type in theme_map:
		for property in theme_map[type]:
			var set_border_color = false

			var saturation = theme_map[type][property][0]
			var value = theme_map[type][property][1]
			var color = Color.from_hsv(hue, saturation / 100.0, value / 100.0)

			if property.substr(0, 3) == "bd_":
				property = property.trim_prefix("bd_")
				set_border_color = true

			var data_type = data_type_map[property]

			match data_type:
				Theme.DATA_TYPE_STYLEBOX:
					var stylebox = current_theme.get_stylebox(property, type) as StyleBoxFlat
					stylebox["border_color" if set_border_color else "bg_color"] = color
				Theme.DATA_TYPE_COLOR:
					current_theme.set_color(property, type, color)

	AppData.settings.set_value("misc", "acc_color", acc_color)
