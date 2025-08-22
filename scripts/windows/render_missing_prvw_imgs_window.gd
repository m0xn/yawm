extends "confirmation_window_controller.gd"

func default_deny_callback():
	super()
	AppData.denied_missing_prvw_imgs_render = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.is_pressed():
			default_deny_callback()
