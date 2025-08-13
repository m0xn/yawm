extends Node

var data_type_map: Dictionary[StringName, Theme.DataType] = {
	"hover": Theme.DATA_TYPE_STYLEBOX,
	"hover_pressed": Theme.DATA_TYPE_STYLEBOX,
	"focus": Theme.DATA_TYPE_STYLEBOX,
	"pressed": Theme.DATA_TYPE_STYLEBOX,
	"fill": Theme.DATA_TYPE_STYLEBOX,
	"grabber": Theme.DATA_TYPE_STYLEBOX,
	"grabber_area": Theme.DATA_TYPE_STYLEBOX,
	"grabber_highlight": Theme.DATA_TYPE_STYLEBOX,
	"grabber_area_highlight": Theme.DATA_TYPE_STYLEBOX,
	"grabber_pressed": Theme.DATA_TYPE_STYLEBOX,
	"font_hover_color": Theme.DATA_TYPE_COLOR,
	"font_hover_pressed_color": Theme.DATA_TYPE_COLOR,
	"font_pressed_color": Theme.DATA_TYPE_COLOR,
}

var theme_map: Dictionary[StringName, Dictionary] = {
	"Button": {
		"hover": [27, 47],
		"bd_focus": [25, 100],
		"pressed": [25, 42]
	},
	"CheckButton": {
		"hover": [27, 47],
		"hover_pressed": [27, 47],
	},
	"CheckBox": {
		"hover": [27, 47]
	},
	"ColorPickerButton": {
		"bd_hover": [24, 68],
		"bd_pressed": [24, 68]
	},
	"HScrollBar": {
		"grabber": [37, 66],
		"grabber_highlight": [37, 80],
		"grabber_pressed": [37, 66],
	},
	"HSlider": {
		"grabber_area": [37, 66],
		"grabber_area_highlight": [37, 80]
	},
	"LineEdit": {
		"bd_focus": [24, 68]
	},
	"MenuButton": {
		"font_hover_color": [19, 95],
		"font_hover_pressed_color": [19, 95],
		"font_pressed_color": [34, 100]
	},
	"OptionButton": {
		"hover": [27, 47],
		"font_pressed_color": [34, 100]
	},
	"ProgressBar": {
		"fill": [42, 73]
	},
	"TextEdit": {
		"bd_focus": [24, 68]
	},
	"VScrollBar": {
		"grabber": [37, 66],
		"grabber_highlight": [37, 80],
		"grabber_pressed": [37, 66],
	},
	"VSlider": {
		"grabber_area": [37, 66],
		"grabber_area_highlight": [37, 80]
	},
}
