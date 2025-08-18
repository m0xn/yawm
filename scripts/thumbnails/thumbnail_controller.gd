extends Panel

@onready var thumbnail_root = get_parent()

signal wallpaper_clicked(thumbnail_ref: Panel)

func _on_mouse_entered() -> void:
	if not thumbnail_root.thumbnail_clicked:
		thumbnail_root.hover_thumbnail()
	thumbnail_root.mouse_inside_thumbnail = true

func _on_mouse_exited() -> void:
	if not thumbnail_root.thumbnail_clicked:
		thumbnail_root.normalize_thumbnail()
	thumbnail_root.mouse_inside_thumbnail = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and thumbnail_root.mouse_inside_thumbnail:
			thumbnail_root.thumbnail_clicked = true
			wallpaper_clicked.emit(thumbnail_root)
