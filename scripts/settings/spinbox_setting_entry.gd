extends "input_field_setting_entry.gd"

func neq(a: Variant, b: Variant) -> bool:
	return abs(a - b) > 10e-5

func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	show_input_validity(true)

# NOTE: SpinBoxes always emit their new value on change, regardless of the source (manually or via code)
#		This avoids duplicate calls
func reset_setting() -> void:
	editable_node[editable_field] = default_value

	AppData.settings.set_value(stts_section, stts_name, default_value)
	reset_to_def_btn.hide()
