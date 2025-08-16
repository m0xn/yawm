extends "spinbox_setting_entry.gd"

var already_applied = false

func _on_value_change(new_value) -> void:
	super(new_value)
	if not already_applied:
		Global.nodes.app_root_ref.get_node("%ScaleFactorLB").text = str(AppData.settings.get_value("misc", "thumbs_init_scale")) + "x"
		Global.nodes.app_root_ref.get_node("%ScaleHSL").value = new_value
		already_applied = true

func _ready() -> void:
	super()
	# NOTE: Force value change event on startup to change the init scale of the thumbnails
	editable_node[on_change_event].emit(editable_node[editable_field])
