extends TextureButton

func _ready() -> void:
	button_down.connect(func (): OS.shell_open("https://www.github.com/m0xn/yawm"))
