extends "base_setting_entry.gd"

@onready var img_proc_section = get_window().get_node("%PanelsContainerVBC/ImgProcSectionVBC")

func _on_value_change(new_value: Variant) -> void:
	super(new_value)
	if get_window().name == "SettingsWindow":
		get_parent().get_node("PrvwDirHBC")["show" if new_value else "hide"].call()
		img_proc_section.get_node("PrvwProcHeaderLB")["show" if new_value else "hide"].call()
		img_proc_section.get_node("PrvwDfHBC")["show" if new_value else "hide"].call()

func _ready() -> void:
	super()
	editable_node[on_change_event].emit(editable_node[editable_field])
