extends Window

func _ready() -> void:
	close_requested.connect(func (): hide())

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.is_pressed():
			hide()
