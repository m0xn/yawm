extends "base_setting_entry.gd"

func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	Global.nodes.app_root_ref.get_node("%DNDTooltipHBC")["show" if new_value else "hide"].call()

func _ready() -> void:
	super()
	Global.nodes.app_root_ref.get_node("%DNDTooltipHBC")["show" if editable_node[editable_field] else "hide"].call()
