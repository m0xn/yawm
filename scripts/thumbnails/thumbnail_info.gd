extends Panel

var filename: String

var mouse_inside_thumbnail: bool
var thumbnail_clicked: bool
var thumbnail_frame_stylebox: StyleBoxFlat

func hover_thumbnail() -> void:
	var hovered_stylebox: StyleBoxFlat = thumbnail_frame_stylebox.duplicate()
	hovered_stylebox.border_color = Color.from_hsv(AppData.settings.get_value("misc", "acc_color").h , 0.27, 0.47)
	get_node("FrameP").add_theme_stylebox_override("panel", hovered_stylebox)

func normalize_thumbnail() -> void:
	get_node("FrameP").add_theme_stylebox_override("panel", thumbnail_frame_stylebox)

# Function intended to be used from an outside controller handling thumbnail selection
func press_thumbnail() -> void:
	var pressed_stylebox: StyleBoxFlat = thumbnail_frame_stylebox.duplicate()
	pressed_stylebox.border_color = Color.from_hsv(AppData.settings.get_value("misc", "acc_color").h, 0.25, 1.0)
	get_node("FrameP").add_theme_stylebox_override("panel", pressed_stylebox)

func _ready() -> void:
	thumbnail_frame_stylebox = get_node("FrameP").get_theme_stylebox("panel")
