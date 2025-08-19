extends "base_setting_entry.gd"

@onready var line_edit_ref = editable_node if editable_node.get_class() == "LineEdit" else editable_node.get_line_edit()

func _on_value_change(new_value: Variant) -> void:
	super(new_value)

func _ready() -> void:
	super()

	var unmodified_border_stylebox = gen_mod_stylebox(true)
	line_edit_ref.text_changed.connect(func (_new_val):
		line_edit_ref.add_theme_stylebox_override("focus", unmodified_border_stylebox))
	editable_node.focus_exited.connect(func ():
		editable_node[editable_field] = AppData.settings.get_value(stts_section, stts_name)
		editable_node.remove_theme_stylebox_override("focus")
	)

func gen_mod_stylebox(unmodified: bool) -> StyleBoxFlat:
	var border_stylebox = StyleBoxFlat.new()

	border_stylebox.border_color = Color8(255, 0, 0) if unmodified else Color8(0, 255, 0)
	border_stylebox.draw_center = false
	border_stylebox.corner_detail = 1

	border_stylebox.border_width_top = 2
	border_stylebox.border_width_right = 2
	border_stylebox.border_width_bottom = 2
	border_stylebox.border_width_left = 2

	border_stylebox.corner_radius_top_right = 5
	border_stylebox.corner_radius_bottom_left = 5

	return border_stylebox

func show_input_validity(valid_input: bool) -> void:
	print(valid_input)
	var border_stylebox = gen_mod_stylebox(not valid_input) # NOTE: In this case, since a valid input would result in a red border, we need to invert this parameter
	line_edit_ref.add_theme_stylebox_override("focus", border_stylebox)

	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.start()
	timer.timeout.connect(func ():
		line_edit_ref.remove_theme_stylebox_override("focus")
		timer.queue_free()
	)
