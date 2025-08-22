extends "base_window.gd"

func default_deny_callback():
	self.queue_free()

func init_window(wnd_title: String, confirmation_msg: String, accept_callback: Callable, deny_callback: Callable = Callable.create(null, "_c_placeholder")) -> void:
	title = wnd_title
	get_node("%ConfirmationMsgRTL").text = confirmation_msg

	get_node("%YesBTN").button_down.connect(accept_callback.bind(self))
	get_node("%NoBTN").button_down.connect(default_deny_callback if deny_callback.get_method() == "_c_placeholder" else deny_callback.bind(self))
