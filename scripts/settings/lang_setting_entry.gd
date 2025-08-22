extends "base_setting_entry.gd"

# NOTE: WP count gets translated manually, so it needs to be updated whenever changing the language
func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	TranslationServer.set_locale(editable_node.get_item_text(new_value))
	Utils.GC.update_wp_count()

func _ready() -> void:
	super()
	TranslationServer.set_locale(editable_node.get_item_text(AppData.settings.get_value(stts_section, stts_name)))
	Utils.GC.update_wp_count()
