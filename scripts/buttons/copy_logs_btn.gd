extends Button

func _ready() -> void:
	button_down.connect(func ():
		DisplayServer.clipboard_set(AppData.logs)
		var gh_issue_window: Window = load("res://scenes/windows/ConfirmationWindow.tscn").instantiate()
		gh_issue_window.show()
		add_child(gh_issue_window)

		gh_issue_window.init_window("GH_ISSUE_WINDOW_TTL", "GH_ISSUE_WINDOW_CONF_MSG_LB", func (caller_window_ref): 
			OS.shell_open("https://github.com/m0xn/yawm/issues")
			caller_window_ref.queue_free()
		)
	)
