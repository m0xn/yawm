extends "base_setting_entry.gd"

func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	Utils.Themes.change_acc_color(new_value)

func neq(a: Variant, b: Variant) -> bool:
	return a.h != b.h
