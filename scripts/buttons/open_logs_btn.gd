extends TextureButton

func _ready() -> void:
	button_down.connect(func ():
		Global.nodes.app_root_ref.get_node("DebugWindowWND").show()
		AppData.new_logs = 0
		Global.nodes.new_logs_ind_label_ref.hide()
	)
