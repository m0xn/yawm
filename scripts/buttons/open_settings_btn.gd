extends TextureButton

func _ready() -> void:
	button_down.connect(func (): get_parent().get_node("%SettingsWindow").show())
