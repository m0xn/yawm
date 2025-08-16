extends HBoxContainer

var class_to_event_map: Dictionary[String, PackedStringArray] = {
	"LineEdit": ["text_submitted", "text"],
	"SpinBox": ["value_changed", "value"],
	"OptionButton": ["item_selected", "selected"],
	"ColorPickerButton": ["color_changed", "color"],
	"CheckBox": ["toggled", "button_pressed"]
}

@export var stts_section: String
@export var stts_name: String
@export var editable_node: Node

@onready var on_change_event := class_to_event_map[editable_node.get_class()][0]
@onready var editable_field := class_to_event_map[editable_node.get_class()][1]

@onready var reset_to_def_btn = get_node("ResetSettingBTN")
@onready var default_value = DefaultSettings.map[stts_section][stts_name]

func _on_value_change(new_value: Variant) -> void:
	AppData.settings.set_value(stts_section, stts_name, new_value)
	reset_to_def_btn["show" if check_imparity(new_value) else "hide"].call()

func neq(a: Variant, b: Variant) -> bool:
	return a != b

func check_imparity(new_value: Variant) -> bool:
	return neq(new_value, default_value)

func reset_setting() -> void:
	editable_node[editable_field] = default_value
	editable_node[on_change_event].emit(default_value)

	AppData.settings.set_value(stts_section, stts_name, default_value)
	reset_to_def_btn.hide()

func _ready() -> void:
	reset_to_def_btn.button_down.connect(reset_setting)

	editable_node[editable_field] = AppData.settings.get_value(stts_section, stts_name)
	reset_to_def_btn["show" if check_imparity(editable_node[editable_field]) else "hide"].call()
	editable_node[on_change_event].connect(_on_value_change)
