extends Button

func _ready() -> void:
	button_down.connect(func (): get_window().hide())
