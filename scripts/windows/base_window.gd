extends Window

func _ready() -> void:
	close_requested.connect(func (): queue_free())

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		print("A key was pressed")
		if event.keycode == KEY_ESCAPE and event.is_pressed():
			self.queue_free()
