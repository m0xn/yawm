extends Panel

var current_thumbnail_size: Vector2
@export var tolerance: float = 0.05

func _ready() -> void:
	get_window().size_changed.connect(adjust_grid_columns)
	current_thumbnail_size = AppData.thumbnail_base_size

	resize_thumbnails(AppData.settings.get_value("misc", "thumbs_init_scale"))
	Global.nodes.scale_slider_ref.value_changed.connect(resize_thumbnails)

func adjust_grid_columns() -> void:
	if len(Global.nodes.grid_container_ref.get_children()) == 0:
		return

	var container_width = get_parent().size.x
	var columns_ratio = container_width / current_thumbnail_size.x
	var new_gc_columns = floor(columns_ratio) if abs(columns_ratio - floor(columns_ratio)) < tolerance else ceil(columns_ratio)

	if new_gc_columns == Global.nodes.grid_container_ref.columns:
		return

	Global.nodes.grid_container_ref.columns = new_gc_columns

func resize_thumbnails(value: float) -> void:
	if not AppData.settings.get_value("misc", "scale_step"):
		return

	Global.nodes.scale_slider_ref.step = AppData.settings.get_value("misc", "scale_step")
	Global.nodes.scale_factor_label_ref.text = str(value) + "x"

	for thumbnail in Global.nodes.grid_container_ref.get_children():
		thumbnail.custom_minimum_size = AppData.thumbnail_base_size * value
		current_thumbnail_size = thumbnail.custom_minimum_size
		call_deferred("adjust_grid_columns")
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_PLUS and event.is_pressed():
			Global.nodes.scale_slider_ref.value += Global.nodes.scale_slider_ref.step
		if event.keycode == KEY_MINUS and event.is_pressed():
			Global.nodes.scale_slider_ref.value -= Global.nodes.scale_slider_ref.step

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_command_or_control_pressed():
			Global.nodes.scale_slider_ref.value += Global.nodes.scale_slider_ref.step
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_command_or_control_pressed():
			Global.nodes.scale_slider_ref.value -= Global.nodes.scale_slider_ref.step
