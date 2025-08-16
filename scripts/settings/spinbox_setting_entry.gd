extends "base_setting_entry.gd"

func neq(a: Variant, b: Variant) -> bool:
	return a - b > 10e-5
