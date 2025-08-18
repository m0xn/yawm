extends Window

func init_window(title_wnd: String, confirmation_msg: String, accept_callback: Callable) -> void:
	title = title_wnd
	get_node("%ConfirmationMsgRTL").text = confirmation_msg

	get_node("%YesBTN").button_down.connect(accept_callback.bind(self))
	get_node("%NoBTN").button_down.connect(func (): self.queue_free())
