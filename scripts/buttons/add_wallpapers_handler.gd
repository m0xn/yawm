extends Button

enum Context {MAIN, WINDOW}
@onready var context: Context = Context.MAIN if get_window().name == "root" else Context.WINDOW
@onready var parent_node = Global.nodes.app_root_ref if context == Context.MAIN else get_window()

func _ready() -> void:
	var file_dialog_window = parent_node.get_node("AddWallpaperFD")
	
	button_down.connect(func (): file_dialog_window.show())
	file_dialog_window.files_selected.connect(Utils.Import.load_to_import_window.bind(self))
