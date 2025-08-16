extends "base_hide_window.gd"

@export var setting_sections: Array[PackedScene]
# @onready var prvw_proc_header_ref = %PanelsContainerVBC.get_node("ImgProcSectionVBC").get_node("PrvwProcHeaderLB")
# @onready var prvw_df_hbc_ref = %PanelsContainerVBC.get_node("ImgProcSectionVBC").get_node("PrvwDfHBC")

func _ready() -> void:
	super()
	close_requested.connect(func ():
		AppData.settings.save("user://settings.cfg")
	)
