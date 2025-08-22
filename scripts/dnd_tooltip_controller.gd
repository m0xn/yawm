extends HBoxContainer

func _ready() -> void:
	(show if AppData.settings.get_value("misc", "enable_dnd_tooltip") else hide).call()
