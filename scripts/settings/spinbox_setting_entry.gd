extends "input_field_setting_entry.gd"

func neq(a: Variant, b: Variant) -> bool:
	return abs(a - b) > 10e-5

func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	show_input_validity(true)
