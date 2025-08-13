extends TextureButton

func _ready() -> void:
	button_down.connect(func (): Global.nodes.app_root_ref.get_node("DebugWindowWND").show())
