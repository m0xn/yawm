extends "base_setting_entry.gd"

func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	ProjectSettings.set("internationalization/locale/test", editable_node.get_item_text(new_value))
	ProjectSettings.save()
