extends Panel

var filename: String

var _mouse_inside_thumbnail: bool
var mouse_inside_thumbnail: bool:
	get: return _mouse_inside_thumbnail
	set(_value): 
		push_warning("[WARNING]: You can't modify private field `_mouse_inside_thumbnail`")

var _thumbnail_clicked: bool
var thumbnail_clicked: bool:
	get: return _thumbnail_clicked
	set(_value):
		push_warning("[WARNING]: You can't modify private field `thumbnail_clicked`")

var _thumbnail_frame_stylebox: StyleBoxFlat
var thumbnail_frame_stylebox: StyleBoxFlat:
	get: return _thumbnail_frame_stylebox
	set(_value):
		push_warning("[WARNING]: You can't modify private field `thumbnail_frame_stylebox`")

signal wallpaper_clicked(thumbnail_ref: Panel)

func hover_thumbnail() -> void:
	var hovered_stylebox: StyleBoxFlat = _thumbnail_frame_stylebox.duplicate()
	hovered_stylebox.border_color = Color.from_hsv(AppData.settings.get_value("misc", "acc_color").h , 0.27, 0.47)
	get_node("FrameP").add_theme_stylebox_override("panel", hovered_stylebox)

func normalize_thumbnail() -> void:
	get_node("FrameP").add_theme_stylebox_override("panel", _thumbnail_frame_stylebox)

# Function intended to be used from an outside controller handling thumbnail selection
func press_thumbnail() -> void:
	var pressed_stylebox: StyleBoxFlat = _thumbnail_frame_stylebox.duplicate()
	pressed_stylebox.border_color = Color.from_hsv(AppData.settings.get_value("misc", "acc_color").h, 0.25, 1.0)
	get_node("FrameP").add_theme_stylebox_override("panel", pressed_stylebox)

func _ready() -> void:
	_thumbnail_frame_stylebox = get_node("FrameP").get_theme_stylebox("panel")
