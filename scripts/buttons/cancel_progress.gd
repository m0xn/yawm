extends Button

func _ready() -> void:
	button_down.connect(func (): get_window().cancel_progress = true)
