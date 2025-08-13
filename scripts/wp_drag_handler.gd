extends Node

func _ready() -> void:
	get_window().files_dropped.connect(load_dropped_files_into_viewport)

func load_dropped_files_into_viewport(dropped_files: PackedStringArray) -> void:
	var import_window_ref = get_parent().get_node_or_null("WPImportWND")

	if import_window_ref == null:
		Utils.Import.load_to_import_window(dropped_files, self)
		return
	
	import_window_ref.add_wps(dropped_files)
