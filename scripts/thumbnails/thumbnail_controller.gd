extends Panel

@onready var thumbnail_root = get_parent()
@onready var default_frame_border = thumbnail_root.get_node("FrameP").get_theme_stylebox("panel")

signal wallpaper_clicked(thumbnail_ref: Panel)

func _on_mouse_entered() -> void:
	if not (thumbnail_root.thumbnail_clicked or thumbnail_root.thumbnail_to_delete):
		thumbnail_root.hover_thumbnail()
	thumbnail_root.mouse_inside_thumbnail = true

func _on_mouse_exited() -> void:
	if not (thumbnail_root.thumbnail_clicked or thumbnail_root.thumbnail_to_delete):
		thumbnail_root.normalize_thumbnail()
	thumbnail_root.mouse_inside_thumbnail = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and thumbnail_root.mouse_inside_thumbnail:
		if event.button_index == MOUSE_BUTTON_LEFT and AppData.currently_selected_thumbnail != thumbnail_root:
			thumbnail_root.thumbnail_clicked = true
			wallpaper_clicked.emit(thumbnail_root)

		if event.button_index == MOUSE_BUTTON_RIGHT:
			thumbnail_root.thumbnail_to_delete = true

			var delete_thumbnail_window = load("res://scenes/windows/ConfirmationWindow.tscn").instantiate()
			delete_thumbnail_window.show()
			add_child(delete_thumbnail_window)

			var red_border = StyleBoxFlat.new()
			red_border.border_color = Color8(255, 0, 0)
			red_border.draw_center = false
			red_border.corner_detail = 1

			red_border.border_width_top = 3
			red_border.border_width_left = 3
			red_border.border_width_right = 3
			red_border.border_width_bottom = 3

			red_border.corner_radius_top_right = 10
			red_border.corner_radius_bottom_left = 10

			thumbnail_root.get_node("FrameP").add_theme_stylebox_override("panel", red_border)

			delete_thumbnail_window.init_window("DELETE_WP_WND_TTL", tr("DELETE_WP_WND_LB") % thumbnail_root.filename, handle_wp_deletion, func (caller_window):
				thumbnail_root.thumbnail_to_delete = false
				thumbnail_root.get_node("FrameP").add_theme_stylebox_override("panel", default_frame_border)
				caller_window.queue_free()
			)

func handle_wp_deletion(caller_window: Window) -> void:
	caller_window.queue_free()
	if AppData.settings.get_value("dirs", "wps_dir") == "":
		Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_DIR") % [tr("STTS_WPS_DIR_LB"), tr("STTS_WPS_DIR_LB")])
		return

	DirAccess.remove_absolute(AppData.settings.get_value("dirs", "thumbs_dir").path_join(thumbnail_root.filename))
	DirAccess.remove_absolute(AppData.settings.get_value("dirs", "wps_dir").path_join(thumbnail_root.filename))
	Global.nodes.grid_container_ref.remove_child(AppData.currently_selected_thumbnail)

	if AppData.settings.get_value("dirs", "enable_prvw_processing"):
		if AppData.settings.get_value("dirs", "prvw_dir") == "":
			Utils.Debug.log_msg(Types.DT.ERROR, tr("DBG_MISSING_DIR") % [tr("STTS_PRVW_DIR_LB"), tr("STTS_PRVW_DIR_LB")])
			return

	DirAccess.remove_absolute(AppData.settings.get_value("dirs", "prvw_dir").path_join(thumbnail_root.filename))

	if thumbnail_root.thumbnail_clicked:
		AppData.currently_selected_thumbnail = null
		Global.nodes.preview_rect_ref.texture = ImageTexture.new()
