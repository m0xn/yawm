extends VBoxContainer

func _ready() -> void:
	%GDLicenseBTN.button_down.connect(func (): $GDLicenseWND.show())
	%FontLicenseBTN.button_down.connect(func (): $FontLicenseWND.show())
	%AppLicenseBTN.button_down.connect(func (): $AppLicenseWND.show())
