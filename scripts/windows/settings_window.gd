extends "base_hide_window.gd"

@export var setting_sections: Array[PackedScene]
@onready var panels_container: VBoxContainer = %PanelsContainerVBC

func _ready() -> void:
	super()

	panels_container.get_node("DirSectionVBC").prvw_toggled.connect(func (toggle_value): 
		panels_container.get_node("ImgProcSectionVBC").get_node("PrvwProcHeaderLB").call("show" if toggle_value else "hide")
		panels_container.get_node("ImgProcSectionVBC").get_node("PrvwDFOptsHBC").call("show" if toggle_value else "hide")
	)

	close_requested.connect(func (): AppData.settings.save("user://settings.cfg"))
