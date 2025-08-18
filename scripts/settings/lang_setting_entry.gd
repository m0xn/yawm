extends "base_setting_entry.gd"

func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	TranslationServer.set_locale(editable_node.get_item_text(new_value))

func _ready() -> void:
	super()
	TranslationServer.set_locale(editable_node.get_item_text(AppData.settings.get_value(stts_section, stts_name)))
